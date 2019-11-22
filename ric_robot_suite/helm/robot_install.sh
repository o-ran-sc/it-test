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
while [ -n "$1" ]; do # while loop starts

    case "$1" in

    -f) OVERRIDEYAML=$2
        shift
        ;;
    *) echo "Option $1 not recognized" ;; # In case you typed a different option other than a,b,c

    esac

    shift

done


if [ -z "$OVERRIDEYAML" ];then
    echo "****************************************************************************************************************"
    echo "                                                     ERROR                                                      "
    echo "****************************************************************************************************************"
    echo "RIC robot deployment without deployment recipe/override is currently disabled. Please specify an recipe/ovrride  with the -f option."
    echo "   the deployment recipe/override should be the same file as is used for RIC platform deplpoyment "
    echo "****************************************************************************************************************"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
GLOBAL_BLOCK=$(cat $OVERRIDEYAML | awk '/^global:/{getline; while ($0 ~ /^ +.*|^ *$/) {print $0; if (getline == 0) {break}}}')
NAMESPACE_BLOCK=$(cat $OVERRIDEYAML | awk '/^  namespace:/{getline; while ($0 ~ /^    .*|^ *$/) {print $0; if (getline == 0) {break}}}')
NAMESPACE=$(echo "$NAMESPACE_BLOCK" | awk '/^ *platform:/{print $2}')
RELEASE_PREFIX=$(echo "$GLOBAL_BLOCK" | awk '/^ *releasePrefix:/{print $2}')
COMPONENTS=ric-robot

echo "Deploying RIC [$COMPONENTS]"


COMMON_CHART_VERSION=$(cat $DIR/../../../dep/ric-common/Common-Template/helm/ric-common/Chart.yaml | grep version | awk '{print $2}')
helm package -d /tmp $DIR/../../../dep/ric-common/Common-Template/helm/ric-common


for component in $COMPONENTS; do

  mkdir -p $DIR/$component/charts/
  cp /tmp/ric-common-$COMMON_CHART_VERSION.tgz $DIR/$component/charts/
  helm install -f $OVERRIDEYAML --namespace "${NAMESPACE}" --name "${RELEASE_PREFIX}-$component" $DIR/../helm/$component
done

echo "RELEASE_NAMESPACE=${NAMESPACE}" > /tmp/ric-robot.conf
echo "RELEASE_NAME=${RELEASE_PREFIX}" >> /tmp/ric-robot.conf
echo "OVERRIDEYAML=${OVERRIDEYAML}" >> /tmp/ric-robot.conf

