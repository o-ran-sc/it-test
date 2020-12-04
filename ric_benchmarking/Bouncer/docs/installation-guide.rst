# ==================================================================================
# Copyright (c) 2020 HCL Technologies Limited.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==================================================================================


Installation Guide
==================

.. contents::
   :depth: 3
   :local:

Abstract
--------

This document describes how to install the Bouncer xAPP. 

Version history

+--------------------+--------------------+--------------------+--------------------+
| **Date**           | **Ver.**           | **Organization**   | **Comment**        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+
| 2020-11-17         |1.0.0               |HCL Technologies    | Cherry Release     |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+


Introduction
------------

This document provides guidelines on how to install and configure the Bouncer xAPP in various environments/operating modes.
The audience of this document is assumed to have good knowledge in RIC Platform.


Preface
-------
The Bouncer xAPP can be run directly as a Linux binary, as a docker image, or in a pod in a Kubernetes environment.  The first
two can be used for testing/evaluation. The last option is how an xAPP is deployed in the RAN Intelligent Controller environment.
This document covers all three methods.  




Software Installation and Deployment
------------------------------------
The build process assumes a Linux environment with a gcc (>= 4.0)  compatible compiler and  has been tested on Ubuntu. For building docker images,
the Docker environment must be present in the system.


Build Process
~~~~~~~~~~~~~
The Bouncer xAPP can be either tested as a Linux binary or as a docker image.
   1. **Linux binary**: 
      The Bouncer xAPP may be compiled and invoked directly. Pre-requisite software packages that must be installed prior to compiling are documented in the Dockerfile in the repository. README file in the repository mentions the steps to be followed to make "b-xapp-main" binary.   
   
   2. **Docker Image**: From the root of the repository, run   *docker --no-cache build -t <image-name> ./* .


Deployment
~~~~~~~~~~
**Invoking  xAPP docker container directly** (not in RIC Kubernetes env.):
        xAPP descriptor(config-file.json) is available say under directory /home/ubuntu/config-file.json,  the docker image can be invoked as *docker run --net host -it --rm -v "/home/test-config:/opt/ric/config" --name  "B-xAPP" <image>*. 


