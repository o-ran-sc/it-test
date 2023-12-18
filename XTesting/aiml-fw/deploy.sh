#!/bin/bash
set -x

# pull the AI/ML framework code base
rm -rf /aimlfw-dep
git clone "https://gerrit.o-ran-sc.org/r/aiml-fw/aimlfw-dep" /aimlfw-dep
cd /aimlfw-dep

bin/install_traininghost.sh 2>&1 | tee /tmp/install-thost-`echo $RANDOM`.log

# deploy InfluxDB as the data lake
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/influxdb

# install the dependencies for populating InfluxDB
pip3 install pandas
pip3 install influxdb-client

# populate the sample data in InfluxDB as source for training
cd /root
python3 insert.py
