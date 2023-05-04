*** Settings ***
Documentation          This is Compliance Test to O-RAN O2 Spec. July 2022
...
Variables              ${EXECDIR}${/}test_configs.yaml
Resource               oran-lcm.robot

Library                SSHLibrary
Suite Setup            Setup Test Bed
Suite Teardown         Tear Down Test Bed

*** Variables ***
${HOST}                ${ocloud.ssh.host}
${PORT}                ${ocloud.ssh.port}
${USERNAME}            ${ocloud.ssh.username}
${PASSWORD}            ${ocloud.ssh.password}
${OPENRC}              ${ocloud.ssh.openrc}

*** Keywords ***
Setup Test Bed
    # [Arguments]    ${args}
    Open Connection And Log In
    # bring up smo mock server
    # bring up oran o2 app
    # Some Keyword    ${args}
    # Another Keyword

Tear Down Test Bed
    # [Arguments]    ${args}
    # tear down oran o2 app
    # tear down smo mock server
    Close All Connections

Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
