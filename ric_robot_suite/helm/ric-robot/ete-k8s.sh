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
# Run the testsuite for the passed tag. Valid tags are health
# Please clean up logs when you are done...
# Note: Do not run multiple concurrent ete.sh as the --display is not parameterized and tests will collide
#
if [ "$1" == "" ] || [ "$2" == "" ]; then
   echo "Usage: ete-k8s.sh <namespace> <tag> [input variable]"
   echo "  <tag>: health etetests e2mgrtests"
   echo "  [input variable] is added to runTags with "-v" prepended"
   echo "         example :   TEST_NODE_B_IP:10.240.0.217 "
   echo "         example :   \"TEST_NODE_B_IP:10.240.0.217 -v TEST_NODE_B_PORT:36421 -v TEST_NODE_B_NAME:AAAA123456\""
   echo "         NOTE1:  TEST_NODE_B_NAME is 4 upper case letters and then 6 numbers in Dashboard validation  "
   echo "         NOTE2:  TEST_NODE_B_PORT real nodeB's use 36422 but e2sim must be on a port other than 36422"
   echo "           "
   echo "  <tag>         "
   echo "         health   "
   echo "         etetests  "
   echo "         e2setup   "
   echo "         x2setup   "
   echo "         e2setup_dash   "
   echo "         x2setup_dash   "
   exit
fi


if [ "$3" != "" ] ; then
    VARIABLES="-v $3"
fi

#set -x

export NAMESPACE="$1"

POD=$(kubectl --namespace  $NAMESPACE get pod -l robotImplementation=ric-robot --no-headers=true | sed 's/ .*//')


TAGS="-i $2"

ETEHOME=/var/opt/RIC
export GLOBAL_BUILD_NUMBER=$(kubectl --namespace $NAMESPACE exec  ${POD}  -- bash -c "ls -1q /share/logs/ | wc -l")
OUTPUT_FOLDER=$(printf %04d $GLOBAL_BUILD_NUMBER)_ete_$2
DISPLAY_NUM=$(($GLOBAL_BUILD_NUMBER + 90))

VARIABLEFILES="-V /share/config/vm_properties.py -V /share/config/integration_robot_properties.py"
VARIABLES="$VARIABLES -v GLOBAL_BUILD_NUMBER:$$"

kubectl --namespace $NAMESPACE exec ${POD} -- ${ETEHOME}/runTags.sh ${VARIABLEFILES} ${VARIABLES} -d /share/logs/${OUTPUT_FOLDER} ${TAGS} --display $DISPLAY_NUM
