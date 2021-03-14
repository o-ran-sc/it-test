*** Settings *** 
Documentation     The main interface for interacting with RIC E2 Term (E2term). 
...                It handles low level stuff like managing the http request library and 
...                E2term required fields 
Library           RequestsLibrary 
Library           UUID 
Library           Process 
Library           Collections 
Library           OperatingSystem 

Resource          /robot/resources/global_properties.robot 
Resource          /robot/resources/json_templater.robot 


*** Variables *** 
${E2TERM_ENDPOINT}      ${GLOBAL_INJECTED_E2TERM_IP_ADDR}:${GLOBAL_E2TERM_SERVER_PORT} 


*** Keywords *** 
Run E2Term Health Check 
     [Documentation]  Runs E2Term Health check 
     Log To Console     Entering in to E2term 
     ${data_path}=    Set Variable    ${E2TERM_ENDPOINT} 
     ${resp} =  Run E2Term RMR Probe Check      ${data_path} 
     Log To Console     ${resp} 

Run E2Term RMR Probe Check 
     [Documentation]    Runs E2Term RMR Probe Check 
     [Arguments]        ${data_path} 

     ${resp} =  Run     /bin/sh -c "/opt/e2/rmr_probe -h ${data_path} -v verbose" 
     Log To Console     Received response from E2term ${resp} 
     ${ret} =   Should Match Regexp     ${resp} OK 
     Log To Console     ${ret} 
     [Return]    ${ret} 
