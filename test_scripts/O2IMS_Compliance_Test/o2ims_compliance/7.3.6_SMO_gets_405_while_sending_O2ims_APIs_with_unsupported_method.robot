*** Settings ***
Documentation  Verify SMO get 405 while sending o2ims APIs with unsupported method
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
${RESOURCETYPE_NAME}        ${ocloud.oran_o2_app.resourcetype_name}


*** Test Cases ***
s1, Operate resourceTypes with unsupported method
    [documentation]  This test case verifies Operate resourceTypes with unsupported method
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    # ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes
    # # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # # Clear Expectations
    # log      ${res}   level=DEBUG
    # Integer  response status    405
    # Object   response body

    # ${res}     PUT   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes
    # # Clear Expectations
    # log      ${res}   level=DEBUG
    # Integer  response status    405
    # Object   response body

    # ${res}     PATCH   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes
    # # Clear Expectations
    # log      ${res}   level=DEBUG
    # Integer  response status    405
    # Object   response body

    # ${res}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes
    # # Clear Expectations
    # log      ${res}   level=DEBUG
    # Integer  response status    405
    # Object   response body

    ${resourceTypeId}   input   3d19af47-e20d-40f9-ae74-f8cc988a045f
    Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    404

    ${resouceTypeData}      input   {'description': 'An ethernet resource of the physical server', 'name': '5af55345-enp61s0f0', 'parentId': '5af55345-134a-406c-93b6-c5e10318afa5', 'resourceId': '016977ee-c0c3-4e5d-9e53-2bf1d6448aa5', 'resourcePoolId': 'ce2eec13-24b0-4cca-aa54-548be6cc985b','resourceTypeId': '3d19af47-e20d-40f9-ae74-f8cc988a045f'}

    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}       ${resouceTypeData}
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,${RESOURCETYPE_NAME})
    ${resourceTypeId}      output   $[0].resourceTypeId
    ${res}     PUT   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

    ${res}     PATCH   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

    ${res}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body



# s2, Operate resourcePool with unsupported method
#     [documentation]  This test case verifies Operate resourcePool with unsupported method
#     [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

s2, Operate Ocloud with unsupported method
    [documentation]  This test case verifies Operate Ocloud with unsupported method
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_Unsupported_Method

    Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/unsupported_method_properties.json
    ${res}     POST   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/
    # Output Schema   response body   ${CURDIR}/schemas/.output/unsupported_method_properties.json
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

    # ${res}     PUT   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1

    ${res}     PUT   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

    ${res}     PATCH   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    405
    Object   response body

    ${res}     DELETE   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/
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
