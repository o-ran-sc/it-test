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
Documentation  Tools for interacting with the MC XApp

Resource       /robot/resources/global_properties.robot
Resource       /robot/resources/mcxapp_properties.robot

Library        Collections
Library        String
Library        KubernetesEntity       ${GLOBAL_XAPP_NAMESPACE}

*** Variables ***

${listenerStatSubstring}              (mcl) mtype=
${listenerStatRegex}                  ^\\s*([0-9]+)\\s+\\[STAT\\]\\s+\\(mcl\\)\\s+mtype=([^\\s]+)\\s+total\\s+writes=([0-9]+)\\s+total\\s+drops=([0-9]+);.*writes=([0-9]+)\\s+drops=([0-9]+)

*** Keywords ***
Retrieve Listener Message Counts
  ${pods} =       Retrieve Pods For Deployment  ${MCDeployment}
  # for now, i'm just going to completely ignore the possibility
  # of multiple MC XApp pods.  that seems safe, i think.
  ${pod} =        Get From List         ${pods}  0
  ${log} =        Retrieve Log For Pod  ${pod}   tail=500
  ${statLogs} =   Get Matches           ${log}   glob=*${listenerStatSubstring}*
  ${stats} =      Parse Listener Statistics      ${statLogs}
  [Return]        ${stats}

Parse Listener Statistics
  [Arguments]  ${logLines}
  # while it's almost certainly safe to assume the log
  # lines are sorted by timestamp, it's not something i'm
  # going to take for granted.
  ${stats} =         Create Dictionary
  FOR  ${statLine}  IN  @{logLines}
     ${match}  ${ts}  ${mtype}  ${tWrites}  ${tDrops}  ${rWrites}  ${rDrops} =
     ...  Should Match Regexp   ${statLine}  ${listenerStatRegex}
     ${stat} =        Create Dictionary
     ...              timestamp=${ts}
     ...              totalWrites=${tWrites}
     ...              totalDrops=${tDrops}
     ...              recentWrites=${rWrites}
     ...              recentDrops=${rDrops}
     ${s}  ${d} =     Run Keyword And Ignore Error
     ...              Get From Dictionary  ${stats}  ${mtype}
     ${prevTS} =      Run Keyword If       "${s}" == "PASS"
     ...              Get From Dictionary  ${d}  timestamp
     ...  ELSE
     ...              Set Variable         -1
     Run Keyword If   ${ts} > ${prevTS}
     ...              Set To Dictionary  ${stats}  ${mtype}  ${stat}
  END
  [Return]     ${stats}
