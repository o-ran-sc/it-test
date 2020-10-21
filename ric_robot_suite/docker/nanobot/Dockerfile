   #   Copyright (c)  2019 AT&T Intellectual Property. 
   #   Copyright (c)  2020 HCL Technologies. 
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
 
   FROM python:3-alpine AS nanobot-build 
 
   RUN apk update && apk add git build-base libffi-dev libxml2 libxslt libxml2-dev libxslt-dev openssl-dev 
 
 
   RUN pip install kubernetes 
   RUN pip install redis 
   RUN pip install asyncio 
   RUN pip install websockets 
   RUN pip install robotframework 
   RUN pip install robotframework-requests 
   RUN pip install robotframework-ncclient 
   RUN pip install UUID 
   WORKDIR /tmp/ 
   RUN git clone -b 3.0.1-ONAP https://gerrit.onap.org/r/testsuite/python-testing-utils.git 
 
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
   ENV DBAAS_SERVICE_HOST=service-ricplt-dbaas-tcp.ricplt.svc.cluster.local 
   ENV DBAAS_SERVICE_PORT=6379 
   RUN apk update && apk add libxslt 
   COPY --from=nanobot-build /usr/local/lib/python3.8 /usr/local/lib/python3.8 
   COPY --from=nanobot-build /usr/local/bin/robot /usr/local/bin 
 
   RUN apk add wget 
   RUN  mkdir -p /robot/lib/python 
   WORKDIR ric-python-utils/ricutils 
   RUN wget -o SDLWrapper.py "https://gerrit.o-ran-sc.org/r/gitweb?p=ric-plt/xapp-frame-py.git;a=blob_plain;f=ricxappframe/xapp_sdl.py" 
   # ONAP eteutils 
   # we only need a few things from this so we won't install the whole thing. 
   COPY --from=nanobot-build /tmp/python-testing-utils/eteutils/StringTemplater.py /robot/lib/python 
   COPY --from=nanobot-build /tmp/python-testing-utils/eteutils/UUID.py /robot/lib/python 
   COPY ric-python-utils/ricutils/*.py /robot/lib/python/ 
 
   #rmr probe for e2term 
    RUN apk update && apk add git gcc linux-headers libc-dev cmake pkgconfig make 
    RUN pip install msgpack 
    RUN python3 -m pip install ricsdl 
    RUN apk add curl 
    RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.2/bin/linux/amd64/kubectl 
    RUN chmod +x ./kubectl 
    RUN mv ./kubectl /usr/local/bin/kubectl 
 
 
    WORKDIR / 
    RUN apk add cmake git gcc 
    RUN git clone https://gerrit.o-ran-sc.org/r/ric-plt/lib/rmr && \ 
         cd rmr && \ 
         mkdir build && \ 
         cd build && \ 
         cmake -DPACK_EXTERNALS=1 -DDEV_PKG=1 .. && \ 
         make install 
    RUN  mkdir -p /opt/e2 
    RUN  cp /rmr/build/src/support/rmr_probe /opt/e2/ 
 
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
   COPY robot/resources/o1mediator /robot/resources/o1mediator 
   COPY robot/resources/ric /robot/resources/ric 
   COPY robot/resources/rnib /robot/resources/rnib 
   COPY robot/resources/rtmgr /robot/resources/rtmgr 
   COPY robot/resources/xapps /robot/resources/xapps 
   # this will actually be overlaid by the helm chart, but 
   # it's good to have the placeholder. 
   COPY robot/resources/global_properties.robot /robot/resources 
 
   RUN mkdir -p /robot/assets/templates 
   COPY robot/assets/templates/e2mgr_setup_nodeb.template /robot/assets/templates 
 
   RUN python -m compileall /robot/lib/python 
 
   WORKDIR / 
 
   CMD ["sleep", "9125d"] 


