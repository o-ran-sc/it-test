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

### Prepare the client certificates for mTLS

Since mTLS is supported by the O2 IMS API service, you need to add the client certificates when requesting the API.

Here are the steps to generate client certificates using the MockServer CA certificate:

* Generate Client Certificates:

Follow these steps to generate client certificates using the MockServer CA certificate.

```bash
cd certs

# Get MockServer CA cert and key
wget -O smo-ca-cert.pem https://raw.githubusercontent.com/mock-server/mockserver/master/mockserver-core/src/main/resources/org/mockserver/socket/CertificateAuthorityCertificate.pem

wget -O smo-ca-key.pem https://raw.githubusercontent.com/mock-server/mockserver/master/mockserver-core/src/main/resources/org/mockserver/socket/CertificateAuthorityPrivateKey.pem

# Generate client CSR (Certificate Signing Request) and key
openssl genrsa -out client-key.pem 2048
openssl req -new -key client-key.pem -out client.csr

# Sign the Client CSR with MockServer's CA
openssl x509 -req -in client.csr -CA smo-ca-cert.pem -CAkey smo-ca-key.pem -CAcreateserial -out client-cert.pem -days 365

# Combine the client cert and private key to one file
cat client-cert.pem client-key.pem > client.pem
```

* Ensure Correct CA Certificate:

Make sure you are using the MockServer CA certificate (smo_cert) when setting up the O2 application.

### Test Configuration File Guide.

The test_configs.yaml is the configuration file for the test script to get environment variables for issuing requests to O2 IMS service, to
install INF O2 Service, please reference doc [10] and [11], after installation and provisioning O2 IMS services, the corresponding O2 IMS parameters
should be input into below config files correspondingly before running automation test.

The sample config file parameters explaination in details as below.
```
ocloud: # O Cloud side configuration.
  ssh: #olcoud ssh info
    host: 192.168.112.12 # API Host Floating IP.
    port: 22 #ssh server port
    username: username
    password: passwd
    openrc: /etc/platform/openrc
  oran_o2_app:
    g_location_id: testlocation_1 # global location id from SMO.
    g_ocloud_id: 18f2dc90-b375-47dd-b8dc-ae80072e6cdb # global ocloud id from SMO.
    smo_token_data: put_smo_token_data_here # smo token, currently generated by o2ims and deliver to SMO side by O-Cloud available notification, refer to doc [0]
    api:
      host: 192.168.112.15 # O2 IMS API Host Floating IP.
      node_port: 30205 # O2 IMS port
      protocol: https #O2 IMS application protocol.

smo: #smo mock server ip and callback endpoints
  service:
    protocol: https # SMO application protocol.
    host: 192.168.112.16 # SMO Host IP.
    port: 1080 # SMO Service Port.
    verify_endpoint: /mockserver/verify # Test tool verification, refer to [1]
  ocloud_observer: # Simulate SMO O Cloud Registration callback Endpoint.
    path: /mock_smo/v1/ocloud_observer
  o2ims_inventory_observer: #Simulate SMO inventory notification callback endpoint.
    path: /mock_smo/v1/o2ims_inventory_observer
  o2ims_alarm_observer: #Simulate SMO alarm notification callback endpoint.
    path: /mock_smo/v1/o2ims_alarm_observer
```
After finish input the parameters, user is ready to run the automation test cases.

### Run Test Scripts

```
robot -L debug -d ./.reports ./o2ims_compliance
```

### Debug tips

Please check the mock server dashboard to help debug your request status.

http://mockserverip:1081/mockserver/dashboard

## Reference
0. [https://oranalliance.atlassian.net/wiki/download/attachments/2612854785/O-RAN.WG6.O2IMS-INTERFACE-v03.00.pdf?api=v2]
1. [https://mock-server.com/]
2. [https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html]
3. [http://robotframework.org/robotframework/2.6.1/libraries/BuiltIn.html]
4. [https://robotframework.org/?tab=1#getting-started]
5. [https://asyrjasalo.github.io/RESTinstance]
6. [https://pypi.org/project/RESTinstance/]
7. [http://robotframework.org/SSHLibrary/]
8. [https://www.mock-server.com/where/docker.html]
9. [https://oranalliance.atlassian.net/wiki/download/attachments/2505408783/O-RAN.WG6-O-CLOUD_CONF_TEST-R003-v01.00.00.docx?api=v2]
10. [https://docs.o-ran-sc.org/projects/o-ran-sc-pti-o2/en/latest/installation-guide.html]
11. [https://docs.o-ran-sc.org/projects/o-ran-sc-pti-o2/en/latest/user-guide.html]