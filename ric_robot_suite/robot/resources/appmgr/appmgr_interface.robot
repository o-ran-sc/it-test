*** Settings ***
Documentation     The main interface for interacting with RIC Applications Manager (AppMgr) . It handles low level stuff like managing the http request library and AppMgr required fields
Library           RequestsLibrary

Resource          ../global_properties.robot

*** Variables ***
${APPMGR_BASE_PATH}             /ric/v1/xapps
${APPMGR_ENDPOINT}              http://service-ricplt-appmgr-http.ricplt.svc.cluster.local:8080
# ${GLOBAL_APPMGR_SERVER_PROTOCOL}://${GLOBAL_INJECTED_APPMGR_IP_ADDR}:${GLOBAL_APPMGR_SERVER_PORT}


*** Keywords ***
Run AppMgr Health Check
     [Documentation]    Runs AppMgr Health check
     Run Keyword        Get Deployed XApps From AppMgr

Get Deployed XApps From AppMgr
     [Documentation]  Obtain the list of deployed XApps from the Appmgr
     ${resp} =        Run Keyword  Run AppMgr GET Request
     [Return]         ${resp.json()}

Get Deployable XApps From AppMgr
     [Documentation]  Obtain the list of deployed XApps from the Appmgr
     ${resp} =        Run Keyword  Run AppMgr GET Request  /search/
     Should Be True   ${resp}
     [Return]         ${resp.json()}

Get XApp By Name From AppMgr
     [Documentation]  Get installed XApp from Appmgr given name
     [Arguments]      ${xapp_name}
     ${resp} =        Run Keyword   Run AppMgr GET Request  /${xapp_name}
     Should Be True   ${resp}
     [Return]         ${resp.json()}

Get XApp By Name and ID From AppMgr
     [Documentation]  Get installed XApp from Appmgr by name and ID
     [Arguments]      ${xapp_name}  ${xapp_id}
     ${resp}=         Run Keyword   Run AppMgr GET Request  /${xapp_name}/${xapp_id}/
     Should Be True   ${resp}
     [Return]         ${resp.json()}
     
Deploy XApp Via AppMgr
     [Documentation]  Create Xapp 
     [Arguments]      ${xapp_name}
     &{dict} =        Create Dictionary        name=${xapp_name}
     ${data} =        Evaluate                 json.dumps(&{dict})  json
     ${resp} =        Run AppMgr POST Request  ${EMPTY}             ${data}
     Should Be True   ${resp}
     [Return]         ${resp}

Undeploy XApp Via AppMgr
     [Documentation]  Create Xapp 
     [Arguments]      ${xapp_name}
     ${resp} =        Run AppMgr DELETE Request  /${xapp_name}
     Should Be True   ${resp}
     [Return]         ${resp}

Deploy All Available XApps Via Appmgr
     [Documentation]  Attempt to deploy any not-currently-deployed XApp
     @{d} =          Get Deployed XApps From AppMgr
     @{deployed} =   Pluck    Name       ${d}
     @{available} =  Get Deployable XApps From AppMgr
     @{toDeploy} =   Subtract From List  ${available}  ${deployed}
     :For            ${xapp}  IN         @{toDeploy}
     \               Deploy XApp Via AppMgr            ${xapp}
     
Run AppMgr GET Request
     [Documentation]  Make an HTTP GET request against the XApp manager
     [Arguments]   ${path}=${EMPTY}
     ${session} =  Create Session     roboAppmgrGet                   ${APPMGR_ENDPOINT}
     ${headers} =  Create Dictionary  Accept=application/json         Content-Type=application/json
     ${resp} =     Get Request        roboAppmgrGet                   ${APPMGR_BASE_PATH}${path}  headers=${headers}
     Log           Received response from AppMgr ${resp.text}
     [Return]      ${resp}

Run AppMgr POST Request
     [Documentation]    Make an HTTP POST request against the XApp manager
     [Arguments]   ${path}=${EMPTY}         ${body}=${EMPTY}
     ${session} =  Create Session     roboAppmgrPost                  ${APPMGR_ENDPOINT}
     ${headers} =  Create Dictionary  Accept=application/json         Content-Type=application/json    
     ${resp} =     Post Request       roboAppmgrPost                  ${APPMGR_BASE_PATH}${path}  headers=${headers}  data=${body}
     Log           Received response from AppMgr ${resp.text}
     [Return]      ${resp}

Run AppMgr DELETE Request
     [Documentation]  Make an HTTP DELETE request against the XApp manager
     [Arguments]      ${path}
     ${session} =     Create Session     roboAppmgrDelete                ${APPMGR_ENDPOINT}
     ${headers} =     Create Dictionary  Accept=application/json         Content-Type=application/json    
     ${resp} =        Delete Request     roboAppmgrDelete                ${APPMGR_BASE_PATH}${path}  headers=${headers}
     Log              Received response from AppMgr ${resp.text}
     [Return]         ${resp}

Pluck
     [Documentation]  Get the values of a specific key from a list of dictionaries
     [Arguments]      ${k}      ${l}
     @{names} =       Evaluate  filter(lambda v: v != None, [i.get(${k}, None) for i in ${l}])
     [Return]         ${names}

Subtract From List
     [Documentation]  Remove the elements of the second argument from the first
     [Arguments]      ${x}  ${y}
     ${diff} =        Run Keyword If  ${y}
     ...              Evaluate  filter(lambda v: v not in ${y}, ${x})
     ...              ELSE
     ...              Set Variable    ${x}
     [Return]         ${diff}
     