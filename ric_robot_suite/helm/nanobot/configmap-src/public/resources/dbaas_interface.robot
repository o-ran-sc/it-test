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
Documentation  Tests for the UE Event Collector XApp 
 
Resource       /robot/resources/global_properties.robot 
Resource       /robot/resources/ric/ric_utils.robot 
 
Library        String 
Library        Collections 
Library        XML 
 
Library        KubernetesEntity  ${GLOBAL_RICPLT_NAMESPACE} 
Library        SDLWrapper       False 
*** Variables *** 
 
*** Keywords *** 
Run dbaas Health Check 
     [Documentation]  Runs dbaas Health check 
     ${data_path} =  Set Variable           /v1/health 
     ${resp} =       Run dbaas GET Request 
 
Run dbaas GET Request 
  ${c} =            Get From Dictionary  ${GLOBAL_RICPLT_COMPONENTS}  dbaas 
  ${ctrl}  ${dbaas1} =  Split String         ${c}       | 
  ${deploy} =       Run Keyword          ${ctrl}        ${dbaas1} 
  ${log} =      Run Keyword     healthcheck 
  Log To Console        ${log} 
  Log   ${log}  console=yes 
  [Return]        ${deploy} 

