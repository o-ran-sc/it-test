*** Settings ***
Documentation     The main interface for interacting with Routing Manager (RtMgr) . It handles low level stuff like managing the http request library and RtMgr required fields


Library        String
Library        Collections
Library        XML
Library        RequestsLibrary
Library        UUID
Library        Process
Library        OperatingSystem



Resource          /robot/resources/global_properties.robot
Resource          /robot/resources/json_templater.robot
Resource          /robot/resources/ric/ric_utils.robot

Library           KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE}

*** Variables ***
${RTMGR_BASE_PATH}    /ric/v1/health/alive




*** Keywords ***
Run RtMgr Health Check
     [Documentation]    Runs RtMgr Health check
     ${data_path}=    Set Variable    ${RTMGR_BASE_PATH}
     ${resp}=    Run Keyword    Run RtMgr Get Request    ${data_path}


Run RtMgr Get Request
     [Documentation]    Runs RtMgr Get request
     [Arguments]    ${data_path}
     ${auth}=    Create List  ${GLOBAL_INJECTED_RTMGR_USER}    ${GLOBAL_INJECTED_RTMGR_PASSWORD}
     ${c} =      Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  rtmgr
     Log To Console     ${c}
     ${ctrl}  ${rtmgr1} =  Split String         ${c}       |
     ${name} =   Run Keyword    RetrievePodsForDeployment       ${rtmgr1}
     ${name1} =  Set Variable   ${name[0]}
     ${cType} =  Set Variable    Pod
     ${ctl} =   Run Keyword     ${ctype}        ${name1}
     ${podIP} =  Set Variable   ${ctl.status.pod_ip}
     ${RTMGR_ENDPOINT}= Set Variable    ${GLOBAL_RTMGR_SERVER_PROTOCOL}://${podIP}:${GLOBAL_RTMGR_SERVER_HTTP_PORT}
     ${session}=    Create Session      rtmgr      ${RTMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     rtmgr    ${data_path}     headers=${headers}
     Log    Received response from RtMgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}
