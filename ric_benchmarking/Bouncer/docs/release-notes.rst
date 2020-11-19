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

Release Notes
=============


This document provides the release notes for the Bronze Release of the Bouncer xAPP.

.. contents::
   :depth: 3
   :local:


Version history
---------------

+--------------------+--------------------+--------------------+--------------------+
| **Date**           | **Ver.**           | **Organization**   | **Comment**        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+
| 2020-11-18         | 1.0.0              |  HCL Technologies  | First draft        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+



Summary
-------

The Bronze release of the Bouncer xAPP demonstrates E2 interface interactions, persistent storage read-write, RMR and E2 Subscription handling. 
Bouncer xAPP uses its Bouncer E2SM (can be found at /src/xapp-asn/e2sm/) for ASN PDUs.


Release Data
------------

+--------------------------------------+--------------------------------------+
| **Project**                          | RAN Intelligent Controller           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Repo/commit-ID**                   | ric-app/benchmarking                 |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              |              Cherry                  |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     |      2020-11-18                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | open-source Bouncer xAPP             |
|                                      |                                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Components
----------

- *src/* contains the main source code. Under that directory :
  
  + *xapp.hpp, xapp.cc* is generic class which implements all the xAPP functionalities for xapp developer to pick and choose.
  + *xapp-utils/* contains generic classes for - persistent data management, configuration management, RMR send/receive etc.
  + *xapp-asn/* contains generic classes for generating/processing ASN1  E2AP and E2SM messages.
  + *xapp-mgmt/* contains code specific xapp management of subscriptions and received messages.

  
    

Limitations
-----------
- The Bouncer xAPP target RIC Benchmarking usecase to determine the latency/thoughput in the RAN-RIC interaction.

- The subscription process assumes, on sending subscription request results in valid subscription response and receiving the message indication. 

- The Bouncer xAPP address RIC Benchmarking usecase doesn't address A1 policy and SDL persistent data storage in particular.
