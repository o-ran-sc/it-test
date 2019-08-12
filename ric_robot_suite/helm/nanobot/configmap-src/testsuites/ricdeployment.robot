#   Copyright (c) 2019 AT&T Intellectual Property.
#   Copyright (c) 2019 Nokia.
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
Documentation   Tests for the existence and functionality of RIC components

Library  KubernetesEntity  ${NAMESPACE}
Library  Collections
Library  String

# Resource        ../resources/appmgr/appmgr_interface.robot
# Resource         ../resources/e2mgr/e2mgr_interface.robot

*** Variables ***
${NAMESPACE}   %{RICPLT_NAMESPACE}
${PFX}         %{RICPLT_RELEASE_NAME}

*** Test Cases ***
Deployments
  [Tags]  etetests  k8stests
  @{Components} =  Split String  %{RICPLT_COMPONENTS}
  :FOR  ${Component}  IN  @{Components}
  \  Log  Retrieving Deployment for ${Component}
  \  ${deploy} =  Deployment   ${PFX}-${Component}
  \  ${status} =  Most Recent Availability Condition  @{deploy.status.conditions}
  \  Should Be Equal As Strings  ${status}  True  ignore_case=True  msg=${Component} is not available
  
*** Keywords ***
Most Recent Availability Condition
  # this makes the probably-unsafe assumption that the conditions are ordered
  # temporally.
  [Arguments]  @{Conditions}
  ${status} =  Set Variable  'False'
  :FOR  ${Condition}  IN  @{Conditions}
  \  ${status} =  Set Variable If  '${Condition.type}' == 'Available'  ${Condition.status}  ${status}
  [Return]  ${status}
