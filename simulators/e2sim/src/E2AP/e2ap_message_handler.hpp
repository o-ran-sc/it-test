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
#ifndef E2AP_MESSAGE_HANDLER_HPP
#define E2AP_MESSAGE_HANDLER_HPP

#include "e2sim_defs.h"
#include "e2sim_sctp.hpp"
#include "asn_e2ap.hpp"
#include "e2ap_asn_codec.hpp"

void e2ap_handle_sctp_data(int &socket_fd, sctp_buffer_t &data);

void e2ap_handle_X2SetupRequest(e2ap_pdu_t* pdu, int &socket_fd);

void e2ap_handle_X2SetupResponse(e2ap_pdu_t* pdu, int &socket_fd);

void e2ap_handle_ENDCX2SetupRequest(e2ap_pdu_t* pdu, int &socket_fd);

void e2ap_handle_RICSubscriptionRequest(e2ap_pdu_t* pdu, int &socket_fd);

#endif
