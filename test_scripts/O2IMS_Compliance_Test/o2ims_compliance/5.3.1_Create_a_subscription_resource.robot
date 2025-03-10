*** Settings ***
Documentation  Create a subscription resource
# Library  REST       ssl_verify=False    loglevel=DEBUG
Library  REST       ssl_verify=False
Variables              ${EXECDIR}${/}test_configs.yaml

Suite Setup            Set REST Headers

*** Variables ***
${ORAN_HOST_EXTERNAL_IP}       ${ocloud.oran_o2_app.api.host}
${ORAN_SERVICE_NODE_PORT}      ${ocloud.oran_o2_app.api.node_port}
${GLOBAL_OCLOUD_ID1}           ${ocloud.oran_o2_app.g_ocloud_id}
${SMO_TOKEN_DATA}              ${ocloud.oran_o2_app.smo_token_data}
${globalLocationId}            ${ocloud.oran_o2_app.g_location_id}
${ENDPOINT_URI}                ${ocloud.oran_o2_notification.endpoint_uri}
${RESOURCE_ADDRESS}            ${ocloud.oran_o2_notification.resource_address}      
${PUBLISHER_EVENT_ENDPOINT}    ${ocloud.oran_o2_notification.publisher_endpoint}

*** Test Cases ***
s1, Return code is “201 OK” when the subscription request is correct
    [documentation]  This test case verifies the capability to create a valid subscription for event notifications.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription

    # Clear all existing event subscriptions
    ${res}     DELETE   ${PUBLISHER_EVENT_ENDPOINT}
    
    Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/subscription_resource_properties.json
    ${subscriptionRequest}      input   {"EndpointUri": "${ENDPOINT_URI}", "ResourceAddress": "${RESOURCE_ADDRESS}"}
    ${res}     POST   ${PUBLISHER_EVENT_ENDPOINT}       ${subscriptionRequest}
    log      ${res}   level=DEBUG
    Integer  response status    201
    Object   response body

s2, Return code is “400 Bad request” when the subscription request is not correct.
    [documentation]  This test case verifies the capability to return an error when subscription request is not correct
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription

    Clear Expectations
    ${subscriptionRequest}      input   {"EndpointUri": "${ENDPOINT_URI}/invalid", "ResourceAddress": "${RESOURCE_ADDRESS}"}
    ${res}     POST   ${PUBLISHER_EVENT_ENDPOINT}       ${subscriptionRequest}
    log      ${res}   level=DEBUG
    Integer  response status    400

s3, Return code is “404 Not found” when the subscription resource is not available.
    [documentation]  This test case verifies the capability to return an error when subscription request is not found
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription

    Clear Expectations
    ${subscriptionRequest}      input   {"EndpointUri": "${ENDPOINT_URI}", "ResourceAddress": "/cluster/node/notfound"}
    ${res}     POST   ${PUBLISHER_EVENT_ENDPOINT}       ${subscriptionRequest}
    log      ${res}   level=DEBUG
    Integer  response status    404

s4, Return code is “409 Conflict” when the subscription resource already exists
    [documentation]  This test case verifies the capability to inform when a resource already exists.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription

    # Clear all existing event subscriptions
    ${res}     DELETE   ${PUBLISHER_EVENT_ENDPOINT}

    Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/subscription_resource_properties.json
    ${subscriptionRequest}      input   {"EndpointUri": "${ENDPOINT_URI}", "ResourceAddress": "${RESOURCE_ADDRESS}"}
    ${res}     POST   ${PUBLISHER_EVENT_ENDPOINT}      ${subscriptionRequest}
    log      ${res}   level=DEBUG
    Integer  response status    201
    Object   response body

    Clear Expectations
    ${subscriptionRequest}      input   {"EndpointUri": "${ENDPOINT_URI}", "ResourceAddress": "${RESOURCE_ADDRESS}"}
    ${res}     POST   ${PUBLISHER_EVENT_ENDPOINT}       ${subscriptionRequest}
    log      ${res}   level=DEBUG
    Integer  response status    409

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem
