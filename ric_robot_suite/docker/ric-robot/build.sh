#!/bin/bash
################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
#   Copyright (c) 2019 Nokia.                                                  #
#                                                                              #
#   Licensed under the Apache License, Version 2.0 (the "License");            #
#   you may not use this file except in compliance with the License.           #
#   You may obtain a copy of the License at                                    #
#                                                                              #
#       http://www.apache.org/licenses/LICENSE-2.0                             #
#                                                                              #
#   Unless required by applicable law or agreed to in writing, software        #
#   distributed under the License is distributed on an "AS IS" BASIS,          #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
#   See the License for the specific language governing permissions and        #
#   limitations under the License.                                             #
################################################################################


#
# To RUN the container localy in a docker environment use the docker run command AFTER the following steps
# PWD is current directory path
# copy  vm_properties.py and integration_robot_properties.py into ./eteshare/config
# mkdir ./eteshare/logs
#
# ./demo.sh init_robot to set web page login(test)/password
# robot test results will be on http://127.0.0.1:88/logs/
#
#RUNPATH= is a full path to a directory where you have placed your environment specific files that 
# should be mounted into the containers /share/config  (e.g., vm_properties.py integration_robot_properties.py)
#

# generate doc
# python 2.7 needed
# pip install robotframework for docgen.py to work

docker build -t ric/testsuite -f docker/ric-robot/Dockerfile .
#docker  run -d --name  ric-robot -p 88:88 -v $RUNPATH/eteshare:/share ric/testsuite:latest lighttpd -D -f /etc/lighttpd/lighttpd.conf
