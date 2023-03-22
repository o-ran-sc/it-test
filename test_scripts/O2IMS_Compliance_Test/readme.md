# Overview

This folder includes the ORAN O2 IMS Compliance Automation Test Scripts, which used
Robot Framework to simulate SMO to issue API request towards O2IMS.

The Mock server simulates the SMO to expose API endpoints for O-Clouds to deliver Notifications from O-Cloud to SMO.

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