#   Copyright (c) 2019 AT&T Intellectual Property.
#   Copyright (c) 2020 HCL Technologies Limited. 
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
Documentation     Executes the End To End Test cases
...
Resource         /robot/resources/appmgr_interface.robot
Resource         /robot/resources/negative_appmgr_tests.robot
Resource         /robot/resources/e2mgr_interface.robot
Resource         /robot//resources/dashboard_interface.robot
Resource         /robot/resources/global_properties.robot
Resource         /robot/resources/ric/ric_utils.robot
 
 
Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library   KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE}
Library   String
*** Variables ***
${TEST_XAPPNAME}      ${GLOBAL_TEST_XAPP}
${TEST_NODE_B_NAME}   ${GLOBAL_TEST_NODEB_NAME}
${TEST_NODE_B_IP}     ${GLOBAL_TEST_NODEB_ADDRESS}
${TEST_NODE_B_PORT}   ${GLOBAL_TEST_NODEB_PORT}
${ricxapp_POD_NAME}   ${GLOBAL_XAPP_NAMESPACE}-${GLOBAL_XAPP}
${TEST_XAPP_ONBOARDER}  ${GLOBAL_TEST_XAPP_ONBOARDER}
*** Test Cases ***
Test XApp Manager Health
    [Tags]  etetests  xapptests
    Run AppMgr Health Check
 
Ensure RIC Xapp Onboarder is deployed and available
    [Tags]  etetests  xapptests
    ${controllerName} = Set Variable    ${GLOBAL_TEST_XAPP_ONBOARDER}
    ${cType}  ${name} = split String  ${controllerName} |
    ${ctrl} =  Run Keyword      ${cType}        ${name}
    Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}

Ensure E2Sim is deployed and available
    [Tags]  etetests  xapptests
    ${ctrl} =   Run Keyword     deployment      ${Global_RAN_DEPLOYMENT}        ${Global_RAN_NAMESPACE}
    Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}
 
#Before doing this kept configfile.json in to shared path and create url
#onboard the xapp using onboard link
Deploy An XApp
    [Tags]  etetests  xapptests  intrusive
    Deploy XApp       ${TEST_XAPPNAME}
 
Retrieve The Deployed XApp
    [Tags]  etetests  xapptests
    Get XApp By Name  ${TEST_XAPPNAME}
 
Attempt To Deploy A Duplicate XApp
    [Tags]  etetests  xapptests  intrusive
    Deploy Duplicate XApp And Expect Error
 
Attempt To Undeploy An Already Undeployed XApp
    [Tags]  etetests  xapptests  intrusive
    Undeploy Nondeployed XApp And Expect Error
 
Attempt To Request A Nonexistent XApp
    [Tags]  etetests  xapptests  intrusive
    Request Nonexistent XApp And Expect Error
 
Get All NodeBs Via E2Mgr
    [Tags]   e2mgrtest   etetests   e2setup   x2setup   ci_tests
    Run E2Mgr Get All NodeBs Request

# disabled below 3 testcases due to x2 setup related APIs deprecated
# webservices interface specification deprecated
#Setup RAN Via E2Mgr X2
#[Tags]   disabled
##[Tags]   e2setup   x2setup
#Run E2Mgr Setup NodeB X2   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
#Wait Until Keyword Succeeds   20s   5s   Check NodeB Status    ${TEST_NODE_B_NAME}
#Setup RAN Via E2Mgr Endc
#[Tags]   disabled
##[Tags]   e2setup   x2setup
#Run E2Mgr Setup NodeB Endc   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
#Wait Until Keyword Succeeds   20s   5s   Check NodeB Status    ${TEST_NODE_B_NAME}
#Get NodeB via E2Mgr
#[Tags]   disabled
#[Tags]   e2setup   x2setup
#Run E2Mgr Get NodeB Request   ${TEST_NODE_B_NAME}

###Not tested dashboard related
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
###############
Verifying E2setup Request From E2sim
    [Tags]  etetests  xapptests
    ${ric_xapp_pod} =   Run Keyword     RetrievePodsForDeployment       ${ricxapp_POD_NAME}     ${GLOBAL_XAPP_NAMESPACE}
    ${ric_xapp_pod1} =  Set Variable    ${ric_xapp_pod[0]}
    Set Global Variable ${ric_xapp_pod1}
    ${e2simpod} =       Run Keyword     RetrievePodsForDeployment       ${Global_RAN_DEPLOYMENT}        ${Global_RAN_NAMESPACE}
    ${e2simpod1} =      Set Variable    ${e2simpod[0]}
    Set Global Variable ${e2simpod1}
    ${setupres_recv} =  Run     kubectl logs ${e2simpod1} -n ${Global_RAN_NAMESPACE} | grep "SETUP"
    Log To Console      Subscription Received: ${setupres_recv}
    Should Match Regexp         ${setupres_recv}       Received SETUP-RESPONSE-SUCCESS

Verifying Subscription Request From Xapp
   [Tags]  etetests  xapptests
   sleep        100
   Log To Console      "Sending Subscription Message from Xapp"
   ${subname} =        Run     kubectl logs ${ric_xapp_pod1} -n ${GLOBAL_XAPP_NAMESPACE} | grep "Subscription SUCCESSFUL"
   Should Match Regexp         ${subname}      Subscription.*SUCCESSFUL
   ${sub_sent} =       Run     kubectl logs ${ric_xapp_pod1} -n ${GLOBAL_XAPP_NAMESPACE} | grep "Message Sent: RMR State = RMR_OK"
   Log To Console      Subscription Sent: ${sub_sent}
   Should Match Regexp         ${sub_sent}     RMR_OK
 
Verifying Subscription Response From E2sim
   [Tags]  etetests  xapptests
   Log To Console      "Receiving Subscription Message from RAN"
   ${subrcv} =  Run     kubectl logs ${ric_xapp_pod1} -n ${GLOBAL_XAPP_NAMESPACE} | grep "Received subscription message of type"
   Log To Console       Subscription Received: ${subrcv}
   Should Match Regexp         ${subrcv}       Received subscription message
 
Verifying Ric Indication From E2sim
   [Tags]  etetests  xapptests
   Log To Console      "Sending Indication Message from E2sim"
   ${indication_sent} =        Run      kubectl logs ${e2simpod1} -n ${Global_RAN_NAMESPACE} | grep "Indication"
   Log To Console       Sending Indication: ${indication_sent}
   Should Match Regexp         ${indication_sent}      sending RIC Indication
 
Verifying Ric Indication on Xapp
   [Tags]  etetests  xapptests
   Log To Console      "Received Indication Message from RAN"
   ${indication_rcv} =  Run     kubectl logs ${ric_xapp_pod1} -n ${GLOBAL_XAPP_NAMESPACE} | grep "Received indication message of type"
   Log To Console       Received Indication: ${indication_rcv}
   Should Match Regexp         ${indication_rcv}       Received indication message
 
Undeploy The Deployed XApp
    [Tags]  etetests  xapptests  intrusive
    Undeploy XApp     ${TEST_XAPPNAME}

