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
	Mnemonic:	rmr_sender2.c
	Abstract:	Very simple test sender that polls and deals with responses
				in between sends (from a single process).

	Date:		18 February 2018
	Author:		E. Scott Daniels

	Modified:	18 Mar 2019 - changes to support demo
*/

#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/epoll.h>
#include <time.h>
#include <rmr/rmr.h>
#include "dummy_a1_rmr_wrapper.h"


void usage( char* argv0 ) {
	fprintf( stderr, "usage: %s [mtype-max]\n", argv0 );
	fprintf( stderr, "Sender will send messages with rotating msg types from 0 through mtype-max (if supplied)\n" );
	fprintf( stderr, "if not supplied, only mtype 0 is sent\n" );
	fprintf( stderr, "The default listen port for return messages is 43086; this can be changed by setting DUMMY_SENDER_RMR_RCV_PORT  in the environment.\n" );
	fprintf( stderr, "The sender will send forever unless DEMO_SENDER_MAX is set in the environment which causes termination after max messages.\n" );
	fprintf( stderr, "The sender will poll for received messages after each send. The amount of time waited is controlled with DEMO_SENDER_PTO (ms) in the env. Use 0 for non-blocking poll.\n" );
}

void send_delay_message(struct rmr_context *rmr_c, char* delay_file_path){
	FILE *fp;
	char delay[255];

	fp = fopen(delay_file_path, "r");
	fscanf(fp, "%s", delay);
	int mtype = 100;
	rmr_pure_send(rmr_c, mtype, delay);
	fprintf( stderr, "Sent delay insert message of type:%d (delay insert) to pendulum control xApp, with content:%s\n",mtype,delay);
	fclose(fp);
}

void send_and_rec_metrics(struct rmr_context *rmr_c, char* metrics_file_path){
	int mtype=102;
	char* message="--give metrics--";
	rmr_pure_send(rmr_c, mtype, message );
	printf("Sent message of type:%d to E2 terminator with content:%s\n",mtype,message);
	int got_metrics=0;
	while (got_metrics == 0){
		if(rmr_poll_for_message(rmr_c) == 1) {
			if(rmr_c->rbuf->mtype == 103)
				got_metrics=1;
		}
	}
	printf("Recieved metrics from E2 terminator with content:%s\n",rmr_c->rbuf->payload);

	FILE *fp;
	fp = fopen(metrics_file_path, "w+");
	fprintf(fp,"%s",rmr_c->rbuf->payload);
	fclose(fp);

}
int main( int argc, char** argv ) {
	struct rmr_context *rmr_c; //obtain our enhanced rmr_context
	char*	lport = "43086";				// default listen port
	char* delay_file_path ="";
	char* metrics_file_path ="";
	if( (eparm = getenv( "DUMMY_SENDER_RMR_RCV_PORT" )) != NULL ) {
		lport = strdup( eparm );
	}

	if( (eparm = getenv( "DELAY_FILE_PATH" )) != NULL ) {
		delay_file_path = eparm ;
	}

	if( (eparm = getenv( "METRICS_FILE_PATH" )) != NULL ) {
		metrics_file_path = eparm ;
	}

     	rmr_c =	rmr_init_wrapper(lport);

	while( ! rmr_ready( rmr_c->mrc ) ) {
		fprintf( stderr, "<TEST> waiting for RMr to indicate ready\n" );
		sleep( 1 );
	}
	fprintf( stderr, "[OK]   initialisation complete\n" );
	fprintf( stderr, "======================================\n[OK]   A1 mediator is up and running!\n==================================\n" );

    	while( 1 ) {
		sleep (2);

		send_delay_message(rmr_c, delay_file_path);

		send_and_rec_metrics(rmr_c, metrics_file_path);
		fprintf( stderr, "-------------------------------------------\n");
	}



	fprintf( stderr, "[INFO] sender is terminating\n");
	rmr_close_wrapper(rmr_c);

	return 0;
}
