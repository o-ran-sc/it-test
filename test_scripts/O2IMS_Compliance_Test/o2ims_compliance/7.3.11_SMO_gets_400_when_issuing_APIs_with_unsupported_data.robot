*** Settings ***
Documentation  Verify SMO gets 400 when issuing APIs with junk/unsupported data
# Library  REST       ssl_verify=False    loglevel=DEBUG
Library    RequestsLibrary
Variables              ${EXECDIR}${/}test_configs.yaml

*** Variables ***
${ORAN_HOST_EXTERNAL_IP}    ${ocloud.oran_o2_app.api.host}
${ORAN_SERVICE_NODE_PORT}   ${ocloud.oran_o2_app.api.node_port}
${GLOBAL_OCLOUD_ID1}        ${ocloud.oran_o2_app.g_ocloud_id}
${SMO_TOKEN_DATA}           ${ocloud.oran_o2_app.smo_token_data}
${globalLocationId}         ${ocloud.oran_o2_app.g_location_id}

${ORAN_O2IMS_ENDPOINT}  ${ocloud.oran_o2_app.api.protocol}://${ORAN_HOST_EXTERNAL_IP}:${ORAN_SERVICE_NODE_PORT}
${o2ims_observer}       https://10.6.85.1:1080/smo/v1/consumer

*** Test Cases ***
s1, Verify create inventory subscription with junk data gets 400 error. 
    [documentation]  This test case verifies return code is “400 Bad request” when the inventory subscription contains junk data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_DeploymentManager
    
    ${tokenHeader}=    Create Dictionary    Authorization=Bearer ${SMO_TOKEN_DATA}    Content-Type=application/json
    Set Suite Variable   ${tokenHeader}
    Create Session    o2ims    ${ORAN_O2IMS_ENDPOINT}    verify=False    debug=1   headers=${tokenHeader}

    # Improperly formatted JSON subscriptionRequest
    ${subscriptionRequest}   Set Variable   {"consumerSubscriptionId" "69253c4b-8398-4602-855d-783865f5f25c","filter" "(eq,extensions/country,US);","callback" ${o2ims_observer}}
    ${res}=   POST On Session   o2ims   /o2ims-infrastructureInventory/v1/subscriptions   data=${subscriptionRequest}   expected_status=400
    log      ${res}   level=DEBUG
    Status Should Be   400   ${res}

s2, Verify create inventory subscription with unsupported data gets 400 error.
    [documentation]  This test case verifies return code is “400 Bad request” when the inventory subscription contains unsupported data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_DeploymentManager

    # Unsupported formatted XML subscriptionRequest
    ${subscriptionRequest}      Set Variable   <?xml version="1.0" encoding="UTF-8" ?><root><consumerSubscriptionId>69253c4b-8398-4602-855d-783865f5f25c</consumerSubscriptionId><filter>(eq,extensions/country,US);</filter><callback>${o2ims_observer}</callback></root>
    ${res}=   POST On Session   o2ims   /o2ims-infrastructureInventory/v1/subscriptions   data=${subscriptionRequest}   expected_status=400
    log      ${res}   level=DEBUG
    Status Should Be   400   ${res}

s3, Verify create monitoring alarm subscription with junk data gets 400 error.
    [documentation]  This test case verifies return code is “400 Bad request” when the alarm subscription contains junk data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_DeploymentManager

    # Improperly formatted JSON subscriptionAlarmRequest
    ${subscriptionAlarmRequest}      Set Variable   {"consumerSubscriptionId" "16d5fc54-cee0-4532-9826-2369f8240e1b","filter" "NEW","callback" ${o2ims_observer}}
    ${res}=   POST On Session   o2ims   /o2ims-infrastructureMonitoring/v1/alarmSubscriptions   data=${subscriptionAlarmRequest}   expected_status=400
    log      ${res}   level=DEBUG
    Status Should Be   400   ${res}


s4, Verify create monitoring alarm subscription with unsupported data gets 400 error.
    [documentation]  This test case verifies return code is “400 Bad request” when the alarm subscription contains unsupported data
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_DeploymentManager

    # Unsupported formatted XML subscriptionAlarmRequest
    ${subscriptionAlarmRequest}      Set Variable   <?xml version="1.0" encoding="UTF-8" ?><root><consumerSubscriptionId>16d5fc54-cee0-4532-9826-2369f8240e1b</consumerSubscriptionId><filter>NEW<filter><callback>${o2ims_observer}</callback></root>
    ${res}=   POST On Session   o2ims   /o2ims-infrastructureMonitoring/v1/alarmSubscriptions   data=${subscriptionAlarmRequest}   expected_status=400
    log      ${res}   level=DEBUG
    Status Should Be   400   ${res}