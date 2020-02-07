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
#include <stdlib.h>

#define NUM_SAMPLE 2000
#define SEC2MUS	1000000
#define LOG_I(...) {}
#define LOG_E(...) {}
#define LOG_D(...) {}

typedef struct {
  char* server_ip;
  int   server_port;
  int rate;
  //... extend as needed
} wg_options_t;

wg_options_t wg_input_options(int argc, char *argv[]);
