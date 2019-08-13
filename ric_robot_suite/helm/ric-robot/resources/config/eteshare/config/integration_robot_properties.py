# Copyright (c) 2019 AT&T Intellectual Property. All rights reserved.
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

# APPMGR
# http:88 is for testing only
GLOBAL_APPMGR_SERVER_PROTOCOL="http"
GLOBAL_APPMGR_SERVER_PORT="8080"
#GLOBAL_APPMGR_SERVER_PORT="80"
# E2MGR
# http:88 is for testing only
GLOBAL_E2MGR_SERVER_PROTOCOL="http"
GLOBAL_E2MGR_SERVER_PORT="3800"
#GLOBAL_E2MGR_SERVER_PORT="80"
# RTMGR
GLOBAL_RTMGR_SERVER_PROTOCOL="http"
GLOBAL_RTMGR_SERVER_PORT="5656"
# DASHBOARD
GLOBAL_DASH_SERVER_PROTOCOL="http"
GLOBAL_DASH_SERVER_PORT="{{ .Values.config.dashboardExternalPort }}"
#global selenium info
GLOBAL_PROXY_WARNING_TITLE=""
GLOBAL_PROXY_WARNING_CONTINUE_XPATH=""
