*** Settings ***
Documentation	  Executes the End To End Test cases
...
Library   Collections
#Library    HTTPUtils
Resource         ../resources/appmgr/appmgr_interface.robot
Resource         ../resources/e2mgr/e2mgr_interface.robot

*** Variables ***
${TEST_XAPPNAME}       DemoXapp1
${TEST_XAPPID}    101
${TEST_NODE_B_NAME}     nodeB1
${TEST_NODE_B_IP}     10.0.0.3
${TEST_NODE_B_PORT}   879


*** Test Cases ***
Get All Xapps 
    [Tags]   etetests  xapptests
    Run AppMgr Get All Request
Create Xapp 
    [Tags]   etetests  xapptests
    Run Create Xapp   ${TEST_XAPPNAME}    ${TEST_XAPPID}
Get Xapp By Name 
    [Tags]   etetests  xapptests
    Run AppMgr Get By XappName   ${TEST_XAPPNAME}
Get Xapp By Name and Id
    [Tags]   etetests  xapptests
    Run AppMgr Get By XappName and XappId    ${TEST_XAPPNAME}   ${TEST_XAPPID}
Setup RAN Via E2 Mgr 
    [Tags]   etetests  e2mgrtests
    Run E2Mgr Setup NodeB   ${TEST_NODE_B_NAME}    ${TEST_NODE_B_IP}   ${TEST_NODE_B_PORT}

