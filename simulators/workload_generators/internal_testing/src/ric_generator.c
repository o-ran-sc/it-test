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
#include <unistd.h>
#include <time.h>

#define UTA_COMPAT
#include "ric_wg.h"
#include <rmr/rmr.h>

struct timespec ts_start_tx;

int read_pdu(const char* filename, unsigned char* buffer) {

  FILE* f = fopen(filename, "r");

  if(f == NULL) {
    fprintf(stderr, "abort: unable to  open PDU file: %s\n",
	    strerror(errno));
    return -1;
  }

  return fread(buffer, sizeof(unsigned char), 2048, f);
}


int main(int argc, char** argv) {
  void* mr;
  char*	proto_port = "tcp:4545";
  rmr_mbuf_t* msg;
  // data portion (payload) of the message
  msg_t* msg_data;
  // total count of msgs sent
  int count = 0;
  // cyced count used to generate type 
  int cyc_count = 0;
  // number of msgs per second
  int rate = argc < 2 ? 10 : atoi(argv[1]);
  // the number of msg types depends on the number of xAPPs
  int type_n = 2;
  // rate in mu-seconds/message
  double v = (1.0/(double)rate) * SEC2MUS;
  // delay between messages
  int delay = (int) v;
  // PDU buffer to be copied to each msg
  unsigned char pdu_li[2048];
  unsigned char pdu_rs[2048];
  char* pdufile1 = "PDU/pdu1.per";
  char* pdufile2 = "PDU/pdu2.per";
  
  struct timespec ts;
  long long elapse;
  double elapse_s;

  int pdu_li_size = read_pdu(pdufile1, pdu_li);
  int pdu_rs_size = read_pdu(pdufile2, pdu_rs);
    
  if((mr = uta_init(proto_port, 4096, UTAFL_NONE)) == NULL) {
      fprintf(stderr, "abort: unable to initialise the lib: %s\n",
	      strerror(errno));
      exit(1);
  }
  // get an initial send buffer
  msg = uta_alloc_msg(mr, sizeof(msg_t));
  if( msg == NULL ) {
    fprintf(stderr, "abort: couldn't allocate initial message\n");
    exit(1);
  }
  //record starting time
  clock_gettime(CLOCK_REALTIME, &ts_start_tx);
  while(count < MAX_TX) {
    //sleep to have an average msg/sec send rate
    usleep(delay);     
    msg->mtype = cyc_count;
    msg_data = (msg_t *) msg->payload;
    msg_data->time_counter = count;
    
    snprintf(msg->xaction, UTA_MAX_XID, "x%05d", count);

    if(msg->mtype == 0) {
      msg_data->pdu_length = pdu_li_size;  
      memcpy(msg_data->payload, pdu_li, sizeof(msg_data->payload));
    }

    if(msg->mtype == 1) {
      msg_data->pdu_length = pdu_rs_size;
      memcpy(msg_data->payload, pdu_rs, sizeof(msg_data->payload));
    }
    msg->len = sizeof(msg_t);
    // set timestamp at the absolute last point
    clock_gettime(CLOCK_REALTIME, &msg_data->ts);

    msg = uta_send_msg(mr, msg);

    count++;
    clock_gettime(CLOCK_REALTIME, &ts);
    elapse = (ts.tv_sec - ts_start_tx.tv_sec) * 1000000000
          + ts.tv_nsec - ts_start_tx.tv_nsec;
    elapse_s = (double) elapse / 1000000000;

    fprintf(stderr, "\rsent %d msgs", count);
    cyc_count = cyc_count < type_n - 1 ? cyc_count + 1 : 0;
  }

  return 0;
}
