#!/bin/bash
set -x

#install pip3
apt install python3-pip -y

#install helm3
export HELM_VERSION=3.5.4

# Install helm (to the specific release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
export BASE_URL="https://get.helm.sh"
export TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
    curl -sL ${BASE_URL}/${TAR_FILE} | tar -xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64

# add helm-diff
helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

# add helm-unittest
helm plugin install https://github.com/quintush/helm-unittest && rm -rf /tmp/helm-*

# add helm-push
helm plugin install https://github.com/chartmuseum/helm-push && rm -rf /tmp/helm-*

# Install jq
apt install jq -y

# pull xapp_onboarder code
git clone "https://gerrit.o-ran-sc.org/r/ric-plt/appmgr"
cd appmgr/xapp_orchestrater/dev/xapp_onboarder

#update the requirement for the package "six" otherwise it might conflict with some other dependencies
cat requirements.txt | sed -e '/six/d' > /tmp/1
echo "six>=1.14.0" >> /tmp/1
cp /tmp/1 requirements.txt

# install xapp_onboarder
pip3 uninstall xapp_onboarder
pip3 install ./

#Create a local helm repository with a port other than 8080 on host
docker run --rm -u 0 -it -d -p 8090:8080 -e DEBUG=1 -e STORAGE=local -e STORAGE_LOCAL_ROOTDIR=/charts -v $(pwd)/charts:/charts chartmuseum/chartmuseum:latest
export CHART_REPO_URL=http://0.0.0.0:8090

cd ../../../..

# use dms_cli to install the kpimon-go xApp
git clone "https://gerrit.o-ran-sc.org/r/ric-app/kpimon-go"
cd kpimon-go/deploy/
export XAPP_VERSION=`grep version config.json | cut -f2 -d: | cut -f2 -d\"`
dms_cli onboard config.json schema.json
dms_cli install kpimon-go ${XAPP_VERSION} ricxapp
