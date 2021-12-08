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
Library	       Process
Library        OperatingSystem

Library        KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE}

*** Variables ***
${SUBMGR_BASE_PATH}    /ric/v1/health/alive
${SUBMGR_SUBDATA_PATH}    /ric/v1/subscriptions
${gnb_id} = 	Set Variable	${GLOBAL_GNBID}


*** Keywords ***
Run submgr Health Check
     [Documentation]    Runs SubMgr Health check
     ${data_path}=	Set Variable    ${SUBMGR_BASE_PATH}
     ${resp} =	 Run Keyword	Run submgr GET Request	${data_path}

Run submgr GET Request
     [Documentation]  Make an HTTP GET request against the submgr
     [Arguments]   ${data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_SUBMGR_USER}    ${GLOBAL_INJECTED_SUBMGR_PASSWORD}
     ${c} =            Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  submgr
     ${ctrl}  ${submgr1} =  Split String         ${c}       |
     ${name} =	Run Keyword	RetrievePodsForDeployment	${submgr1}
     ${name1} =	Set Variable	${name[0]}
     Log To Console	${name1}
     ${cType} =        Set Variable    Pod
     ${ctrl1} =	Run Keyword	${cType}	${name1}
     ${podIP} =	Set Variable	${ctrl1.status.pod_ip}
     Log To Console	${podIP}
     #${SUBMGR_ENDPOINT}=	Set Variable	${GLOBAL_SUBMGR_SERVER_PROTOCOL}://${GLOBAL_SUBMGR_HTTP_SERVER}:${GLOBAL_SUBMGR_PORT}
     ${SUBMGR_ENDPOINT}=	Set Variable	${GLOBAL_SUBMGR_SERVER_PROTOCOL}://${podIP}:8080
     ${session}=    Create Session      robosubmgr	${SUBMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Get Request     robosubmgr    ${data_path}     headers=${headers}
     Log    Received response from SubMgr ${resp.text}
     Should Be Equal As Strings        ${resp.status_code}     200
     [Return]    ${resp}

Run submgr SUBSCRIPTIONGET Request
     [Documentation]  Make an HTTP GET request against the submgr
     [Arguments]   ${sub_data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_SUBMGR_USER}    ${GLOBAL_INJECTED_SUBMGR_PASSWORD}
     ${c} =            Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  submgr
     ${ctrl}  ${submgr1} =  Split String         ${c}       |
     ${name} =	Run Keyword	RetrievePodsForDeployment	${submgr1}
     ${name1} =	Set Variable	${name[0]}
     Log To Console	${name1}
     ${cType} =        Set Variable    Pod
     ${ctrl1} =	Run Keyword	${cType}	${name1}
     ${podIP} =	Set Variable	${ctrl1.status.pod_ip}
     Log To Console	${podIP}
     #${SUBMGR_ENDPOINT}=	Set Variable	${GLOBAL_SUBMGR_SERVER_PROTOCOL}://${GLOBAL_SUBMGR_HTTP_SERVER}:${GLOBAL_SUBMGR_PORT}
     ${SUBMGR_ENDPOINT}=	Set Variable	${GLOBAL_SUBMGR_SERVER_PROTOCOL}://${podIP}:8088
     Log To Console	${SUBMGR_ENDPOINT}
     ${session}=    Create Session      subscriptioncheck	${SUBMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Get Request     subscriptioncheck    ${sub_data_path}     headers=${headers}
     Log To Console	${resp}
     Log TO Console	${resp.text}
     Log TO Console	${gnb_id}
     ${ret} =    Run Keyword And Return Status	 Should Contain		${resp.text}		"${GLOBAL_GNBID}"
     [Return]    ${ret}



Run submgr SUBSCRIPTIONMERGE Check
     [Documentation]  Make an HTTP GET request against the submgr
     [Arguments]   ${sub_data_path}
     ${auth}=  Create List  ${GLOBAL_INJECTED_SUBMGR_USER}    ${GLOBAL_INJECTED_SUBMGR_PASSWORD}
     ${c} =            Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  submgr
     ${ctrl}  ${submgr1} =  Split String         ${c}       |
     ${name} =	Run Keyword	RetrievePodsForDeployment	${submgr1}
     ${name1} =	Set Variable	${name[0]}
     Log To Console	${name1}
     ${cType} =        Set Variable    Pod
     ${ctrl1} =	Run Keyword	${cType}	${name1}
     ${podIP} =	Set Variable	${ctrl1.status.pod_ip}
     Log To Console	${podIP}
     #${SUBMGR_ENDPOINT}=	Set Variable	${GLOBAL_SUBMGR_SERVER_PROTOCOL}://${GLOBAL_SUBMGR_HTTP_SERVER}:${GLOBAL_SUBMGR_PORT}
     ${SUBMGR_ENDPOINT}=	Set Variable	${GLOBAL_SUBMGR_SERVER_PROTOCOL}://${podIP}:8088
     Log To Console	${SUBMGR_ENDPOINT}
     ${session}=    Create Session      subscriptioncheck1	${SUBMGR_ENDPOINT}   auth=${auth}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    
     ${resp}=   Get Request     subscriptioncheck1    ${sub_data_path}     headers=${headers}
     Log To Console	${resp}
     Log TO Console	${resp.text}
     Log TO Console	${gnb_id}
     @{jsonoutput} =    To Json		${resp.text}
     Log TO Console	${jsonoutput}
     FOR	 ${item}	 IN	@{jsonoutput}
        Log To Console  ${item}
        ${json}=  Set variable    ${item['Endpoint']}
        ${len_endpointfromjson} =    Get Length		${json}
        Log To Console  ${json}
        Log To Console  ${len_endpointfromjson}
        ${ret} =	Run Keyword And Return Status	Should Be Equal As Integers	${len_endpointfromjson}	2
        Log To Console  ${ret}
     END
     [Return]	${ret}

