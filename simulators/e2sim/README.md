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

# INSTALLATION
  * Tested environment: Ubuntu 16.04
  * Install dependencies
    $ sudo apt-get update
    $ sudo apt-get install -y
        build-essential
        git
        cmake
        libsctp-dev
        lksctp-tools
        autoconf
        automake
        libtool
        bison
        flex
        libboost-all-dev
    $ sudo apt-get clean

  ## Build
    $ ./build_e2sim

# SET ENVIRONMENT VARIABLE
  Add this line to `~/.bashrc`
  $  export E2SIM_DIR=<your e2sim directory>

# RUN E2SIM
  $  cd $E2SIM_DIR/build/
  $ ./e2agent [SERVER IP] [PORT]

  By default, SERVER IP = 127.0.0.1, PORT = 36422 (X2AP Port)

# DOCKER
  Note: The commands in this section must be run from $E2SIM_DIR

  * Build docker image
  $ ./build_docker

  ## Run docker container
  $ sudo docker run --rm --net host -it e2agent sh -c "./build/e2agent [SERVER IP] [PORT]"

# SUPPORTED MESSAGE FLOWS (Last updated May 24, 2019)

- X2 SETUP REQUEST          (RIC -> RAN)
- X2 SETUP RESPONSE         (RAN -> RIC)

- ENDC X2 SETUP REQUEST     (RIC -> RAN)
- ENDC X2 SETUP RESPONSE    (RAN -> RIC)

- RIC SUBSCRIPTION REQUEST  (RIC -> RAN)
- RIC SUBSCRIPTION RESPONSE (RAN -> RIC)
- RIC SUBSCRIPTION FAILURE  (RAN -> RIC)


# Change logs:
  03/12/2019: currently supports sending and receiving X2 SETUP messages
  05/21/2019: add support for ENDC X2 SETUP   
              no longer use asn1c
              all X2AP and E2AP messages are encapsulated into E2AP-PDU
  05/24/2019: add support for RIC SUBSCRIPTION REQUEST, RESPONSE, and FAILURE
