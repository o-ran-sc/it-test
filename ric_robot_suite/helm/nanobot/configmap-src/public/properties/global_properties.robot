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

{{- $domain := default "cluster.local" .Values.ric.cluster.domain }}
{{- $ricpltNS := include "common.namespace.platform" . }}
{{- $xappNS := include "common.namespace.xapp" . }}
{{- $ricplt := printf "%s.svc.%s" $ricpltNS $domain }}
{{- $release := default "r1" .Values.ric.robot.release }}
{{- $testxapp := default "robot-xapp" .Values.ric.robot.environment.xapp }}
{{- $dt := "deployment" }}
{{- $e2_suff := "alpha" }}
{{- $ds := "" }}
#
*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                  format is all caps with underscores between words and prepended with GLOBAL
...                  make sure you prepend them with GLOBAL so that other files can easily see it is from this file.


*** Variables ***
#{{ printf "%s.%s" (include "common.servicename.a1mediator.http" .) $ricplt }}
# {{ printf "%s-alpha.%s" (include "common.servicename.e2term.rmr" .) $ricplt}}
&{GLOBAL_RICPLT_COMPONENTS}           {{- range $k, $v := .Values.ric.platform.components }}
                                      {{- if $v }}
                                      {{- $ct := index $v "controller" }}
                                      {{- if $ct }}
                                      {{- $dt = index $ct "type" | default "deployment" | lower }}
                                      {{- $ds = index $ct "suffix" | default "" }}
                                      {{- if $ds }}
                                      {{- $ds = (printf "-%s" $ds) }}
                                      {{- end }}
                                      {{- else }}
                                      {{- $dt = "deployment" }}
                                      {{- $ds = "" }}
                                      {{- end }}
                                      {{- end }}
...                                   {{$k}}={{$dt}}|{{include (printf "common.%sname.%s" $dt $k) $}}{{$ds}}
                                      {{- end }}
&{GLOBAL_RICPLT_XAPPS}                {{- range keys .Values.ric.xapp }}
...                                   {{.}}={{ printf "%s-%s" $xappNS . }}
                                      {{- end }}
#
${GLOBAL_PLMNID}              {{ .Values.ric.robot.environment.gNodeB.plmnid }}
${GLOBAL_GNBID}               {{ .Values.ric.robot.environment.gNodeB.gnbid }}
#

${GLOBAL_APPLICATION_ID}              {{ default "r0" .Values.ric.robot.release | printf "nanobot-%s" }}
${GLOBAL_BUILD_NUMBER}                {{ default "0" .Values.ric.platform.build  }}
${GLOBAL_RICPLT_NAMESPACE}            {{ $ricpltNS  }}
${GLOBAL_XAPP_NAMESPACE}              {{ $xappNS  }}
#
{{- if .Values.ric.platform.components.appmgr }}
${GLOBAL_APPMGR_SERVER_PROTOCOL}      {{ default "http" .Values.ric.platform.components.appmgr.protocol  }}
${GLOBAL_INJECTED_APPMGR_IP_ADDR}     {{ printf "%s.%s" (include "common.servicename.appmgr.http" .) $ricplt  }}
${GLOBAL_APPMGR_SERVER_PORT}          {{ include "common.serviceport.appmgr.http" .  }}
${GLOBAL_INJECTED_APPMGR_USER}        {{ .Values.ric.platform.components.appmgr.user  }}
${GLOBAL_INJECTED_APPMGR_PASSWORD}    {{ .Values.ric.platform.components.appmgr.password  }}
{{- end }}
#
{{- if .Values.ric.platform.components.e2mgr }}
${GLOBAL_E2MGR_SERVER_PROTOCOL}       {{ default "http" .Values.ric.platform.components.e2mgr.protocol  }}
${GLOBAL_INJECTED_E2MGR_IP_ADDR}      {{ printf "%s.%s" (include "common.servicename.e2mgr.http" .) $ricplt  }}
${GLOBAL_E2MGR_SERVER_PORT}           {{ include "common.serviceport.e2mgr.http" .  }}
${GLOBAL_INJECTED_E2MGR_USER}         {{ .Values.ric.platform.components.e2mgr.user  }}
${GLOBAL_INJECTED_E2MGR_PASSWORD}     {{ .Values.ric.platform.components.e2mgr.password  }}
{{- end }}
#
{{- if .Values.ric.platform.components.e2term }}
${GLOBAL_INJECTED_E2TERM_IP_ADDR}           {{ printf "%s-alpha.%s" (include "common.servicename.e2term.rmr" .) $ricplt}}
${GLOBAL_E2TERM_SERVER_PORT}           {{ include "common.serviceport.e2term.rmr.data" .  }}
{{- end }}
#
{{- if .Values.ric.platform.components.rtmgr }}
${GLOBAL_RTMGR_SERVER_PROTOCOL}       {{ default "http" .Values.ric.platform.components.rtmgr.protocol  }}
${GLOBAL_INJECTED_RTMGR_IP_ADDR}      {{ printf "%s.%s" (include "common.servicename.rtmgr.http" .) $ricplt  }}
${GLOBAL_RTMGR_SERVER_PORT}           {{ include "common.serviceport.rtmgr.http" .  }}
${GLOBAL_RTMGR_SERVER_HTTP_PORT}      {{ default "8080" }}
${GLOBAL_INJECTED_RTMGR_USER}         {{ .Values.ric.platform.components.rtmgr.user  }}
${GLOBAL_INJECTED_RTMGR_PASSWORD}     {{ .Values.ric.platform.components.rtmgr.password  }}
{{- end }}
#
#
{{- if .Values.ric.platform.components.a1mediator }}
${GLOBAL_A1MEDIATOR_SERVER_PROTOCOL}       {{ default "http" .Values.ric.platform.components.a1mediator.protocol }}
${GLOBAL_INJECTED_A1MEDIATOR_IP_ADDR}      {{ printf "%s.%s" (include "common.servicename.a1mediator.http" .) $ricplt }}
${GLOBAL_A1MEDIATOR_SERVER_PORT}           {{ include "common.serviceport.a1mediator.http" . }}
${GLOBAL_A1MEDIATOR_POLICY_ID}             {{ default "6266268" .Values.ric.platform.components.a1mediator.policyID }}
${GLOBAL_A1MEDIATOR_TARGET_XAPP}           {{ default $testxapp .Values.ric.platform.components.a1mediator.xappName }}
{{- end }}
#
{{- if .Values.ric.platform.components.o1mediator }}
${GLOBAL_O1MEDIATOR_SERVER_PROTOCOL}    {{ default "http" .Values.ric.platform.components.o1mediator.protocol }}
${GLOBAL_O1MEDIATOR_HTTP_SERVER}        {{ printf "%s.%s" (include "common.servicename.o1mediator.http" .) $ricplt }}
${GLOBAL_O1MEDIATOR_SERVER_PORT}        {{ include "common.serviceport.o1mediator.http" . }}
${GLOBAL_O1MEDIATOR_HOST}               {{ printf "%s.%s" (include "common.servicename.o1mediator.tcp.netconf" .) $ricplt }}
${GLOBAL_O1MEDIATOR_PORT}               {{ include "common.serviceport.o1mediator.tcp.netconf" .  }}
${GLOBAL_O1MEDIATOR_USER}               {{ .Values.ric.platform.components.o1mediator.user }}
${GLOBAL_O1MEDIATOR_PASSWORD}           {{ .Values.ric.platform.components.o1mediator.password }}
${GLOBAL_O1MEDIATOR_TARGET_XAPP}        {{ default $testxapp .Values.ric.platform.components.o1mediator.xapp.name }}
${GLOBAL_O1MEDIATOR_XAPP_VERSION}       {{ default "1.0" .Values.ric.platform.components.o1mediator.xapp.version }}
${GLOBAL_O1MEDIATOR_DEPLOYMENT_WAIT}    {{ default "180" .Values.ric.platform.components.o1mediator.xapp.wait }}
{{- end }}
#
{{- if .Values.ric.platform.components.submgr }}
${GLOBAL_SUBMGR_SERVER_PROTOCOL}      {{ default "http" .Values.ric.platform.components.submgr.protocol }}
${GLOBAL_SUBMGR_HTTP_SERVER}          {{ printf "%s.%s" (include "common.servicename.submgr.http" .) $ricplt }}
${GLOBAL_SUBMGR_SERVER_PORT}          {{ include "common.serviceport.submgr.http" . }}
${GLOBAL_SUBMGR_SERVER_PROTOCOL}      {{ default "http" .Values.ric.platform.components.submgr.protocol  }}
${GLOBAL_INJECTED_SUBMGR_IP_ADDR}     {{ printf "%s.%s" (include "common.servicename.submgr.http" .) $ricplt  }}
${GLOBAL_INJECTED_SUBMGR_USER}        {{ .Values.ric.platform.components.submgr.user  }}
${GLOBAL_INJECTED_SUBMGR_PASSWORD}    {{ .Values.ric.platform.components.submgr.password  }}
{{- end }}
#
${GLOBAL_TEST_XAPP}                   {{ default "xapp-std" .Values.ric.robot.environment.xapp }}
${GLOBAL_TEST_XAPP_ONBOARDER}         {{ default "deployment|deployment-ricplt-xapp-onboarder" }}
#
${GLOBAL_TEST_NODEB_NAME}             {{ default "AAAA456789" .Values.ric.robot.environment.gNodeB.name }}
${GLOBAL_TEST_NODEB_ADDRESS}          {{ default "10.0.0.3"   .Values.ric.robot.environment.gNodeB.address }}
${GLOBAL_TEST_NODEB_PORT}             {{ default "36421"      .Values.ric.robot.environment.gNodeB.port }}
#
${GLOBAL_DASH_SERVER_PROTOCOL}        {{ default "http"       .Values.ric.robot.environment.dashboard.protocol }}
${GLOBAL_DASH_SERVER_PORT}            {{ default "31080"      .Values.ric.robot.environment.dashboard.port }}
${GLOBAL_INJECTED_DASH_IP_ADDR}       {{ default "127.0.0.1"  .Values.ric.robot.environment.dashboard.port }}
${GLOBAL_XAPP}                        {{ .Values.ric.robot.environment.xapp }}
${GLOBAL_DUPLICATE_XAPP}              {{ .Values.ric.robot.environment.duplicate_xapp }}
${GLOBAL_XAPP_DEPLOYMENT}             {{ printf "%s-%s" ($xappNS) .Values.ric.robot.environment.xapp }}
${GLOBAL_XAPPKPIMON_DEPLOYMENT}       {{ printf "%s"  .Values.ric.robot.environment.xapp }}
${Global_RAN_NAMESPACE}               {{ .Values.ric.robot.environment.gNodeB.ran_namespace }}
${Global_RAN_DEPLOYMENT}              {{ .Values.ric.robot.environment.gNodeB.ran_deployment }}
#
${GLOBAL_CLUSTER_IP}        {{ .Values.ric.robot.environment.cluster.cluster.ip }}
${Global_Username}          {{ .Values.ric.robot.environment.cluster.username }}
${Global_Password}          {{ .Values.ric.robot.environment.cluster.password }}

