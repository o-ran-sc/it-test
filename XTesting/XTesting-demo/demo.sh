#! /bin/bash
set -x

echo "This is to demonstrate the XTesting work flow against the OSC RIC platform deployment and perform health check"

if [ $# -lt 2 ]
then 
	echo "Usage: $0 target-ip private-key-file-path [working-directory]"
	exit 1
fi

# pick up the input parameters from command line
IP=$1
KEYFILE=$2
ORIG=$PWD
if [ $# -ge 3 ]
then
	WORKDIR=$3
else
	WORKDIR=$PWD
fi

# make the working directory if it's not there yet
if [ ! -d $WORKDIR ]
then 
	mkdir -p $WORKDIR
fi

# copy over the health check test case to the working directory
cp healthcheck.robot $WORKDIR

cd $WORKDIR

# replace it with the target IP address for health check
sed -i "s/TARGET-IP/${IP}/" healthcheck.robot

###### step 1 deploy Kubernetes cluster and obtain the Kube config

# remove the old one if it's already there
if [ -d kubeadm ]
then
	rm -rf kubeadm
fi

# copy over the content to build the kubeadm container
mkdir kubeadm
cp -r $ORIG/../kubeadm/* kubeadm/

cd kubeadm
# update the host IP in the environment file
TMPFILE=/tmp/tmp`date +%s`
cat sample_env | sed -e '/ANSIBLE_HOST_IP/d' > $TMPFILE
echo "ANSIBLE_HOST_IP=${IP}" > sample_env
cat $TMPFILE >> sample_env

# copy the private key to the inventory/sample folder as id_rsa
cp $KEYFILE id_rsa
chmod 400 id_rsa

# build the Docker image
docker build -t kubeadm .

# run the docker container to deploy Kubernetes onto the SUT specified by the IP address
docker run -v ~/.kube:/kubeadm/config kubeadm 

###### step 2 complete the deployment based on the Kube config from step 1

cd $WORKDIR
# remove the old one if it's already there
if [ -d richelm ]
then
	rm -rf richelm
fi

#copy over the content to build the richelm container
mkdir richelm
cp -r $ORIG/../richelm/* richelm/

#build the container
cd richelm && ./build.sh static

#run the container with the kubeconfig to complete the RIC platform deployment
sudo docker run -ti --rm -w /apps -v ~/.kube:/root/.kube -t richelmlegacy:1.19.16 

# sometimes some RIC platform containers are not up right away so wait a bit
sleep 60	

cd $WORKDIR
###### step 3 run the health check test case 
ansible-playbook healthcheck.robot

###### step 4 onboard/install the kpimon-go xApp on the remote host
# copy over the deploy.sh to remote
scp -o StrictHostKeyChecking=no -i $KEYFILE -q $ORIG/../xapp/deploy.sh root@${IP}:~

# copy remote IP to the hosts.yaml file
cd $ORIG/../xapp
echo "${IP}" >> hosts.yaml

# onboard/install the kpimon-go xApp on remote
ansible-playbook -b -v  -i hosts.yaml --become --private-key $KEYFILE cluster.yaml
