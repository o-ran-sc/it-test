FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    python-pip \
    virtualenv

COPY . /a1_server

CMD /a1_server/run_server
