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
Mnemonic:	rmr_rcvr2.c
Abstract:	Very simple test listener built on RMr libraries. It does nothing
but return the message it recevied back to the sender.

Define these environment variables to have some control:
RMR_SEED_RT -- path to the static routing table
RMR_RTG_SVC -- host:port of the route table generator

One command line parm is accepted: stats frequency.  This is a number, n,
which causes stats to be generated after every n messages. If set to 0
each message is written when received and no stats (msg rate) is generated.

Date:		11 February 2018
Author:		E. Scott Daniels

Mods:		18 Mar 2019 -- simplified for demo base.
 */

#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <rmr/rmr.h>
#include <sys/time.h>

long current_timestamp_in_us(){
        struct timeval currentTime;
        gettimeofday(&currentTime, NULL);
        return currentTime.tv_sec * (int)1e6 + currentTime.tv_usec;
}

long delay=0; //sent from the a1 med in milliseconds
void handle_pendulum_angle_message(void* mrc,rmr_mbuf_t* msg){
	fprintf(stderr, "Sleeping for %ld microseconds", delay);
	// usleep(delay/20000.0); //sleep for <delay> us
  usleep(delay/20); //ms
  int max_rt=2;
	fprintf( stderr, "Received message from E2 termination of type:%d (pendulum control), with content:%s\n",msg->mtype,msg->payload);
	msg->len = snprintf( msg->payload, 1024, "$%d#\n",(int)delay/20000);
	msg->mtype=33;
	msg = rmr_rts_msg( mrc, msg ); 								// this is a retur to sender; preferred
	if( (msg = rmr_rts_msg( mrc, msg )) != NULL ) {
		max_rt = 2;//should be small to prevent rmr issues
		while( max_rt > 0 && msg->state != RMR_OK && errno == EAGAIN ) {		// just keep trying
			max_rt--;
			rmr_rts_msg( mrc, msg );
			//rmr_send_msg (mrc, msg);
		}
	}
}


//void handle_pendulum_angle_message(){
//	int mtype=33;
//	char* message="Reply hello back to Arduino!";
//	rmr_pure_send(rmr_c, mtype, message );
//	printf("Sent message of type:%d to E2 terminator with content:%s\n",mtype,message);
//}

void handle_delay_insertion_message(void* mrc,rmr_mbuf_t* msg){
	fprintf( stderr, "Received message from A1 mediator of type:%d (delay insert), with content:%s\n",msg->mtype,msg->payload);
	delay = atol(msg->payload);//payload is being sent in microseconds
}



int main( int argc, char** argv ) {
	void* mrc;      					// msg router context
	rmr_mbuf_t* msg = NULL;				// message received
	char*	listen_port;
	int stat_freq = 20000;				// write stats after reciving this many messages


	if( (listen_port = getenv( "PENDULUM_XAPP_RMR_RCV_PORT" )) == NULL ) {
		listen_port = "4560";
	}

	if( argc > 1 ) {
		stat_freq = atoi( argv[1] );
	}
	fprintf( stderr, "<TEST> stats will be reported every %d messages\n", stat_freq );

	mrc = rmr_init( listen_port, RMR_MAX_RCV_BYTES, RMRFL_NONE );	// start your engines!
	if( mrc == NULL ) {
		fprintf( stderr, "<TEST> ABORT:  unable to initialise RMr\n" );
		exit( 1 );
	}

	while( ! rmr_ready( mrc ) ) {
		fprintf( stderr, "<TEST> waiting for RMr to show ready\n" );
		sleep( 1 );
	}
	fprintf( stderr, "<TEST> RMr now shows ready\n" );

	fprintf( stderr, "<TEST> listening on %s\n", listen_port);

	fprintf( stderr, "======================================\n Pendulum Control xApp Running\n======================================\n");
	long received_angle_message_time =0;
	while( 1 ) {
		msg = rmr_rcv_msg( mrc, msg );						// block until one arrives
		if( msg == NULL ) {
			continue;				// shouldn't happen, but don't crash if we get nothing
		}
		if( msg->mtype < 0 || msg->state != RMR_OK ) {
			fprintf( stderr, "[WRN] bad msg:  state=%d  errno=%d\n", msg->state, errno );
			continue;			// just loop to receive another
		}

		switch (msg->mtype){
		    case 0:
			     received_angle_message_time = current_timestamp_in_us();
			     handle_pendulum_angle_message(mrc,msg);
			     fprintf(stderr, "Time taken to reply to E2 term:%ld micro seconds \n",current_timestamp_in_us()-received_angle_message_time);
	       		     break;
		    case 100:  handle_delay_insertion_message(mrc,msg);
	       		     break;
		    default: fprintf( stdout, "[WRN] bad msg: =%d\n", msg->mtype);
		}
	}
}
