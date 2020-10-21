*** Settings ***
Documentation     The main interface for interacting with RIC E2 Manager (Dashboard) . It handles low level stuff like managing the http request library and E2Mgr required fields
Library           RequestsLibrary
Library           UUID

Resource          /robot/resources/global_properties.robot
Resource          /robot/resources/json_templater.robot

*** Variables ***
${DASH_E2MGR_BASE_PATH}        /e2mgr/v1/nodeb   #/nodeb  /nodeb/setup
${DASH_E2MGR_BASE_VERSION}        /e2mgr/v1
${DASH_ENDPOINT}     ${GLOBAL_DASH_SERVER_PROTOCOL}://${GLOBAL_INJECTED_DASH_IP_ADDR}:${GLOBAL_DASH_SERVER_PORT}
${E2MGR_SETUP_NODEB_TEMPLATE}     robot/assets/templates/e2mgr_setup_nodeb.template


*** Keywords ***
Run Dashboard Health Check
     [Documentation]    Runs Dashboard Health check
     # need to confirm Dashboard Health Check URL
     ${data_path}=    Set Variable    /v1/health
     ${resp}=    Run Keyword    Run Dashboard Get Request    ${data_path}

Dashboard Check NodeB Status
     [Documentation]    Check NodeB Status
     [Arguments]      ${ran_name}
     ${resp}=  Run Keyword   Run Dashboard Get NodeB Request    ${ran_name}
     Should Be Equal As Strings        ${resp.json()['connectionStatus']}     CONNECTED

Run Dashboard Get NodeB Request
     [Documentation]    Runs Dashboard Get NodeB Request
     [Arguments]      ${ran_name}
     ${data_path}=    Set Variable    ${DASH_E2MGR_BASE_PATH}/${ran_name}
     ${resp}=    Run Keyword    Run Dashboard Get Request    ${data_path}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run Dashboard Get All NodeBs Request
     [Documentation]    Runs Dashboard Get All NodeBs Request
     ${data_path}=    Set Variable    ${DASH_E2MGR_BASE_VERSION}/nodeb-ids
     ${resp}=    Run Keyword    Run Dashboard Get Request    ${data_path}

Run Dashboard Setup NodeB X2
     [documentation]     Setup X2 NodeB via E2 Manager
     [Arguments]      ${ran_name}  ${ran_ip}   ${ran_port}
     ${data_path}=    Set Variable    ${DASH_E2MGR_BASE_PATH}/x2-setup
     ${dict}=    Create Dictionary    ran_name=${ran_name}    ran_ip=${ran_ip}   ran_port=${ran_port}
     ${data}=   Fill JSON Template File    ${E2MGR_SETUP_NODEB_TEMPLATE}    ${dict}
     ${auth}=  Create List  ${GLOBAL_INJECTED_DASH_USER}    ${GLOBAL_INJECTED_DASH_PASSWORD}
     ${session}=    Create Session      e2mgr      ${DASH_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request     e2mgr     ${data_path}     data=${data}   headers=${headers}
     Log    Received response from Dashboard ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run Dashboard Setup NodeB Endc
     [documentation]     Setup Endc NodeB via E2 Manager
     [Arguments]      ${ran_name}  ${ran_ip}   ${ran_port}
     ${data_path}=    Set Variable    ${DASH_E2MGR_BASE_PATH}/endc-setup
     ${dict}=    Create Dictionary    ran_name=${ran_name}    ran_ip=${ran_ip}   ran_port=${ran_port}
     ${data}=   Fill JSON Template File    ${E2MGR_SETUP_NODEB_TEMPLATE}    ${dict}
     ${auth}=  Create List  ${GLOBAL_INJECTED_DASH_USER}    ${GLOBAL_INJECTED_DASH_PASSWORD}
     ${session}=    Create Session      e2mgr      ${DASH_ENDPOINT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request     e2mgr     ${data_path}     data=${data}   headers=${headers}
     Log    Received response from Dashboard ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run Dashboard Delete NodeB
     [documentation]     Delete NodeB via E2 Manager
     [Arguments]      ${ran_name}
     ${data_path}=    Set Variable    ${DASH_E2MGR_BASE_PATH}/${ran_name}
     ${resp}=    Run Dashboard Delete Request    ${data_path}
     Should Be Equal As Strings        ${resp.status_code}     200


Run Dashboard Get Request
     [Documentation]    Runs Dashboard Get Request
     [Arguments]    ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_DASH_USER}    ${GLOBAL_INJECTED_DASH_PASSWORD}
     ${session}=    Create Session      e2mgr      ${DASH_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     e2mgr     ${data_path}     headers=${headers}
     Log    Received response from Dashboard ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run Dashboard Delete Request
     [Documentation]    Runs Dashboard Delete Request
     [Arguments]    ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_DASH_USER}    ${GLOBAL_INJECTED_DASH_PASSWORD}
     ${session}=    Create Session      e2mgr      ${DASH_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     e2mgr     ${data_path}     headers=${headers}
     Log    Received response from Dashboard ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}


