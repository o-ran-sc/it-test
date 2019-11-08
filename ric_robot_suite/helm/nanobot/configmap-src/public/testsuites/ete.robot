#   Copyright (c) 2019 AT&T Intellectual Property.
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

*** Settings ***
Documentation	  Executes the End To End Test cases
...
Library   Collections
Library   OperatingSystem

Resource         ../resources/appmgr/appmgr_interface.robot
Resource         ../resources/appmgr/negative_appmgr_tests.robot
Resource         ../resources/e2mgr/e2mgr_interface.robot
Resource         ../resources/dashboard/dashboard_interface.robot

*** Variables ***
${TEST_XAPPNAME}      ${GLOBAL_TEST_XAPP}
${TEST_NODE_B_NAME}   ${GLOBAL_TEST_NODEB_NAME}
${TEST_NODE_B_IP}     ${GLOBAL_TEST_NODEB_ADDRESS}
${TEST_NODE_B_PORT}   ${GLOBAL_TEST_NODEB_PORT}


*** Test Cases ***
Test XApp Manager Health
    [Tags]  etetests  xapptests
    Run AppMgr Health Check
Deploy An XApp    
    [Tags]  etetests  xapptests  intrusive
    Deploy XApp       ${TEST_XAPPNAME}
Retrieve The Deployed XApp
    [Tags]  etetests  xapptests
    Get XApp By Name  ${TEST_XAPPNAME}
Attempt To Deploy A Duplicate XApp
    [Tags]  etetests  xapptests  intrusive
    Deploy Duplicate XApp And Expect Error
Undeploy The Deployed XApp
    [Tags]  etetests  xapptests  intrusive
    Undeploy XApp     ${TEST_XAPPNAME}
Attempt To Undeploy An Already Undeployed XApp
    [Tags]  etetests  xapptests  intrusive
    Undeploy Nondeployed XApp And Expect Error
Attempt To Request A Nonexistent XApp
    [Tags]  etetests  xapptests  intrusive
    Request Nonexistent XApp And Expect Error
    
Setup RAN Via E2Mgr X2
    [Tags]   x2setup
    Run E2Mgr Setup NodeB X2   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Check NodeB Status    ${TEST_NODE_B_NAME}
Setup RAN Via E2Mgr Endc
    [Tags]   e2setup
    Run E2Mgr Setup NodeB Endc   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Check NodeB Status    ${TEST_NODE_B_NAME}
Get NodeB via E2Mgr
    [Tags]   e2setup   x2setup
    Run E2Mgr Get NodeB Request   ${TEST_NODE_B_NAME}
Get All NodeBs Via E2Mgr
    [Tags]   e2mgrtest   etetests   e2setup   x2setup   ci_tests
    Run E2Mgr Get All NodeBs Request
Setup RAN Via Dashboard Endc
    [Tags]   e2setup_dash
    Run Dashboard Setup NodeB Endc   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Dashboard Check NodeB Status    ${TEST_NODE_B_NAME}
Setup RAN Via Dashboard X2
    [Tags]   x2setup_dash
    Run Dashboard Setup NodeB X2    ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Dashboard Check NodeB Status    ${TEST_NODE_B_NAME}
Get NodeB via Dashboard
    [Tags]   e2setup_dash   x2setup_dash
    Run Dashboard Get NodeB Request   ${TEST_NODE_B_NAME}
Get All NodeBs via Dashboard
    [Tags]   e2setup_dash   x2setup_dash    ci_tests
    Run Dashboard Get All NodeBs Request
