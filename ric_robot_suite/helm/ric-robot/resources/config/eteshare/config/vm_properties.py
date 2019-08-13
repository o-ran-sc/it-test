# Copyright (c)  2019 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# File generated from /opt/config
#


GLOBAL_INJECTED_APPMGR_IP_ADDR = "service-{{ .Release.Namespace }}-appmgr-http.{{ .Release.Namespace }}"
GLOBAL_INJECTED_APPMGR_USER = "test"
GLOBAL_INJECTED_APPMGR_PASSWORD = "test"

GLOBAL_INJECTED_DASH_IP_ADDR = "{{ .Values.config.dashboardExternalIp }}"
GLOBAL_INJECTED_DASH_USER = "test"
GLOBAL_INJECTED_DASH_PASSWORD = "test"

GLOBAL_INJECTED_E2MGR_IP_ADDR = "service-{{ .Release.Namespace }}-e2mgr-http.{{ .Release.Namespace }}"
GLOBAL_INJECTED_E2MGR_USER = "test"
GLOBAL_INJECTED_E2MGR_PASSWORD = "test"

GLOBAL_INJECTED_RTMGR_IP_ADDR = "service-{{ .Release.Namespace }}-rtmgr-http.{{ .Release.Namespace }}"
GLOBAL_INJECTED_RTMGR_USER = "test"
GLOBAL_INJECTED_RTMGR_PASSWORD = "test"

GLOBAL_INJECTED_PROPERTIES = {
    "GLOBAL_INJECTED_APPMGR_IP_ADDR" : "service-{{ .Release.Namespace }}-appmgr-http.{{ .Release.Namespace }}",
    "GLOBAL_INJECTED_APPMGR_USER" : "test",
    "GLOBAL_INJECTED_APPMGR_PASSWORD" : "test",
    "GLOBAL_INJECTED_DASH_IP_ADDR" : "{{ .Values.config.dashboardExternalIp }}",
    "GLOBAL_INJECTED_DASH_USER" : "test",
    "GLOBAL_INJECTED_DASH_PASSWORD" : "test",
    "GLOBAL_INJECTED_E2MGR_IP_ADDR" : "service-{{ .Release.Namespace }}-e2mgr-http.{{ .Release.Namespace }}",
    "GLOBAL_INJECTED_E2MGR_USER" : "test",
    "GLOBAL_INJECTED_E2MGR_PASSWORD" : "test",
    "GLOBAL_INJECTED_RTMGR_IP_ADDR" : "service-{{ .Release.Namespace }}-rtmgr-http.{{ .Release.Namespace }}",
    "GLOBAL_INJECTED_RTMGR_USER" : "test",
    "GLOBAL_INJECTED_RTMGR_PASSWORD" : "test"
}

