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
Documentation	  Initializes RIC Test Web Page and Password

Library    Collections
Library    OperatingSystem
Library    StringTemplater


Test Timeout    5 minutes

*** Variables ***
${URLS_HTML_TEMPLATE}   robot/assets/templates/web/index.html.template

${HOSTS_PREFIX}   vm
${WEB_USER}       test
${WEB_PASSWORD}

${URLS_HTML}   html/index.html
${CREDENTIALS_FILE}   /etc/lighttpd/authorization
#${CREDENTIALS_FILE}   authorization

*** Test Cases ***
Update RIC Page
    [Tags]   UpdateWebPage
    Run Keyword If   '${WEB_PASSWORD}' == ''   Fail   "WEB Password must not be empty"
    Run Keyword If   '${WEB_PASSWORD}' != ''   Create File   ${CREDENTIALS_FILE}   ${WEB_USER}:${WEB_PASSWORD}

*** Keywords ***
