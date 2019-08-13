/*****************************************************************************
#                                                                            *
# Copyright 2019 AT&T Intellectual Property                                  *
# Copyright 2019 Nokia                                                       *
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
#include "e2ap_message_handler.hpp"

void e2ap_handle_sctp_data(int &socket_fd, sctp_buffer_t &data)
{
  //decode the data into E2AP-PDU
  e2ap_pdu_t* pdu = new_e2ap_pdu();

  e2ap_decode_pdu(pdu, data.buffer, data.len);

  e2ap_print_pdu(pdu);

  int index = e2ap_get_index(pdu);
  int procedureCode = e2ap_get_procedureCode(pdu);

  LOG_I("[E2AP] Unpacked E2AP-PDU: index = %d, procedureCode = %d\n", index, procedureCode);

  switch(procedureCode)
  {
    case 6: //X2Setup
      switch(index)
      {
        case 1: //initiatingMessage
          LOG_D("[E2AP] Received X2-SETUP-REQUEST");
          e2ap_handle_X2SetupRequest(pdu, socket_fd);
          break;

        case 2: //successfulOutcome
          LOG_D("[E2AP] Received X2-SETUP-RESPONSE");
          //e2ap_handle_X2SetupResponse(pdu, socket_fd);
          break;

        case 3:
          break;

        default:
          LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU", index);
          break;
      }
      break;

    case 36: //ENDCX2Setup
      switch(index)
      {
        case 1: //initiatingMessage
          LOG_D("[E2AP] Received ENDC-X2-SETUP-REQUEST");
          e2ap_handle_ENDCX2SetupRequest(pdu, socket_fd);
          break;

        case 2: //successfulOutcome
          LOG_D("[E2AP] Received ENDC-X2-SETUP-RESPONSE");
          //x2ap_handle_X2SetupResponse(pdu, socket_fd);
          break;

        case 3:
          LOG_D("[E2AP] Received ENDC-X2-SETUP-FAILURE");
          break;

        default:
          LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU", index);
          break;
      }
      break;

    case 201: //RIC SUBSCRIPTION
      switch(index)
      {
        case 1: //initiatingMessage
          LOG_D("[E2AP] Received RIC-SUBSCRIPTION-REQUEST");
          e2ap_handle_RICSubscriptionRequest(pdu, socket_fd);
          break;

        case 2:
          LOG_D("[E2AP] Received RIC-SUBSCRIPTION-RESPONSE");
          break;

        case 3:
          LOG_D("[E2AP] Received RIC-SUBSCRIPTION-FAILURE");
          break;

        default:
        LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU", index);
        break;
      }
      break;

    default:
      LOG_E("[E2AP] No available handler for procedureCode=%d", procedureCode);
      break;
  }
}

void e2ap_handle_X2SetupRequest(e2ap_pdu_t* pdu, int &socket_fd)
{
  /*
  Simply send back X2SetupResponse
  Todo: add more handling options (failure, duplicated request, etc.)
  */

  e2ap_pdu_t* res_pdu = new_e2ap_pdu();
  eNB_config cfg;

  e2ap_create_X2SetupResponse(res_pdu, cfg);
  LOG_D("[E2AP] Created X2-SETUP-RESPONSE")

  e2ap_print_pdu(res_pdu);

  //encode response pdu into buffer
  sctp_buffer_t res_data;
  e2ap_encode_pdu(res_pdu, res_data.buffer, sizeof(res_data.buffer), res_data.len);

  //send response data over sctp
  if(sctp_send_data(socket_fd, res_data) > 0) {
    LOG_I("[SCTP] Sent X2-SETUP-RESPONSE");
  } else {
    LOG_E("[SCTP] Unable to send X2-SETUP-RESPONSE to peer");
  }
}

void e2ap_handle_X2SetupResponse(e2ap_pdu_t* pdu, int &socket_fd)
{
  ;
}

void e2ap_handle_ENDCX2SetupRequest(e2ap_pdu_t* pdu, int &socket_fd)
{
  /*
  Simply send back ENDCX2SetupResponse
  Todo: add more handling options (failure, duplicated request, etc.)
  */

  e2ap_pdu_t* res_pdu = new_e2ap_pdu();
  gNB_config gnb_cfg;

  e2ap_create_ENDCX2SetupResponse(res_pdu, gnb_cfg);
  LOG_D("[E2AP] Created ENDC-X2-SETUP-RESPONSE");

  e2ap_print_pdu(res_pdu);

  sctp_buffer_t data;
  e2ap_encode_pdu(res_pdu, data.buffer, sizeof(data.buffer), data.len);

  //send response data over sctp
  if(sctp_send_data(socket_fd, data) > 0) {
    LOG_I("[SCTP] Sent ENDC-X2-SETUP-RESPONSE");
  } else {
    LOG_E("[SCTP] Unable to send ENDC-X2-SETUP-RESPONSE to peer");
  }
}

void e2ap_handle_RICSubscriptionRequest(e2ap_pdu_t* pdu, int &socket_fd)
{
  RICsubscription_params_t params;
  e2ap_parse_RICsubscriptionRequest(pdu, params);

  /* Example handling logic
  - Accept if request id is even-numbered -> send back response
    in this case, accept every other actions

  - Reject if request id is odd-numbered -> send back failure
  */

  e2ap_pdu_t* res_pdu = new_e2ap_pdu();
  bool is_failure = false;

  if(params.request_id % 2 == 0)
  {
    for(size_t i = 0; i < params.actionList.size(); i++)
    {
      if(i%2 == 0){
        params.actionList[i].isAdmitted = true;
      } else {
        params.actionList[i].isAdmitted = false;
        params.actionList[i].notAdmitted_cause = RICcause_radioNetwork;
        params.actionList[i].notAdmitted_subCause = 5;
      }
    }

    e2ap_create_RICsubscriptionResponse(res_pdu, params);
    LOG_I("[E2AP] Created RIC-SUBSCRIPTION-RESPONSE");
  }
  else
  {
    is_failure = true;

    for(size_t i = 0; i < params.actionList.size(); i++)
    {
      params.actionList[i].isAdmitted = false;
      params.actionList[i].notAdmitted_cause = RICcause_radioNetwork;
      params.actionList[i].notAdmitted_subCause = 5;
    }

    e2ap_create_RICsubscriptionFailure(res_pdu, params);
    LOG_I("[E2AP] Created RIC-SUBSCRIPTION-FAILURE");
  }

  e2ap_print_pdu(res_pdu);

  //Encode into buffer
  sctp_buffer_t data;
  e2ap_encode_pdu(res_pdu, data.buffer, sizeof(data.buffer), data.len);

  //send response data over sctp
  if(sctp_send_data(socket_fd, data) > 0)
  {
    if(is_failure) {
      LOG_I("[SCTP] Sent RIC-SUBSCRIPTION-FAILURE");
    }
    else {
      LOG_I("[SCTP] Sent RIC-SUBSCRIPTION-RESPONSE");
    }
  }
  else
  {
    if(is_failure) {
      LOG_I("[SCTP] Unable to send RIC-SUBSCRIPTION-FAILURE");
    }
    else {
      LOG_E("[SCTP] Unable to send RIC-SUBSCRIPTION-RESPONSE");
    }
  }

}
