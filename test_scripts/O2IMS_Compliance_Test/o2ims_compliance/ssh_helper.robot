*** Settings ***

Library                SSHLibrary
Variables              ${EXECDIR}${/}test_configs.yaml

*** Variables ***
${HOST}                ${ocloud.ssh.host}
${PORT}                ${ocloud.ssh.port}
${USERNAME}            ${ocloud.ssh.username}
${PASSWORD}            ${ocloud.ssh.password}
${OPENRC}              ${ocloud.ssh.openrc}

${DD_TEST_ASSERT_CMD}     "dd if=/dev/zero of=/home/sysadmin/fullfill-8G.zeros bs=512M count=15"
${DD_TEST_CLEAR_CMD}        "[ -e '/home/sysadmin/fullfill-8G.zeros' ] && rm /home/sysadmin/fullfill-8G.zeros "
${VERIFY_ALARM_ASSERTED}  "fm alarm-list"

*** Keywords ***
Open Connection And Log In
    Open Connection                  ${HOST}             port=${PORT}
    Login                            ${USERNAME}         ${PASSWORD}

Execute Command With Sudo
    [Documentation]               Execute Command With Sudo and always return stderr and rc
    [Arguments]                   ${cmd}
    ${stdout}  ${stderr}  ${rc}=  Execute Command               ${cmd}  sudo=True  sudo_password=${PASSWORD}  return_stderr=True  return_rc=True
    log                           rc = ${rc}   level=DEBUG
    Should Be Equal               ${rc} 0
    RETURN                        ${stdout}  ${stderr}  ${rc}

Assert Alarm With Disk Usage
    [Documentation]               Set up conditions to assert disk usage StarlingX Alarm
    ${stdout}  ${stderr}  ${rc}=  Execute Command    ${DD_TEST_ASSERT_CMD}  return_stderr=True  return_rc=True
    log                           rc = ${rc}   level=DEBUG
    Should Be Equal               ${rc} 0
    RETURN                        ${stdout}  ${stderr}  ${rc}

Clear Alarm With Disk Usage
    [Documentation]               Tear down conditions to clear disk usage StarlingX Alarm
    ${stdout}  ${stderr}  ${rc}=  Execute Command    ${DD_TEST_CLEAR_CMD}  return_stderr=True  return_rc=True
    log                           rc = ${rc}   level=DEBUG
#     Should Be Equal               ${rc}  0
    RETURN                        ${stdout}  ${stderr}  ${rc}
