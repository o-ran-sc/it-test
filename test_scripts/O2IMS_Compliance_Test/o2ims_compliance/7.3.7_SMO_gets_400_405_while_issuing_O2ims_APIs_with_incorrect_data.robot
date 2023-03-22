*** Settings ***
Documentation  Verify SMO gets 4xx response while issuing o2ims APIs with incorrect data
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


*** Test Cases ***
s1, Operate resourceTypes with invalid data
    [documentation]  This test case verifies Operate resourceTypes with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,WrongAttrName,anyvalue)
    # Output Schema   response body   ${CURDIR}/schemas/.output/client_errors_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?fields=(resourceTypeId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

s2, Operate resourcePool with invalid data
    [documentation]  This test case verifies Operate resourcePool with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools?fields=(resourceTypeId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

s3, Operate Resource with invalid data
    [documentation]  This test case verifies Operate Resource with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    # ${resourcePoolId}   input   $[0].resourcePoolId
    ${resourcePoolId}      output   $[0].resourcePoolId

    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?fields=(resourceTypeId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

s4, Operate DeploymentManager with invalid data
    [documentation]  This test case verifies Operate DeploymentManager with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers?fields=(deploymentManagerId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

s5, Operate Ocloud with invalid data
    [documentation]  This test case verifies Operate Ocloud with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1?fields=(resourceId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

s6, Operate Inventory Subscription with invalid data
    [documentation]  This test case verifies Operate Inventory Subscription with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions?fields=(SubscriptionId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

s7, Operate Alarm with invalid data
    [documentation]  This test case verifies Operate Alarm with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms?fields=(AlarmId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

s8, Operate Alarm Subscription with invalid data
    [documentation]  This test case verifies Operate Alarm Subscription with invalid data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions?fields=(AlarmSubscriptionId,WrongAttrName)
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body


*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
