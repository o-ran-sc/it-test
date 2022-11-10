#!/bin/bash -x

#cp -rfp inventory/sample inventory/oransc-cluster
. sample_env
declare -a IPS=($ANSIBLE_HOST_IP)
CONFIG_FILE=hosts.yaml python3 inventory.py ${IPS[@]}
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i hosts.yaml --become --private-key ${ANSIBLE_SSH_KEY} cluster.yml

#sshpass -p $ANSIBLE_PASSWORD scp -o StrictHostKeyChecking=no -i ${ANSIBLE_SSH_KEY} -q root@$ANSIBLE_HOST_IP:/root/.kube/config ${PROJECT_ROOT}/config
scp -o StrictHostKeyChecking=no -i ${ANSIBLE_SSH_KEY} -q root@$ANSIBLE_HOST_IP:/root/.kube/config ${PROJECT_ROOT}/config
sed -i "s/127.0.0.1/${ANSIBLE_HOST_IP}/g" "${PROJECT_ROOT}"/config
