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
Documentation     Executes the End To End Test cases
...
Resource         /robot/resources/appmgr_interface.robot
Resource         /robot/resources/negative_appmgr_tests.robot
Resource         /robot/resources/e2mgr_interface.robot
Resource         /robot//resources/dashboard_interface.robot
Resource         /robot/resources/global_properties.robot
Resource         /robot/resources/ric/ric_utils.robot
Resource         /robot/resources/e2term_interface.robot

Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library   KubernetesEntity  ricplt
Library   SDLWrapper    False
Library   String

*** Variables ***
${TEST_XAPPNAME}      ${GLOBAL_TEST_XAPP}
${TEST_NODE_B_NAME}   ${GLOBAL_TEST_NODEB_NAME}
${TEST_NODE_B_IP}     ${GLOBAL_TEST_NODEB_ADDRESS}
${TEST_NODE_B_PORT}   ${GLOBAL_TEST_NODEB_PORT}
#${ricxapp_POD_NAME}   ${GLOBAL_XAPP_NAMESPACE}-${GLOBAL_XAPP}
${TEST_XAPP_ONBOARDER}  ${GLOBAL_TEST_XAPP_ONBOARDER}

*** Keywords ***
Keyword Check subreq
        [Arguments]     ${linematch}
        ${result_subreq} =      Set variable    1
        Set Global Variable     ${result_subreq}
        ${messages} =       Split String     ${linematch}     ,
        Log To Console      ${messages}
        ${ts} =             Get From List    ${messages}     0
        Log To Console      ${ts}
        ${timestamp1} =      Split String    ${ts}    :
        ${timestampval1} =   Get From List   ${timestamp1}   1
        Log To Console       ${timestampval1}
        Set Global Variable     ${timestampval1}

Keyword Check No subreq
        ${aaa} =        Set Variable    1


Keyword Check subres
        [Arguments]     ${linematch}
        ${result_subres} =      Set variable    1
        Set Global Variable     ${result_subres}
        ${messages1} =      Split String     ${linematch}     ,
        Log To Console      ${messages1}
        ${ts1} =            Get From List    ${messages1}    0
        Log To Console      ${ts1}
        ${timestamp2} =      Split String    ${ts1}   :
        ${timestampval2} =   Get From List   ${timestamp2}   1
        Log To Console       ${timestampval2}
        Set Global Variable     ${timestampval2}

Keyword Check No subres
        ${aaa} =        Set Variable    1


Keyword Check IndMessage
        [Arguments]     ${linematch}
        ${result_Ind1} =        Set Variable    1
        Set Global Variable     ${result_Ind1}
        ${messages} =       Split String     ${linematch}       :
        Log To Console      ${messages}
        ${timestampval_ind1} =             Get From List    ${messages}     1
        Log To Console       ${timestampval_ind1}
        Set Global Variable     ${timestampval_ind1}
        Append To List    ${IndMessgList}    ${timestampval_ind1}

Keyword Check No IndMsg
        ${aaa} =        Set Variable    1

Keyword Check ControlMsg
        [Arguments]     ${linematch}
        ${result_ctrl1} =       Set Variable    1
        Set Global Variable     ${result_ctrl1}
        ${messages1} =      Split String     ${linematch}       :
        Log To Console      ${messages1}
        ${timestampval_ctrl1} =            Get From List    ${messages1}    1
        Log To Console       ${timestampval_ctrl1}
        Set Global Variable     ${timestampval_ctrl1}
        Append To List    ${ContMessgList}    ${timestampval_ctrl1}

Keyword Check No CtrlMsg
        ${aaa} =        Set Variable    1


*** Test Cases ***
Test XApp Manager Health
    [Tags]  etetests  xapptests
    Run AppMgr Health Check


Ensure RIC Xapp Onboarder is deployed and available
    [Tags]  etetests  xapptests
    ${controllerName} = Set Variable    ${GLOBAL_TEST_XAPP_ONBOARDER}
    ${cType}  ${name} = Split String  ${controllerName} |
    Log To Console      ${cType}
    ${ctrl} =  Run Keyword      ${cType}        ${name}
    Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}


Get All NodeBs Via E2Mgr
    [Tags]   e2mgrtest   etetests   e2setup   x2setup
    ${log} =    Run E2Mgr Get All NodeBs Request
    FOR ${item} IN      @{log.json()}
        Log To Console  ${item}
        ${json}=  Set variable    ${item['globalNbId']["plmnId"]}
        Should Be Equal ${json} ${GLOBAL_PLMNID}
    END

Get All E2T Via E2Mgr
    [Tags]   e2mgrtests   etetests   e2setup   x2setup
    ${log} =    Run E2Mgr Get All E2T Request
    Log To Console      ${log}

Get NodeB Request Via E2Mgr
    [Tags]   e2mgrtests   etetests   e2setup   x2setup
    Run E2Mgr Get NodeB Request ${GLOBAL_GNBID}


RetriveLog From XAPP
    [Tags]  etetests  xapptests  intrusive
    ${podname} =        Run Keyword     RetrievePodsForDeployment      ${GLOBAL_XAPPKPIMON_DEPLOYMENT}  namespace=${GLOBAL_XAPP_NAMESPACE}
    Log To Console      ${podname}
    ${ric_xapp_pod1} =  Set Variable    ${podname[0]}
    Log To Console      ${ric_xapp_pod1}
    ${log1} =           Run keyword     RetrieveLogForPod       ${ric_xapp_pod1}       namespace=${GLOBAL_XAPP_NAMESPACE}
    ${stringLog}        Convert To String       ${log1}
    Set Global Variable         ${stringLog}
    Set Global Variable         ${log1}

Verifying Subscription Request From Xapp
   [Tags]  etetests  xapptests
   #Sleep       90000
    Log To Console      "Sending Subscription Message from Xapp"
    Should Match Regexp ${stringLog}    The RMR message to be sent is 12010

Verifying Subscription Response From E2sim
   [Tags]  etetests  xapptests
    Log To Console      "Received Subscription Message from RAN"
    Should Match Regexp ${stringLog}    Received message type: 12011

Verifying Ric Indication on Xapp
   [Tags]  etetests  xapptests
    #Sleep      20000
    Log To Console      "Received Indication Message from RAN"
    Should Match Regexp ${stringLog}    Received message type: 12050

Verifying ueid from dbass by using sdl
   [Tags]  etetests  xapptests
   Log To Console       "Verifying Healthcheck of dbass"
   ${log} =     Run Keyword     healthcheck
   Log To Console       ${log}
   Log To Console       "Received ueid from dbass from sdl"
   ${Allueid} = Run Keyword     find and get    kpimon  {TS-UE-metrics} false
   Log To Console       ${Allueid}
   Log To Console       "############ printing the ueid's ###########"
   Log To Console       ${Allueid.keys()}
   ${ueid_check} =      Set Variable    0
   ${ueid} =    Set Variable    ${None}
   FOR  ${key}  IN      @{Allueid.keys()}
        ${ueid_check} = Set Variable    1
        ${ueid} =       Run Keyword     get     kpimon  ${key}  false
        Log To Console  ${key}
        Log To Console  "--------------ueid---------------"
        Log To Console  ${ueid}

   END
   Should Not Be Equal  ${ueid} ${None}
   Should Match ${ueid_check}   1

Verifying cellid from dbass by using sdl
   [Tags]  etetests  xapptests
   Log To Console       "Verifying Healthcheck of dbass"
   ${log} =     Run Keyword     healthcheck
   Log To Console       ${log}
   Log To Console       "Received cellid from dbass from sdl"
   ${Allcellid} =       Run Keyword     find and get    kpimon  {TS-cell-metrics}       false
   Log To Console       ${Allcellid}
   Log To Console       "############ printing the cellid's ###########"
   Log To Console       ${Allcellid.keys()}
   ${cellid_check} =    Set Variable    0
   ${cellid} =  Set Variable    ${None}
   FOR  ${key}  IN      @{Allcellid.keys()}
        ${cellid_check} =       Set Variable    1
        ${cellid} =       Run Keyword     get     kpimon  ${key}  false
        Log To Console  ${key}
        Log To Console  "--------------cellid---------------"
        Log To Console  ${cellid}
   END
   Should Not Be Equal  ${cellid}       ${None}
   Should Match ${cellid_check} 1
