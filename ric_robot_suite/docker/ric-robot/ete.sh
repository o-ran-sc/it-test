# Copyright © 2019 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash
function usage
{
        echo "Usage: ete.sh <command> [<parameters>]"
        echo " "
        echo "       ete.sh health "
        echo "               - Execute RIC health tests for each component"
        echo "       ete.sh etetests"
        echo "               - Execute RIC ete tests "
        echo "       ete.sh appmgr"
        echo "               - Execute RIC appmgr tests "
        echo " "
}


#
# Run the testsuite for the passed tag. Valid tags are health
# Please clean up logs when you are done...
# Note: Do not run multiple concurrent ete.sh as the --display is not parameterized and tests will collide
#
if [ "$1" == "" ] ; then
   echo "Usage: ete.sh  [ health  | etetests | xapptests]"
   exit
fi

set -x


POD=ric-robot

TAGS="-i $1"

ETEHOME=/var/opt/RIC
export GLOBAL_BUILD_NUMBER=$(docker exec  -it ${POD}  bash -c "ls -1q /share/logs/ | wc -l")
GLOBAL_BUILD_NUMBER=$(echo $GLOBAL_BUILD_NUMBER | tr -d '\r')
OUTPUT_FOLDER=$(printf %04d $GLOBAL_BUILD_NUMBER)_ete_$1
DISPLAY_NUM=$(($GLOBAL_BUILD_NUMBER + 90))

VARIABLEFILES="-V /share/config/vm_properties.py -V /share/config/integration_robot_properties.py"
VARIABLES="-v GLOBAL_BUILD_NUMBER:$$"

docker  exec -it ${POD} ${ETEHOME}/runTags.sh ${VARIABLEFILES} ${VARIABLES} -d /share/logs/${OUTPUT_FOLDER} ${TAGS} --display $DISPLAY_NUM
