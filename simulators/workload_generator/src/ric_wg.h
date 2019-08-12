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

#define SEC2MUS	1000000
#define MAX_TRANS 10000
#define MAX_RCV_COUNT 100
#define MAX_TX 1000

typedef struct msg {
  //counter for messages, first message has time_counter 0;
  long long time_counter;
  //transaction id
  long long tid;
  //timestamp for latency measure
  struct timespec ts;
  //the length of the PDU
  int pdu_length;

  unsigned char payload[2048];
} msg_t;
