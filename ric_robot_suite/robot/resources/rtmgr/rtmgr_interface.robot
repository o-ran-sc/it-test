*** Settings ***
Documentation     The main interface for interacting with Routing Manager (RtMgr) . It handles low level stuff like managing the http request library and RtMgr required fields

Library           RequestsLibrary
Library           UUID

Resource          ../global_properties.robot
Resource          ../json_templater.robot

*** Variables ***
${RTMGR_BASE_PATH}        /v1
${RTMGR_ENDPOINT}     ${GLOBAL_RTMGR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_RTMGR_IP_ADDR}:${GLOBAL_RTMGR_SERVER_PORT}


*** Keywords ***
Run RtMgr Health Check
     [Documentation]    Runs RtMgr Health check
     ${data_path}=    Set Variable    ${RTMGR_BASE_PATH}/health
     ${resp}=    Run Keyword    Run RtMgr Get Request    ${data_path}


Run RtMgr Get Request
     [Documentation]    Runs RtMgr Get request
     [Arguments]    ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_RTMGR_USER}    ${GLOBAL_INJECTED_RTMGR_PASSWORD}
     ${session}=    Create Session      rtmgr      ${RTMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Get Request     rtmgr    ${data_path}     headers=${headers}
     Log    Received response from RtMgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}
