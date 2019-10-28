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
#include <unistd.h>

void e2ap_handle_sctp_data(int &socket_fd, sctp_buffer_t &data)
{
  //decode the data into E2AP-PDU
  E2AP_PDU_t* pdu = new E2AP_PDU_t();

  e2ap_asn1c_decode_pdu(pdu, data.buffer, data.len);

  e2ap_asn1c_print_pdu(pdu);

  int procedureCode = e2ap_asn1c_get_procedureCode(pdu);
  int index = (int)pdu->present;

  LOG_D("[E2AP] Unpacked E2AP-PDU: index = %d, procedureCode = %d\n",
                            index, procedureCode);

  switch(procedureCode)
  {
    case ProcedureCode_id_x2Setup: //X2Setup = 6
      switch(index)
      {
        case E2AP_PDU_PR_initiatingMessage: //initiatingMessage
          LOG_I("[E2AP] Received X2-SETUP-REQUEST");
          e2ap_handle_X2SetupRequest(pdu, socket_fd);
          break;

        case E2AP_PDU_PR_successfulOutcome: //successfulOutcome
          LOG_I("[E2AP] Received X2-SETUP-RESPONSE");
          break;

        case E2AP_PDU_PR_unsuccessfulOutcome:
          break;

        default:
          LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU", index);
          break;
      }
      break;

    case ProcedureCode_id_endcX2Setup: //ENDCX2Setup = 36
      switch(index)
      {
        case E2AP_PDU_PR_initiatingMessage: //initiatingMessage
          LOG_I("[E2AP] Received ENDC-X2-SETUP-REQUEST");
          e2ap_handle_ENDCX2SetupRequest(pdu, socket_fd);
          break;

        case E2AP_PDU_PR_successfulOutcome: //successfulOutcome
          LOG_I("[E2AP] Received ENDC-X2-SETUP-RESPONSE");
          //no handler yet
          break;

        case E2AP_PDU_PR_unsuccessfulOutcome:
          LOG_I("[E2AP] Received ENDC-X2-SETUP-FAILURE");
          //no handler yet
          break;

        default:
          LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU", index);
          break;
      }
      break;

    case ProcedureCode_id_reset: //reset = 7
      switch(index)
      {
        case E2AP_PDU_PR_initiatingMessage:
          LOG_I("[E2AP] Received RESET-REQUEST");
          break;

        case E2AP_PDU_PR_successfulOutcome:
          break;

        case E2AP_PDU_PR_unsuccessfulOutcome:
          break;

        default:
          LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU", index);
          break;
      }
      break;

    case ProcedureCode_id_ricSubscription: //RIC SUBSCRIPTION = 201
      switch(index)
      {
        case E2AP_PDU_PR_initiatingMessage: //initiatingMessage
          LOG_I("[E2AP] Received RIC-SUBSCRIPTION-REQUEST");
          //e2ap_handle_RICSubscriptionRequest(pdu, socket_fd);
          e2ap_handle_RICSubscriptionRequest_securityDemo(pdu, socket_fd);
          break;

        case E2AP_PDU_PR_successfulOutcome:
          LOG_I("[E2AP] Received RIC-SUBSCRIPTION-RESPONSE");
          break;

        case E2AP_PDU_PR_unsuccessfulOutcome:
          LOG_I("[E2AP] Received RIC-SUBSCRIPTION-FAILURE");
          break;

        default:
          LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU", index);
          break;
      }
      break;

    case ProcedureCode_id_ricIndication: // 205
      switch(index)
      {
        case E2AP_PDU_PR_initiatingMessage: //initiatingMessage
          LOG_I("[E2AP] Received RIC-INDICATION");
          // e2ap_handle_RICSubscriptionRequest(pdu, socket_fd);
          break;

        default:
          LOG_E("[E2AP] Invalid message index=%d in E2AP-PDU %d", index,
                                    (int)ProcedureCode_id_ricIndication);
          break;
      }
      break;

    default:
      LOG_E("[E2AP] No available handler for procedureCode=%d", procedureCode);
      break;
  }
}

/*
Simply send back X2SetupResponse
Todo: add more handling options (failure, duplicated request, etc.)
*/
void e2ap_handle_X2SetupRequest(E2AP_PDU_t* pdu, int &socket_fd)
{
  E2AP_PDU_t* res_pdu = e2ap_xml_to_pdu("E2AP_X2SetupResponse.xml");

  LOG_D("[E2AP] Created X2-SETUP-RESPONSE");

  e2ap_asn1c_print_pdu(res_pdu);

  uint8_t       *buf;
  sctp_buffer_t data;

  data.len = e2ap_asn1c_encode_pdu(res_pdu, &buf);
  memcpy(data.buffer, buf, data.len);

  //send response data over sctp
  if(sctp_send_data(socket_fd, data) > 0) {
    LOG_I("[SCTP] Sent X2-SETUP-RESPONSE");
  } else {
    LOG_E("[SCTP] Unable to send X2-SETUP-RESPONSE to peer");
  }
}

/*
Simply send back ENDCX2SetupResponse
Todo: add more handling options (failure, duplicated request, etc.)
*/
void e2ap_handle_ENDCX2SetupRequest(E2AP_PDU_t* pdu, int &socket_fd)
{
  E2AP_PDU_t* res_pdu = e2ap_xml_to_pdu("E2AP_ENDCX2SetupResponse.xml");

  LOG_D("[E2AP] Created ENDC-X2-SETUP-RESPONSE");

  e2ap_asn1c_print_pdu(res_pdu);

  uint8_t       *buf;
  sctp_buffer_t data;

  data.len = e2ap_asn1c_encode_pdu(res_pdu, &buf);
  memcpy(data.buffer, buf, data.len);

  //send response data over sctp
  if(sctp_send_data(socket_fd, data) > 0) {
    LOG_I("[SCTP] Sent ENDC-X2-SETUP-RESPONSE");
  } else {
    LOG_E("[SCTP] Unable to send ENDC-X2-SETUP-RESPONSE to peer");
  }
}

/*
Simply send back hard-coded RICSubscriptionResponse
Todo: add more handling options (failure, duplicated request, etc.)
*/
void e2ap_handle_RICSubscriptionRequest(E2AP_PDU_t* pdu, int &socket_fd)
{
  E2AP_PDU_t* res_pdu = e2ap_xml_to_pdu("E2AP_RICsubscriptionResponse.xml");

  LOG_D("[E2AP] Created RIC-SUBSCRIPTION-RESPONSE");

  e2ap_asn1c_print_pdu(res_pdu);

  uint8_t       *buf;
  sctp_buffer_t data;

  data.len = e2ap_asn1c_encode_pdu(res_pdu, &buf);
  memcpy(data.buffer, buf, data.len);

  //send response data over sctp
  if(sctp_send_data(socket_fd, data) > 0) {
    LOG_I("[SCTP] Sent RIC-SUBSCRIPTION-RESPONSE");
  } else {
    LOG_E("[SCTP] Unable to send RIC-SUBSCRIPTION-RESPONSE to peer");
  }
}

void e2ap_handle_RICSubscriptionRequest_securityDemo(E2AP_PDU_t* pdu, int &socket_fd)
{
  E2AP_PDU_t* res_pdu = e2ap_xml_to_pdu("E2AP_RICsubscriptionResponse.xml");

  LOG_D("[E2AP] Created RIC-SUBSCRIPTION-RESPONSE");

  e2ap_asn1c_print_pdu(res_pdu);

  uint8_t       *buf;
  sctp_buffer_t data;

  data.len = e2ap_asn1c_encode_pdu(res_pdu, &buf);
  memcpy(data.buffer, buf, data.len);

  //send response data over sctp
  if(sctp_send_data(socket_fd, data) > 0) {
    LOG_I("[SCTP] Sent RIC-SUBSCRIPTION-RESPONSE");
  } else {
    LOG_E("[SCTP] Unable to send RIC-SUBSCRIPTION-RESPONSE to peer");
  }

  //Start sending RIC Indication
  int count1 = 0, count2 = 0;

  E2AP_PDU_t* indication_type1 = e2ap_xml_to_pdu("E2AP_RICindication_type1.xml");
  E2AP_PDU_t* indication_type2 = e2ap_xml_to_pdu("E2AP_RICindication_type2.xml");

  uint8_t *buf1, *buf2;
  sctp_buffer_t data1, data2;
  data1.len = e2ap_asn1c_encode_pdu(indication_type1, &buf1);
  memcpy(data1.buffer, buf1, data1.len);

  data2.len = e2ap_asn1c_encode_pdu(indication_type2, &buf2);
  memcpy(data2.buffer, buf2, data2.len);

  while(1){
    sleep(1);
    //type1
    if(sctp_send_data(socket_fd, data1) > 0) {
      count1++;
      LOG_I("[SCTP] Sent RIC-INDICATION SgNBAdditionRequest Type 1, count1 = %d", count1);
    } else {
      LOG_E("[SCTP] Unable to send RIC-INDICATION to peer");
    }

    sleep(1);
    //type2
    if(sctp_send_data(socket_fd, data2) > 0) {
      count2++;
      LOG_I("[SCTP] Sent RIC-INDICATION SgNBAdditionRequest Type 2, count2 = %d", count2);
    } else {
      LOG_E("[SCTP] Unable to send RIC-INDICATION to peer");
    }
  } //end while

}

// void e2ap_handle_RICSubscriptionRequest_old(e2ap_pdu_t* pdu, int &socket_fd)
// {
//   RICsubscription_params_t params;
//   e2ap_parse_RICsubscriptionRequest(pdu, params);
//
//   /* Example handling logic
//   - Accept if request id is even-numbered -> send back response
//     in this case, accept every other actions
//
//   - Reject if request id is odd-numbered -> send back failure
//   */
//
//   e2ap_pdu_t* res_pdu = new_e2ap_pdu();
//   bool is_failure = false;
//
//   if(params.request_id % 2 == 0)
//   {
//     for(size_t i = 0; i < params.actionList.size(); i++)
//     {
//       if(i%2 == 0){
//         params.actionList[i].isAdmitted = true;
//       } else {
//         params.actionList[i].isAdmitted = false;
//         params.actionList[i].notAdmitted_cause = RICcause_radioNetwork;
//         params.actionList[i].notAdmitted_subCause = 5;
//       }
//     }
//
//     e2ap_create_RICsubscriptionResponse(res_pdu, params);
//     LOG_I("[E2AP] Created RIC-SUBSCRIPTION-RESPONSE");
//   }
//   else
//   {
//     is_failure = true;
//
//     for(size_t i = 0; i < params.actionList.size(); i++)
//     {
//       params.actionList[i].isAdmitted = false;
//       params.actionList[i].notAdmitted_cause = RICcause_radioNetwork;
//       params.actionList[i].notAdmitted_subCause = 5;
//     }
//
//     e2ap_create_RICsubscriptionFailure(res_pdu, params);
//     LOG_I("[E2AP] Created RIC-SUBSCRIPTION-FAILURE");
//   }
//
//   e2ap_print_pdu(res_pdu);
//
//   //Encode into buffer
//   sctp_buffer_t data;
//   e2ap_encode_pdu(res_pdu, data.buffer, sizeof(data.buffer), data.len);
//
//   //send response data over sctp
//   if(sctp_send_data(socket_fd, data) > 0)
//   {
//     if(is_failure) {
//       LOG_I("[SCTP] Sent RIC-SUBSCRIPTION-FAILURE");
//     }
//     else {
//       LOG_I("[SCTP] Sent RIC-SUBSCRIPTION-RESPONSE");
//     }
//   }
//   else
//   {
//     if(is_failure) {
//       LOG_I("[SCTP] Unable to send RIC-SUBSCRIPTION-FAILURE");
//     }
//     else {
//       LOG_E("[SCTP] Unable to send RIC-SUBSCRIPTION-RESPONSE");
//     }
//   }
//
// }
