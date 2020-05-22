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

Resource       ../resources/global_properties.robot
Resource       ../resources/ric/ric_utils.robot

Library  KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE}
Library  Collections
Library  String

*** Test Cases ***
Deployments
  [Tags]  etetests  k8stests  ci_tests
  FOR  ${component}  IN  @{GLOBAL_RICPLT_COMPONENTS}
     ${controllerName} =  Get From Dictionary              ${GLOBAL_RICPLT_COMPONENTS}  ${Component}
     ${cType}  ${name} =  Split String  ${controllerName}  |
     ${ctrl} =            Run Keyword   ${cType}           ${name}
     Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}
     # this doesn't seem to exist for statefulsets
     ${status} =          Run Keyword If       '${cType}' == 'deployment'
     ...                  ${status} =          Most Recent Availability Condition  @{deploy.status.conditions}
     ...  ELSE
     ...                  Set Variable         'True'
     Should Be Equal As Strings  ${status}  True  ignore_case=True  msg=${Component} is not available
  END
  
  