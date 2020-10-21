*** Settings *** 
Documentation  Keywords for interacting with the A1 interface, including policy creation, instantiaton, and deletion 
 
Library        RequestsLibrary 
 
Resource       /robot/resources/global_properties.robot 
 
Resource       /robot/resources/ric/ric_utils.robot 
 
*** Variables *** 
${A1MEDIATOR_BASE_PATH}  /a1-p/policytypes 
${A1MEDIATOR_ENDPOINT}   ${GLOBAL_A1MEDIATOR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_A1MEDIATOR_IP_ADDR}:${GLOBAL_A1MEDIATOR_SERVER_PORT} 
 
*** Keywords *** 
 
Run A1Mediator Health Check 
     [Documentation]    Runs A1Mediator Health check 
     Log To Console     Entering a1mediator 
     ${resp} =  Run A1mediator GET Request 
     Log To Console     ${resp} 
 
Create A1 Policy Type 
     [Documentation]  Create a new policy via the A1 Mediator. 
     [Arguments]      ${type}  ${name}  ${description}  ${properties}  ${required}=@{EMPTY} 
     ${typeID} =        Convert To Integer  ${type} 
     Should Be True     ${type} > 0         Policy type must be an integer > 0 
     ${createSchema} =  Create Dictionary 
     ...                $schema=http://json-schema.org/draft-07/schema# 
     ...                type=object 
     ...                properties=${properties} 
     ...                required=@{required} 
     ${createBody} =    Create Dictionary 
     ...                name=${name} 
     ...                policy_type_id=${typeID} 
     ...                description=${description} 
     ...                create_schema=${createSchema} 
     ${createJSON} =    Evaluate                    json.dumps(&{createBody})  json,uuid 
     ${resp} =          Run A1Mediator PUT Request  /${type}  body=${createJSON} 
     [Return]           ${resp} 
 
Instantiate A1 Policy 
     [Documentation]  Create a new instance of an A1 policy 
     [Arguments]      ${type}  ${instance}  ${properties}=${EMPTY} 
     ${typeID} =        Convert To Integer  ${type} 
     Should Be True     ${type} > 0         Policy type must be an integer > 0 
     ${instanceJSON} =  Evaluate            json.dumps(&{properties})  json,uuid 
     ${resp} =          Run A1Mediator PUT Request  /${type}/policies/${instance}  body=${instanceJSON} 
     [Return]           ${resp} 
 
Delete A1 Instance 
     [Documentation]  Remove an A1 policy instance 
     [Arguments]      ${type}  ${instance} 
     ${typeID} =        Convert To Integer  ${type} 
     Should Be True     ${type} > 0         Policy type must be an integer > 0 
     ${resp} =          Run A1Mediator DELETE Request  /${type}/policies/${instance} 
     [Return]           ${resp} 
 
Delete A1 Policy 
     [Documentation]  Remove an A1 policy type 
     [Arguments]      ${type} 
     ${typeID} =        Convert To Integer  ${type} 
     Should Be True     ${type} > 0         Policy type must be an integer > 0 
     ${resp} =          Run A1Mediator DELETE Request  /${type} 
     [Return]           ${resp} 
 
Retrieve A1 Policy 
     [Documentation]  Get a defined policy from A1 
     [Arguments]      ${type} 
     ${typeID} =        Convert To Integer  ${type} 
     Should Be True     ${type} > 0         Policy type must be an integer > 0 
     ${resp} =          Run A1Mediator GET Request  /${type} 
     [Return]           ${resp} 
 
Retrieve A1 Instance 
     [Documentation]  Get a defined policy from A1.  If no instance is specified, retrieve all instances. 
     [Arguments]      ${type}  ${instance}=${EMPTY} 
     ${typeID} =        Convert To Integer  ${type} 
     Should Be True     ${type} > 0         Policy type must be an integer > 0 
     ${resp} =          Run Keyword If              "${instance}" != "${EMPTY}" 
     ...                Run A1Mediator GET Request  /${type}/policies/${instance} 
     ...                ELSE 
     ...                Run A1Mediator GET Request  /${type}/policies 
     [Return]           ${resp} 
 
Retrieve A1 Instance Status 
     [Documentation]  Get policy instance status 
     [Arguments]      ${type}  ${instance}=${EMPTY} 
     ${typeID} =        Convert To Integer  ${type} 
     Should Be True     ${type} > 0         Policy type must be an integer > 0 
     ${resp} =          Run A1Mediator GET Request                /${type}/policies/${instance}/status 
     [Return]           ${resp} 
 
Run A1mediator GET Request 
     [Documentation]  Make an HTTP GET request against the XApp manager 
     [Arguments]   ${path}=${EMPTY} 
     ${session} =  Create Session     roboA1mediatorGet           ${A1MEDIATOR_ENDPOINT} 
     ${headers} =  Create Dictionary  Accept=application/json     Content-Type=application/json 
     ${resp} =     Get Request        roboA1mediatorGet           ${A1MEDIATOR_BASE_PATH}${path}  headers=${headers} 
     [Return]      ${resp} 
 
Run A1mediator PUT Request 
     [Documentation]    Make an HTTP PUT request against the XApp manager 
     [Arguments]   ${path}=${EMPTY}   ${body}=${EMPTY} 
     ${session} =  Create Session     roboA1mediatorPut           ${A1MEDIATOR_ENDPOINT} 
     ${headers} =  Create Dictionary  Accept=application/json     Content-Type=application/json 
     ${resp} =     PUT Request        roboA1mediatorPut           ${A1MEDIATOR_BASE_PATH}${path} 
     ...                                                           headers=${headers} 
     ...                                                           data=${body} 
     [Return]      ${resp} 
 
Run A1mediator POST Request 
     [Documentation]    Make an HTTP POST request against the XApp manager 
     [Arguments]   ${path}=${EMPTY}   ${body}=${EMPTY} 
     ${session} =  Create Session     roboA1mediatorPost          ${A1MEDIATOR_ENDPOINT} 
     ${headers} =  Create Dictionary  Accept=application/json     Content-Type=application/json 
     ${resp} =     POST Request       roboA1mediatorPost          ${A1MEDIATOR_BASE_PATH}${path} 
     ...                                                           headers=${headers} 
     ...                                                           data=${body} 
     [Return]      ${resp} 
 
Run A1mediator DELETE Request 
     [Documentation]  Make an HTTP DELETE request against the XApp manager 
     [Arguments]      ${path} 
     ${session} =     Create Session     roboA1mediatorDelete     ${A1MEDIATOR_ENDPOINT} 
     ${headers} =     Create Dictionary  Accept=application/json  Content-Type=application/json 
     ${resp} =        Delete Request     roboA1mediatorDelete     ${A1MEDIATOR_BASE_PATH}${path}  headers=${headers} 
     [Return]         ${resp} 

