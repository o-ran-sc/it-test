*** Settings ***
Documentation  Keywords for interacting with the XApp Manager, including listing, deploying, and undeploying XApps

Library        RequestsLibrary

Resource       ../global_properties.robot

Resource       ../ric/ric_utils.robot

*** Variables ***
${APPMGR_BASE_PATH}  /ric/v1/xapps
${APPMGR_ENDPOINT}   ${GLOBAL_APPMGR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_APPMGR_IP_ADDR}:${GLOBAL_APPMGR_SERVER_PORT}

*** Keywords ***
Run AppMgr Health Check
     [Documentation]    Runs AppMgr Health check
     Run Keyword        Get Deployed XApps

Get Deployed XApps
     [Documentation]  Obtain the list of deployed XApps from the Appmgr
     ${resp} =        Run AppMgr GET Request
     [Return]         ${resp.json()}

Get Deployable XApps
     [Documentation]  Obtain the list of deployed XApps from the Appmgr
     ${resp} =        Run AppMgr GET Request  /search/
     Should Be True   ${resp}
     [Return]         ${resp.json()}

Get XApp By Name
     [Documentation]  Get installed XApp from Appmgr given name
     [Arguments]      ${xapp_name}
     ${resp} =        Run AppMgr GET Request  /${xapp_name}
     Should Be True   ${resp}
     [Return]         ${resp.json()}

Get XApp By Name and ID
     [Documentation]  Get installed XApp from Appmgr by name and ID
     [Arguments]      ${xapp_name}  ${xapp_id}
     ${resp}=         Run AppMgr GET Request  /${xapp_name}/${xapp_id}/
     Should Be True   ${resp}
     [Return]         ${resp.json()}

Deploy XApp
     [Documentation]  Create Xapp
     [Arguments]      ${xapp_name}
     &{dict} =        Create Dictionary        name=${xapp_name}
     ${data} =        Evaluate                 json.dumps(&{dict})  json
     ${resp} =        Run AppMgr POST Request  ${EMPTY}             ${data}
     Should Be True   ${resp}
     [Return]         ${resp}

Deploy XApps
     [Documentation]  Create one or more XApps
     [Arguments]      @{xapp_names}
     FOR             ${xapp}  IN             @{xapp_names}
                     Deploy XApp   ${xapp}
     END
     
Undeploy XApp
     [Documentation]  Remove a deployed XApp
     [Arguments]      ${xapp_name}
     ${resp} =        Run AppMgr DELETE Request  /${xapp_name}
     Should Be True   ${resp}
     [Return]         ${resp}

Undeploy XApps
     [Documentation]  Remove one or more deployed XApps
     [Arguments]      @{xapp_names}
     FOR             ${xapp}  IN     @{xapp_names}
                     Undeploy XApp   ${xapp}

Deploy All Available XApps
     [Documentation]  Attempt to deploy any not-currently-deployed XApp
     @{d} =          Get Deployed XApps
     @{deployed} =   Pluck               name          ${d}
     @{available} =  Get Deployable XApps
     @{toDeploy} =   Subtract From List  ${available}  ${deployed}
     Deploy XApps    @{toDeploy}

Undeploy All Running XApps
     [Documentation]  Undeploy any deployed XApps
     @{d} =           Get Deployed XApps
     @{deployed} =    Pluck  name  ${d}
     Run Keyword If   ${deployed}  Undeploy XApps  @{deployed}

Run AppMgr GET Request
     [Documentation]  Make an HTTP GET request against the XApp manager
     [Arguments]   ${path}=${EMPTY}
     ${session} =  Create Session     roboAppmgrGet                   ${APPMGR_ENDPOINT}
     ${headers} =  Create Dictionary  Accept=application/json         Content-Type=application/json
     ${resp} =     Get Request        roboAppmgrGet                   ${APPMGR_BASE_PATH}${path}  headers=${headers}
     [Return]      ${resp}

Run AppMgr POST Request
     [Documentation]    Make an HTTP POST request against the XApp manager
     [Arguments]   ${path}=${EMPTY}   ${body}=${EMPTY}
     ${session} =  Create Session     roboAppmgrPost                  ${APPMGR_ENDPOINT}
     ${headers} =  Create Dictionary  Accept=application/json         Content-Type=application/json
     ${resp} =     Post Request       roboAppmgrPost                  ${APPMGR_BASE_PATH}${path}  headers=${headers}  data=${body}
     [Return]      ${resp}

Run AppMgr DELETE Request
     [Documentation]  Make an HTTP DELETE request against the XApp manager
     [Arguments]      ${path}
     ${session} =     Create Session     roboAppmgrDelete                ${APPMGR_ENDPOINT}
     ${headers} =     Create Dictionary  Accept=application/json         Content-Type=application/json
     ${resp} =        Delete Request     roboAppmgrDelete                ${APPMGR_BASE_PATH}${path}  headers=${headers}
     [Return]         ${resp}
