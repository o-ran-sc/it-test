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
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
   echo "Usage: ete-k8s.sh <namespace> <tag> <override_file> [input variable]"
   echo "  [input variable] is added to runTags with "-v" prepended"
   echo "         example :   TEST_NODE_B_IP:10.240.0.217 "
   echo "         example :   \"TEST_NODE_B_IP:10.240.0.217 -v TEST_NODE_B_PORT:36421 -v TEST_NODE_B_NAME:BBBB654321\""
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

# setup a detail log file
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
LOGFILE=/tmp/ete-k8s.e2sim.$current_time.log

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


# extract the base to find root to dep

BASE=${DIR%/test*}

BASEDIR50=$BASE/dep/ric-platform/50-RIC-Platform
#OVERRIDEYAML=$BASE/dep/RECIPE_EXAMPLE/ric-platform
OVERRIDEYAML=$3

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
    echo -n "."
  done
  echo "."
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
    echo -n "."
  done
  echo "."
}


# wait_for_e2mgr
#  e2mgr can take a few seconds after the POD is running to be up
#  

wait_for_e2mgr() {
  E2MGR_IP=$(kubectl -n ricplt  get services | grep e2mgr-http | awk '{print $3}')
  #echo $E2MGR_IP
  CMD3="curl -s -o /dev/null -w \"%{http_code}\" http://$E2MGR_IP:3800/v1/nodeb-ids"
  echo $CMD3
  HTTP_CODE=$(eval "$CMD3")
  echo $HTTP_CODE
  while [  $HTTP_CODE  -ne 200 ]; do
    sleep 1
    HTTP_CODE=$(eval "$CMD3")
    echo -n "."
  done
}





if [ "$4" != "" ] ; then
    VARIABLES="-v $4"
fi

#set -x

export NAMESPACE="$1"

POD=$(kubectl --namespace $NAMESPACE get pods | sed 's/ .*//'| grep robot | grep -v nano)

TAG="$2"
TAGS="-i $2"


# if $2 is e2setup or x2setup then helm delete/helm install
shift
while [ $# -gt 0 ]
do
        key="$1"
        echo -n "KEY:"
        echo $key
        case $key in
        e2setup|e2setup_dash|x2setup|x2setup_dash)
                        helm delete  ${RELEASE_NAME}-e2term   --purge  >> $LOGFILE
                        helm delete  ${RELEASE_NAME}-e2mgr   --purge   >> $LOGFILE
                        helm delete  ${RELEASE_NAME}-e2sim  --purge  >> $LOGFILE
                        wait_for_pods_terminated  0  $NAMESPACE e2sim
                        wait_for_pods_terminated  0  $NAMESPACE e2term
                        wait_for_pods_terminated  0  $NAMESPACE e2mgr
                        helm install -f $OVERRIDEYAML --namespace "${NAMESPACE}" --name "${RELEASE_NAME}-e2term" $BASEDIR50/helm/e2term >> $LOGFILE
                        helm install -f $OVERRIDEYAML --namespace "${NAMESPACE}" --name "${RELEASE_NAME}-e2mgr" $BASEDIR50/helm/e2mgr >> $LOGFILE
                        cd /root/test/simulators/e2sim/helm
                        ./e2sim_install.sh     >> $LOGFILE
                        wait_for_pods_running 1 $NAMESPACE e2term
                        wait_for_pods_running 1 $NAMESPACE e2mgr
                        wait_for_pods_running 1 $NAMESPACE e2sim
                        # wait for application
                        wait_for_e2mgr
                        E2SIMIP=$(kubectl -n ricplt get pod -o=wide | grep e2sim | sed 's/\s\s*/ /g' | cut -d ' ' -f6)
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
