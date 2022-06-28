*** Settings ***
Documentation    Suite description
Resource      /robot/resources/submgr_interface.robot
Resource      /robot/resources/global_properties.robot
Resource      /robot/resources/dashboard_interface.robot
Resource      /robot/resources/appmgr_interface.robot
Resource      /robot/resources/e2term_interface.robot
Resource      /robot/resources/rtmgr_interface.robot
Resource      /robot/resources/e2mgr_interface.robot
Resource      /robot/resources/json_templater.robot

Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library   KubernetesEntity  ricplt
Library   String
Library   KubernetesEntity    ${GLOBAL_RICPLT_NAMESPACE}
Library   UUID
Library   SSHLibrary
*** Variables ***
${E2TERM_ENDPOINT}      ${GLOBAL_INJECTED_E2TERM_IP_ADDR}:${GLOBAL_E2TERM_SERVER_PORT}
${Health_check}         bouncer-xapp ricxapp
*** Keywords ***
SSH to OS with ROOT
    Open Connection   ${GLOBAL_CLUSTER_IP}
    ${output} =       Login           ubuntu            ubuntu
    Should Contain    ${output}       Last login
    Start Command     pwd
    ${pwd} =          Read Command Output
    Should Be Equal   ${pwd}     /home/ubuntu
    ${written}=       Write      sudo su -
    ${output}=        Read       delay=0.5s
    Should Contain    ${output}      [sudo] password for ubuntu:
    ${written}=       Write      ubuntu
    ${output}=        Read       delay=0.5s
    Should Contain    ${output}        root@

Run E2Term Health Check 2
     [Documentation]  Runs E2Term Health check
     Log To Console     Entering in to E2term
     ${data_path}=    Set Variable    ${E2TERM_ENDPOINT}
     ${resp} =  Run E2Term RMR Probe Check      ${data_path}
     Log To Console     ${resp}

Run E2Term RMR Probe Check
     [Documentation]    Runs E2Term RMR Probe Check
     [Arguments]        ${data_path}

     ${resp} =  Run     /bin/sh -c "/opt/e2/rmr_probe -h ${data_path} -v verbose"
     Log To Console     Received response from E2term ${resp}
     Should Contain    ${resp}       [INFO] sending message: health check request prev=0 <eom>
     Should Contain    ${resp}       [INFO] got: (OK) state=0
     [Return]    ${resp}

Keyword xapp health check
        ${Output} =     RUN      dms_cli health_check ${Health_check}
        Log To Console  ${Output}

Keyword check svc status

        [Arguments]     ${linematch}
        ${message} =      Split String     ${linematch}
        ${get} =            Get From List    ${message}    2
        [Return]        ${get}

Keyword Ensure Helm3 is installed
    SSH to OS with ROOT
    ${written}=        Write         helm version
    ${output}=         Read          delay=0.5s
    Should Contain     ${output}           Version:"v3.6.1"


Keyword Deploy E2SIM
        ${written}=        Write    cd /root/e2-interface/e2sim/e2sm_examples/kpm_e2sm/helm
    ${output}=         Read      delay=0.5s
        ${written}=        Write    helm install e2sim --namespace test .
    ${output}=         Read      delay=3s
    Log To Console      ${output}
    Should Contain     ${output}      deployed
        ${written}=        Write        cd /root
        Sleep   30s


Keyword Ensure E2Setup procedure is successfully
    Sleep       60s
    ${data_path} =    Set Variable             ${E2MGR_BASE_PATH}/states
    ${resp} =         Run E2Mgr GET Request    ${data_path}
    ${resp_text} =    Convert To String        ${resp.json()}
    Log to console    ${resp_text}
    Should Match Regexp      ${resp_text}                  CONNECTED

Keyword Deploy Bouncer
        ${written}=        Write    docker run --rm -u 0 -it -d -p 8090:8080 -e DEBUG=1 -e STORAGE=local -e STORAGE_LOCAL_ROOTDIR=/charts -v $(pwd)/charts:/charts chartmuseum/chartmuseum:latest
    ${output}=         Read      delay=3s
        ${written}=        Write    export CHART_REPO_URL=http://0.0.0.0:8090
    ${output}=         Read      delay=0.5s
        ${written}=        Write    dms_cli onboard /root/rest_complete/Bouncer/init/config-file.json /root/rest_complete/Bouncer/init/schema.json
    ${output}=         Read      delay=3s
    Should Contain     ${output}     "status": "Created"
        ${written}=        Write    dms_cli install bouncer-xapp 2.0.0 ricxapp
    ${output}=         Read      delay=3s
    Should Contain     ${output}     status: OK
        ${written}=       Write     kubectl get svc -n ricplt | grep appmgr
    ${output}=         Read      delay=3s
    Log To Console       ${output}
    ${Log}=     convert To String       ${output}
    ${contain}=  Run Keyword And Return Status   Should Contain  ${Log}     ClusterIP
    ${appmgrip}=   Run Keyword If  ${contain}      Keyword check svc status    ${Log}
    Log To Console       ${appmgrip}
    Set Global Variable     ${appmgrip}

    ${written}=        Write   curl -v -X POST "http://${appmgrip}:8080/ric/v1/register" -H "accept: application/json" -H "Content-Type: application/json" -d "@bouncer-register.json"
    ${output}=         Read      delay=1s
    Should Contain     ${output}     201 Created

keyword Deploy Bouncer Successful Case
        ${written}=        Write    docker run --rm -u 0 -it -d -p 8090:8080 -e DEBUG=1 -e STORAGE=local -e STORAGE_LOCAL_ROOTDIR=/charts -v $(pwd)/charts:/charts chartmuseum/chartmuseum:latest
    ${output}=         Read      delay=3s
        ${written}=        Write    export CHART_REPO_URL=http://0.0.0.0:8090
    ${output}=         Read      delay=0.5s
        ${written}=        Write    dms_cli onboard /root/bouncer_rest/Bouncer/init/config-file.json /root/bouncer_rest/Bouncer/init/schema.json
    ${output}=         Read      delay=3s
    Should Contain     ${output}     "status": "Created"

        ${written}=       Write     kubectl get svc -n ricplt | grep appmgr
    ${output}=         Read      delay=3s
    Log To Console       ${output}
    ${Log}=     convert To String       ${output}
    ${contain}=  Run Keyword And Return Status   Should Contain  ${Log}     ClusterIP
    ${appmgrip}=   Run Keyword If  ${contain}      Keyword check svc status    ${Log}
    Log To Console       ${appmgrip}
    Set Global Variable     ${appmgrip}

        ${written}=        Write    dms_cli install bouncer-xapp 2.0.0 ricxapp
    ${output}=         Read      delay=3s
    Should Contain     ${output}     status: OK

    ${written}=        Write   curl -v -X POST "http://${appmgrip}:8080/ric/v1/register" -H "accept: application/json" -H "Content-Type: application/json" -d "@bouncer-register.json"
    ${output}=         Read      delay=1s
    Should Contain     ${output}     201 Created


Keyword Ensure Bouncer is deployed and available
    ${ctrl} =   Run Keyword     deployment      ricxapp-bouncer-xapp        ricxapp
    Should Be Equal      ${ctrl.status.replicas}          ${ctrl.status.ready_replicas}

Keyword Undeploy Bouncer
        ${written}=        Write    dms_cli uninstall bouncer-xapp ricxapp
    ${output}=         Read      delay=5s
    Should Contain     ${output}     status: OK

Keyword Undeploy E2SIM
    ${written}=        Write    helm uninstall e2sim -n test
    ${output}=         Read      delay=5s
    Should Contain     ${output}      uninstalled

Keyword Deploy Successful E2SIM
        ${written}=        Write        cd /root/test/ric_benchmarking/e2-interface/e2sim/e2sm_examples/kpm_e2sm/helm
    ${output}=         Read      delay=0.5s
        ${written}=        Write    helm install e2sim --namespace test .
    ${output}=         Read      delay=3s
    Should Contain     ${output}      deployed
        ${written}=        Write        cd /root


