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
	Mnemonic:	dummy_rcvr.c
	Abstract:	RMr receiver that discards everything.

				Define these environment variables to have some control:
					RMR_SEED_RT -- path to the static routing table
					RMR_RTG_SVC -- host:port of the route table generator

	Date:		24 March 2019
	Author:		E. Scott Daniels

	Mods:
*/

#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <rmr/rmr.h>

int main( int argc, char** argv ) {
    void* mrc;      					// msg router context
    rmr_mbuf_t* msg = NULL;				// message received
	int i;
	char*	listen_port;
	int		count = 0;

	if( (listen_port = getenv( "DUMMY_RCVR_PORT" )) == NULL ) {
		listen_port = "19289";
	}

    mrc = rmr_init( listen_port, RMR_MAX_RCV_BYTES, RMRFL_NONE );	// start your engines!
	if( mrc == NULL ) {
		fprintf( stderr, "<RCVR> ABORT:  unable to initialise RMr\n" );
		exit( 1 );
	}

	while( ! rmr_ready( mrc ) ) {
		fprintf( stderr, "<RCVR> waiting for RMr to show ready\n" );
		sleep( 1 );
	}
	fprintf( stderr, "<RCVR> RMr now shows ready\n" );

	fprintf( stderr, "<RCVR> listening on %s build=%s @ %s\n", listen_port, __DATE__, __TIME__  );

    while( 1 ) {
		msg = rmr_rcv_msg( mrc, msg );						// block until one arrives
		count++;
		//if( count % 1000 == 0 ) {
			fprintf( stderr, "receiver received: %d\n", count );
		//}
    }
}
