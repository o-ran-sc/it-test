# Copyright 2019 AT&T Intellectual Property
# Copyright 2019 Nokia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cmake_minimum_required(VERSION 3.5.1)
set(CMAKE_CXX_COMPILER "/usr/bin/g++")
set(CMAKE_CXX_STANDARD 14)

project(e2sim)

set (HOME_DIR     $ENV{HOME})

include_directories("src")
include_directories("src/ASN1/lib")
include_directories("src/SCTP/")
include_directories("src/E2AP")
include_directories("src/X2AP")

#for ASN1_API
#include_directories("src/ASN1")
#include_directories("src/ASN1/asn")
#include_directories("src/ASN1/generated")
#add_library(ASN1_API
#  "src/ASN1/lib/asn_x2ap.cpp"
#)

link_directories("build")

#-----------------------------------------------
file(GLOB E2AGENT_SOURCES
      "src/e2agent.cpp"
      "src/e2sim_defs.cpp"
      "src/SCTP/*.cpp"
      "src/E2AP/*.cpp"
      )
add_executable(e2agent ${E2AGENT_SOURCES})

#for ASN1_API
target_link_libraries(e2agent ASN1_API)

#-----------------------------------------------
file(GLOB E2TERM_SOURCES
      "src/e2termination_test.cpp"
      "src/e2sim_defs.cpp"
      "src/SCTP/*.cpp"
      "src/E2AP/*.cpp"
      )
add_executable(e2term ${E2TERM_SOURCES})
target_link_libraries(e2term ASN1_API)

#-----------------------------------------------
file(GLOB X2TERM_SOURCES
      "src/x2termination_test.cpp"
      "src/e2sim_defs.cpp"
      "src/SCTP/*.cpp"
      "src/X2AP/*.cpp"
      )
add_executable(x2term ${X2TERM_SOURCES})
target_link_libraries(x2term ASN1_API)
