#! /bin/bash
set -x

echo "This is to deploy the AI-ML framework training host"

if [ $# -lt 2 ]
then 
	echo "Usage: $0 target-ip private-key-file-path" 
	exit 1
fi

# pick up the input parameters from command line
IP=$1
KEYFILE=$2

# copy over the deploy.sh to remote
scp -o StrictHostKeyChecking=no -i $KEYFILE -q deploy.sh root@${IP}:~

# copy remote IP to the hosts.yaml file
echo "${IP}" >> hosts.yaml

# kick start the installation on remote
ansible-playbook -b -v  -i hosts.yaml --become --private-key $KEYFILE cluster.yaml
