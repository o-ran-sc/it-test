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
Documentation  Tests for the Measurement Campaign XApp


Resource       /robot/resources/global_properties.robot
Resource       /robot/resources/mcxapp_properties.robot

Resource       /robot/resources/ric/ric_utils.robot

Library        Collections
Library        KubernetesEntity          ${GLOBAL_XAPP_NAMESPACE}

*** Variables ***
${writerVesSuccesses}       .*successful\\s+ves\\s+posts\\s*-\\s*([1-9][0-9]*)
${writerVesErrors}          .*failed\\s+ves\\s+posts\\s*-\\s*([1-9][0-9]*)

*** Test Cases ***
XApp Should Be Available
  [Tags]  etetests  xapptests  mcxapptests
  ${deploymentName} =  Get From Dictionary  ${GLOBAL_RICPLT_XAPPS}  mcxapp
  Set Suite Variable   ${deploymentName}
  ${deploy} =          Deployment           ${deploymentName}
  ${status} =          Most Recent Availability Condition           @{deploy.status.conditions}
  Should Be Equal As Strings   ${status}  True  ignore_case=True

Writer Should Be Successfully Sending Statistics
  [Tags]  etetests  xapptests  mcxapptests
  Set Test Variable  ${finalStatus}  PASS
  FOR  ${stat}  IN  @{GLOBAL_MCXAPP_WRITER_STATISTICS}
     ${statRE} =        Regexp Escape  ${stat}
     ${log} =           Most Recent Container Logs    ${deploymentName}
     ...                ${GLOBAL_MCXAPP_WRITER_NAME}
     ...                ^${statRE}:\\s+successful\\s+ves\\s+posts\\.*
     ${status}  ${u} =  Run Keyword And Ignore Error
     ...                Should Contain Match  ${log}  regexp=${writerVesSuccesses}
     ${finalStatus} =   Set Variable If  "${status}" == "FAIL"
     ...                FAIL
     ...                ${finalStatus}
     Run Keyword If     "${status}" == "FAIL"
     ...                Log  No messages have been sent to VES for ${stat}
     ${status}  ${u} =  Run Keyword And Ignore Error
     ...                Should Not Contain Match  ${log}  regexp=${writerVesErrors}
     ${finalStatus} =   Set Variable If  "${status}" == "FAIL"
     ...                FAIL
     ...                ${finalStatus}
     Run Keyword If     "${status}" == "FAIL"
     ...                Log  ${stat} is producing errors logging to VES
  END
  Run Keyword If        "${finalStatus}" == "FAIL"
  ...                   Fail  One or more statistics is not being succesfully logged

