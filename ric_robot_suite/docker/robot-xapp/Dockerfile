# ==================================================================================
#       Copyright (c) 2018-2019 AT&T Intellectual Property.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# ==================================================================================

FROM alpine AS xapp-alpine-go-base

RUN apk update && apk add build-base autoconf automake libtool cmake ninja pkgconfig git go

WORKDIR /tmp
RUN git clone  https://gerrit.o-ran-sc.org/r/ric-plt/lib/rmr 
RUN mkdir /tmp/rmr/build
WORKDIR /tmp/rmr/build
RUN cmake .. -DPACK_EXTERNALS=1 -DDEV_PKG=1 
RUN make install

RUN mkdir /tmp/robot-xapp
COPY xapp/src /tmp/robot-xapp
WORKDIR /tmp/robot-xapp
ENV CGO_CFLAGS "-I /usr/local/include -L/usr/local/lib"
RUN go build robot-xapp.go

#
FROM alpine

COPY --from=xapp-alpine-go-base /usr/local/lib64/libnng.so /usr/lib/libnng.so.1
COPY --from=xapp-alpine-go-base /tmp/robot-xapp/robot-xapp /robot-xapp

COPY xapp/local.rt /local.rt
COPY xapp/config-file.json /config-file.json
COPY xapp/schema.json /schema.json

ENV DBAAS_SERVICE_HOST service-ricplt-dbaas-tcp.ricplt.svc.cluster.local
ENV DBAAS_SERVICE_PORT 6379
ENV DBAAS_PORT_6379_TCP_ADDR service-ricplt-dbaas-tcp.ricplt.svc.cluster.local
ENV DBAAS_PORT_6379_TCP_PORT 6379

ENV RMR_SEED_RT /local.rt

WORKDIR /
CMD [ "/robot-xapp", "-f", "/config-file.json" ]
