*** Settings ***
Documentation     The main interface for interacting with RIC Applications Manager (AppMgr) . It handles low level stuff like managing the http request library and AppMgr required fields
Library           RequestsLibrary
Library           UUID

Resource          ../global_properties.robot
Resource          ../json_templater.robot

*** Variables ***
${APPMGR_BASE_PATH}        /ric/v1/xapps/   
${APPMGR_ENDPOINT}     ${GLOBAL_APPMGR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_APPMGR_IP_ADDR}:${GLOBAL_APPMGR_SERVER_PORT}
${APPMGR_CREATE_XAPP_TEMPLATE}     robot/assets/templates/appmgr_create_xapp.template


*** Keywords ***
Run AppMgr Health Check
     [Documentation]    Runs AppMgr Health check
     Run Keyword   Run AppMgr Get All Request

Run AppMgr Get All Request 
     [Documentation]    Runs AppMgr Get List of Xapps Request
     ${resp}=    Run Keyword    Run AppMgr Get Request    ${APPMGR_BASE_PATH}
     Should Be Equal As Strings        ${resp.status_code}     200

Run AppMgr Get By XappName and XappId
     [documentation]     Get Xapp data by XappName and XappId
     [Arguments]      ${xapp_name}  ${xapp_id}
     ${data_path}=    Set Variable    ${APPMGR_BASE_PATH}${xapp_name}/${xapp_id}
     ${resp}=   Run Keyword   Run AppMgr Get Request    ${data_path}
     Should Be Equal As Strings        ${resp.status_code}     200

Run AppMgr Get By XappName 
     [documentation]     Get List of Xapp data by XappName
     [Arguments]      ${xapp_name}
     ${data_path}=    Set Variable    ${APPMGR_BASE_PATH}${xapp_name}
     ${resp}=   Run Keyword   Run AppMgr Get Request    ${data_path}
     Should Be Equal As Strings        ${resp.status_code}     200

Run Create Xapp
     [documentation]     Create Xapp 
     [Arguments]      ${xapp_name}   ${xapp_id}  
     ${data_path}=    Set Variable    ${APPMGR_BASE_PATH}
     ${dict}=    Create Dictionary    xapp_name=${xapp_name}    xapp_id=${xapp_id}
     ${data}=   Fill JSON Template File    ${APPMGR_CREATE_XAPP_TEMPLATE}    ${dict}
     ${auth}=  Create List  ${GLOBAL_INJECTED_APPMGR_USER}    ${GLOBAL_INJECTED_APPMGR_PASSWORD}
     ${session}=    Create Session      appmgr      ${APPMGR_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Post Request     appmgr     ${data_path}     data=${data}   headers=${headers}
     Log    Received response from AppMgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}


Run AppMgr Get Request
     [Documentation]    Runs AppMgr Get request
     [Arguments]    ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_APPMGR_USER}    ${GLOBAL_INJECTED_APPMGR_PASSWORD}
     ${session}=    Create Session      appmgr      ${APPMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Get Request     appmgr     ${data_path}     headers=${headers}
     Log    Received response from AppMgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run AppMgr Delete Request
     [documentation]     Delete Xapp data by XappId
     [Arguments]      ${xapp_id}
     ${data_path}=    Set Variable    ${APPMGR_BASE_PATH}/${xapp_id}
     ${auth}=  Create List  ${GLOBAL_INJECTED_APPMGR_USER}    ${GLOBAL_INJECTED_APPMGR_PASSWORD}
     ${session}=    Create Session      appmgr      ${APPMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Delete Request     appmgr     ${data_path}     headers=${headers}
     Log    Received response from AppMgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
