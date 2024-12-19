*** Settings ***
Documentation  Verify SMO succeeds to get O2dms (in kubernetes native API profile) access information
# Library  REST       ssl_verify=False    loglevel=DEBUG
Library  REST       ssl_verify=False
Variables              ${EXECDIR}${/}test_configs.yaml

Suite Setup            Set REST Headers

*** Variables ***
${ORAN_HOST_EXTERNAL_IP}    ${ocloud.oran_o2_app.api.host}
${ORAN_SERVICE_NODE_PORT}   ${ocloud.oran_o2_app.api.node_port}
${GLOBAL_OCLOUD_ID1}        ${ocloud.oran_o2_app.g_ocloud_id}
${SMO_TOKEN_DATA}           ${ocloud.oran_o2_app.smo_token_data}
${globalLocationId}         ${ocloud.oran_o2_app.g_location_id}

${ORAN_O2IMS_ENDPOINT}  ${ocloud.oran_o2_app.api.protocol}://${ORAN_HOST_EXTERNAL_IP}:${ORAN_SERVICE_NODE_PORT}

${deploymentManagerName}    ${ocloud.oran_o2_app.deploymentmanager_name}

*** Test Cases ***
s1, query deploymentManager list without filter
    [documentation]  This test case verifies query deploymentManager list without filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_DeploymentManager

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/deploymentManagers_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers
    # Output Schema   response body   ${CURDIR}/schemas/.output/deploymentManagers_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200
    Array   response body

s2, query deploymentManager list with filter
    [documentation]  This test case verifies query deploymentManager list with filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_DeploymentManager

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/deploymentManagers_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers?filter=(cont,name,${deploymentManagerName})
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

s3, query a deploymentManager detail
    [documentation]  This test case verifies query a deploymentManager detail
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_DeploymentManager

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/deploymentManagers_properties.json
    ${res1}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers?filter=(cont,name,${deploymentManagerName})
    # Clear Expectations
    log      ${res1}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    ${deploymentManagerId}      output   $[0].deploymentManagerId

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/deploymentManager_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers/${deploymentManagerId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/deploymentManager_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Object       response body

    # all_fields
    Expect Response Body        ${CURDIR}/schemas/deploymentManager_allfields_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers/${deploymentManagerId}?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/deploymentManager_allfields_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Object       response body


*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem
