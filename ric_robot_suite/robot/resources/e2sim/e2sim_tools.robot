*** Settings ***
Documentation     Routines for managing interactions with the E2 Simulator

Resource          ../global_properties.robot

Library           KubernetesEntity  ${NAMESPACE}
Library           E2SimUtils        ${DBHOST}     ${DBPORT}


*** Variables ***
${DBHOST}         ${GLOBAL_INJECTED_DBAAS_IP_ADDR}
${DBPORT}         ${GLOBAL_DBAAS_SERVER_PORT}
${NAMESPACE}      ${GLOBAL_RICPLT_NAMESPACE}

*** Keywords ***
Generate RAN Name
     [Documentation]    Generate a new RAN name suitable for use with E2
     [Arguments]        ${ran_name_prefix}=${EMPTY}
     ${resp} =          randomRANName   ${ran_name_prefix}
     [Return]           ${resp}

Delete RAN Database Entry
     [Documentation]                Delete the RNIB record for a specific RAN Name
     [Arguments]                    ${ran_name}
     ${gnbs} =                      gNodeBDelete    ${ran_name}
     Dictionary Should Contain Key  ${gnbs}         ${ran_name}

Restart E2 Simulator
     [Documentation]                Restart all E2Sim pods
     [Arguments]                    ${deployment}=  ${GLOBAL_INJECTED_E2MGR_DEPLOYMENT} 
     ${resp} =                      Redeploy        ${deployment}
     [Return]                       ${resp}
