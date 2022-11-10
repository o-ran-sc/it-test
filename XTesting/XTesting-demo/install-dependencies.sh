#! /bin/bash -x

# openssh
apt install -y openssh-server
systemctl status ssh
ufw allow ssh

# docker
apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null


apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable docker
systemctl start docker

# XTesting dependencies
apt update && apt install git -y
[ -z "$VIRTUAL_ENV" ] && apt install python3-pip -y && pip3 install ansible
ansible-galaxy install collivier.xtesting
ansible-galaxy collection install ansible.posix community.general community.grafana \
  community.kubernetes community.docker community.postgresql
