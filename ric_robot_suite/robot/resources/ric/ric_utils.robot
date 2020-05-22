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
Documentation  A library of utility keywords that may be useful
...            in various test suites.

Library        Collections

*** Keywords ***
#
# Kubernetes Utilities
Most Recent Availability Condition
  # this makes the probably-unsafe assumption that the conditions are ordered
  # temporally.
  [Arguments]  @{Conditions}
  ${status} =  Set Variable  'False'
  FOR  ${Condition}  IN  @{Conditions}
     ${status} =  Set Variable If  '${Condition.type}' == 'Available'  ${Condition.status}  ${status}
  END   
  [Return]  ${status}

Most Recent Container Logs
  [Arguments]  ${deployment}  ${container}=${EMPTY}  ${regex}=${EMPTY}
  ${pods} =            Retrieve Pods For Deployment  ${deployment}
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

Component Should Be Ready
  [Documentation]  Given a Kubernetes controller object as returned from the KubernetesEntity
  ...              library routines (such as 'Deployment' or Statefulset'), check whether the
  ...              entity is ready
  [Arguments]      ${entity}
  Should Be Equal  ${entity.status.replicas}           ${entity.status.ready_replicas}
  # This doesn't seem to make sense for statefulsets
  ${status} =      Run Keyword If                      '${entity.kind}' == 'Deployment'
  ...              Most Recent Availability Condition  @{entity.status.conditions}
  ...  ELSE
  ...              Set Variable                        True
  Should Be Equal As Strings  ${status}  True  ignore_case=True
  [Return]         ${status}
  
#
# Robot metatools
Run Keyword If Present
  [Documentation]  Run the given keyword, ignoring errors and returning status, if it exists.
  ...              Returns "PASS" if the keyword does not exist.
  [Arguments]            ${kw}
  ${exists}  ${u} =      Run Keyword And Ignore Error
  ...                    Keyword Should Exist          ${kw}
  ${status}  ${u} =      Run Keyword If                '${exists}' == 'PASS'
  ...                    Run Keyword And Ignore Error  ${kw}
  ...                    ELSE
  ...                    Set Variable   PASS  unused
  [Return]               ${status}

#
# Data manipulation
Toggle Flag
    [Documentation]      Apply "not" to a boolean flag
    [Arguments]          ${flag}
    ${bFlag} =           Convert To Boolean  ${flag}
    ${bFlag} =           Set Variable If     ${bFlag}  ${false}  ${true}
    [Return]             ${bFlag}

Most Recent Match
    [Arguments]    ${list}        ${regex}
    ${matches} =   Get Matches    ${list}     regexp=${regex}
    Should Not Be Empty           ${matches}  No log entries matching ${regex}
    ${match} =     Get From List  ${matches}  -1
    [Return]       ${match}
  
Pluck
     [Documentation]  Get the values of a specific key from a list of dictionaries
     [Arguments]      ${k}      ${l}
     @{names} =       Evaluate  filter(lambda v: v != None, [i.get('${k}', None) for i in ${l}])
     [Return]         ${names}

Subtract From List
     [Documentation]  Remove the elements of the second argument from the first
     [Arguments]      ${x}  ${y}
     ${diff} =        Run Keyword If  ${y}
     ...              Evaluate  filter(lambda v: v not in ${y}, ${x})
     ...              ELSE
     ...              Set Variable    ${x}
     [Return]         ${diff}
