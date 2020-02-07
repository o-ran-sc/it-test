/*****************************************************************************
#                                                                            *
# Copyright 2020 AT&T Intellectual Property                                  *
# Copyright 2020 Nokia                                                       *
#                                                                            *
# Licensed under the Apache License, Version 2.0 (the "License");            *
# you may not use this file except in compliance with the License.           *
# You may obtain a copy of the License at                                    *
#                                                                            *
#      http://www.apache.org/licenses/LICENSE-2.0                            *
#                                                                            *
# Unless required by applicable law or agreed to in writing, software        *
# distributed under the License is distributed on an "AS IS" BASIS,          *
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
# See the License for the specific language governing permissions and        *
# limitations under the License.                                             *
#                                                                            *
******************************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <string>
#include <iostream>
#include <vector>
#include <thread>
#include "./wg_defs.h"
#include "e2sim_sctp.hpp"
#include "e2ap_message_handler.hpp"

extern "C" {
#include "E2AP-PDU.h"
#include "e2ap_asn1c_codec.h"
#include "ProtocolIE-Field.h"
}


using namespace std;

int keep_looping;
struct timespec* start_ts = (struct timespec*)malloc(sizeof(struct timespec));
vector<struct timespec*> msg_ts = vector<struct timespec*>(NUM_SAMPLE, NULL);
vector<float> latency_v = vector<float>(NUM_SAMPLE, 0.0);

int subresponse_get_sequenceNum(E2AP_PDU_t* pdu) {
  SuccessfulOutcome_t* responseMsg = pdu->choice.successfulOutcome;
  RICrequestID_t* requestid;
  int num_IEs = responseMsg->value.choice.RICsubscriptionResponse.protocolIEs.\
      list.count;

  for (int edx = 0; edx < num_IEs; edx++) {
    RICsubscriptionResponse_IEs_t* memb_ptr =
        responseMsg->value.choice.RICsubscriptionResponse.protocolIEs.list.\
        array[edx];
    switch (memb_ptr->id) {
      case (ProtocolIE_ID_id_RICrequestID):
        requestid = &memb_ptr->value.choice.RICrequestID;
        return requestid->ricRequestSequenceNumber;
        break;
    }
  }
}

void subrequest_set_sequenceNum(E2AP_PDU_t* pdu, int seq) {
  InitiatingMessage_t* initiatingMessage = pdu->choice.initiatingMessage;
  RICrequestID_t* requestid;
  int num_IEs = initiatingMessage->value.choice.RICsubscriptionRequest.\
      protocolIEs.list.count;
  for (int edx = 0; edx < num_IEs; edx++) {
    RICsubscriptionRequest_IEs_t* memb_ptr = initiatingMessage->value.choice.\
        RICsubscriptionRequest.protocolIEs.list.array[edx];
    switch (memb_ptr->id) {
      case (ProtocolIE_ID_id_RICrequestID):
        requestid = &memb_ptr->value.choice.RICrequestID;
        requestid->ricRequestSequenceNumber = seq;
        break;
    }
  }
}

int wg_setup(int socket_fd) {
  sctp_buffer_t recv_buf;
  // stage 1: Receive ENDC_X2_Setup Request; Send ENDC_X2_Setup Response
  while (sctp_receive_data(socket_fd, recv_buf) <= 0)
    continue;
  // decode the data into E2AP-PDU
  E2AP_PDU_t* pdu = new E2AP_PDU_t();
  e2ap_asn1c_decode_pdu(pdu, recv_buf.buffer, recv_buf.len);
  int procedureCode = e2ap_asn1c_get_procedureCode(pdu);
  int index = static_cast<int>(pdu->present);
  e2ap_handle_ENDCX2SetupRequest(pdu, socket_fd);
  // stage 2: send a response wait for request,if not keep sending
  while (1) {
    E2AP_PDU_t* res_pdu = e2ap_xml_to_pdu("E2AP_RICsubscriptionResponse.xml");
    uint8_t* buf;
    sctp_buffer_t data;
    data.len = e2ap_asn1c_encode_pdu(res_pdu, &buf);
    memcpy(data.buffer, buf, data.len);
    if (sctp_send_data(socket_fd, data) > 0) {
      LOG_I("[WG] Sent RIC-SUBSCRIPTION-RESPONSE");
    } else {
      LOG_E("[WG] Unable to send RIC-SUBSCRIPTION-RESPONSE to peer");
    }
    while (sctp_receive_data(socket_fd, recv_buf) <= 0)
      continue;
    e2ap_asn1c_decode_pdu(pdu, recv_buf.buffer, recv_buf.len);
    // e2ap_asn1c_print_pdu(pdu);
    procedureCode = e2ap_asn1c_get_procedureCode(pdu);
    index = static_cast<int>(pdu->present);
    if (procedureCode == ProcedureCode_id_ricSubscription && \
        index == E2AP_PDU_PR_initiatingMessage) {
      LOG_I("[WG] Received RIC-SUBSCRIPTION-REQUEST");
      return 0;
    }
  }
  return -1;
}

int wg_generator(int client_fd, int lapse) {
  int count = 0;
  while (1) {
    E2AP_PDU_t* res_pdu = e2ap_xml_to_pdu("E2AP_RICsubscriptionResponse.xml");
    subrequest_set_sequenceNum(res_pdu, count);
    uint8_t* buf;
    sctp_buffer_t data;
    data.len = e2ap_asn1c_encode_pdu(res_pdu, &buf);
    memcpy(data.buffer, buf, data.len);
    // send response data over sctp
    usleep(lapse);
    if (sctp_send_data(client_fd, data) > 0) {
      int index = count % keep_looping;
      struct timespec* ts_p = (struct timespec*)malloc(sizeof(struct timespec));
      clock_gettime(CLOCK_REALTIME, ts_p);
      msg_ts[index] = ts_p;
    } else {
      LOG_E("[WG] Unable to send RIC-SUBSCRIPTION-RESPONSE to peer");
      return -1;
    }
    count++;
  }
  return 0;
}

int wg_receiver(int client_fd) {
  int count_msg_recved = 0;
  clock_gettime(CLOCK_REALTIME, start_ts);
  while (1) {
    sctp_buffer_t recv_buf;
    // stage 1: Receive ENDC_X2_Setup Request; Send ENDC_X2_Setup Response
    while (sctp_receive_data(client_fd, recv_buf) <= 0)
      continue;
    count_msg_recved++;
    // decode the data into E2AP-PDU
    E2AP_PDU_t* pdu = new E2AP_PDU_t();
    e2ap_asn1c_decode_pdu(pdu, recv_buf.buffer, recv_buf.len);
    int seq_n = subresponse_get_sequenceNum(pdu);
    int index = seq_n % keep_looping;
    if (index == 0) {
      char fname[256];
      snprintf(fname, sizeof fname, "cdf.csv");
      FILE *fptr = fopen(fname, "w");
      for (int i = 0; i < latency_v.size(); i++)
        fprintf(fptr, "%d %f\n", i, latency_v[i]);
      fclose(fptr);
    }
    if (msg_ts[index] != NULL && index < msg_ts.size()) {
      struct timespec* ts = (struct timespec*)malloc(sizeof(struct timespec));
      clock_gettime(CLOCK_REALTIME, ts);
      uint64_t elapse = (ts->tv_sec - msg_ts[index]->tv_sec) * 1000000000 + \
          ts->tv_nsec - msg_ts[index]->tv_nsec;
      double ms_elapse = static_cast<double>(elapse) / 1000000;
      uint64_t total_elapse = (ts->tv_sec - start_ts->tv_sec) * 1000000000 + \
          ts->tv_nsec - start_ts->tv_nsec;
      double total_ms_elapse = static_cast<double>(total_elapse / 1000000);
      latency_v[index] = ms_elapse;
      cout << '\r' << ms_elapse << "ms " << count_msg_recved * 1000.0 / \
                      total_ms_elapse << "msgs/second" << flush;
    }
  }
}

int main(int argc, char* argv[]) {
  LOG_I("Start WG");
  wg_options_t ops = wg_input_options(argc, argv);
  int server_fd = sctp_start_server(ops.server_ip, ops.server_port);
  int client_fd = sctp_accept_connection(ops.server_ip, server_fd);
  keep_looping = NUM_SAMPLE;
  LOG_I("[SCTP] Waiting for SCTP data");
  uint64_t count = 0;
  int lapse = static_cast<int>(((1.0/static_cast<double>(ops.rate)) * SEC2MUS));
  wg_setup(client_fd);
  thread generator = thread(wg_generator, client_fd, lapse);
  thread receiver = thread(wg_receiver, client_fd);
  generator.join();
  receiver.join();
  return 0;
}
