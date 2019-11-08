#/*****************************************************************************
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
#******************************************************************************/


# INSTALLATION (tested on Ubuntu 16.04)
  1. Install dependencies
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

  2. SET ENVIRONMENT VARIABLE
    Add this line to `~/.bashrc`
      export E2SIM_DIR=<your e2sim directory>

  3. Build the official e2sim
    $ ./build_e2sim

# USAGE
  $  $E2SIM_DIR/build/e2sim [SERVER IP] [PORT]

  By default, SERVER IP = 127.0.0.1, PORT = 36421

# DOCKER
  Note: The commands in this section must be run from $E2SIM_DIR

  * Build docker image
  $ sudo docker build -f docker/Dockerfile -t [DOCKER_IMAGE]:[TAG] .

  * Example how to run docker container
  $ sudo docker run --rm --net host -it [DOCKER_IMAGE]:[TAG] sh -c "./build/e2sim [SERVER IP] [PORT]"

# SUPPORTED MESSAGE FLOWS

- RIC INDICATION            (RAN -> RIC)      version 1.3.0   September 13, 2019
    SgNBAdditionRequest

- RIC SUBSCRIPTION REQUEST  (RIC -> RAN)      version 1.2.0   May 24, 2019
- RIC SUBSCRIPTION RESPONSE (RAN -> RIC)
- RIC SUBSCRIPTION FAILURE  (RAN -> RIC)

- ENDC X2 SETUP REQUEST     (RIC -> RAN)
- ENDC X2 SETUP RESPONSE    (RAN -> RIC)

- X2 SETUP REQUEST          (RIC -> RAN)
- X2 SETUP RESPONSE         (RAN -> RIC)

# GENERATING ASN1C CODES FOR E2AP, E2SM, X2AP
 1. Install asn1c compiler
 ./tools/install_asn1c

 2. Generate asn1c codes using e2ap, e2sm and x2ap specs
 Download the following files into tools/asn_defs
  - e2ap-v031.asn
  - e2sm-gNB-X2-release-1-v041.asn
  - x2ap-no-desc-15-04.asn

# Change logs:
  03/12/2019: currently supports sending and receiving X2 SETUP messages
  05/21/2019: add support for ENDC X2 SETUP   
              no longer use asn1c
              all X2AP and E2AP messages are encapsulated into E2AP-PDU
  05/24/2019: add support for RIC SUBSCRIPTION REQUEST, RESPONSE, and FAILURE
