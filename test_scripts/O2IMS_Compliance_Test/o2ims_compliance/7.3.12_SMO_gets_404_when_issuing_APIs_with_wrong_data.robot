*** Settings ***
Documentation  SMO gets 404 when issuing APIs with wrong data
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
s1, query inventory subscription with with wrong subscriptionId to delete inventory subscription.
    [documentation]  This test case verifies return code is “404” when the inventory subscriptionId does not exist
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    # Clear Expectations
    ${invalidSubscriptionId}      input   69253c4b-8398-4602-855d-783865f5f25c
    ${res}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions/${invalidSubscriptionId} 
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    404

s2, query inventory subscription with with wrong alarmSubscriptionId to delete alarm subscription.
    [documentation]  This test case verifies return code is “404” when the alarm subscriptionId does not exist
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Client_Errors

    # Clear Expectations
    ${invalidAlarmSubscriptionId}      input   69253c4b-8398-4602-855d-783865f5f25c
    ${res}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions/${invalidAlarmSubscriptionId} 
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    404


*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem
