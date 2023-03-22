*** Settings ***

# Library                SSHLibrary
Resource               ssh_helper.robot

Variables              ${EXECDIR}${/}test_configs.yaml

*** Variables ***
${HOST}                ${ocloud.ssh.host}
${PORT}                ${ocloud.ssh.port}
${USERNAME}            ${ocloud.ssh.username}
${PASSWORD}            ${ocloud.ssh.password}
${OPENRC}              ${ocloud.ssh.openrc}

${GLOBAL_OCLOUD_ID1}    ${ocloud.oran_o2_app.g_ocloud_id}

${mockserver_port}     1081
${mockserver_endpoint}      ${HOST}:${mockserver_port}
${testdir}              ocloudtest
${override_cmd}         cat <<EOF >ocloudtest/override.yaml
... smo_endpoint: ${mockserver_endpoint}/mock_smo/v1/ocloud_observer
... global_ocloud_id: ${GLOBAL_OCLOUD_ID1}
... EOF


*** Keywords ***
Setup Oran O2 App
    # [Arguments]    ${args}
    ${stdout}  ${stderr}  ${rc}=     Execute Command  docker run -d -p ${mockserver_port}:1080 --name ${mockserver_name} mockserver/mockserver


Tear Down Oran O2 App
    # [Arguments]    ${args}
    # tear down oran o2 app
    # tear down smo mock server
    # Tear Down SMO Server
    Close All Connections

Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}

