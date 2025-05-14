
*** Settings ***

# Library                SSHLibrary
Resource               ssh_helper.robot
Resource               smo_server_mock.robot
Variables              ${EXECDIR}${/}test_configs.yaml


*** Variables ***
${HOST}                ${ocloud.ssh.host}
${PORT}                ${ocloud.ssh.port}
${USERNAME}            ${ocloud.ssh.username}
${PASSWORD}            ${ocloud.ssh.password}
${OPENRC}              ${ocloud.ssh.openrc}

${mockserver_port}     1081
${mockserver_name}     smo1

${SMO_VERIFY_URL}     ${smo.service.protocol}://${smo.service.host}:${smo.service.port}${smo.service.verify_endpoint}
${SMO_INV_OBSERVER_URL}     ${smo.service.protocol}://${smo.service.host}:${smo.service.port}${smo.o2ims_inventory_observer.path}
*** Keywords ***
# export mockserver_host=128.224.115.23
# export mockserver_port=1081
# export mockserver_endpoint="http://${mockserver_host}:${mockserver_port}/mockserver"
# # docker run -d --rm -p --name smo 1080:1080 mockserver/mockserver
# sudo docker run -d -p ${mockserver_port}:1080 --name smo mockserver/mockserver

Setup SMO Server
    # [Arguments]    ${args}
    # Open Connection And Log In
    # bring up smo mock server
    ${stdout}  ${stderr}  ${rc}=     Execute Command With Sudo  docker run -d -p ${mockserver_port}:1080 --name ${mockserver_name} mockserver/mockserver
    log                              ${stdout}   level=DEBUG
    log                              ${stderr}   level=DEBUG
    # ${stdout}                        Execute Command     source ${OPENRC} && system host-list
    # bring up oran o2 app
    # Some Keyword    ${args}
    # Another Keyword

Tear Down SMO Server
    # [Arguments]    ${args}
    # tear down oran o2 app
    # tear down smo mock server
    ${stdout}  ${stderr}  ${rc}=     Execute Command With Sudo  docker stop ${mockserver_name}
    log                              ${stdout}   level=DEBUG
    log                              ${stderr}   level=DEBUG
    ${stdout}  ${stderr}  ${rc}=     Execute Command With Sudo  docker rm ${mockserver_name}
    log                              ${stdout}   level=DEBUG
    log                              ${stderr}   level=DEBUG
    # Close All Connections


SMO called by IMS verification
    [Arguments]    ${args}
    Set Headers     {"Content-Type": "application/json"}
    ${res}    put   ${SMO_VERIFY_URL}  ${args}
    log       ${res}  level=DEBUG
    # Whether the O-Cloud performs a reachability check (i.e., ETSI GS NFV-SOL 015 V1.1.1, section 5.9) or not is
    # optional; therefore, here we provide the ability to override the verification based on the support provided by
    # the O-Cloud.
    IF   ${ocloud.oran_o2_app.expect_callback_verify}
        Integer     response status    202
    ELSE
        Integer     response status    406
    END
