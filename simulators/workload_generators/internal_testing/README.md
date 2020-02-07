# ======================================================================
#         Copyright (c) 2019 Nokia
#         Copyright (c) 2018-2019 AT&T Intellectual Property.

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
#    implied. See the License for the specific language governing 
#    permissions andlimitations under the License.
# ======================================================================

RIC workload_generator is a tool to test the performanc of xAPPs in RIC. It works by generating PDU messages at a specified rate, receiving the reply messages and caculating performance counters including but not limited to latency and throughput. RIC workload_generator currently consists of two applications: ric_generator and ric_receiver.

ric_generator sends PDU messages to the xAPP. ric_receiver receives messages and computes performance counters.

workload_generator test setup
============================================

                     -------------           -----------                     
                    |     RIC     |  t1     |           |<-- -      t1: sending time          
                    |  generator  |---->----|           |---> |     t2: receiving time
                    |             |         |           |   | |     latency = t2 - t1
                    |             |         |    xAPP   |   v ^
                    |             |         |           |   | |
                    |     RIC     |----<----|           |<--  |
                    |   receiver  |  t2     |           |----->
                    |             |         |           |
                     -------------           -----------


workload_generator directory structure
==============================================
ric_receiver: receiver executable
ric_generator: generator executable
run.sh: script to run workload_generator
back2back_test.sh: script to run workload_generator in back2back test mode (i.e generator is connected directly to receiver)
Makefile: Makefile to build the source
src: source code
report: detailed report generated after each run
PDU: example PDU files (.per)
seed.rt: RMR routing table
test.srt: RMR routing table for back to back testing

Build workload_generator using
=================================
1. Install RMR

2. after checking out workload_generator in directory (for example at /opt/workload_generator, and this readme will use this directory afterwards) do following
1) cd /opt/workload_generator
2) make

Configuration
===============================
1. Configure seed.rt on the workload generator machine.

workload_generator can run on baremetal servers, VMs and containers. 

workload_generator is built upon RMR. It reads the seed.rt file to figure out the destination of messages based on message types. Currently workload_generator only supports two message types numbered as 0 and 1, so in seed.rt you need to specify the destination IP address of the xAPP. For instance if your xAPP's ip address and port number are IP1:PORT1, the seed.rt would look like
"
newrt|start
     rte|0|IP1:PORT1
     rte|1|IP1:PORT1
newrt|end
"
   

2. Configure RMR routing information on the xAPP machine.

RIC xAPP which is built upon RMR can work with workload_generator. It requires that xAPP should know how to send the message back to the receiver. That means the routing table, either static like seed.rt or dynamic using rt service (please refer to RMR Manual if you need to know more about rt service) should include a route entry for reply message. For example, if the reply message has a type number 3 and the address of the workload_generator is IP2:PORT2. The routing table on xAPP machine (say it is named as xAPP_seed.rt) may look like

"
newrt|start
     rte|3|IP2:PORT2
newrt|end
"

3. Setup PDU files

You can put up to 2 PDU files in the PDU directory. By default, the workload generator reads pdu1.per and pdu2.per in this directory. 

Execution
=========================

1. run back to back test
/opt/workload_generator/back2back_test.sh

2. run xAPP test
/opt/workload_generator/run.sh [rate]

workload_generator stops automatically, after sending 1000 messages.
A report will be generated as /opt/workload_generator/report/xAPP_counters.csv

Uninstall workload_generator
=========================
cd /opt/workload_generator
make clean
