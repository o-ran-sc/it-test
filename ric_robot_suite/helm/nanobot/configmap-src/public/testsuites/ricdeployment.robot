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
***settings ***
Documentation   Tests for the existence and functionality of RIC components

Resource       /robot/resources/global_properties.robot

Resource       /robot/resources/ric/ric_utils.robot

Library  KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE}
Library  Collections
Library  String

*** Keywords ***
Assign True
  [Return]      True

*** Variables ****
#&{GLOBAL_RICPLT_COMPONENTS}    {dbaas = statefulset|statefulset-ricplt-dbaas}

*** Test Cases ***
Ensure RIC components are deployed and available
  [Tags]  etetests  k8stests  ci_tests
  FOR  ${component}  IN  @{GLOBAL_RICPLT_COMPONENTS}
     ${controllerName} =  Get From Dictionary              ${GLOBAL_RICPLT_COMPONENTS}  ${Component}
     ${cType}  ${name} =  Split String  ${controllerName}  |
     Log To Console     ${cType}
     ${ctrl} =  Run Keyword     ${cType}        ${name}
     Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}
     Log To Console     ${Component}
     #Log To Console    ${cType}
     #

     Log To Console     ${ctrl.status}
     ${status} =        Run Keyword If  '${cType}' == 'deployment'
     ...                  Most Recent Availability Condition    @{ctrl.status.conditions}
     ...                ELSE
     ...                  Assign True
     Log To Console     ${status}
     Log To Console     ----------------------------
     Should Be Equal As Strings  ${status}  True  ignore_case=True  msg=${Component} is not available
  END

