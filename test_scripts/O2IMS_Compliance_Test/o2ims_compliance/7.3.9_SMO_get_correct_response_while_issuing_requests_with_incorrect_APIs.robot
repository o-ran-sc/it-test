*** Settings ***
Documentation  Verify SMO gets client error response while issuing requests with incorrect APIs
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
# Wrong port number set to 1
${WRONG_PORT_ORAN_O2IMS_ENDPOINT}  ${ocloud.oran_o2_app.api.protocol}://${ORAN_HOST_EXTERNAL_IP}:1



*** Test Cases ***
s1, Verify query with wrong port does not receive API response.
    [documentation]  Verify query with wrong port does not receive API response.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    TRY
       ${res}     GET   ${WRONG_PORT_ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1
    EXCEPT    ConnectionError: *    type=glob
       log    PASS:query with wrong port got error code   level=DEBUG
    END

s2, Verify query with wrong url got error code.
    [documentation]  Verify query with wrong url got error code.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagersWrongURL
    log      ${res}   level=DEBUG
    Integer  response status    404
    # Object   response body

s3, Verify query with wrong api version got error code.
    [documentation]  Verify query with wrong api version got error code.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Expect Response Body      ${CURDIR}${/}..${/}o2ims_compliance${/}schemas${/}client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v2/deploymentManagers
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    404
    # Object   response body

s4, Verify query with wrong deploymentManagerID got error code.
    [documentation]  Verify query with wrong deploymentManagerID got error code.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    # Clear Expectations
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Expect Response Body        ${CURDIR}${/}..${/}o2ims_compliance${/}schemas${/}client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers/708296a0-fb87-4c60-94fc-74cece8ddf84
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    404
    Object   response body


*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    # Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem
