/*****************************************************************************
#                                                                            *
# Copyright 2020 AT&T Intellectual Property                                  *
# Copyright (c) 2020 Samsung Electronics Co., Ltd. All Rights Reserved.      *
# Copyright (c) 2020 HCL Technologies Limited.                               *
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
#include <fstream>
#include <vector>
#include <sys/time.h>
#include "e2sim.hpp"
#include "e2sim_defs.h"
#include "e2sim_sctp.hpp"
#include "e2ap_message_handler.hpp"
#include "encode_e2apv1.hpp"
using namespace std;

//int client_fd = 0;

std::unordered_map<long, OCTET_STRING_t*> E2Sim::getRegistered_ran_functions() {
  return ran_functions_registered;
}

void E2Sim::register_subscription_callback(long func_id, SubscriptionCallback cb) {
  fprintf(stderr,"%%%%about to register callback for subscription for func_id %d\n", func_id);
  subscription_callbacks[func_id] = cb;
  
}

SubscriptionCallback E2Sim::get_subscription_callback(long func_id) {
  fprintf(stderr, "%%%%we are getting the subscription callback for func id %d\n", func_id);
  SubscriptionCallback cb;

  try {
    cb = subscription_callbacks.at(func_id);
  } catch(const std::out_of_range& e) {
    throw std::out_of_range("Function ID is not registered");
  }
  return cb;

}

void E2Sim::register_e2sm(long func_id, OCTET_STRING_t *ostr) {

  //Error conditions:
  //If we already have an entry for func_id
  
  printf("%%%%about to register e2sm func desc for %d\n", func_id);

  ran_functions_registered[func_id] = ostr;

}


void E2Sim::encode_and_send_sctp_data(E2AP_PDU_t* pdu,int client_fd)
{
  uint8_t       *buf;
  sctp_buffer_t data;

  int procedureCodeValue = e2ap_asn1c_get_procedureCode(pdu);
  fprintf(stderr, "RIC Procedurecode in encode_and_send_sctp_data : %d \n",procedureCodeValue);
  fprintf(stderr, "client_fd value in encode_and_send_sctp_data : %d \n",client_fd);
  data.len = e2ap_asn1c_encode_pdu(pdu, &buf);
  memcpy(data.buffer, buf, min(data.len, MAX_SCTP_BUFFER));
  struct timeval ts_sent;
  sctp_send_data(client_fd, data);
  gettimeofday(&ts_sent, NULL);

  if(procedureCodeValue == ProcedureCode_id_RICindication){

     Time[client_fd]=ts_sent;
      fprintf(stderr, "pushed in Time map for client_fd=%d\n",client_fd);


    }
/*
  if(procedureCodeValue == ProcedureCode_id_RICindication){

       fprintf(stderr, "RIC Indication Procedurecode : %d \n",procedureCodeValue);
       struct timeval ts_recv;
       struct timeval ts_sent;
       std::fstream io_file;

       sctp_send_data(client_fd, data);
       gettimeofday(&ts_sent, NULL);

       sctp_buffer_t recv_buf;
  
       if(sctp_receive_data(client_fd, recv_buf) > 0){
   
            gettimeofday(&ts_recv, NULL);

            E2AP_PDU_t* pdu = (E2AP_PDU_t*)calloc(1, sizeof(E2AP_PDU));
            ASN_STRUCT_RESET(asn_DEF_E2AP_PDU, pdu);
            asn_transfer_syntax syntax;
            syntax = ATS_ALIGNED_BASIC_PER;
            auto rval = asn_decode(nullptr, syntax, &asn_DEF_E2AP_PDU, (void **) &pdu,recv_buf.buffer, recv_buf.len);

            int control_procedureCode = e2ap_asn1c_get_procedureCode(pdu);
            fprintf(stderr, "Received Msg procedurecode is: %d\nfull buffer is : %s\n",control_procedureCode, recv_buf.buffer);

            //Received control procedure code is 111 because bouncer xapp not doing any pdu contraction/encode for control msg and its simply sending the msg for round trip calculation
            if(control_procedureCode == 111 ){

                 io_file.open("e2sim_timestamp.txt", std::ios::in|std::ios::out|std::ios::app);
                 io_file << "Sent RIC Indication at time: " << (ts_sent.tv_sec * 1000000) + (ts_sent.tv_usec) << std::endl;
                 fprintf(stderr, "Sent RIC Indication at time: %ld\n" ,((ts_sent.tv_sec * 1000000) + (ts_sent.tv_usec)));

                 io_file << "Received RIC Control Msg at time: " << (ts_recv.tv_sec * 1000000) + (ts_recv.tv_usec) << std::endl;
                 fprintf(stderr,"Received RIC Control Msg at time: %ld\n" ,((ts_recv.tv_sec * 1000000) + (ts_recv.tv_usec)));
                 io_file << "Time diff in Microseconds:" << ((ts_recv.tv_sec - ts_sent.tv_sec)*1000000 + (ts_recv.tv_usec - ts_sent.tv_usec)) << std::endl;

                 fprintf(stderr, "Time diff in Microseconds: %ld\n",(((ts_recv.tv_sec - ts_sent.tv_sec)*1000000 + (ts_recv.tv_usec - ts_sent.tv_usec))));

		 io_file.close();
             }


         }
    }
   
  else{
           sctp_send_data(client_fd, data);
  }
  */
}


void E2Sim::wait_for_sctp_data()
{
  int client_fd=3;
  sctp_buffer_t recv_buf;
  if(sctp_receive_data(client_fd, recv_buf) > 0)
  {
    LOG_I("[SCTP] Received new data of size %d", recv_buf.len);
    e2ap_handle_sctp_data(client_fd, recv_buf, false, this);
  }
}



void E2Sim::generate_e2apv1_subscription_response_success(E2AP_PDU *e2ap_pdu, long reqActionIdsAccepted[], long reqActionIdsRejected[], int accept_size, int reject_size, long reqRequestorId, long reqInstanceId) {
  encoding::generate_e2apv1_subscription_response_success(e2ap_pdu, reqActionIdsAccepted, reqActionIdsRejected, accept_size, reject_size, reqRequestorId, reqInstanceId);
}

void E2Sim::generate_e2apv1_subscription_delete_response_success(E2AP_PDU *e2ap_pdu, long reqRequestorId, long reqInstanceId) {
  encoding::generate_e2apv1_subscription_delete_response_success(e2ap_pdu, reqRequestorId, reqInstanceId);
}

void E2Sim::generate_e2apv1_indication_request_parameterized(E2AP_PDU *e2ap_pdu, long requestorId, long instanceId, long ranFunctionId, long actionId, long seqNum, uint8_t *ind_header_buf, int header_length, uint8_t *ind_message_buf, int message_length) {
  encoding::generate_e2apv1_indication_request_parameterized(e2ap_pdu, requestorId, instanceId, ranFunctionId, actionId, seqNum, ind_header_buf, header_length, ind_message_buf, message_length);

}

int E2Sim::run_loop(int argc, char* argv[], int plmnId){

  printf("Start E2 Agent (E2 Simulator)\n");

  ifstream simfile;
  string line;

  simfile.open("simulation.txt", ios::in);

  if (simfile.is_open()) {

    while (getline(simfile, line)) {
      cout << line << "\n";
    }

    simfile.close();

  }

  bool xmlenc = false;

  printf("ip address is:%s\n",argv[1]);

  options_t ops = read_input_options(argc, argv);

  printf("After reading input options\n");
int client_fd = 0;
  //E2 Agent will automatically restart upon sctp disconnection
 // int server_fd = sctp_start_server(ops.server_ip, ops.server_port);  
 printf("before starting client, client_fd value is %d\n", client_fd);
  client_fd = sctp_start_client(ops.server_ip, ops.server_port);
  E2AP_PDU_t* pdu_setup = (E2AP_PDU_t*)calloc(1,sizeof(E2AP_PDU));


  printf("After starting client\n");
  printf("client_fd value is %d\n", client_fd);
  
  std::vector<encoding::ran_func_info> all_funcs;

  //Loop through RAN function definitions that are registered

  for (std::pair<long, OCTET_STRING_t*> elem : ran_functions_registered) {
    printf("looping through ran func\n");
    encoding::ran_func_info next_func;

    next_func.ranFunctionId = elem.first;
    next_func.ranFunctionDesc = elem.second;
    next_func.ranFunctionRev = (long)2;
    all_funcs.push_back(next_func);
  }
    
  printf("about to call setup request encode\n");

  //int plmnid = plmnId; 
  fprintf(stderr, "plmn id is : %d\n",plmnId);

  generate_e2apv1_setup_request_parameterized(pdu_setup, all_funcs,plmnId);
 
  //generate_e2apv1_setup_request_parameterized(pdu_setup, all_funcs);

  fprintf(stderr,"After generating e2setup req\n");

  xer_fprint(stderr, &asn_DEF_E2AP_PDU, pdu_setup);

  printf("After XER Encoding\n");

  auto buffer_size = MAX_SCTP_BUFFER;
  unsigned char buffer[MAX_SCTP_BUFFER];
  
  sctp_buffer_t data;

  char *error_buf = (char*)calloc(300, sizeof(char));
  size_t errlen;

  asn_check_constraints(&asn_DEF_E2AP_PDU, pdu_setup, error_buf, &errlen);
  printf("error length %d\n", errlen);
  printf("error buf %s\n", error_buf);

  auto er = asn_encode_to_buffer(nullptr, ATS_ALIGNED_BASIC_PER, &asn_DEF_E2AP_PDU, pdu_setup, buffer, buffer_size);

  data.len = er.encoded;

  fprintf(stderr, "er encded is %d\n", er.encoded);

  memcpy(data.buffer, buffer, er.encoded);

  if(sctp_send_data(client_fd, data) > 0) {
    LOG_I("[SCTP] Sent E2-SETUP-REQUEST");
  } else {
    LOG_E("[SCTP] Unable to send E2-SETUP-REQUEST to peer");
  }

  sctp_buffer_t recv_buf;

  LOG_I("[SCTP] Waiting for SCTP data");

  while(1) //constantly looking for data on SCTP interface
  {
    if(sctp_receive_data(client_fd, recv_buf) <= 0)
    {
	    fprintf(stderr, "client_fd in while loop  is : %d\n",client_fd);
	    LOG_I("breaking while loop");
      break;
    }

    LOG_I("[SCTP] Received new data of size %d", recv_buf.len);
	fprintf(stderr, "client_fd in while loop  is : %d\n",client_fd);
    e2ap_handle_sctp_data(client_fd, recv_buf, xmlenc, this);
    if (xmlenc) xmlenc = false;
  }

  return 0;
}
