*** Settings ***
Documentation	  Executes the End To End Test cases
...
Library   Collections

Resource         ../resources/appmgr/appmgr_interface.robot
Resource         ../resources/appmgr/negative_appmgr_tests.robot
Resource         ../resources/e2mgr/e2mgr_interface.robot

*** Variables ***
${TEST_XAPPNAME}       xapp-std
${TEST_NODE_B_NAME}     nodeB1
${TEST_NODE_B_IP}     10.0.0.3
${TEST_NODE_B_PORT}   879


*** Test Cases ***
Test XApp Manager Health
    [Tags]   etetests  xapptests
    Run AppMgr Health Check
Deploy An XApp    
    [Tags]   etetests  xapptests
    Deploy XApp Via Appmgr        ${TEST_XAPPNAME}
Retrieve The Deployed XApp
    [Tags]   etetests  xapptests
    Get XApp By Name From AppMgr  ${TEST_XAPPNAME}
Attempt To Deploy A Duplicate XApp
    [Tags]   etetests  xapptests
    Deploy Duplicate XApp And Expect Error
Undeploy The Deployed XApp
    Undeploy XApp Via AppMgr      ${TEST_XAPPNAME}
Attempt To Undeploy An Already Undeployed XApp
    Undeploy Nondeployed XApp And Expect Error
Attempt To Request A Nonexistent XApp
    Request Nonexistent XApp And Expect Error
    
Setup RAN Via E2 Mgr 
    [Tags]   etetests  e2mgrtests
    Run E2Mgr Setup NodeB   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}

