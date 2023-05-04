*** Settings ***

Library                SSHLibrary
Resource               ssh_helper.robot
Resource               smo_server_mock.robot

Variables              ${EXECDIR}${/}test_configs.yaml

*** Variables ***
${HOST}                ${ocloud.ssh.host}
${PORT}                ${ocloud.ssh.port}
${USERNAME}            ${ocloud.ssh.username}
${PASSWORD}            ${ocloud.ssh.password}
${OPENRC}              ${ocloud.ssh.openrc}

*** Keywords ***
Setup Test Bed
    # [Arguments]    ${args}
    # Set Log Level   DEBUG
    Open Connection And Log In
    # bring up smo mock server
    # Setup SMO Server 
    # ${stdout}                        Execute Command     source ${OPENRC} && system host-list
    # bring up oran o2 app
    # Some Keyword    ${args}
    # Another Keyword

Tear Down Test Bed
    # [Arguments]    ${args}
    # tear down oran o2 app
    # tear down smo mock server
    # Tear Down SMO Server
    Close All Connections

Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

