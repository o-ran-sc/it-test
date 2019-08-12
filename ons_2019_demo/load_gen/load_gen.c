/*
 *
 * Copyright 2019 AT&T Intellectual Property
 * Copyright 2019 Nokia
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

// :vim ts=4 sw=4 noet:

/*
	Mnemonic:	load_gen.c
	Abstract:	Very simple load generator. Reads the message rate from a
				file (argv[1]) which is expected to be between 0 and 100000.
				Messages are sent with a fixed mtype of 104.

	Date:		24 March 2019
	Author:		E. Scott Daniels
*/

#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/epoll.h>
#include <time.h>

#include <rmr/rmr.h>

/*
	Rewinds, reads and converts the value in the file to the number of microseconds (usleep units)
	that the caller should sleep between messages. If the effective mps is 0, then we block here
	until the rate goes up. We'll check 1/sec if blocked.
*/
int		mps = 1;			// msg/sec rate from file  (sloppy, but global helps prevent time calls)
static inline int read_delay( int fd ) {
	char 	rbuf[128];		// read buffer
	int 	n;				// bytes read
	int		mus = 0;		// mu sec delay
	double	v;

	if( fd < 0 ) {
		return 0;
	}

	do {
		lseek( fd, 0, SEEK_SET );
		if( (n = read( fd, rbuf, sizeof( rbuf ) )) >0 ) {
			mps = atoi( rbuf );
			v = 1.0 / ((double) mps / 1000000.0);		// msg/microsec

			mus = (int) v;
		}

		if( mus <= 0 ) {
			//fprintf( stderr, "<LGEN> sending blocked\n" );
			sleep( 1 );
		}
	} while( mus <= 0 );

	return mus;
}

int main( int argc, char** argv ) {
	int delay_fd;		// file des of the delay file
    int rcv_fd;     // pollable fd
    void* mrc;      //msg router context
    struct epoll_event events[10];          // wait on 10 possible events
    struct epoll_event epe;                 // event definition for event to listen to
    int     ep_fd = -1;
	int nready;
	int i;
	int mtype = 104;						// we loop through several message types
	rmr_mbuf_t*		sbuf;					// send buffer
	rmr_mbuf_t*		rbuf;					// received buffer
	int	epoll_to = 1;						// epoll timout -- 0 don't call
	char wbuf[2048];
	char* lport = "12036";					// default listen port
	int	delay = 2000000;					// microsecond delay between messages; default to very slow
	int	next_read = 0;						// counter for next read of delay
	char*	eparm;
	char*	rate_file = "rate_file";


	if( (eparm = getenv( "DEMO_LOAD_GEN_PORT" )) != NULL ) {
		lport = strdup( eparm );
	}

    mrc = rmr_init( lport, 1400, RMRFL_NONE );
    rcv_fd = rmr_get_rcvfd( mrc );
	if( rcv_fd < 0 ) {
		fprintf( stderr, "[FAIL] unable to set up polling fd\n" );
		exit( 1 );
	}

	if( argc > 1 ) {
		rate_file = argv[1];
	}

	if( (delay_fd = open( rate_file, O_RDONLY )) < 0 ) {
		fprintf( stderr, "abort: unable to open delay file: %s: %d\n", rate_file, errno );
		exit( 1 );
	}

	if( (ep_fd = epoll_create1( 0 )) < 0 ) {
		fprintf( stderr, "[FAIL] unable to create epoll fd: %d\n", errno );
		exit( 1 );
	}
    epe.events = EPOLLIN;
    epe.data.fd = rcv_fd;

    if( epoll_ctl( ep_fd, EPOLL_CTL_ADD, rcv_fd, &epe ) != 0 )  {
		fprintf( stderr, "[FAIL] epoll_ctl status not 0 : %s\n", strerror( errno ) );
		exit( 1 );
	}

	sbuf = rmr_alloc_msg( mrc, 256 );
	rbuf = NULL;

	while( ! rmr_ready( mrc ) ) {
		fprintf( stderr, "waiting for RMr to show ready\n" );
		sleep( 1 );
	}
	fprintf( stderr, "<LGEN> rmr shows ready\n" );


	mps = 1;
    while( 1 ) {
		if( next_read <= 0 ) {
			delay = read_delay( delay_fd );
			next_read = mps;
			//fprintf( stderr, "<LGEN> next_read=%d delay=%d\n", next_read, delay );
		}

		snprintf( sbuf->payload, 200, "msg from load generator %d\n", next_read );

		sbuf->mtype = mtype;
		sbuf->len =  strlen( sbuf->payload );
		sbuf->state = 0;
		sbuf = rmr_send_msg( mrc, sbuf );			// we send, we dont care about success or failure, but on failure, have a break
		if( sbuf->state != RMR_OK ) {
			sleep( 1 );
			next_read = 0;							// mostly for testing
		}

		nready = epoll_wait( ep_fd, events, 10, 0 );		// we shouldn't have anything, but prevent queue full issues
		for( i = 0; i < nready && i < 10; i++ ) {           // loop through to find what is ready
			if( events[i].data.fd == rcv_fd ) {             // RMr has something
				errno = 0;
				rbuf = rmr_rcv_msg( mrc, rbuf );
			}
		}

		next_read--;
		usleep( delay );
    }
}
