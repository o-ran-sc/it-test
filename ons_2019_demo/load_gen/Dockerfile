#
# Copyright 2019 AT&T Intellectual Property
# Copyright 2019 Nokia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# sudo docker build -t load_gen .
# sudo docker run --rm -it load_gen

FROM ubuntu:16.04

# Install necessary packages
RUN apt-get update
RUN apt-get update && apt-get install -y gcc git make bash vim cmake g++ ksh
RUN apt-get install -y iputils-ping

# Install rmr in /usr/local
WORKDIR /home
RUN git clone https://gerrit.oran-osc.org/r/ric-plt/lib/rmr
RUN date; ls -al /usr/local/lib
RUN cd rmr; git checkout 6735f136906ce2; mkdir .build; cd .build; cmake ..; make install

# COPY code
RUN     mkdir /home/load_gen
COPY    ./ /home/load_gen
WORKDIR /home/load_gen

# Configure the receiver
RUN mkdir /usr/local/route
ENV C_INCLUDE_PATH=/usr/local/include
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# local.rt should be in the /usr/local/route directory mounted from the outside world.
# example for command line:  -v /demo/test/route:/usr/local/route
ENV RMR_SEED_RT=/usr/local/route/local.rt
# export RMR_SEED_RT=$HOME/global_rmr_files/global_rmr_routes.rt

RUN gcc load_gen.c -g -o load_gen -L /usr/local/lib -lrmr_nng -lnng -lpthread -lm

CMD ./load_gen
