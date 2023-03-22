#!/bin/bash
# $1 mocker server host
# $2 mocker server port
export mockserver_host=$1
export mockserver_port=$2
export SMO_ENDPOINT="https://${mockserver_host}:${mockserver_port}/mockserver"

VALID_CLOUD_OBSERVER="{
 \"id\": \"mock_smo_registration\",
  \"httpRequest\" : {
    \"path\" : \"/mock_smo/v1/ocloud_observer\",
    \"method\":\"POST\"
  },
  \"httpResponse\" : {
   \"statusCode\": 204,
    \"body\" : {
    \"status\": 204,
    \"result\": \"Welcome to mocked smo server!\"
    }
  },
  \"priority\" : 10
}"

INVALID_CLOUD_OBSERVER="{
  \"id\": \"invalid_mock_smo_registration\",
  \"httpRequest\" : {
    \"path\" : \"/mock_smo/v1/invalid_ocloud_observer\",
    \"method\":\"POST\"
  },
  \"httpResponse\" : {
    \"statusCode\": 500,
    \"body\" : {
    \"status\": 500,
    \"result\": \"mocked smo server invalid\"
    }
  },
  \"priority\" : 10
}"

O2IMS_INVENTORY_OBSERVER="{
  \"id\": \"mock_smo_inventory_change_notification_endpoint_registration\",
  \"httpRequest\" : {
    \"path\" : \"/mock_smo/v1/o2ims_inventory_observer\",
    \"method\":\"POST\"
  },
  \"httpResponse\" : {
    \"statusCode\": 204,
    \"body\" : {
    \"status\": 204,
    \"result\": \"this is mocked inventory change notification callback\"
    }
  },
  \"priority\" : 10
}"

O2IMS_ALARM_OBSERVER="{
  \"id\": \"mock_smo_alarm_notification_endpoint_registration\",
  \"httpRequest\" : {
    \"path\" : \"/mock_smo/v1/o2ims_alarm_observer\",
    \"method\":\"POST\"
  },
  \"httpResponse\" : {
    \"statusCode\": 204,
    \"body\" : {
    \"status\": 204,
    \"result\": \"Welcome to mocked smo server alarm notification endpoint\"
    }
  },
  \"priority\" : 10
}"

curl -s -k -X PUT $SMO_ENDPOINT/expectation  --header 'Content-Type: application/json' \
--header 'Accept: application/json' \
-d "${VALID_CLOUD_OBSERVER}" 

curl -s -k -X PUT $SMO_ENDPOINT/expectation  --header 'Content-Type: application/json' \
--header 'Accept: application/json' \
-d "${INVALID_CLOUD_OBSERVER}"

curl -s -k -X PUT $SMO_ENDPOINT/expectation  --header 'Content-Type: application/json' \
--header 'Accept: application/json' \
-d "${O2IMS_INVENTORY_OBSERVER}"


curl -s -k -X PUT $SMO_ENDPOINT/expectation  --header 'Content-Type: application/json' \
--header 'Accept: application/json' \
-d "${O2IMS_ALARM_OBSERVER}"

exit
