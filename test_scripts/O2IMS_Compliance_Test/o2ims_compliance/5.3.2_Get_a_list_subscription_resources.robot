*** Settings ***
Documentation  Get a list of subscription resources
#Library  REST       ssl_verify=False    loglevel=DEBUG
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
s1, Return code is “200 OK”, with Response message body content containing an array of Subscriptioninfo
    [documentation]  This test case verifies the capability to query the list of subscriptions for event notifications from event consumers.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription

    # At least one subscription must exist so it can be queried.
    ${subscriptionRequest}      input   {"EndpointUri": "${ENDPOINT_URI}", "ResourceAddress": "${RESOURCE_ADDRESS}"}
    ${res}     POST   ${PUBLISHER_EVENT_ENDPOINT}       ${subscriptionRequest}

    Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/subscriptions_resource_properties.json
    ${res}     GET   ${PUBLISHER_EVENT_ENDPOINT}
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem