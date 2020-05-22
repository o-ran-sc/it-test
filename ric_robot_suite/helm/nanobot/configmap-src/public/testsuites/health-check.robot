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
Documentation      Run basic health checks for all known components which have one

Resource           /robot/resources/global_properties.robot

Resource           /robot/resources/ric/ric_utils.robot

*** Test Cases ***
Basic Component Health Checks
  [Documentation]  For any defined RIC component with a health check keyword,
  ...              Run that keyword.  "Health check" keywords have names of the
  ...              form "Run ${component} Health Check".
  # This could have been entirely implemented in Helm; however, I wanted to
  # allow for the possibility that it would be used (with some modification)
  # by the ric-robot, which does not perform template expansion on testsuites.
  [Tags]  health
  Set Test Variable    ${finalStatus}  PASS
  FOR   ${component}  IN              @{GLOBAL_RICPLT_COMPONENTS}
     Run Keyword And Ignore Error
     ...   Import Resource                /robot/resources/${component}/${component}_interface.robot
     ${healthCheck} =  Set Variable    Run ${component} Health Check
     ${status} =       Run Keyword If Present                   ${healthCheck}
     ${finalStatus} =  Set Variable If   '${status}' == 'FAIL'  FAIL  ${finalStatus}
     Run Keyword If    '${status}' == 'FAIL'
     ...               Log  ${component} is unhealthy
  END
  Run Keyword If       '${finalStatus}' == 'FAIL'
  ...                  Fail  One or more Health Checks failed
