*** settings ***
Documentation     Negative tests for the AppMgr: ensure that AppMgr produces expected errors for a variety of invalid requests

Library           Collections
Library           UUID

Resource          /robot/resources/global_properties.robot
Resource          appmgr_interface.robot

*** Keywords ***
Deploy Duplicate XApp And Expect Error
     [Documentation]      Ensure AppMgr produces an appropriate error when an already-running XApp is deployed
     @{d} =               Get Deployed XApps
     Should Not Be Empty  ${d}      No XApps currently deployed
     @{names} =           Pluck     name  ${d}
     ${xapp} =            Evaluate  random.choice(${names})  random
     ${status}  ${u} =    Run Keyword And Ignore Error  Deploy XApp  ${xapp}
     Should Be Equal As Strings  ${status}          FAIL

Undeploy Nondeployed XApp And Expect Error
     [Documentation]      Ensure AppMgr produces an appropriate error when an existing but non-running XApp is deleted
     @{d} =               Get Deployed XApps
     @{a} =               Get Deployable XApps
     Should Not Be Empty  ${a}       No XApps available to deploy
     @{dNames} =          Pluck      name     ${d}
     @{a} =               Subtract From List  ${a}  ${dNames}
     Should Not Be Empty  ${a}                No undeployed XApps
     ${xapp} =            Evaluate            random.choice(${a})  random
     ${status}  ${u} =    Run Keyword And Ignore Error  Undeploy XApp  ${xapp}
     Should Be Equal As Strings               ${status}            FAIL

Request Nonexistent XApp And Expect Error
     [Documentation]    Ensure AppMgr produces an appropriate error when retrieving a nonexistent XApp
     ${xapp} =          Generate UUID
     ${status}  ${u} =  Run Keyword And Ignore Error  Get XApp By Name {$xapp}
     Should Be Equal As Strings  ${status}   FAIL


