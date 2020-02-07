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

installation(assuming you are in the directory where this README resides):

1. export E2SIM_DIR=[YOUR E2SIM DIRECTORY]
2. cmake .
3. make

run wg:
1. ./wg_serial 0.0.0.0 36421 [rate]
2. ./wg_concur 0.0.0.0 36421 [rate]

for example:
run wg serial mode at 10msgs/second:
./wg_serial 10.2.0.16 36421 10
run wg concurrent mode at 100msgs/second:
./wg_concur 10.2.0.16 36421 100