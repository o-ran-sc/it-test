*** Settings ***
Documentation     Testing RIC components are available via calls.
...
...               Testing RIC components are available via calls.
Test Timeout      10 second
Resource          ../resources/appmgr/appmgr_interface.robot
Resource          ../resources/e2mgr/e2mgr_interface.robot
Resource          ../resources/rtmgr/rtmgr_interface.robot

*** Test Cases ***
Basic AppMgr Health Check
    [Tags]    health    
    Run AppMgr Health Check
Basic E2Mgr Health Check
    [Tags]    health    
    Run E2Mgr Health Check
#Basic RtMgr Health Check
#    [Tags]    health    
#    Run RtMgr Health Check

