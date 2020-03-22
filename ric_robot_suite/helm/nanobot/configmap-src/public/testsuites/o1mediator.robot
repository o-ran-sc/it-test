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
Library        KubernetesEntity       ${GLOBAL_XAPP_NAMESPACE}
Library        XML

*** Variables ***
${sessionPfx} =   nanobot-O1

*** Test Cases ***
O1 Mediator Should Be Available
  [Tags]   etetests  o1mediatortests
  ${o1} =        Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  o1mediator
  ${O1Deploy} =  Deployment           ${o1}
  ${status} =    Most Recent Availability Condition  @{deploy.status.conditions}
  Should Be Equal As Strings          ${status}  True  ignore_case=True

Connect To O1 Mediator
   [tags]  etetests  o1mediatortests
   ${sessionGensym} =    Generate Random String
   ${O1Session} =        Set Variable  ${sessionPfx}-${sessionGensym}
   Set Suite Variable    ${O1Session}
   Log To Console        Session ${O1Session}
   Set Suite Variable    ${O1Session}
   ${status} =           Establish O1 Session
   ...                   ${GLOBAL_O1MEDIATOR_USER}
   ...                   ${GLOBAL_O1MEDIATOR_PASSWORD}
   ...                   ${O1Session}
   ...                   ${GLOBAL_O1MEDIATOR_HOST}
   ...                   ${GLOBAL_O1MEDIATOR_PORT}
   Should Be True        ${status}

O1 Netconf Configuration Should Be Available
   [tags]  etetests  o1mediatortests
   ${conf} =         Retrieve O1 Running Configuration  ${O1Session}

Deploy XApp Via O1
   [tags]  etetests  o1mediatortests  intrusive
   Deploy An XApp Using O1  ${O1Session}
   ...                      ${GLOBAL_O1MEDIATOR_TARGET_XAPP}
   ...                      ${GLOBAL_O1MEDIATOR_XAPP_VERSION}
