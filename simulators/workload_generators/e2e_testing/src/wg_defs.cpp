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

#include "wg_defs.h"
#include "e2sim_defs.h"
#include <getopt.h>
#include <iostream>

using namespace std;

wg_options_t wg_input_options(int argc, char *argv[]) {
  wg_options_t options;
  options.server_ip = (char*)DEFAULT_SCTP_IP;
  options.server_port = X2AP_SCTP_PORT;
  options.rate = 1;
  if (argc == 4) {
    options.server_ip = argv[1];
    options.server_port = atoi(argv[2]);
    options.rate = atoi(argv[3]);
  } else if (argc == 3) {
    options.server_ip = argv[1];
    options.server_port = atoi(argv[2]);
    if (options.server_port < 1 || options.server_port > 65535) {
      LOG_E("Invalid port number (%d). Valid values are between 1 and 65535.\n",
            options.server_port);
      exit(1);
    }
  } else if (argc == 2) {
    options.server_ip = argv[1];
  } else if (argc == 1) {
    options.server_ip = (char*)DEFAULT_SCTP_IP;
  } else {
    LOG_I("Unrecognized option.\n");
    LOG_I("Usage: %s [SERVER IP ADDRESS] [SERVER PORT] [RATE]\n", argv[0]);
    exit(1);
  }
  return options;
}
