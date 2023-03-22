*** Settings ***
Documentation  Verify SMO succeeds to subscribe for O2ims inventory changes notification and succeeds to receive notifications
# Library  REST       ssl_verify=False    loglevel=DEBUG
Library  REST       ssl_verify=False
Resource             smo_server_mock.robot
Variables              ${EXECDIR}${/}test_configs.yaml

Suite Setup            Set REST Headers And Clear Subscriptions
Suite Teardown         Clear Subscriptions

*** Variables ***
${ORAN_HOST_EXTERNAL_IP}    ${ocloud.oran_o2_app.api.host}
${ORAN_SERVICE_NODE_PORT}   ${ocloud.oran_o2_app.api.node_port}
${GLOBAL_OCLOUD_ID1}        ${ocloud.oran_o2_app.g_ocloud_id}
${SMO_TOKEN_DATA}           ${ocloud.oran_o2_app.smo_token_data}
${globalLocationId}         ${ocloud.oran_o2_app.g_location_id}

${ORAN_O2IMS_ENDPOINT}  ${ocloud.oran_o2_app.api.protocol}://${ORAN_HOST_EXTERNAL_IP}:${ORAN_SERVICE_NODE_PORT}

${SMO_INV_OBSERVER_URL}     ${smo.service.protocol}://${smo.service.host}:${smo.service.port}${smo.o2ims_inventory_observer.path}
${consumerSubscriptionId}   3F20D850-AF4F-A84F-FB5A-0AD585410361

# ${subscription_data}  {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(neq,resourcePools.globalLocationId,${globalLocationId})" }

# ${subscription_data}  {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "" }

*** Test Cases ***
s1, create a subscription
    [documentation]  This test case verifies ocloud inventory subscription management
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory_Subscription

    ${invalid_subscription_data}  input     {"consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "" }

# Check error input logic
    Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions     ${invalid_subscription_data}
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

    Clear Expectations
    # Expect Request        ${CURDIR}/schemas/subscription_post_resp_properties.json
    # Expect Response Body        ${CURDIR}/schemas/subscription_post_resp_properties.json
    Expect Response Body        ${CURDIR}/schemas/subscription_properties.json
    Set Headers     {"Content-Type": "application/json"}
    ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,objectType,ResourceTypeInfo)" }
    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,objectType,ResourceTypeInfo);(eq,resourceTypeId,id1234)" }
    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,objectType,ResourceTypeInfo);(neq,resourceTypeId,id1234)" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(neq,objectType,ResourceTypeInfo);(neq,resourceTypeId,id1234)" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(neq,vendor,id1234)" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,resourceId,resourceid1234)|(eq,objectType,ResourceTypeInfo);(neq,resourceTypeId, typeid1234)" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,objectType,ResourceInfo);(neq,resourceId,resourceid1234)|(eq,objectType,ResourceTypeInfo);(neq,resourceTypeId, typeid1234)" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,objectType,ResourceInfo);(eq,resourceId,bc175af1-b6ff-4002-80db-4ee3c2d4fce6) | (eq,objectType,ResourceInfo);(eq,resourceId,resourceid5678)" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,objectType,ResourceInfo);(neq,resourceId,bc175af1-b6ff-4002-80db-4ee3c2d4fce6) | (eq,objectType,ResourceInfo);(eq,resourceId,resourceid5678)" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "[(eq,objectType,ResourceInfo);(neq,resourceId,bc175af1-b6ff-4002-80db-4ee3c2d4fce6) | (eq,objectType,ResourceInfo);(eq,resourceId,resourceid5678)]" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "[(eq,objectType,ResourceInfo);(eq,resourceId,resourceid1234)]" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "[()|()]" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "[]" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "()" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "();" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": ";()" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": ";();" }

    # ${subscription_data}  input     {"callback": "${SMO_INV_OBSERVER_URL}", "consumerSubscriptionId": "${consumerSubscriptionId}", "filter": "(eq,objectType,ResourceInfo);(eq,resourceId,resourceid1234);" }

    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions     ${subscription_data}
    # Output Schema     request body   ${CURDIR}/schemas/.output/subscription_post_req_properties.json
    # Output Schema   response body   ${CURDIR}/schemas/.output/subscription_post_resp_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    201
    Object   response body

#  s2, query subscription list without filter
#      [documentation]  This test case verifies Query OCloud resourceTypes without filter
#      [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory_Subscription

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions
    # Output Schema   response body   ${CURDIR}/schemas/.output/subscriptions_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    Expect Response Body        ${CURDIR}/schemas/subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions?all_fields
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

# s3, query subscription list with filter
#      [documentation]  This test case verifies Query OCloud resourceTypes with filter
#      [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory_Subscription

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions?filter=(eq,consumerSubscriptionId,${consumerSubscriptionId})
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1

#  s4, query a subscription detail
#      [documentation]  This test case verifies Query OCloud resourceTypes detail
#      [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory_Subscription

     Clear Expectations
     ${res}  GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions
     log   ${res}   level=INFO
    ${subscriptionId}      output   $[0].subscriptionId
    Set Global Variable   ${subscriptionId}
     Clear Expectations
    #Expect Response Body        ${CURDIR}/schemas/subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions/${subscriptionId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourceType_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Object       response body


# Check duplication logic
    Expect Response Body        ${CURDIR}/schemas/client_errors_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions     ${subscription_data}
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    400
    Object   response body

# s5, smo receives notification upon o2ims inventory changes
#      [documentation]  This test case verifies Query OCloud resourcePools without filter
#      [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory_Subscription

    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/subscriptions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions
    #Output Schema   response body   ${CURDIR}/schemas/.output/resourcePools_properties.json
    Clear Expectations
     log      ${res}   level=INFO
     Integer     response status    200
     Array       response body
     Array       $   minItems=1  uniqueItems=true
    ${verify_data}   Output  {"httpRequest": {"path": "${smo.o2ims_inventory_observer.path}"},"times": {"atLeast": 1}}
    SMO called by IMS verification   ${verify_data}


#  s6, delete a subscription
#      [documentation]  This test case verifies Query OCloud resourcePools with filter
#      [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory_Subscription

    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/subscriptions_properties.json
    ${res}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions/${subscriptionId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePools_properties.json
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    # Array       response body
    # Array       $   minItems=1  maxItems=1

# s7, smo stop receiving notification upon o2ims inventory changes
#     [documentation]  This test case verifies Query OCloud resourcePools detail
#     [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory_Subscription

    # # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/subscriptions_properties.json
    # ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions/${subscriptionId}
    # # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePool_properties.json
    # Clear Expectations
    # log      ${res}   level=INFO
    # Integer     response status    200
    # Object       response body

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}

Clear Subscriptions
    Clear Expectations
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions
    log     ${res}   level=DEBUG
    @{subs}        output  $
    FOR     ${sub}      IN      @{subs}
        ${subscriptionId}=  input   ${sub}[subscriptionId]
        ${res2}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/subscriptions/${subscriptionId}
        log     ${res2}   level=DEBUG
    END

Set REST Headers And Clear Subscriptions
    Set REST Headers
    Clear Subscriptions
