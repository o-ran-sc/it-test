#!/bin/bash
set -x

# pull the AI/ML framework code base
rm -rf /aimlfw-dep
git clone "https://gerrit.o-ran-sc.org/r/aiml-fw/aimlfw-dep" /aimlfw-dep
cd /aimlfw-dep

bin/install_traininghost.sh 2>&1 | tee /tmp/install-thost-`echo $RANDOM`.log
