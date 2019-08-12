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
   echo "  [input variable] is added to runTags with "-v" prepended"
   echo "         example :   TEST_NODE_B_IP:10.240.0.217 "
   echo "         example :   \"TEST_NODE_B_IP:10.240.0.217 -v TEST_NODE_B_PORT:34622 -v TEST_NODE_B_NAME:BBBB654321\""
   echo "         note:   TEST_NODE_B_NAME is 4 upper case letters and then 6 numbers in Dashboard validation  "
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


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

#/root/test/ric_robot_suite/helm
# extract the base to find root to dep

BASE=${DIR%/test*}

BASEDIR50=$BASE/dep/ric-platform/50-RIC-Platform/
OVERRIDEYAML=$BASE/dep/RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE

echo "Using etc/ric.conf from $BASEDIR50"

source $BASEDIR50/etc/ric.conf


if [ -z "$RICPLT_RELEASE_NAME" ];then
   RELEASE_NAME=$helm_release_name
else
   RELEASE_NAME=$RICPLT_RELEASE_NAME
fi



# first parameter: number of expected running pods
# second parameter: namespace (all-namespaces means all namespaces)
# third parameter: [optional] keyword
wait_for_pods_running () {
  NS="$2"
  CMD="kubectl get pods --all-namespaces "
  if [ "$NS" != "all-namespaces" ]; then
    CMD="kubectl get pods -n $2 "
  fi
  KEYWORD="Running"
  if [ "$#" == "3" ]; then
    KEYWORD="${3}.*Running"
  fi

  CMD2="$CMD | grep \"$KEYWORD\" | wc -l"
  NUMPODS=$(eval "$CMD2")
  echo "waiting for $NUMPODS/$1 pods running in namespace [$NS] with keyword [$KEYWORD]"
  while [  $NUMPODS -lt $1 ]; do
    sleep 5
    NUMPODS=$(eval "$CMD2")
    echo "> waiting for $NUMPODS/$1 pods running in namespace [$NS] with keyword [$KEYWORD]"
  done
}

wait_for_pods_terminated() {
  NS="$2"
  CMD="kubectl get pods --all-namespaces "
  if [ "$NS" != "all-namespaces" ]; then
    CMD="kubectl get pods -n $2 "
  fi
  KEYWORD="Running"
  if [ "$#" == "3" ]; then
    KEYWORD="${3}"
  fi

  CMD2="$CMD | grep \"$KEYWORD\" | wc -l"
  NUMPODS=$(eval "$CMD2")
  echo "waiting for $NUMPODS/$1 pods terminated (gone) in namespace [$NS] with keyword [$KEYWORD]"
  while [  $NUMPODS -gt $1 ]; do
    sleep 5
    NUMPODS=$(eval "$CMD2")
    echo "> waiting for $NUMPODS/$1 pods terminated (gone) in namespace [$NS] with keyword [$KEYWORD]"
  done
}


if [ "$3" != "" ] ; then
    VARIABLES="-v $3"
fi

set -x

export NAMESPACE="$1"

POD=$(kubectl --namespace $NAMESPACE get pods | sed 's/ .*//'| grep robot)

TAG="$2"
TAGS="-i $2"


# if $2 is e2setup or x2setup then helm delete/helm install 
shift
while [ $# -gt 0 ]
do
        key="$1"
        echo "KEY:"
        echo $key
        case $key in
        e2setup|e2setup_dash|x2setup|x2setup_dash)
                        #/root/dep/ric-platform/50-RIC-Platform/bin/harry-uninstall
                        helm delete  ${RELEASE_NAME}-e2term   --purge
                        helm delete  ${RELEASE_NAME}-e2mgr   --purge
			helm delete  ${RELEASE_NAME}-e2sim  --purge
                        wait_for_pods_terminated  0  $NAMESPACE e2sim
                        wait_for_pods_terminated  0  $NAMESPACE e2term
                        wait_for_pods_terminated  0  $NAMESPACE e2mgr
                        helm install -f $OVERRIDEYAML --namespace "${NAMESPACE}" --name "${RELEASE_NAME}-e2term" $BASEDIR50/helm/e2term
                        helm install -f $OVERRIDEYAML --namespace "${NAMESPACE}" --name "${RELEASE_NAME}-e2mgr" $BASEDIR50/helm/e2mgr
                        cd /root/test/simulators/e2sim/helm
		        ./e2sim_install.sh
                        wait_for_pods_running 1 $NAMESPACE e2term
                        wait_for_pods_running 1 $NAMESPACE e2mgr
                        wait_for_pods_running 1 $NAMESPACE e2sim
                        E2SIMIP=$(kubectl -n ricplt get pod -o=wide | grep e2sim | sed 's/\s\s*/ /g' | cut -d ' ' -f6)
			echo $E2SIMIP
                        VARIABLES="$VARIABLES -v TEST_NODE_B_IP:$E2SIMIP"
			shift
			;;
        *)
			shift
			;;
        esac
done


ETEHOME=/var/opt/RIC
export GLOBAL_BUILD_NUMBER=$(kubectl --namespace $NAMESPACE exec  ${POD}  -- bash -c "ls -1q /share/logs/ | wc -l")
OUTPUT_FOLDER=$(printf %04d $GLOBAL_BUILD_NUMBER)_ete_$TAG
DISPLAY_NUM=$(($GLOBAL_BUILD_NUMBER + 90))

VARIABLEFILES="-V /share/config/vm_properties.py -V /share/config/integration_robot_properties.py"
#VARIABLEFILES="-V /tmp/vm_properties.py -V /share/config/integration_robot_properties.py"
VARIABLES="$VARIABLES -v GLOBAL_BUILD_NUMBER:$$"



kubectl --namespace $NAMESPACE exec ${POD} -- ${ETEHOME}/runTags.sh ${VARIABLEFILES} ${VARIABLES} -d /share/logs/${OUTPUT_FOLDER} ${TAGS} --display $DISPLAY_NUM
