*** Settings ***
Documentation  Verify SMO succeeds to query inventory with O2ims APIs and correct token
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
s1, query o-cloud detail
    [documentation]  This test case verifies Query OCloud Detail
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS
    # Builtin.Set Log Level   DEBUG
    # Set SSL Verify      False
    # Set Headers     {"accept": "application/json"}
    # Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/ocloud_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/
    # Output Schema   response body   ${CURDIR}/schemas/.output/ocloud_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200
    # Object   response body
    String   $.globalcloudId    ${GLOBAL_OCLOUD_ID1}
    # Sometimes serviceUri might not contain the port number in the json response if it is a well-known port.
    IF      ${ORAN_SERVICE_NODE_PORT} == 443 or ${ORAN_SERVICE_NODE_PORT} == 80
        String   $.serviceUri    ${ORAN_O2IMS_ENDPOINT}  ${ocloud.oran_o2_app.api.protocol}://${ORAN_HOST_EXTERNAL_IP}
    ELSE
        String   $.serviceUri    ${ORAN_O2IMS_ENDPOINT}
    END

    # all_fields
    Expect Response Body        ${CURDIR}/schemas/ocloud_allfields_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/ocloud_allfields_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer  response status    200

s2, query resource type list without filter
    [documentation]  This test case verifies Query OCloud resourceTypes without filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourceTypes_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourceTypes_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    # all_fields
    Expect Response Body        ${CURDIR}/schemas/resourceTypes_allfields_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourceTypes_allfields_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body


s3, query resource type list with filters
    [documentation]  This test case verifies Query OCloud resourceTypes with filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourceTypes_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver)
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  maxItems=1
    # String      $[0].resourceTypeId
    # String      $[0].name
    # String      $[0].resourceKind
    # String      $[0].resourceClass
    # String      $[0].resourceTypeId

s4, query resource type list with selectors
    [documentation]  This test case verifies query resource type list with selectors
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourceTypes_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?fields=name,description
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

s5, query Resource Type detail
    [documentation]  This test case verifies Query OCloud resourceTypes detail
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver)
    ${resourceTypeId}      output   $[0].resourceTypeId
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourceType_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourceType_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Object       response body

    # all_fields
    Expect Response Body        ${CURDIR}/schemas/resourceType_allfields_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes/${resourceTypeId}?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourceType_allfields_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Object       response body
    String   $.alarmDictionary.managementInterfaceId    "O2IMS"

s6, query Resource Pool list without filter
    [documentation]  This test case verifies Query OCloud resourcePools without filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourcePools_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePools_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

    # # all_fields
    # # Expect Response Body        ${CURDIR}/schemas/resourcePools_allfields_properties.json
    # ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePools_allfields_properties.json
    # Clear Expectations
    # log      ${res}   level=DEBUG
    # Integer     response status    200

s7, query Resource Pool list with filter
    [documentation]  This test case verifies Query OCloud resourcePools with filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory

    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    ${resourcePoolId}      output   $[0].resourcePoolId

    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourcePools_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools?filter=(eq,resourcePoolId,${resourcePoolId})
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePools_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  maxItems=1

s8, query Resource Pool list with selector
    [documentation]  This test case verifies query Resource Pool list with selector
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourcePools_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePools_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Array       response body
    Array       $   minItems=1  uniqueItems=true

s9, query Resource Pool detail
    [documentation]  This test case verifies Query OCloud resourcePools detail
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    ${resourcePoolId}      output   $[0].resourcePoolId
    # Clear Expectations
    Expect Response Body        ${CURDIR}/schemas/resourcePool_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePool_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200
    Object       response body

    # all_fields
    Expect Response Body        ${CURDIR}/schemas/resourcePool_allfields_properties.json
    ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}?all_fields
    # Output Schema   response body   ${CURDIR}/schemas/.output/resourcePool_allfields_properties.json
    Clear Expectations
    log      ${res}   level=DEBUG
    Integer     response status    200


s10, query Resource list of a Resource Pool without filter
    [documentation]  This test case verifies Query OCloud Resource list without filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]
        # Clear Expectations
        Expect Response Body        ${CURDIR}/schemas/resources_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources
        # Output Schema   response body   ${CURDIR}/schemas/.output/resources_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Array       response body
        Array       $   minItems=1  uniqueItems=true
    END


s11, query Resource list of a Resource Pool with filter
    [documentation]  This test case verifies Query OCloud Resource list with filter
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver)
    ${resourceTypeId}      output   $[0].resourceTypeId
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]
        # Clear Expectations
        Expect Response Body        ${CURDIR}/schemas/resources_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
        # Output Schema   response body   ${CURDIR}/schemas/.output/resources_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Array       response body
        Array       $   minItems=1  uniqueItems=true
    END


s12, query Resource list of a Resource Pool with selector
    [documentation]  This test case verifies query Resource list of a Resource Pool with selector
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver)
    ${resourceTypeId}      output   $[0].resourceTypeId
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]
        # Clear Expectations
        Expect Response Body        ${CURDIR}/schemas/resources_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?exclude_default
        # Output Schema   response body   ${CURDIR}/schemas/.output/resources_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Array       response body
        Array       $   minItems=1  uniqueItems=true
    END

s13, query Resource detail
    [documentation]  This test case verifies Query OCloud Resource Detail of pserver
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver)
    ${resourceTypeId}      output   $[0].resourceTypeId
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]

        Clear Expectations
        GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
        @{resources}    output   $
        ${length1}=     Get Length     ${resources}
        IF      ${length1} == 0
            log     "resourcePool with id: ${resourcePoolId} has no resource"
            CONTINUE
        END
        ${resourceId}      output   $[0].resourceId

        Expect Response Body        ${CURDIR}/schemas/resource_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources/${resourceId}

        # Output Schema   response body   ${CURDIR}/schemas/.output/resource_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Object      response body

        # all_fields

        Expect Response Body        ${CURDIR}/schemas/resource_allfields_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources/${resourceId}?all_fields
        # Output Schema   response body   ${CURDIR}/schemas/.output/resource_allfields_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        ${description}    output    $.description
        should contain  ${description}  hostname:
        should contain  ${description}  id:
        should contain  ${description}  personality:
        should contain  ${description}  subfunctions:
        should contain  ${description}  max_cpu_mhz_allowed:
        should contain  ${description}  install_state:
        should contain  ${description}  operational:
        should contain  ${description}  availability:
        should contain  ${description}  administrative:
        should contain  ${description}  boot_device:
        should contain  ${description}  mgmt_mac:
        should contain  ${description}  clock_synchronization:
        should contain  ${description}  rootfs_device:
        Object      $.extensions
        String      $.extensions['hostname']
        Integer      $.extensions['id']
        String      $.extensions['personality']
        # String      $.extensions['max_cpu_mhz_allowed']
        # String      $.extensions['install_state']
        String      $.extensions['operational']
        String      $.extensions['availability']
        String      $.extensions['administrative']
        String      $.extensions['boot_device']
        String      $.extensions['rootfs_device']
        String      $.extensions['subfunctions']
        String      $.extensions['mgmt_mac']
        String      $.extensions['clock_synchronization']

        BREAK
    END


s14, query Resource detail of an accelerator
    [documentation]  This test case verifies Query OCloud Resource Detail of an accelerator
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver_acc)
    ${resourceTypeId}      output   $[0].resourceTypeId
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]

        Clear Expectations
        GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
        @{resources}    output   $
        ${length1}=     Get Length     ${resources}
        IF      ${length1} == 0
            log     "resourcePool with id: ${resourcePoolId} has no resource of accelerator"
            CONTINUE
        END
        ${resourceId}      output   $[0].resourceId

        Expect Response Body        ${CURDIR}/schemas/resource_allfields_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources/${resourceId}?all_fields

        # Output Schema   response body   ${CURDIR}/schemas/.output/resource_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Object      response body
        ${description}    output    $.description
        should contain  ${description}  name:
        should contain  ${description}  pdevice:
        should contain  ${description}  pciaddr:
        should contain  ${description}  pvendor_id:
        should contain  ${description}  pvendor:
        should contain  ${description}  pclass_id:
        should contain  ${description}  pclass:
        should contain  ${description}  psvendor:
        should contain  ${description}  psdevice:
        should contain  ${description}  sriov_totalvfs:
        should contain  ${description}  sriov_numvfs:
        should contain  ${description}  numa_node:
        # should contain  ${description}  name:
        # should contain  ${description}  class:
        # should contain  ${description}  vendor:
        Object      $.extensions
        String      $.extensions['name']
        String      $.extensions['pdevice']
        String      $.extensions['pciaddr']
        String      $.extensions['pvendor_id']
        String      $.extensions['pvendor']
        String      $.extensions['pclass_id']
        String      $.extensions['pclass']
        String      $.extensions['psvendor']
        String      $.extensions['psdevice']
        # Integer      $.extensions['sriov_totalvfs']
        Integer     $.extensions['sriov_numvfs']
        Integer     $.extensions['numa_node']

        BREAK
    END

s15, query Resource detail of an cpu
    [documentation]  This test case verifies Query OCloud Resource Detail of an cpu
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver_cpu)
    ${resourceTypeId}      output   $[0].resourceTypeId
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]

        Clear Expectations
        GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
        @{resources}    output   $
        ${length1}=     Get Length     ${resources}
        IF      ${length1} == 0
            log     "resourcePool with id: ${resourcePoolId} has no resource of accelerator"
            CONTINUE
        END
        ${resourceId}      output   $[0].resourceId

        Expect Response Body        ${CURDIR}/schemas/resource_allfields_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources/${resourceId}?all_fields

        # Output Schema   response body   ${CURDIR}/schemas/.output/resource_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Object      response body
        ${description}    output    $.description
        should contain  ${description}  core:
        should contain  ${description}  thread:
        should contain  ${description}  allocated_function:
        should contain  ${description}  numa_node:
        should contain  ${description}  cpu_model:
        should contain  ${description}  cpu_family:
        should contain  ${description}  cpu:
        Object      $.extensions
        Integer      $.extensions['cpu']
        Integer      $.extensions['core']
        Integer      $.extensions['thread']
        String      $.extensions['allocated_function']
        Integer      $.extensions['numa_node']
        String      $.extensions['cpu_model']
        String      $.extensions['cpu_family']

        BREAK
    END


s16, query Resource detail of an interface
    [documentation]  This test case verifies Query OCloud Resource Detail of an interface
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver_if)
    ${resourceTypeId}      output   $[0].resourceTypeId
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]

        Clear Expectations
        GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
        @{resources}    output   $
        ${length1}=     Get Length     ${resources}
        IF      ${length1} == 0
            log     "resourcePool with id: ${resourcePoolId} has no resource of accelerator"
            CONTINUE
        END
        ${resourceId}      output   $[0].resourceId

        Expect Response Body        ${CURDIR}/schemas/resource_allfields_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources/${resourceId}?all_fields

        # Output Schema   response body   ${CURDIR}/schemas/.output/resource_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Object      response body
        ${description}    output    $.description
        should contain  ${description}  ifname:
        should contain  ${description}  iftype:
        should contain  ${description}  imac:
        should contain  ${description}  vlan_id:
        should contain  ${description}  imtu:
        should contain  ${description}  ifclass:
        should contain  ${description}  uses:
        should contain  ${description}  max_tx_rate:
        should contain  ${description}  sriov_vf_driver:
        should contain  ${description}  sriov_numvfs:
        should contain  ${description}  ptp_role:
        Object      $.extensions
        String      $.extensions['ifname']
        String      $.extensions['iftype']
        String      $.extensions['imac']
        # Integer      $.extensions['vlan_id']
        Integer      $.extensions['imtu']
        # String      $.extensions['ifclass']
        # String      $.extensions['uses']
        # Integer      $.extensions['max_tx_rate']
        # String      $.extensions['sriov_vf_driver']
        # Integer     $.extensions['sriov_numvfs']
        # String     $.extensions['ptp_role']

        BREAK
    END


s17, query Resource detail of a memory
    [documentation]  This test case verifies Query OCloud Resource Detail of a memory
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver_mem)
    ${resourceTypeId}      output   $[0].resourceTypeId
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]

        Clear Expectations
        GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
        @{resources}    output   $
        ${length1}=     Get Length     ${resources}
        IF      ${length1} == 0
            log     "resourcePool with id: ${resourcePoolId} has no resource of accelerator"
            CONTINUE
        END
        ${resourceId}      output   $[0].resourceId

        Expect Response Body        ${CURDIR}/schemas/resource_allfields_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources/${resourceId}?all_fields

        # Output Schema   response body   ${CURDIR}/schemas/.output/resource_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Object      response body
        ${description}    output    $.description
        should contain  ${description}  memtotal_mib:
        should contain  ${description}  memavail_mib:
        should contain  ${description}  vm_hugepages_use_1G:
        should contain  ${description}  vm_hugepages_possible_1G:
        should contain  ${description}  hugepages_configured:
        should contain  ${description}  vm_hugepages_avail_1G:
        should contain  ${description}  vm_hugepages_nr_1G:
        should contain  ${description}  vm_hugepages_nr_4K:
        should contain  ${description}  vm_hugepages_nr_2M:
        should contain  ${description}  numa_node:
        should contain  ${description}  vm_hugepages_possible_2M:
        should contain  ${description}  vm_hugepages_avail_2M:
        should contain  ${description}  platform_reserved_mib:
        Object      $.extensions
        Integer      $.extensions['memtotal_mib']
        Integer      $.extensions['memavail_mib']
        # String       $.extensions['vm_hugepages_use_1G']
        Integer      $.extensions['vm_hugepages_possible_1G']
        # String       $.extensions['hugepages_configured']
        Integer      $.extensions['vm_hugepages_avail_1G']
        Integer      $.extensions['vm_hugepages_nr_1G']
        Integer      $.extensions['vm_hugepages_nr_4K']
        Integer      $.extensions['vm_hugepages_nr_2M']
        Integer      $.extensions['vm_hugepages_possible_2M']
        Integer      $.extensions['vm_hugepages_avail_2M']
        Integer      $.extensions['platform_reserved_mib']
        Integer      $.extensions['numa_node']

        BREAK
    END

s18, query Resource detail of an ethernet port
    [documentation]  This test case verifies Query OCloud Resource Detail of an ethernet port
    [tags]  ORAN_Compliance     ORAN_O2     ORAN_O2IMS    ORAN_O2IMS_Inventory
    Clear Expectations
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourceTypes?filter=(eq,name,pserver_ethernet)
    ${resourceTypeId}      output   $[0].resourceTypeId
    GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools
    @{resourcePools}     output  $
    FOR     ${resourcePool}     IN      @{resourcePools}
        # ${resourcePoolId}      output   $[0].resourcePoolId
        ${resourcePoolId}       input       ${resourcePool}[resourcePoolId]

        Clear Expectations
        GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources?filter=(eq,resourceTypeId,${resourceTypeId})
        @{resources}    output   $
        ${length1}=     Get Length     ${resources}
        IF      ${length1} == 0
            log     "resourcePool with id: ${resourcePoolId} has no resource of accelerator"
            CONTINUE
        END
        ${resourceId}      output   $[0].resourceId

        Expect Response Body        ${CURDIR}/schemas/resource_allfields_properties.json
        ${res}     GET   ${ORAN_O2IMS_ENDPOINT}/o2ims-infrastructureInventory/v1/resourcePools/${resourcePoolId}/resources/${resourceId}?all_fields

        # Output Schema   response body   ${CURDIR}/schemas/.output/resource_properties.json
        # Clear Expectations
        log      ${res}   level=DEBUG
        Integer     response status    200
        Object      response body
        ${description}    output    $.description
        should contain  ${description}  name:
        should contain  ${description}  pdevice:
        should contain  ${description}  pciaddr:
        should contain  ${description}  mac:
        should contain  ${description}  dev_id:
        should contain  ${description}  pclass:
        should contain  ${description}  psvendor:
        should contain  ${description}  psdevice:
        should contain  ${description}  sriov_totalvfs:
        should contain  ${description}  sriov_numvfs:
        should contain  ${description}  numa_node:
        should contain  ${description}  capabilities:
        should contain  ${description}  type:
        should contain  ${description}  driver:
        Object      $.extensions
        String      $.extensions['name']
        String      $.extensions['pdevice']
        String      $.extensions['pciaddr']
        String      $.extensions['mac']
        Integer      $.extensions['dev_id']
        String      $.extensions['pclass']
        String      $.extensions['psvendor']
        String      $.extensions['psdevice']
        # Integer      $.extensions['sriov_totalvfs']
        Integer     $.extensions['sriov_numvfs']
        Integer     $.extensions['numa_node']
        # Integer     $.extensions['capabilities']
        String     $.extensions['type']
        String     $.extensions['driver']

        BREAK
    END

*** Keywords ***
Set REST Headers
    Set Headers     {"accept": "application/json"}
    Set Headers     {"Authorization": "Bearer ${SMO_TOKEN_DATA}"}
    Set Client Cert   ${CURDIR}/../certs/client.pem
