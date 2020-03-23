#   Copyright (c) 2019 AT&T Intellectual Property.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

*** Settings ***
Documentation   Tests for the A1 Mediator

Resource       /robot/resources/global_properties.robot
Resource       /robot/resources/a1mediator/a1mediator_interface.robot
Resource       /robot/resources/appmgr/appmgr_interface.robot

Library  UUID

*** Variables ***
${POLICY_ID}    ${GLOBAL_A1MEDIATOR_POLICY_ID}
${TARGET_XAPP}  ${GLOBAL_A1MEDIATOR_TARGET_XAPP}

*** Test Cases ***
Deploy Target XApp If Necessary
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${err}  ${xappStatus} =  Run Keyword And Ignore Error
  ...                      Get XApp By Name          ${TARGET_XAPP}
  Run Keyword If           '${err}' == 'FAIL'
  ...                      Deploy XApp               ${TARGET_XAPP}
  
Create Policy
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${policyProperty} =      Create Dictionary
  ...                      type=string
  ...                      description=a message
  ${policyProperties} =    Create Dictionary
  ...                      message=${policyProperty}
  ${policyName} =          Generate UUID
  ${policyName} =          Convert To String         ${policyName}
  Set Suite Variable       ${policyName}
  ${resp} =                Create A1 Policy Type
  ...                      ${POLICY_ID}
  ...                      ${policyName}
  ...                      ${policyName}
  ...                      ${policyProperties}
  Should Be True           ${resp}
  
Policy Should Exist
  [Tags]  etetests  ci_tests  a1tests
  ${resp} =                Retrieve A1 Policy        ${POLICY_ID}
  Should Be True           ${resp}
  Should Be Equal          ${resp.json()}[name]      ${policyName}
  
Create Policy Instance
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${instanceName} =        Generate UUID
  ${instanceName} =        Convert To String         ${instanceName}
  Set Suite Variable       ${instanceName}
  ${instanceMessage} =     Generate UUID
  ${instanceMessage} =     Convert To String         ${instanceMessage}
  ${instanceProperties} =  Create Dictionary
  ...                      message=${instanceMessage}
  Set Suite Variable       ${instanceMessage}
  ${resp} =                Instantiate A1 Policy
  ...                      ${POLICY_ID}
  ...                      ${instanceName}
  ...                      ${instanceProperties}
  Should Be True           ${resp}
  
Policy Should Have Instances
  [Tags]  etetests  ci_tests  a1tests
  ${resp} =                Retrieve A1 Instance      ${POLICY_ID}
  Should Be True           ${resp}
  Should Not Be Empty      ${resp.json()}
  
Instance Should Exist
  [Tags]  etetests  ci_tests  a1tests
  ${resp} =                Retrieve A1 Instance      ${POLICY_ID}     ${instanceName}
  Should Be True           ${resp}
  Should Be Equal          ${resp.json()}[message]   ${instanceMessage}

Instance Should Be IN EFFECT
  [Tags]  etetests  ci_tests  a1tests
  Wait Until Keyword Succeeds  3x  5s                Status Is IN EFFECT

Delete Policy Instance
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${resp} =                Delete A1 Instance       ${POLICY_ID}      ${instanceName}
  Should Be True           ${resp}

Instance Should Not Exist
  [Tags]  etetests  ci_tests  a1tests
  Wait Until Keyword Succeeds  3x  5s               Instance Has Been Deleted
  
Delete Policy
  [Tags]  etetests  ci_tests  a1tests  intrusive
  ${resp} =                Delete A1 Policy         ${POLICY_ID}
  Should Be True           ${resp}

Policy Should Not Exist
  [Tags]  etetests  ci_tests  a1tests
  Wait Until Keyword Succeeds  3x  5s               Policy Has Been Deleted

Undeploy Target XApp
  [Tags]  etetests  ci_tests  a1tests  intrusive
  Undeploy XApp            ${TARGET_XAPP}
  
*** Keywords ***
Status Is IN EFFECT
  ${resp} =                Retrieve A1 Instance Status
  ...                      ${POLICY_ID}
  ...                      ${instanceName}
  Should Be True           ${resp}  
  Should Be Equal          ${resp.json()}[instance_status]    IN EFFECT

Instance Has Been Deleted
  ${resp} =                   Retrieve A1 Instance
  ...                         ${POLICY_ID}
  ...                         ${instanceName}
  Should Be Equal As Strings  ${resp.status_code}  404

Policy Has Been Deleted
  ${resp} =                   Retrieve A1 Policy   ${POLICY_ID}
  Should Be Equal As Strings  ${resp.status_code}  404
