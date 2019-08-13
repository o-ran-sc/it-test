*** Settings ***
Documentation     The main interface for interacting with RIC E2 Manager (E2Mgr) . It handles low level stuff like managing the http request library and E2Mgr required fields
Library           RequestsLibrary
Library           UUID

Resource          ../global_properties.robot
Resource          ../json_templater.robot

*** Variables ***
${E2MGR_BASE_PATH}        /v1/nodeb   #/nodeb  /nodeb/setup
${E2MGR_BASE_VERSION}        /v1
${E2MGR_ENDPOINT}     ${GLOBAL_E2MGR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_E2MGR_IP_ADDR}:${GLOBAL_E2MGR_SERVER_PORT}
${E2MGR_SETUP_NODEB_TEMPLATE}     robot/assets/templates/e2mgr_setup_nodeb.template


*** Keywords ***
Run E2Mgr Health Check
     [Documentation]    Runs E2Mgr Health check
     ${data_path}=    Set Variable    /v1/health
     ${resp}=    Run Keyword    Run E2Mgr Get Request    ${data_path}

Check NodeB Status
     [Documentation]    Check NodeB Status
     [Arguments]      ${ran_name}
     ${resp}=  Run Keyword   Run E2Mgr Get NodeB Request    ${ran_name}
     Should Be Equal As Strings        ${resp.json()['connectionStatus']}     CONNECTED

Run E2Mgr Get NodeB Request
     [Documentation]    Runs E2Mgr Get NodeB Request
     [Arguments]      ${ran_name}
     ${data_path}=    Set Variable    ${E2MGR_BASE_PATH}/${ran_name}
     ${resp}=    Run Keyword    Run E2Mgr Get Request    ${data_path}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run E2Mgr Get All NodeBs Request 
     [Documentation]    Runs E2Mgr Get All NodeBs Request
     ${data_path}=    Set Variable    ${E2MGR_BASE_VERSION}/nodeb-ids
     ${resp}=    Run Keyword    Run E2Mgr Get Request    ${data_path}

Run E2Mgr Setup NodeB X2
     [documentation]     Setup X2 NodeB via E2 Manager
     [Arguments]      ${ran_name}  ${ran_ip}   ${ran_port}
     ${data_path}=    Set Variable    ${E2MGR_BASE_PATH}/x2-setup
     ${dict}=    Create Dictionary    ran_name=${ran_name}    ran_ip=${ran_ip}   ran_port=${ran_port}
     ${data}=   Fill JSON Template File    ${E2MGR_SETUP_NODEB_TEMPLATE}    ${dict}
     ${auth}=  Create List  ${GLOBAL_INJECTED_E2MGR_USER}    ${GLOBAL_INJECTED_E2MGR_PASSWORD}
     ${session}=    Create Session      e2mgr      ${E2MGR_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Post Request     e2mgr     ${data_path}     data=${data}   headers=${headers}
     Log    Received response from E2Mgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run E2Mgr Setup NodeB Endc
     [documentation]     Setup Endc NodeB via E2 Manager
     [Arguments]      ${ran_name}  ${ran_ip}   ${ran_port}
     ${data_path}=    Set Variable    ${E2MGR_BASE_PATH}/endc-setup
     ${dict}=    Create Dictionary    ran_name=${ran_name}    ran_ip=${ran_ip}   ran_port=${ran_port}
     ${data}=   Fill JSON Template File    ${E2MGR_SETUP_NODEB_TEMPLATE}    ${dict}
     ${auth}=  Create List  ${GLOBAL_INJECTED_E2MGR_USER}    ${GLOBAL_INJECTED_E2MGR_PASSWORD}
     ${session}=    Create Session      e2mgr      ${E2MGR_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Post Request     e2mgr     ${data_path}     data=${data}   headers=${headers}
     Log    Received response from E2Mgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run E2Mgr Delete NodeB
     [documentation]     Delete NodeB via E2 Manager
     [Arguments]      ${ran_name}  
     ${data_path}=    Set Variable    ${E2MGR_BASE_PATH}/${ran_name}
     ${resp}=    Run E2Mgr Delete Request    ${data_path}
     Should Be Equal As Strings        ${resp.status_code}     200


Run E2Mgr Get Request
     [Documentation]    Runs E2Mgr Get Request
     [Arguments]    ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_E2MGR_USER}    ${GLOBAL_INJECTED_E2MGR_PASSWORD}
     ${session}=    Create Session      e2mgr      ${E2MGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Get Request     e2mgr     ${data_path}     headers=${headers}
     Log    Received response from E2Mgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run E2Mgr Delete Request
     [Documentation]    Runs E2Mgr Delete Request
     [Arguments]    ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_E2MGR_USER}    ${GLOBAL_INJECTED_E2MGR_PASSWORD}
     ${session}=    Create Session      e2mgr      ${E2MGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Delete Request     e2mgr     ${data_path}     headers=${headers}
     Log    Received response from E2Mgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}
