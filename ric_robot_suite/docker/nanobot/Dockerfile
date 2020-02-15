#   Copyright (c) 2019 AT&T Intellectual Property.
#   Copyright (c) 2019 Nokia.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
FROM python:3-alpine

MAINTAINER "RIC"

LABEL name="Docker image for the RIC Robot Testing Framework"

ENV ROBOT_HOME="/robot"
ENV ROBOT_OPTIONS="-T -d /robot/log --console verbose -C off -P /robot/lib/python"
ENV KUBECONFIG="/robot/etc/kubernetes-admin-conf"
ENV PYTHONPATH="/robot/lib/python"
ENV RICPLT_NAMESPACE=ricplt
ENV RICPLT_RELEASE_NAME=ric-full
ENV RICPLT_COMPONENTS="a1mediator appmgr dbaas e2mgr e2term rtmgr"

RUN  mkdir -p /robot/lib/python

# ONAP eteutils
# we only need a few things from this so we won't install
# the whole thing.
# we could do this in a builder image but that seems execssive.
RUN apk update && apk add git
WORKDIR /tmp/
RUN git clone -b 3.0.1-ONAP https://gerrit.onap.org/r/testsuite/python-testing-utils.git
RUN cp /tmp/python-testing-utils/eteutils/StringTemplater.py /robot/lib/python
RUN cp /tmp/python-testing-utils/eteutils/UUID.py /robot/lib/python
RUN rm -rf /tmp/python-testing-utils
RUN apk del --purge  git

COPY ric-python-utils/ricutils/*.py /robot/lib/python/

#
# for the nanobot container, we only need a subset of the various support
# files/libraries, so we pick and choose what to copy..
RUN mkdir /robot/resources
COPY robot/resources/json_templater.robot /robot/resources
COPY robot/resources/a1mediator /robot/resources/a1mediator
COPY robot/resources/appmgr /robot/resources/appmgr
COPY robot/resources/dashboard /robot/resources/dashboard
COPY robot/resources/e2mgr /robot/resources/e2mgr
COPY robot/resources/e2sim /robot/resources/e2sim
COPY robot/resources/e2term /robot/resources/e2term
COPY robot/resources/ric /robot/resources/ric
COPY robot/resources/rnib /robot/resources/rnib
COPY robot/resources/rtmgr /robot/resources/rtmgr
COPY robot/resources/xapps /robot/resources/xapps
# this will actually be overlaid by the helm chart, but
# it's good to have the placeholder.
COPY robot/resources/global_properties.robot /robot/resources

RUN mkdir -p /robot/assets/templates
COPY robot/assets/templates/e2mgr_setup_nodeb.template /robot/assets/templates

RUN pip install UUID
RUN pip install kubernetes
RUN pip install redis
RUN pip install robotframework
RUN pip install robotframework-requests

RUN python -m compileall /robot/lib/python

WORKDIR /

CMD ["sleep", "9125d"]
