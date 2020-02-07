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
set(E2SIM_HOME $ENV{E2SIM_DIR})
set(CMAKE_CXX_FLAGS " -lpthread")
message(STATUS "E2SIM_HOME: ${E2SIM_HOME}")
add_definitions("-D ASN_DISABLE_OER_SUPPORT")


project(wg)

include_directories("src")
include_directories("${E2SIM_HOME}/src")
include_directories("${E2SIM_HOME}/src/SCTP/")
include_directories("${E2SIM_HOME}/src/E2AP")
include_directories("${E2SIM_HOME}/src/E2AP/E2SM")
include_directories("${E2SIM_HOME}/ASN1c")

#----------------------------------------------
file(GLOB WG_SOURCES
      "src/wg_concur.cpp"
      "src/wg_defs.cpp"
      "${E2SIM_HOME}/src/e2sim_defs.cpp"
      "${E2SIM_HOME}/src/SCTP/*.cpp"
      "${E2SIM_HOME}/src/E2AP/*.c"
      "${E2SIM_HOME}/src/E2AP/*.cpp"
      "${E2SIM_HOME}/ASN1c/*.c"
      )
add_executable(wg_concur ${WG_SOURCES})
#add_executable(wg ${WG_SOURCES})
target_link_libraries(wg_concur pthread )    

#----------------------------------------------
file(GLOB WG_SOURCES
      "src/wg_serial.cpp"
      "src/wg_defs.cpp"
      "${E2SIM_HOME}/src/e2sim_defs.cpp"
      "${E2SIM_HOME}/src/SCTP/*.cpp"
      "${E2SIM_HOME}/src/E2AP/*.c"
      "${E2SIM_HOME}/src/E2AP/*.cpp"
      "${E2SIM_HOME}/ASN1c/*.c"
      )
add_executable(wg_serial ${WG_SOURCES})
