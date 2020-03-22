#
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

FROM ubuntu
## Be careful of Windows newlines

MAINTAINER "RIC"

LABEL name="Docker image for the RIC Robot Testing Framework"
LABEL usage="docker run -e ROBOT_TEST=<testname> -ti ric-robot"


ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV BUILDTIME=true

# Install Python, Pip, Robot framework, chromium, lighttpd web server

# temporarily removed chromium-browser and chromium-chromedriver as
# they've moved to snaps and we don't have snapd support in this container
# yet. This will break robot tests that depend on the browser, but we don't
# have those in the RIC at this point anyway.

RUN apt-get update \
    && apt-get install \
        --no-install-recommends \
        --assume-yes \
            dnsutils \
            git \
            gcc \
            libffi-dev \
            libssl-dev \
            lighttpd \
            make \
            net-tools \
            php  \
            php-cgi \
            python3-pip \
            python-dev \
            python-setuptools \
            python-redis \
            unzip \
            vim   \
            x11-utils \
            x11-xserver-utils \
            xvfb \
            xxd


RUN pip3 install robotframework==3.0.4 \
    && python --version

# Copy the robot code

COPY robot /var/opt/RIC/robot
COPY docker/ric-robot/red.xml /var/opt/RIC
COPY ric-python-utils /var/opt/RIC/ric-python-utils
COPY docker/ric-robot/runTags.sh /var/opt/RIC
COPY docker/ric-robot/setup.sh /var/opt/RIC
COPY docker/ric-robot/version.properties /var/opt/RIC
COPY docker/ric-robot/README.md /var/opt/RIC
COPY docker/ric-robot/lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY docker/ric-robot/authorization /etc/lighttpd/authorization

RUN chmod 777 /var/opt/RIC/setup.sh \
    && chmod 777 /var/opt/RIC/runTags.sh \
    && chmod 600 /var/opt/RIC/robot/assets/keys/*

RUN cd /var/opt/RIC \
    && ./setup.sh \
    && apt-get autoremove --assume-yes \
    && rm -rf /var/lib/apt/lists/*  \
    && apt-get clean

RUN mkdir /root/.kube

CMD ["lighttpd", "-D", "-f",  "/etc/lighttpd/lighttpd.conf"]



