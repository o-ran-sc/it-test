*** Settings ***
Documentation  Verify general aspects of o2ims APIs
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
s1, query ApiVersionInformation of o2ims infrastructureInventory services 
    [documentation]  This test case verifies query ApiVersionInformation of o2ims infrastructureInventory services 
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_GeneralAspect

    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/api_versions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/api_versions
    # Output Schema   response body   ${CURDIR}/schemas/.output/api_versions_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200
    Object   response body  

    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/api_versions
    # Output Schema   response body   ${CURDIR}/schemas/.output/api_versions_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200
    Object   response body

s2, query ApiVersionInformation of o2ims infrastructureMonitoring services 
    [documentation]  This test case verifies query ApiVersionInformation of o2ims infrastructureMonitoring services 
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_GeneralAspect

    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/api_versions_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/api_versions
    # Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200
    Object   response body

    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureMonitoring/v1/api_versions
    # Output Schema   response body   ${CURDIR}/schemas/.output/api_versions_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200
    Object   response body

s3, query Resources with nextpage_opaque_marker
    [documentation]  This test case verifies query Resources with nextpage_opaque_marker
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_GeneralAspect

    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    ${resourcePoolId}      output   $[0].resourcePoolId
    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/resources_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?nextpage_opaque_marker=2
    # Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

s4, query Resources with filters
    [documentation]  This test case verifies query Resources with filters
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_GeneralAspect

    Clear Expectations

    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver)
    ${resourceTypeId}      output   $[0].resourceTypeId

    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    ${resourcePoolId}      output   $[0].resourcePoolId
    # Clear Expectations
    # Expect Response Body        ${CURDIR}/schemas/resources_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
    # Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true
    @{resources}     output  $
    FOR     ${resource}     IN      @{resources}
        Should Be Equal  ${resource}[resourceTypeId]  ${resourceTypeId}
    END

    # filter accelerator
    ${substring1}   input   "Intel Corporation"
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(cont,description,${substring1})
    # Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true
    @{resources}     output  $
    FOR     ${resource}     IN      @{resources}
        should contain  ${resource}[description]  ${substring1}
    END

    # filters combination
    
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver_ethernet)
    ${resourceTypeId}      output   $[0].resourceTypeId

    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    ${resourcePoolId}      output   $[0].resourcePoolId
    # Clear Expectations
    ${substring1}   input   "Intel Corporation"
    # Expect Response Body        ${CURDIR}/schemas/resources_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources     {"filter": "(eq,resourceTypeId,${resourceTypeId});(cont,description,${substring1})"}
    # Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true
    @{resources}     output  $
    FOR     ${resource}     IN      @{resources}
        Should Be Equal  ${resource}[resourceTypeId]  ${resourceTypeId}
        Should Contain  ${resource}[description]  ${substring1}
    END

s5, query Resources with attribute selector
    [documentation]  This test case verifies query Resources with attribute selector
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS     ORAN_O2IMS_GeneralAspect

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourceTypes_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?all_fields
    Clear Expectations
    log      ${res}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    Expect Response Body        ${CURDIR}/schemas/resourceTypes_field2_properties.json
    ${res2}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?fields=extensions
    Clear Expectations
    log      ${res2}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    Expect Response Body        ${CURDIR}/schemas/resourceTypes_field3_properties.json
    ${res2}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?exclude_fields=extensions
    Clear Expectations
    log      ${res2}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    Expect Response Body        ${CURDIR}/schemas/resourceTypes_field4_properties.json
    ${res2}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?exclude_default
    Clear Expectations
    log      ${res2}   level=INFO
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
