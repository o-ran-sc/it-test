*** Settings ***
Documentation	  Executes the End To End Test cases
...
Library   Collections
Library   OperatingSystem
Resource         ../resources/appmgr/appmgr_interface.robot
Resource         ../resources/e2mgr/e2mgr_interface.robot
Resource         ../resources/dashboard/dashboard_interface.robot

*** Variables ***
${TEST_XAPPNAME}       DemoXapp1
${TEST_XAPPID}    101
${TEST_NODE_B_NAME}     AAAA456789
${TEST_NODE_B_IP}     10.0.0.3
${TEST_NODE_B_PORT}   36422


*** Test Cases ***
Get All Xapps
    [Tags]   etetests  xapptests   ci_tests
    Run AppMgr Get All Request
Create Xapp
    [Tags]   etetests  xapptests   ci_tests
    Run Create Xapp   ${TEST_XAPPNAME}    ${TEST_XAPPID}
Get Xapp By Name
    [Tags]   etetests  xapptests
    Run AppMgr Get By XappName   ${TEST_XAPPNAME}
Get Xapp By Name and Id
    [Tags]   etetests   xapptests
    Run AppMgr Get By XappName and XappId    ${TEST_XAPPNAME}   ${TEST_XAPPID}
Setup RAN Via E2Mgr X2
    [Tags]   x2setup
    Run E2Mgr Setup NodeB X2   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Check NodeB Status    ${TEST_NODE_B_NAME}
Setup RAN Via E2Mgr Endc
    [Tags]   e2setup
    Run E2Mgr Setup NodeB Endc   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Check NodeB Status    ${TEST_NODE_B_NAME}
Get NodeB via E2Mgr
    [Tags]   e2setup   x2setup
    Run E2Mgr Get NodeB Request   ${TEST_NODE_B_NAME}
Get All NodeBs Via E2Mgr
    [Tags]   e2mgrtest   etetests   e2setup   x2setup   ci_tests
    Run E2Mgr Get All NodeBs Request
Setup RAN Via Dashboard Endc
    [Tags]   e2setup_dash
    Run Dashboard Setup NodeB Endc   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Dashboard Check NodeB Status    ${TEST_NODE_B_NAME}
Setup RAN Via Dashboard X2
    [Tags]   x2setup_dash
    Run Dashboard Setup NodeB X2    ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}
    Wait Until Keyword Succeeds   20s   5s   Dashboard Check NodeB Status    ${TEST_NODE_B_NAME}
Get NodeB via Dashboard
    [Tags]   e2setup_dash   x2setup_dash
    Run Dashboard Get NodeB Request   ${TEST_NODE_B_NAME}
Get All NodeBs via Dashboard
    [Tags]   e2setup_dash   x2setup_dash    ci_tests
    Run Dashboard Get All NodeBs Request

