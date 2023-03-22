# Overview

This folder includes the ORAN O2 IMS Compliance Automation Test Scripts, which used
Robot Framework to simulate SMO to issue API request towards O2IMS.

The Mock server simulates the SMO to expose API endpoints for O-Clouds to deliver Notifications from O-Cloud to SMO.

The detailed structure with comments is below.

```
O2IMS_Compliance_Test
       |--o2ims_compliance # where all the compliance test cases related are here.
                     |--schemas   # all the json schema used to validate the O2ims response body are put here.
                                 |-- xxx.json #The json schema which used by automation test cases to validate the o2ims response body compliance to O-RAN Working Group 6 O2ims Interface Specification.
                                 |--yyy.json # For example:  Expect Response Body        ${CURDIR}/schemas/alarm_subscription_properties.json
                                 |-- …..json
                     |--__init__.robot #helper robot script where put common key words definition used by test cases scripts.
                     |--oran-helm.robot# same as above.
                     |--oran-lcm.robot # same as above.
                     |--smo_server_mock.robot # helper robot script where put smo server mock related common key words together.
                     |--ssh_helper.robot # ssh helper robot script used by test cases scripts.
                     |--7.3.2_SMO_succeeds_xxx.robot # The automation test cases which are in compliance to test spec, which you can find in reference doc [9] 
                     |--7.3.3…  #the same as above one.
                     |-- …
                     |--7.3.10  # same as above one.
       |--mock.sh # The sample script to help input smo mock endpoints in mock server
       |--readme.md #Overall explaination about this folder mainly about how to compose test env and run robot test cases etc.
       |--test_configs.yaml # The config file used by robot framework and test cases script with comments.

```

## Test Environment Preparation

### Prepare robot framework with virtualenv

```
virtualenv .robot
source .robot/bin/activate
pip3 install --upgrade robotframework
pip3 install --upgrade RESTinstance
pip3 install --upgrade robotframework-sshlibrary

robot --version

```
### Prepare SMO Mock Server

Please see reference doc [8] to set up mock server.

Use the sample shell script to add mock expectations to mock server.

```
bash sample.sh 127.0.0.1 1080
```

Use the sample command below to check can get the expected response from mockserver.

For one example on local test env.

```

 curl -v -k -X POST http://127.0.0.1:1080/mock_smo/v1/ocloud_observer
*   Trying 127.0.0.1...
* Connected to 127.0.0.1 (127.0.0.1) port 1080 (#0)
> POST /mock_smo/v1/ocloud_observer HTTP/1.1
> Host: 127.0.0.1:1080
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 204 No Content
< connection: keep-alive
< content-type: application/json; charset=utf-8
<
* Connection #0 to host 127.0.0.1 left intact
```

And other test sample expectations are the same way.

### Test Configuration File

The test_configs.yaml is the configuration file for the test script
to get environments for issuing requests to O2 IMS service.

### Run Test Scripts

```
robot -L debug -d ./.reports ./o2ims
```

### Debug tips

Please check the mock server dashboard to help debug your request status.

http://mockserverip:1081/mockserver/dashboard

## Reference

1. [https://mock-server.com/]
2. [https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html]
3. [http://robotframework.org/robotframework/2.6.1/libraries/BuiltIn.html]
4. [https://robotframework.org/?tab=1#getting-started]
5. [https://asyrjasalo.github.io/RESTinstance]
6. [https://pypi.org/project/RESTinstance/]
7. [http://robotframework.org/SSHLibrary/]
8. [https://www.mock-server.com/where/docker.html]
9. [https://oranalliance.atlassian.net/wiki/download/attachments/2505408783/O-RAN.WG6-O-CLOUD_CONF_TEST-R003-v01.00.00.docx?api=v2]