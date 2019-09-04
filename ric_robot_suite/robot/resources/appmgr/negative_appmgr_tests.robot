*** Settings ***
Documentation     Negative tests for the AppMgr: ensure that AppMgr produces expected errors for a variety of invalid requests
Library           Collections
Library           UUID

Resource          ../global_properties.robot
Resource          appmgr_interface.robot

*** Keywords ***
Deploy Duplicate XApp And Expect Error
     [Documentation]      Ensure AppMgr produces an appropriate error when an already-running XApp is deployed
     @{d} =               Get Deployed XApps From AppMgr
     Should Not Be Empty  ${d}      No XApps currently deployed
     @{names} =           Pluck     Name  ${d}
     ${xapp} =            Evaluate  random.choice(${names})  random
     ${status} =          Run Keyword And Ignore Error  Deploy XApp Via AppMgr  ${xapp}
     Should Be Equal As Strings  ${status}          FAIL

Undeploy Nondeployed XApp And Expect Error
     [Documentation]      Ensure AppMgr produces an appropriate error when an existing but non-running XApp is deleted
     @{d} =               Get Deployed XApps From AppMgr
     @{a} =               Get Deployable XApps From AppMgr
     Should Not Be Empty  ${a}       No XApps available to deploy
     @{dNames} =          Pluck      Name  ${d}
     ${xapp} =            Run Keyword If  ${dNames}
     ...                  Evaluate   random.choice(filter(lambda v: v not in ${dNames}, ${a}))  random
     ...                  ELSE
     ...                  Evaluate   random.choice(${a})  random
     ${status}  ${u} =    Run Keyword And Ignore Error  Undeploy XApp Via AppMgr  ${xapp}
     Should Be Equal As Strings      ${status}            FAIL

Request Nonexistent XApp And Expect Error
     [Documentation]    Ensure AppMgr produces an appropriate error when retrieving a nonexistent XApp
     ${xapp} =          Generate UUID
     ${status}  ${u} =  Run Keyword And Ignore Error  Get XApp By Name From AppMgr  {$xapp}
     Should Be Equal As Strings  ${status}   FAIL

Pluck
     [Documentation]  Get the values of a specific key from a list of dictionaries
     [Arguments]      ${k}      ${l}
     @{names} =       Evaluate  filter(lambda v: v != None, [i.get(${k}, None) for i in ${l}])
     [Return]         ${names}
