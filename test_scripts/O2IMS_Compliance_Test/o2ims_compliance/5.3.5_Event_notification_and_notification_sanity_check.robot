*** Settings ***
Documentation  Event notification and Notification sanity check
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
${RESOURCE_ADDRESS}            ${ocloud.oran_o2_notification.resource_address}
${CONSUMER_EVENT_ENDPOINT}     ${ocloud.oran_o2_notification.consumer_endpoint}


*** Test Cases ***
s1, Return code is “204 Success” when the event notification is correct
    [documentation]  This test case verifies the capability to create a valid subscription for event notifications.
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Event_Subscription
    ${eventid}    Evaluate    str(__import__('uuid').uuid4())
    Log    Generated UUID: ${eventid}
    # example of a valid PTP event notification
    ${eventNotification}      input   {"specversion":"1.0","id":"${eventid}","source":"/sync/ptp-status/lock-state","type":"event.sync.ptp-status.ptp-state-change","time":"2024-12-04T09:25:22.75028442Z","data":{"version":"1.0","values":[{"ResourceAddress":"${RESOURCE_ADDRESS}","data_type":"notification","value_type":"enumeration","value":"HOLDOVER"},{"ResourceAddress":"${RESOURCE_ADDRESS}","data_type":"metric","value_type":"decimal64.3", "value": "9287556"}]}}

    ${res}     POST   ${CONSUMER_EVENT_ENDPOINT}       ${eventNotification}
    log      ${res}   level=DEBUG
    Integer  response status    204

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Content-Type": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem