*** Settings ***
Documentation   Get Detail of individual subscription resource.
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
s1, The return code is “200 OK”, with Response message body content containing Subscriptioninfo.
    [documentation]  This test case verifies the capability to query successfully the detail of a subscription from event consumers.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription

    # At least one subscription must exist so it can be queried.
    ${subscriptionRequest}      input   {"EndpointUri": "${ENDPOINT_URI}", "ResourceAddress": "${RESOURCE_ADDRESS}"}
    ${res}     POST   ${PUBLISHER_EVENT_ENDPOINT}       ${subscriptionRequest}

    Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/subscriptions_resource_properties.json
    ${res}     GET   ${PUBLISHER_EVENT_ENDPOINT}
    @{subscriptions}     output  $
    FOR     ${subscription}     IN      @{subscriptions}
        ${subscriptionId}       input       ${subscription}[SubscriptionId]
        Clear Expectations
        Expect Response Body        ${CURDIR}/schemas/subscription_resource_properties.json
        ${res}     GET   ${PUBLISHER_EVENT_ENDPOINT}/${subscriptionId}
        # Output Schema   response body   ${CURDIR}/schemas/.output/resources_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Object       response body
    END

s2, Return code is “404 Not found” when the subscription resource is not available (not created).
    [documentation]  This test case verifies the capability to query an invalid subscription and return a Not Found error.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription
    ${unknownSubscriptionId}    Evaluate    str(__import__('uuid').uuid4())
    Log    Generated UUID: ${unknownSubscriptionId}

    Clear Expectations
    ${res}     GET   ${PUBLISHER_EVENT_ENDPOINT}/${unknownSubscriptionId}
    log      ${res}   level=DEBUG
    Integer  response status    404

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem
