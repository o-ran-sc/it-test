/*
======================================================================
        Copyright (c) 2019 Nokia
        Copyright (c) 2018-2019 AT&T Intellectual Property.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
   implied. See the License for the specific language governing 
   permissions andlimitations under the License.
======================================================================
*/

#include <ctype.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <stdbool.h>

#define UTA_COMPAT
#include <rmr/rmr.h>
#include "ric_wg.h"

//array to save ts for each transaction
time_t ts_array[MAX_TRANS];
//array to save tns for each transaction
long int tns_array[MAX_TRANS];
//array to save latency for each transaction
double latency_array[MAX_TRANS]={0};
//array to save time passed for each transaction
double elapse_array[MAX_TRANS]={0};
//array to save typeid for each transaction
int type_array[MAX_TRANS]={0};

//they are used to track time in order to get msg rate
time_t ts_start_rcv;
long int tns_start_rcv;

int main( int argc, char** argv ) {
  
  void* mr;
  char*	proto_port = "tcp:4560";
  uta_mbuf_t* msg = NULL;
  msg_t* pm;
  struct timespec ts;
  long long delta;
  long long elapse;
  double ms_delta;
  double ms_elapse;
  double total_ms_delta = 0.0;
  double ave_latency = 0.0;
  double rcv_rate = 0.0;
  long long rcv_count = 0;
  
  if((mr = uta_init( proto_port,
		     UTA_MAX_RCV_BYTES, UTAFL_NONE )) == NULL) {
    fprintf(stderr,
	    "abort: unable to initialize the message lib: %s\n",
	    strerror(errno));
    exit(1);
  }
  
  while(rcv_count <= MAX_RCV_COUNT) {

    msg = uta_rcv_msg(mr, msg);
   
    if(msg) {
      type_array[rcv_count] = msg->mtype;
      pm = (msg_t *) msg->payload;
      clock_gettime(CLOCK_REALTIME, &ts);
      //record the time when the first msg is recieved 
      if(rcv_count == 0) {
	ts_start_rcv = ts.tv_sec;
	tns_start_rcv = ts.tv_nsec;
      }
	
      delta = (ts.tv_sec - (pm->ts).tv_sec) * 1000000000 +
	ts.tv_nsec - (pm->ts).tv_nsec;
	  
      ms_delta = (double) delta / 1000000;
      elapse = (ts.tv_sec - ts_start_rcv) * 1000000000
	+ ts.tv_nsec - tns_start_rcv;
      ms_elapse = (double) elapse / 1000000;
      elapse_array[rcv_count] = ms_elapse;
      total_ms_delta += ms_delta;
      latency_array[rcv_count] = ms_delta;
      rcv_count++;
    }
   
  }
  //when test ends dump memory into file
  total_ms_delta -= latency_array[rcv_count - 1];
  ms_elapse = elapse_array[rcv_count - 2];
  rcv_count--;
  ave_latency = total_ms_delta/rcv_count;
  rcv_rate = (rcv_count/ms_elapse)*1000.0;
  char fname[256];
  snprintf(fname, sizeof fname, "report/xAPP_counters.csv");
  FILE *fptr = fopen(fname, "w");
  fprintf(fptr, "average latency %.3fmillisec\n", ave_latency);
  for(int i = 0; i < rcv_count; i++)
    fprintf(fptr, "%d %.3fmillisec \n", i, latency_array[i]);
  return 0;
}

