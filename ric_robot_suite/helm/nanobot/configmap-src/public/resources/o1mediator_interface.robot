#   Copyright (c) 2019 AT&T Intellectual Property. 
#   Copyright (c) 2020 HCL Technologies Limited. 
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
Library  XML              use_lxml=True 
Library  NcclientLibrary 
 
Resource       /robot/resources/global_properties.robot 
Resource       /robot/resources/ric/ric_utils.robot 
 
*** Variables *** 
${XAppNS}                 urn:o-ran:ric:xapp-desc:1.0 
${NetconfNS}              urn:ietf:params:xml:ns:netconf:base:1.0 
${ricXML} =               <ric xmlns="${XAppNS}"></ric> 
${configXML}              <config xmlns="${NetconfNS}">${ricXML}</config> 
${O1MEDIATOR_ENDPOINT}   ${GLOBAL_O1MEDIATOR_SERVER_PROTOCOL}://${GLOBAL_O1MEDIATOR_HTTP_SERVER}:${GLOBAL_O1MEDIATOR_SERVER_PORT} 
 
*** Keywords *** 
Run o1mediator Health Check 
     [Documentation]    Runs O1Mediator Health check 
     ${resp} =   Run Keyword    Run o1mediator GET Request 
 
Run o1mediator GET Request 
     [Documentation]  Make an HTTP GET request against the XApp manager 
     [Arguments]   ${path}=${EMPTY} 
     ${session} =  Create Session     roboo1mediatorGet               ${O1MEDIATOR_ENDPOINT} 
     ${headers} =  Create Dictionary  Accept=application/json         Content-Type=application/json 
     ${resp} =     Get Request        roboo1mediatorGet                ${O1MEDIATOR_ENDPOINT}   headers=${headers} 
     [Return]      ${resp} 
 
 
Establish O1 Session 
  [Arguments]  ${user} 
  ...          ${password} 
  ...          ${session} 
  ...          ${host}=service-ricplt-o1mediator-tcp-netconf.ricplt 
  ...          ${port}=830 
  ...          ${hostkey_verify}=${False} 
  ...          ${key}=/dev/null 
  ${status} =  Connect      host=${host} 
  ...           port=${port} 
  ...           username=${user} 
  ...           password=${password} 
  ...           key_filename=${key} 
  ...           look_for_keys=False 
  ...           alias=${session} 
  [Return]     ${status} 
 
Retrieve O1 State 
  [Arguments]     ${session} 
  # this doesn't actually seem to result in filtered XML, 
  # but it matches what the O1 CLI does. 
  ${filter} =     Parse XML   ${ricXML} 
  ${config} =     Get         ${session}  filter_criteria=${filter} 
  [Return]        ${config} 
 
Retrieve O1 Running Configuration 
  [Arguments]     ${session} 
  ${config} =     Get Config  ${session}  running 
  [Return]        ${config} 
 
Deploy An XApp Using O1 
  [Arguments]         ${session}   ${app}   ${version} 
  ${xappCreateXML} =  Generate XApp Deployment XML  ${app}  ${version}  create 
  Edit Config         ${session}   running  ${xappCreateXML} 
 
Remove An XApp Using O1 
  [Arguments]         ${session}   ${app}   ${version} 
  ${xappDeleteXML} =  Generate XApp Deployment XML  ${app}  ${version}  delete 
  Edit Config         ${session}   running  ${xappDeleteXML} 
 
Close O1 Session 
  [Arguments]         ${session} 
  Close Session       ${session} 
 
*** Keywords *** 
Generate XApp Deployment XML 
  [Arguments]  ${name}    ${version}  ${operation} 
  ${XML} =     Parse XML  ${configXML} 
  Add Element  ${XML} 
  ...                     <xapps xmlns="${XAppNS}"></xapps> 
  ...                     xpath=ric 
  Add Element  ${XML}     <xapp xmlns:xc="${NetconfNS}" xc:operation="${operation}"></xapp> 
  ...                     xpath=ric/xapps 
  Add Element  ${XML} 
  ...                     <name>${name}</name> 
  ...                     xpath=ric/xapps/xapp 
  Add Element  ${XML}     <release-name>xapp-${name}</release-name> 
  ...                     xpath=ric/xapps/xapp 
  Add Element  ${XML}     <version>${version}</version> 
  ...                     xpath=ric/xapps/xapp 
  Add Element  ${XML}     <namespace>${GLOBAL_XAPP_NAMESPACE}</namespace> 
  ...                     xpath=ric/xapps/xapp 
  [Return]                ${XML} 

