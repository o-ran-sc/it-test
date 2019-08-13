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
#ifndef E2AP_ASN_CODEC_HPP
#define E2AP_ASN_CODEC_HPP

#include "e2sim_defs.h"
#include "asn_e2ap.hpp"

#define ERROR_MESSAGE_BUFFER 1024
#define PDU_PRINT_BUFFER     4096

void e2ap_encode_pdu(e2ap_pdu_t* pdu, unsigned char* buf, int buf_size, int &encoded_size);

void e2ap_decode_pdu(e2ap_pdu_t* pdu, unsigned char* buf, int &encoded_size);

void e2ap_print_pdu(e2ap_pdu_t* pdu);

#endif
