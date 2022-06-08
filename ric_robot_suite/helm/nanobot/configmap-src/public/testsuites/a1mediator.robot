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
Documentation   Tests for the A1 Mediator

Resource      /robot/resources/global_properties.robot
Resource      /robot/resources/a1mediator/a1mediator_interface.robot
#Resource      /robot/resources/appmgr/appmgr_interface.robot
Resource      /robot/resources/appmgr_interface.robot
Resource      /robot/resources/rtmgr_interface.robot
Resource      /robot/resources/e2mgr_interface.robot
Resource      /robot//resources/dashboard_interface.robot
Resource      /robot/resources/ric/ric_utils.robot
Resource      /robot/resources/negative_appmgr_tests.robot

Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library   KubernetesEntity  ricplt
Library   String
Library   KubernetesEntity    ${GLOBAL_RICPLT_NAMESPACE}
Library   UUID
Library   SSHLibrary

*** Variables ***
${POLICY_ID}    ${GLOBAL_A1MEDIATOR_POLICY_ID}
${TARGET_XAPP}  ${GLOBAL_A1MEDIATOR_TARGET_XAPP}
${TEST_XAPPNAME}      ${GLOBAL_TEST_XAPP}
${TEST_NODE_B_NAME}   ${GLOBAL_TEST_NODEB_NAME}
${TEST_NODE_B_IP}     ${GLOBAL_TEST_NODEB_ADDRESS}
${TEST_NODE_B_PORT}   ${GLOBAL_TEST_NODEB_PORT}
${ricxapp_POD_NAME}   ${GLOBAL_XAPP_NAMESPACE}-${GLOBAL_XAPP}
${TEST_XAPP_ONBOARDER}  ${GLOBAL_TEST_XAPP_ONBOARDER}

*** Test Cases ***
AppMgr Health Check
    [Tags]  Conformance
    Run AppMgr Health Check

E2Mgr Health Check
    [Tags]  Conformance
    Run E2Mgr Health Check

RtMgr Health Check
    [Tags]  Conformance
    Run RtMgr Health Check

Ensure helm version
    [Tags]  Conformance
    SSH to OS with ROOT
    ${written}=        Write         helm version
    ${output}=         Read          delay=0.5s
    Should Contain     ${output}           Version:"v3.6.1"

Deploy E2sim
    [Tags]  Conformance
    Sleep       20s
        ${written}=        Write    cd /root/test/ric_benchmarking/e2-interface/e2sim/e2sm_examples/kpm_e2sm/helm
    ${output}=         Read      delay=0.5s
        ${written}=        Write    helm install e2sim --namespace test .
    ${output}=         Read      delay=3s
    Should Contain     ${output}      deployed
    Sleep       20s

Test XApp Manager Health
    [Tags]  Conformance
    Run AppMgr Health Check

Ensure E2Sim is deployed and available
    [Tags]  Conformance
    ${ctrl} =   Run Keyword     deployment      ${Global_RAN_DEPLOYMENT}        ${Global_RAN_NAMESPACE}
    Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}

Ensure E2Setup procedure
    [Tags]  Conformance
    Keyword Ensure E2Setup procedure is successfully

Deploy Xapp
     ${input}   Write   cd /root/hw/init
     ${output}  Read    delay=0.5s
     ${input}   Write   docker run --rm -u 0 -it -d -p 8090:8080 -e DEBUG=1 -e STORAGE=local -e STORAGE_LOCAL_ROOTDIR=/charts -v $(pwd)/charts:/charts chartmuseum/chartmuseum:latest
     ${output}  Read    delay=0.5s
     ${input}   Write   export CHART_REPO_URL=http://0.0.0.0:8090
     ${output}  Read    delay=0.5s
     ${input}   Write   dms_cli onboard config-file.json schema.json
     ${output}  Read    delay=0.5s
     ${input}   Write   cd /root
     ${output}  Read    delay=0.5s
     ${input}   Write   curl -X GET http://0.0.0.0:8090/api/charts | jq .
     ${output}  Read    delay=0.5s
      ${written}=       Write     kubectl get svc -n ricplt | grep appmgr
     ${output}=         Read      delay=3s
     ${Log}=     convert To String       ${output}
     ${contain}=        Run Keyword And Return Status   Should Contain  ${Log}     ClusterIP
     ${appmgrip}=       Run Keyword If  ${contain}      Keyword check svc status        ${Log}
     Log To Console     ${appmgrip}
     Set Global Variable        ${appmgrip}
     ${input}   Write   dms_cli install hwxapp 1.0.0 ricxapp
     ${output}  Read    delay=0.5s
     ${input}   Write   curl -v -X POST "http://${appmgrip}:8080/ric/v1/register" -H "accept: application/json" -H "Content-Type: application/json" -d "@hw-register.json"
     ${output}=         Read      delay=3s
     Log To Console     ${output}
     Should Contain     ${output}     201 Created
     Sleep      80s

#Attempt To Undeploy An Already Undeployed XApp
#    [Tags]  Conformance
#    Undeploy Nondeployed XApp And Expect Error

#Attempt To Request A Nonexistent XApp
#    [Tags]  Conformance
#    Request Nonexistent XApp And Expect Error

Get All NodeBs Via E2Mgr
    [Tags]   Conformance
    ${log} =    Run E2Mgr Get All NodeBs Request
    FOR ${item} IN       @{log.json()}
        Log To Console  ${item}
        ${json}=  Set variable    ${item['globalNbId']["plmnId"]}
        Log To Console  ${json}
        Exit For Loop If        "${json}" == "${GLOBAL_PLMNID}"
        Log     ${json}
    END

Get All E2T Via E2Mgr
    [Tags]   Conformance
    ${log} =    Run E2Mgr Get All E2T Request
    Log To Console      ${log}

Create Policy
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${policyProperty} =      Create Dictionary
  ...                      type=string
  ...                      description=a message
  ${policyProperties} =    Create Dictionary
  ...                      message=${policyProperty}
  ${policyName} =          Generate UUID
  ${policyName} =          Convert To String         ${policyName}
  Set Suite Variable       ${policyName}
  ${resp} =                Create A1 Policy Type
  ...                      ${POLICY_ID}
  ...                      ${policyName}
  ...                      ${policyName}
  ...                      ${policyProperties}
  Should Be True           ${resp}

Policy Should Exist
  [Tags]  etetests  ci_tests  a1tests
  ${resp} =                Retrieve A1 Policy        ${POLICY_ID}
  Should Be True           ${resp}
  Should Be Equal          ${resp.json()}[name]      ${policyName}

Create Policy Instance
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${instanceName} =        Generate UUID
  ${instanceName} =        Convert To String         ${instanceName}
  Set Suite Variable       ${instanceName}
  ${instanceMessage} =     Generate UUID
  ${instanceMessage} =     Convert To String         ${instanceMessage}
  ${instanceProperties} =  Create Dictionary
  ...                      message=${instanceMessage}
  Set Suite Variable       ${instanceMessage}
  ${resp} =                Instantiate A1 Policy
  ...                      ${POLICY_ID}
  ...                      ${instanceName}
  ...                      ${instanceProperties}
  Should Be True           ${resp}

Policy Should Have Instances
  [Tags]  etetests  ci_tests  a1tests
  ${resp} =                Retrieve A1 Instance      ${POLICY_ID}
  Should Be True           ${resp}
  Should Not Be Empty      ${resp.json()}

Instance Should Exist
  [Tags]  etetests  ci_tests  a1tests
  Sleep         60s
  ${resp} =                Retrieve A1 Instance      ${POLICY_ID}     ${instanceName}
  Should Be True           ${resp}
  Should Be Equal          ${resp.json()}[message]   ${instanceMessage}

Instance Should Be IN EFFECT
  [Tags]  etetests  ci_tests  a1tests
  Wait Until Keyword Succeeds  3x  5s   Status Is IN EFFECT

#E2 setup procedure verification
RetriveLog From GNB
    [Tags]  Conformance
    Sleep       60s
    ${e2simpodname} =   Run Keyword     RetrievePodsForDeployment       ${Global_RAN_DEPLOYMENT}        namespace=${Global_RAN_NAMESPACE}
    Log To Console      ${e2simpodname}
    ${e2sim_pod1} =  Set Variable       ${e2simpodname[0]}
    Log To Console      ${e2sim_pod1}
    ${e2sim_log} =      Run keyword     RetrieveLogForPod       ${e2sim_pod1}   namespace=${Global_RAN_NAMESPACE}
    ${e2simstringLog}        Convert To String       ${e2sim_log}
    Set Global Variable         ${e2simstringLog}
    Set Global Variable         ${e2sim_log}

Verifying Setup Request on e2sim
    [Tags]  Conformance
    Log To Console      "Verified Subscription request message on e2sim"
    Should Match Regexp  ${e2simstringLog}      E2setupRequest

Verifying Setup Response on e2sim
    [Tags]  Conformance
    Log To Console      "Verified Subscription request message on e2sim"
    Should Match Regexp  ${e2simstringLog}      E2setupResponse

#Xapp verification
RetriveLog From XAPP
        [Tags]  etetests  xapptests  intrusive
        Sleep   20s
        ${podname} =    Run Keyword      RetrievePodsForDeployment      ${GLOBAL_XAPP_DEPLOYMENT}       namespace=ricxapp
        Log To Console  ${podname}
        ${ric_xapp_pod1} =      Set Variable    ${podname[0]}
        Log To Console  ${ric_xapp_pod1}
        ${log1} =       Run keyword      RetrieveLogForPod      ${ric_xapp_pod1}        namespace=ricxapp
        #Log To Console ${log1}
        ${stringLog}    Convert To String       ${log1}
        Set Global Variable     ${stringLog}
        Set Global Variable     ${log1}

Verifying Subscription Request From Xapp
   [Tags]  etetests  xapptests
   Sleep        10
   Log To Console      "Sending Subscription Message from Xapp"
   Should Match Regexp   ${stringLog}    Transmitted subscription request

Verifying Subscription Response From E2sim
   [Tags]  etetests  xapptests
    Log To Console      "Received Subscription Message from RAN"
    Should Match Regexp  ${stringLog}    Received subscription message of type = 12011

Verifying Ric Indication on Xapp
   [Tags]  etetests  xapptests
    Log To Console      "Received Indication Message from RAN"
    Should Match Regexp  ${stringLog}    Received Indication message of type = 12050

#Ric subscriptions on e2sim
Verifying Subscription request on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription request message on e2sim"
    Should Match Regexp  ${e2simstringLog}      subscriptionRequest

Verifying Subscription response on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription response message on e2sim"
    Should Match Regexp  ${e2simstringLog}      subscriptionResponse

Verifying RIC Indication on e2sim
    [Tags]  Functional
    Log To Console      "Verified RIC Indication message on e2sim"
    Should Match Regexp  ${e2simstringLog}      RIC Indication Generated

Delete Policy Instance
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${resp} =                Delete A1 Instance       ${POLICY_ID}      ${instanceName}
  Should Be True           ${resp}

Instance Should Not Exist
  [Tags]  etetests  ci_tests  a1tests
  Wait Until Keyword Succeeds  3x  5s               Instance Has Been Deleted

Delete Policy
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${resp} =                Delete A1 Policy         ${POLICY_ID}
  Should Be True           ${resp}

Policy Should Not Exist
  [Tags]  etetests  ci_tests  a1tests
  Wait Until Keyword Succeeds  3x  5s               Policy Has Been Deleted

Undeploy xapp
    [Tags]  Conformance
        ${written}=        Write    dms_cli uninstall hwxapp ricxapp
    ${output}=         Read      delay=5s
    Should Contain     ${output}     status: OK

Undeploy E2SIM
    [Tags]  Conformance
    ${written}=             Write           helm uninstall e2sim -n test
    ${output}=              Read            delay=5s
    Should Contain          ${output}       uninstalled
    Sleep                   10s

*** Keywords ***

SSH to OS with ROOT
    Open Connection   ${GLOBAL_CLUSTER_IP}
    ${output} =       Login           ubuntu            ubuntu
    Should Contain    ${output}       Last login
    Start Command     pwd
    ${pwd} =          Read Command Output
    Should Be Equal   ${pwd}     /home/ubuntu
    ${written}=       Write      sudo su -
    ${output}=        Read       delay=0.5s
    Should Contain    ${output}      [sudo] password for ubuntu:
    ${written}=       Write      ubuntu
    ${output}=        Read       delay=0.5s
    Should Contain    ${output}        root@


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
        ${checkNosubreq} =      Set Variable    1


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
        ${checkNosubres} =      Set Variable    1


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
        ${checkNoindication} =  Set Variable    1

Status Is IN EFFECT
  ${resp} =                Retrieve A1 Instance Status
  ...                      ${POLICY_ID}
  ...                      ${instanceName}
  Should Be True           ${resp}
  Should Be Equal          ${resp.json()}[instance_status]    IN EFFECT

Instance Has Been Deleted
  ${resp} =                   Retrieve A1 Instance
  ...                         ${POLICY_ID}
  ...                         ${instanceName}
  Should Be Equal As Strings  ${resp.status_code}  404

Policy Has Been Deleted
  ${resp} =                   Retrieve A1 Policy   ${POLICY_ID}
  Should Be Equal As Strings  ${resp.status_code}  404

Keyword check svc status
        [Arguments]     ${linematch}
        ${message} =      Split String     ${linematch}
        ${get} =            Get From List    ${message}    2
        [Return]        ${get}

Keyword Ensure E2Setup procedure is successfully
    Sleep       30s
    ${data_path} =    Set Variable             ${E2MGR_BASE_PATH}/states
    ${resp} =         Run E2Mgr GET Request    ${data_path}
    ${resp_text} =    Convert To String        ${resp.json()}
    Log to console    ${resp_text}
    Should Match Regexp      ${resp_text}                  CONNECTED
