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
Resource         /robot/resources/submgr_interface.robot
Resource         /robot/resources/deployment_setup.robot

Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library   KubernetesEntity  ricplt
Library   String

*** Variables ***
${TEST_XAPPNAME}      ${GLOBAL_TEST_XAPP}
${TEST_NODE_B_NAME}   ${GLOBAL_TEST_NODEB_NAME}
${TEST_NODE_B_IP}     ${GLOBAL_TEST_NODEB_ADDRESS}
${TEST_NODE_B_PORT}   ${GLOBAL_TEST_NODEB_PORT}
${ricxapp_POD_NAME}   ${GLOBAL_XAPP_NAMESPACE}-${GLOBAL_XAPP}
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
        ${checkNocontrol} =     Set Variable    1


*** Test Cases ***
Ensure helm version
    [Tags]  Functional
     SSH to OS with ROOT
     Keyword Ensure Helm3 is installed

#Deploy RIC Components
    #[Tags]  Functional
    #Log To Console      "Deploy Componets
    #Keyword Deploy RIC Components

Deploy E2sim
    [Tags]  Functional
    ${output}=  Keyword Deploy E2SIM
    Log To Console      ${output}

Test XApp Manager Health
    [Tags]  Functional
    Run AppMgr Health Check

Ensure E2Sim is deployed and available
    [Tags]  Functional
    ${ctrl} =   Run Keyword     deployment      ${Global_RAN_DEPLOYMENT}        ${Global_RAN_NAMESPACE}
    Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}

Ensure E2Setup procedure
    [Tags]  Functional
    Keyword Ensure E2Setup procedure is successfully

Deploy Xapp
    [Tags]  Functional
    Keyword Deploy Bouncer
    Sleep       170s

Ensure Xapp is Deployed And Available
    [Tags]  Functional
    Keyword Ensure Bouncer is deployed and available

Attempt To Undeploy An Already Undeployed XApp
    [Tags]  Functional
    Undeploy Nondeployed XApp And Expect Error

Attempt To Request A Nonexistent XApp
    [Tags]  Functional
    Request Nonexistent XApp And Expect Error


Get All NodeBs Via E2Mgr
    [Tags]  Functional
    ${log} =    Run E2Mgr Get All NodeBs Request
    FOR ${item}  IN      @{log.json()}
        Log To Console  ${item}
        ${json}=  Set variable    ${item['globalNbId']["plmnId"]}
        Log To Console  ${json}
        #Should Be Equal        ${json} ${GLOBAL_PLMNID}
        Exit For Loop If        "${json}" == "${GLOBAL_PLMNID}"
        Log     ${json}
    END

Get All E2T Via E2Mgr
    [Tags]   Functional
    ${log} =    Run E2Mgr Get All E2T Request
    Log To Console      ${log}

RetriveLog From GNB
    Sleep       80s
    [Tags]  Functional
    ${e2simpodname} =   Run Keyword     RetrievePodsForDeployment       ${Global_RAN_DEPLOYMENT}        namespace=${Global_RAN_NAMESPACE}
    Log To Console      ${e2simpodname}
    ${e2sim_pod1} =  Set Variable       ${e2simpodname[0]}
    Log To Console      ${e2sim_pod1}
    ${e2sim_log} =      Run keyword     RetrieveLogForPod       ${e2sim_pod1}   namespace=${Global_RAN_NAMESPACE}
    ${e2simstringLog}        Convert To String       ${e2sim_log}
    Set Global Variable         ${e2simstringLog}
    Set Global Variable         ${e2sim_log}

Verifying Setup Request on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription delete request message on e2sim"
    Should Match Regexp  ${e2simstringLog}      E2setupRequest

Verifying Setup Response on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription delete request message on e2sim"
    Should Match Regexp  ${e2simstringLog}      E2setupResponse

RetriveLog From XAPP
    Sleep       30s
    [Tags]  Functional
    ${podname} =        Run Keyword     RetrievePodsForDeployment       ${GLOBAL_XAPP_DEPLOYMENT}      namespace=ricxapp
    Log To Console      ${podname}
    ${ric_xapp_pod1} =  Set Variable    ${podname[0]}
    Log To Console      ${ric_xapp_pod1}
    ${log1} =           Run keyword     RetrieveLogForPod       ${ric_xapp_pod1}       namespace=ricxapp
    #Log To Console     ${log1}
    ${stringLog}        Convert To String       ${log1}
    Set Global Variable         ${stringLog}
    Set Global Variable         ${log1}

Verifying Subscription Request From Xapp
   [Tags]  Functional
   Log To Console      "Sending Subscription Message from Xapp"
   Should Match Regexp   ${stringLog}   subscription request

Verifying Subscription Response From E2sim
   [Tags]  Functional
    Log To Console      "Received Subscription Message from RAN"
    Should Match Regexp  ${stringLog}   Recieved REST subscription response

Verifying Ric Indication on Xapp
   [Tags]  Functional
    Log To Console      "Received Indication Message from RAN"
    Should Match Regexp  ${stringLog}    Received indication message of type = 12050

Verifying Control message on Xapp
   [Tags]  Functional
    Log To Console      "Verified Control message from Xapp"
    Should Match Regexp  ${stringLog}   Bouncer Control OK

Verifying Xapp Event Intance ID on Xapp
   [Tags]  Functional
    Log To Console      "Verified Xapp Event Intance ID on Xapp"
    Should Match Regexp  ${stringLog}   "XappEventInstanceId":12345

Verifying E2 Event Intance ID on Xapp
   [Tags]  Functional
    Log To Console      "Verified E2 Event Intance ID on Xapp"
    Should Match Regexp  ${stringLog}   "E2EventInstanceId":1

Verifying Subscription delete on Xapp
   [Tags]  Functional
    Log To Console      "Verified Subscription delete message from Xapp"
    Should Match Regexp  ${stringLog}   Deleted: true


Verifying Subscription request on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription request message on e2sim"
    Should Match Regexp  ${e2simstringLog}      subscriptionRequest

Verifying Subscription response on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription response message on e2sim"
    Should Match Regexp  ${e2simstringLog}      subscriptionResponse

Verifying Subscription delete request on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription delete request message on e2sim"
    Should Match Regexp  ${e2simstringLog}      subscriptionDeleteRequest

Verifying Subscription delete response on e2sim
    [Tags]  Functional
    Log To Console      "Verified Subscription delete response message on e2sim"
    Should Match Regexp  ${e2simstringLog}      subscriptionDeleteResponse

Verifying deleted succsessfully on e2sim
    [Tags]  Functional
    Log To Console      "Verified deleted succsessfully  message on e2sim"
    Should Match Regexp  ${e2simstringLog}      deleted succsessfully

Undeploy Xapp
   [Tags]  Functional
   Keyword Undeploy Bouncer

Undeploy E2sim
    [Tags]  Functional
    Keyword Undeploy E2SIM
