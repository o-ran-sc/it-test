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
        echo "Usage: demo.sh <command> [<parameters>]"
        echo " "
        echo "       demo.sh <namespace> init_robot"
        echo "               - Execute both initialize of robot login/password etc"
        echo " "
}


#
# For docker container environment
#
# Run the testsuite for the passed tag. Valid tags are health
# Please clean up logs when you are done...
# Note: Do not run multiple concurrent demo.sh/ete.sh as the --display is not parameterized and tests will collide
#
if [ "$1" == "" ] ; then
   echo "Usage: demo.sh  [ init_robot ]"
   exit
fi

##
## if more than 1 tag is supplied, the must be provided with -i or -e
##
while [ $# -gt 0 ]
do
        key="$1"
        echo "KEY:"
        echo $key

        case $key in
        init_robot)
                        TAG="UpdateWebPage"
                        read -s -p "WEB Site Password for user 'test': " WEB_PASSWORD
                        if [ "$WEB_PASSWORD" = "" ]; then
                                echo ""
                                echo "WEB Password is required for user 'test'"
                                exit
                        fi
                        VARIABLES="$VARIABLES -v WEB_PASSWORD:$WEB_PASSWORD"
                        shift
                        if [ $# -eq 2 ];then
                                VARIABLES="$VARIABLES -v HOSTS_PREFIX:$1"
                        fi
                        shift
                        ;;
        *)
                        usage
                        exit
        esac
done

set -x

POD=ric-robot

TAGS="-i $TAG"


ETEHOME=/var/opt/RIC
#export GLOBAL_BUILD_NUMBER=$(docker exec  -it ${POD}  bash -c "ls -1q /share/logs/ | wc -l ")
GLOBAL_BUILD_NUMBER=$(docker exec  -it ${POD}  bash -c "ls -1q /share/logs/ | wc -l")
GLOBAL_BUILD_NUMBER=$(echo "$GLOBAL_BUILD_NUMBER" | tr -d '\r')
OUTPUT_FOLDER=$(printf %04d $GLOBAL_BUILD_NUMBER)_demo_$TAG
DISPLAY_NUM=$(($GLOBAL_BUILD_NUMBER + 90))

VARIABLEFILES="-V /share/config/vm_properties.py -V /share/config/integration_robot_properties.py"
VARIABLES="$VARIABLES -v GLOBAL_BUILD_NUMBER:$$"

docker  exec -it ${POD} ${ETEHOME}/runTags.sh ${VARIABLEFILES} ${VARIABLES} -d /share/logs/${OUTPUT_FOLDER} ${TAGS} --display $DISPLAY_NUM
