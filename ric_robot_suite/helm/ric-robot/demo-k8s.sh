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


function usage
{
	echo "Usage: demo.sh namespace <command> [<parameters>]"
	echo " "
	echo "       demo.sh <namespace> init_robot"
    echo "               - Initialize robot after all RIC VMs have started"
}



# Set the defaults

#echo "Number of parameters:" 
#echo $#

if [ $# -lt 2 ];then
	usage
	exit
fi

NAMESPACE=$1
POD=$(kubectl --namespace $NAMESPACE get pods -l robotImplementation=ric-robot  --no-headers=true | sed 's/ .*//')

shift

##
## if more than 1 tag is supplied, the must be provided with -i or -e
##
while [ $# -gt 0 ]
do
	key="$1"
        #echo "KEY:"
        #echo $key

	case $key in
    	init_robot)
			TAG="UpdateWebPage"
		        WEB_PASSWORD=test
			VARIABLES="$VARIABLES -v WEB_PASSWORD:$WEB_PASSWORD"
			shift
			if [ $# -eq 2 ];then
				VARIABLES="$VARIABLES -v HOSTS_PREFIX:$1"
			fi
			# copy the .kube/config into the robot container
                        kubectl -n $NAMESPACE cp /root/.kube/config $POD:/root/.kube/config
			shift
			;;
    	*)
			usage
			exit
	esac
done

#set -x


ETEHOME=/var/opt/RIC

export GLOBAL_BUILD_NUMBER=$(kubectl --namespace $NAMESPACE exec  ${POD}  -- bash -c "ls -1q /share/logs/ | wc -l")
OUTPUT_FOLDER=$(printf %04d $GLOBAL_BUILD_NUMBER)_demo_$key
DISPLAY_NUM=$(($GLOBAL_BUILD_NUMBER + 90))

VARIABLEFILES="-V /share/config/vm_properties.py -V /share/config/integration_robot_properties.py -V /share/config/integration_preload_parameters.py"

kubectl --namespace $NAMESPACE exec ${POD} -- ${ETEHOME}/runTags.sh ${VARIABLEFILES} ${VARIABLES} -d /share/logs/${OUTPUT_FOLDER} -i ${TAG} --display $DISPLAY_NUM 2> ${TAG}.out

