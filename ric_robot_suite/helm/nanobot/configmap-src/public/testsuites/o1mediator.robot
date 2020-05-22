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
Documentation  Tests for the UE Event Collector XApp

Resource       /robot/resources/global_properties.robot

Resource       /robot/resources/o1mediator/o1mediator_interface.robot
Resource       /robot/resources/ric/ric_utils.robot

Library        String
Library        Collections
Library        XML

Library        KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE}

*** Variables ***
${sessionPfx} =   nanobot-O1

*** Test Cases ***
O1 Mediator Should Be Available
  [Tags]   etetests  o1mediatortests
  ${c} =            Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  o1mediator
  ${ctrl}  ${o1} =  Split String         ${c}           |
  ${deploy} =       Run Keyword          ${ctrl}        ${o1}
  Component Should Be Ready              ${deploy}

Connect To O1 Mediator
   [tags]  etetests  o1mediatortests
   ${sessionGensym} =    Generate Random String
   ${O1Session} =        Set Variable  ${sessionPfx}-${sessionGensym}
   Set Suite Variable    ${O1Session}
   Set Suite Variable    ${O1Session}
   ${status} =           Establish O1 Session
   ...                   ${GLOBAL_O1MEDIATOR_USER}
   ...                   ${GLOBAL_O1MEDIATOR_PASSWORD}
   ...                   ${O1Session}
   ...                   ${GLOBAL_O1MEDIATOR_HOST}
   ...                   ${GLOBAL_O1MEDIATOR_PORT}
   Should Be True        ${status}

Get O1 State
   [tags]  etetests  o1mediatortests
   ${conf} =         Retrieve O1 State  ${O1Session}
   # just going to let this bail at a lower layer if
   # the Get fails.  Might be better to look for ric stuff
   # in the active modules, though.
   ${confXML} =      Element To String  ${conf}
   
Deploy XApp Via O1
   [tags]  etetests  o1mediatortests  intrusive
   Deploy An XApp Using O1  ${O1Session}
   ...                      ${GLOBAL_O1MEDIATOR_TARGET_XAPP}
   ...                      ${GLOBAL_O1MEDIATOR_XAPP_VERSION}

XApp Should Be Running
   [tags]  etetests  o1mediatortests
   Wait For Deployment      ${GLOBAL_XAPP_NAMESPACE}-${GLOBAL_O1MEDIATOR_TARGET_XAPP}
   ...                      timeout=${GLOBAL_O1MEDIATOR_DEPLOYMENT_WAIT}
   ...                      namespace=${GLOBAL_XAPP_NAMESPACE}

Undeploy XApp Via O1
   [tags]  etetests  o1mediatortests  intrusive
   Remove An XApp Using O1  ${O1Session}
   ...                      ${GLOBAL_O1MEDIATOR_TARGET_XAPP}
   ...                      ${GLOBAL_O1MEDIATOR_XAPP_VERSION}

XApp Should Not Be Running
   [tags]  etetests  o1mediatortests
   ${status}  ${deploy} =      Run Keyword And Ignore Error
   ...                         Deployment  ${GLOBAL_XAPP_NAMESPACE}-${GLOBAL_O1MEDIATOR_TARGET_XAPP}
   ${status} =                 Run Keyword If  '${status}' == 'PASS'
   ...                         Most Recent Availablity Condition  @{deploy.status.conditions}
   ...  ELSE
   ...                         Set Variable   False
   Should Be Equal As Strings  '${status}'  'False'
   
Disconnect From O1
   [tags]  etetests  o1mediatortests
   Close O1 Session  ${O1Session}
