*** Settings ***
Documentation  Tests for the UE Event Collector XApp

Resource       /robot/resources/global_properties.robot
Resource       /robot/resources/ric/ric_utils.robot
Resource       /robot/resources/json_templater.robot

Library        String
Library        Collections
Library        XML
Library        RequestsLibrary
Library        UUID
Library        Process
Library        OperatingSystem

Library        KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE}

*** Variables ***
${SUBMGR_BASE_PATH}    /ric/v1/health/alive


*** Keywords ***
Run submgr Health Check
     [Documentation]    Runs SubMgr Health check
     ${data_path}=      Set Variable    ${SUBMGR_BASE_PATH}
     ${resp} =   Run Keyword    Run submgr GET Request  ${data_path}

Run submgr GET Request
     [Documentation]  Make an HTTP GET request against the submgr
     [Arguments]   ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_SUBMGR_USER}    ${GLOBAL_INJECTED_SUBMGR_PASSWORD}
     ${c} =            Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  submgr
     ${ctrl}  ${submgr1} =  Split String         ${c}       |
     ${name} =  Run Keyword     RetrievePodsForDeployment       ${submgr1}
     ${name1} = Set Variable    ${name[0]}
     ${cType} =        Set Variable    Pod
     ${ctrl1} = Run Keyword     ${cType}        ${name1}
     ${podIP} = Set Variable    ${ctrl1.status.pod_ip}
     Log To Console     ${podIP}
     ${SUBMGR_ENDPOINT}=        Set Variable    ${GLOBAL_SUBMGR_SERVER_PROTOCOL}://${podIP}:${GLOBAL_SUBMGR_SERVER_PORT}
     ${session}=    Create Session      robosubmgr      ${SUBMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     robosubmgr    ${data_path}     headers=${headers}
     Log    Received response from SubMgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}
