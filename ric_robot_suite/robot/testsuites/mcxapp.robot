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

Resource       ../resources/xapps/mcxapp_properties.robot
Resource       ../resources/global_properties.robot

Library        Collections
Library        KubernetesEntity          ${GLOBAL_XAPP_NAMESPACE}

*** Variables ***
${deploymentName} =         ${GLOBAL_XAPP_NAMESPACE}-mcxapp
${listenerContainerName} =  mc-xapp-listener
${listenerStatRegex} =      ^[0-9]+\\s*\\[STAT\\]\\s*\\(mcl\\)
${recentListenerDrops} =    last 60s.*drops\\s*=\\s*[1-9]
${recentListenerErrors} =   last 60s.*errs\\s*=\\s*[1-9]

*** Test Cases ***
MC XApp Should Be Available
  [Tags]  etetests  xapptests  mcxapptests
  ${deploy} =          Deployment           ${deploymentName}
  ${status} =          Most Recent Availability Condition           @{deploy.status.conditions}
  Should Be Equal As Strings   ${status}  True  ignore_case=True

MC XApp Listener Should Not Be Dropping Messages
  [Tags]  etetests  xapptests  mcxapptests
  ${log} =  Most Recent Container Log  ${listenerContainerName}  ${listenerStatRegex}
  Should Not Contain Match             ${log}                    ${recentListenerDrops}
  
MC XApp Listener Should Not Be Producing Errors
  [Tags]  etetests  xapptests  mcxapptests
  ${log} =  Most Recent Container Log  ${listenerContainerName}  ${listenerStatRegex}
  Should Not Contain Match             ${log}                    ${recentListenerErrors}

Writer Should Be Successfully Sending Statistics
  [Tags]  etetests  xapptests  mcxapptests
  Set Test Variable  ${finalStatus}  PASS
  FOR  ${stat}  IN  @{GLOBAL_MCXAPP_WRITER_STATISTICS}
     ${statRE} =        Regexp Escape  ${stat}
     ${log} =           Most Recent Container Log
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

*** Keywords ***
Most Recent Availability Condition
  # this makes the probably-unsafe assumption that the conditions are ordered
  # temporally.
  [Arguments]  @{Conditions}
  ${status} =  Set Variable  'False'
  FOR  ${Condition}  IN  @{Conditions}
     ${status} =  Set Variable If  '${Condition.type}' == 'Available'  ${Condition.status}  ${status}
  END   
  [Return]  ${status}

Most Recent Match
  [Arguments]    ${list}        ${regex}
  ${matches} =   Get Matches    ${list}     regexp=${regex}
  Should Not Be Empty           ${matches}  No log entries matching ${regex}
  ${match} =     Get From List  ${matches}  -1
  [Return]       ${match}
  
Most Recent Container Log
  [Arguments]   ${container}=${EMPTY}  ${regex}=${EMPTY}
  ${pods} =            Retrieve Pods For Deployment  ${deploymentName}
  ${logs} =            Create List
  FOR  ${pod}  IN  @{pods}
     ${log} =   Retrieve Log For Pod     ${pod}             ${container}
     Should Not Be Empty        ${log}   No log entries for ${pod}/${container}
     ${line} =  Run Keyword If           "${regex}" != "${EMPTY}"
     ...                                 Most Recent Match  ${log}  ${regex}
     ...        ELSE
     ...                                 Get From List      ${log}  -1
     Append To List             ${logs}  ${line}
  END   
  [Return]                      ${logs}

