*** Settings ***
Documentation  Verify SMO gets 405 while sending o2ims APIs with unsupported method
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

${ORAN_O2IMS_ENDPOINT}      ${ocloud.oran_o2_app.api.protocol}://${ORAN_HOST_EXTERNAL_IP}:${ORAN_SERVICE_NODE_PORT}
${SMO_INV_OBSERVER_URL}     ${smo.service.protocol}://${smo.service.host}:${smo.service.port}${smo.o2ims_inventory_observer.path}

*** Test Cases ***
s1, Verify operate resourceTypes with unsupported method gets 405 error.
    [documentation]  This test case verifies operate resourceTypes with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes
    ${resourceTypeId}      output   $[0].resourceTypeId
    ${resouceTypeData}      input   {'description': 'An ethernet resource of the physical server', 'name': '5af55345-enp61s0f0', 'parentId': '5af55345-134a-406c-93b6-c5e10318afa5', 'resourceId': '016977ee-c0c3-4e5d-9e53-2bf1d6448aa5', 'resourcePoolId': 'ce2eec13-24b0-4cca-aa54-548be6cc985b','resourceTypeId': '3d19af47-e20d-40f9-ae74-f8cc988a045f'}
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}       ${resouceTypeData}
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

s2, Verify operate resourcePool with unsupported method gets 405 error.
    [documentation]  This test case verifies operate resourcePool with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

s3, Verify operate resource with unsupported method gets 405 error.
    [documentation]  This test case verifies operate resource with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    ${resourcePoolId}      output   $[0].resourcePoolId
    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

s4, Verify operate DeploymentManager with unsupported method gets 405 error.
    [documentation]  This test case verifies operate DeploymentManager with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/deploymentManagers
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

s5, Verify operate O-cloud with unsupported method gets 405 error.
    [documentation]  This test case verifies operate O-cloud with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

s6, Verify operate Inventory Subscription with unsupported method gets 405 error.
    [documentation]  This test case verifies operate Inventory Subscription with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method
    ${consumerSubscriptionId}    Evaluate    str(__import__('uuid').uuid4())
    ${subscriptionId}    Evaluate    str(__import__('uuid').uuid4())

    ${subscriptionRequest}   input   {"filter":"(eq,extensions/country,ES);","callback":"${SMO_INV_OBSERVER_URL}","consumerSubscriptionId":"${consumerSubscriptionId}","subscriptionId":"${subscriptionId}"}
    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     PATCH   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions     ${subscriptionRequest}
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

s7, Verify operate Alarm with unsupported method gets 405 error.
    [documentation]  This test case verifies operate Alarm with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

s8, Verify operate Alarm Subscription with unsupported method gets 405 error.
    [documentation]  This test case verifies operate Alarm Subscription with unsupported method returns a "405 Method Not Allowed error".
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method
    ${consumerSubscriptionId}    Evaluate    str(__import__('uuid').uuid4())

    ${subscriptionAlarmRequest}    input    {"consumerSubscriptionId": "${consumerSubscriptionId}","filter": "NEW","callback": "${SMO_INV_OBSERVER_URL}"}
    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     PATCH   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions   ${subscriptionAlarmRequest}
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem