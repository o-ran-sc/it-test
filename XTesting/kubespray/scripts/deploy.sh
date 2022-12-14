#!/bin/bash

cp -rfp inventory/sample inventory/oransc-cluster
. sample_env
declare -a IPS=($ANSIBLE_HOST_IP)
CONFIG_FILE=inventory/oransc-cluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
ansible-playbook -i inventory/oransc-cluster/hosts.yaml --become --private-key inventory/oransc-cluster/id_rsa cluster.yml

#sshpass -p $ANSIBLE_PASSWORD scp -o StrictHostKeyChecking=no -i inventory/oransc-cluster/id_rsa -q root@$ANSIBLE_HOST_IP:/root/.kube/config ${PROJECT_ROOT}/config
scp -o StrictHostKeyChecking=no -i inventory/oransc-cluster/id_rsa -q root@$ANSIBLE_HOST_IP:/root/.kube/config ${PROJECT_ROOT}/config
sed -i "s/127.0.0.1/${ANSIBLE_HOST_IP}/g" "${PROJECT_ROOT}"/config
