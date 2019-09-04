*** Settings ***
Documentation	  Executes the End To End Test cases
...
Library   Collections

Resource         ../resources/appmgr/appmgr_interface.robot
Resource         ../resources/appmgr/negative_appmgr_tests.robot
Resource         ../resources/e2mgr/e2mgr_interface.robot

*** Variables ***
${TEST_XAPPNAME}       DemoXapp1
${TEST_XAPPID}    101
${TEST_NODE_B_NAME}     nodeB1
${TEST_NODE_B_IP}     10.0.0.3
${TEST_NODE_B_PORT}   879


*** Test Cases ***
Test XApp Manager
    [Tags]   etetests  xapptests
    Run AppMgr Health Check
    Deploy XApp Via Appmgr        ${TEST_XAPPNAME}
    Get XApp By Name From AppMgr  ${TEST_XAPPNAME}
    Deploy Duplicate XApp And Expect Error
    Undeploy XApp Via AppMgr      ${TEST_XAPPNAME}
    Undeploy Nondeployed XApp And Expect Error
    Request Nonexistent XApp And Expect Error
    
Setup RAN Via E2 Mgr 
    [Tags]   etetests  e2mgrtests
    Run E2Mgr Setup NodeB   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}

