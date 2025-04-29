*** Settings ***
Documentation  Verify SMO succeeds to create alarmSubscription, receive alarm notification, and query alarm list
# Library  REST       ssl_verify=False    loglevel=DEBUG
Library  REST       ssl_verify=False

Resource               ssh_helper.robot

Variables              ${EXECDIR}${/}test_configs.yaml

# Suite Setup            Set REST Headers
Suite Setup            Set REST Headers And Clear Subscriptions
Suite Teardown         Clear Subscriptions

*** Variables ***
${HOST}                ${ocloud.ssh.host}
${PORT}                ${ocloud.ssh.port}
${USERNAME}            ${ocloud.ssh.username}
${PASSWORD}            ${ocloud.ssh.password}
${OPENRC}              ${ocloud.ssh.openrc}

${ORAN_HOST_EXTERNAL_IP}    ${ocloud.oran_o2_app.api.host}
${ORAN_SERVICE_NODE_PORT}   ${ocloud.oran_o2_app.api.node_port}
${GLOBAL_OCLOUD_ID1}        ${ocloud.oran_o2_app.g_ocloud_id}
${SMO_TOKEN_DATA}           ${ocloud.oran_o2_app.smo_token_data}
${globalLocationId}         ${ocloud.oran_o2_app.g_location_id}

${ORAN_O2IMS_ENDPOINT}  ${ocloud.oran_o2_app.api.protocol}://${ORAN_HOST_EXTERNAL_IP}:${ORAN_SERVICE_NODE_PORT}

${SMO_ALARM_OBSERVER_URL}     ${smo.service.protocol}://${smo.service.host}:${smo.service.port}${smo.o2ims_alarm_observer.path}
${consumerSubscriptionId}   3F20D850-AF4F-A84F-FB5A-0AD585410361

# ${subscription_data}  {"callback": "${SMO_ALARM_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(neq,resourcePools.globalLocationId,${globalLocationId})" }

# ${subscription_data}  {"callback": "${SMO_ALARM_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "" }

*** Test Cases ***
s1, create alarmSubscription
    [documentation]  This test case verifies create alarmSubscription
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Alarm_Subscription

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/alarm_subscription_post_resp_properties.json
    Expect Response Body        ${CURDIR}/schemas/alarm_subscription_properties.json

    Set Headers     {"Content-Type": "application/json"}
    ${subscription_data}  input     {"callback": "${SMO_ALARM_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}"}

    # ${subscription_data}  input     {"callback": "${SMO_ALARM_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,resourceTypeID,typeid1234)" }

    # ${subscription_data}  input     {"callback": "${SMO_ALARM_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(neq,resourceTypeID,typeid1234)" }

    # ${subscription_data}  input     {"callback": "${SMO_ALARM_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,perceivedSeverity,1)" }

    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions     ${subscription_data}
    # Output Schema     request body   ${CURDIR}/schemas/.output/alarm_subscription_post_req_properties.json
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarm_subscription_post_resp_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    201
    Object   response body

# s2, query alarmSubscription list
    # [documentation]  This test case verifies query alarmSubscription list
    # [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Alarm_Subscription

    Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/alarm_subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarm_subscriptions_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    # all_fields
    Expect Response Body        ${CURDIR}/schemas/alarm_subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarm_subscriptions_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

# s?, query alarmSubscription list with filter
#     [documentation]  This test case verifies Query OCloud resourceTypes with filter
#     [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Alarm_Subscription

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/alarm_subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions?filter=(eq,consumerSubscriptionId,${consumerSubscriptionId})
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1

# s3, query alarmSubscription detail
#     [documentation]  This test case verifies Query OCloud resourceTypes detail
#     [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Alarm_Subscription

    # Clear Expectations
    # GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions/${subscriptionId}
    ${subscriptionId}      output   $[0].alarmSubscriptionId
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/alarm_subscription_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions/${subscriptionId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarm_subscriptions_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Object       response body

    # all_fields
    Expect Response Body        ${CURDIR}/schemas/alarm_subscription_allfields_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions/${subscriptionId}?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarm_subscription_allfields_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Object       response body


# Check duplication logic
    Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions     ${subscription_data}
    # Output Schema   response body   ${CURDIR}/schemas/.output/client_errors_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

# s4, Stx/WRCP generates an alarm change event and check SMO succeeds to receive a alarm change notification
#     [documentation]  This test case verifies Query OCloud resourcePools without filter
#     [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Alarm_Subscription

    # ${stdout}  ${stderr}  ${rc}=    Assert Alarm With Disk Usage
    # log     ${rc}   level=DEBUG
    # Should Be Equal     ${rc} 0


# s5, query alarm list without filter

    Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/alarms_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarms_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    # # query with filter
    # Expect Response Body        ${CURDIR}/schemas/alarms_properties.json
    # ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms?all_fields&filter=(eq,perceivedSeverity,1)
    # # Output Schema   response body   ${CURDIR}/schemas/.output/alarms_properties.json
    # Clear Expectations
    # log      ${res}   level=DEBUG
    # Integer     response status    200
    # Array       response body
    # Array       $   minItems=1  uniqueItems=true

    # extract resourceTypeID for query with fitler test
    ${resourceTypeID}      output   $[0].resourceTypeID

# s6, query alarm list with filter
    Clear Expectations
    # GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver)
    # ${resourceTypeID}      output   $[0].resourceTypeID
    Expect Response Body        ${CURDIR}/schemas/alarms_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms?filter=(eq,resourceTypeID,${resourceTypeID})
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true
    Expect Response Body        ${CURDIR}/schemas/alarms_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms    {"filter": "(eq,resourceTypeID,${resourceTypeID};eq,alarmAcknowledged,false)"}
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true


# s7, query alarm detail
    Expect Response Body        ${CURDIR}/schemas/alarms_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarms_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    # all fields
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms?all_fields
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    # alarm detail
    ${alarmEventRecordId}      output   $[0].alarmEventRecordId
    Expect Response Body        ${CURDIR}/schemas/alarm_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms/${alarmEventRecordId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/alarm_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200

    # all fields
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarms/${alarmEventRecordId}?all_fields
    log      ${res}   level=DEBUG
    Integer     response status    200
    Object       response body
    Object      $.extensions

# s8, delete the alarmSubscription
#     [documentation]  This test case verifies Query OCloud resourcePools with filter
#     [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Alarm_Subscription

    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/alarm_subscriptions_properties.json
    ${res}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions/${subscriptionId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePools_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    # Array       response body
    # Array       $   minItems=1  maxItems=1

# s9, Stx/WRCP generates an alarm change event and check SMO cannot receive any alarm change notification
#     [documentation]  This test case verifies Query OCloud resourcePools detail
#     [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Alarm_Subscription

    # # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/alarm_subscriptions_properties.json
    # ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions/${subscriptionId}
    # # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePool_properties.json
    # Clear Expectations
    # log      ${res}   level=INFO
    # Integer     response status    200
    # Object       response body

# clear the alarm condition
    ${stdout}  ${stderr}  ${rc}=    Clear Alarm With Disk Usage
#    log     ${rc}   level=DEBUG
#    Should Be Equal     ${rc} 0


*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem

Clear Subscriptions
    Clear Expectations
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions
    log     ${res}   level=DEBUG
    @{subs}        output  $
    FOR     ${sub}      IN      @{subs}
        ${subscriptionId}=  input   ${sub}[alarmSubscriptionId]
        ${res2}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/alarmSubscriptions/${subscriptionId}
        log     ${res2}   level=DEBUG
    END

Set REST Headers And Clear Subscriptions
    Set REST Headers
    Clear Subscriptions
