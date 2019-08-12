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
