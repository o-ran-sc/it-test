*** Settings ***
Documentation  Verify SMO get security error response while issuing APIs with incorrect token
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

${SMO_TOKEN_DATA_INVALID}       ${ocloud.oran_o2_app.smo_token_data}[10:]${ocloud.oran_o2_app.smo_token_data}[:10]


*** Test Cases ***
s1, Issue API Request without Authorization Bearer Token Header
    [documentation]  This test case verifies Issue API Request without Authorization Bearer Token Header
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/
    # Output Schema   response body   ${CURDIR}/schemas/.output/client_errors_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    401
    # Object   response body

s2, Issue API Request with Authorization Bearer Token Header and invalid token
    [documentation]  This test case verifies Issue API Request with Authorization Bearer Token Header and invalid token
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA_INVALID}"}
    Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?fields=(resourceTypeId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    401
    # Object   response body

s3, Issue API Request with Authorization Bearer Token Header and valid token
    [documentation]  This test case verifies Issue API Request with Authorization Bearer Token Header and valid token
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    # Clear Expectations
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Expect Response Body        ${CURDIR}/schemas/ocloud_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1
    # Output Schema   response body   ${CURDIR}/schemas/.output/ocloud_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200
    Object   response body


*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    # Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
