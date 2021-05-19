#! /bin/bash

#Installation to use ssh
sudo yum install -y epel-release
sudo yum install -y sshpass
sudo yum install -y git

#Ansible installation
sudo yum install -y epel ansible

#Create ssh config
sudo bash -c 'touch /home/vagrant/.ssh/config'
sudo bash -c 'printf "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n" > /home/vagrant/.ssh/config'
sudo chmod 600 /home/vagrant/.ssh/config

sudo ssh-keygen -b 4096 -t rsa -f /home/vagrant/.ssh/id_rsa -q -C "" -N ""
sudo chown vagrant /home/vagrant/.ssh/id_rsa*
sudo chgrp vagrant /home/vagrant/.ssh/id_rsa*

cp /home/vagrant/.ssh/id_rsa.pub /home/vagrant/authorized_keys

sudo bash -c 'mkdir /root/.ssh'
sudo bash -c 'touch /root/.ssh/authorized_keys'
#sudo bash -c 'cp .ssh/authorized_keys .ssh/authorized_keys.orig'
sudo bash -c 'cat ~vagrant/authorized_keys > /root/.ssh/authorized_keys'
sudo bash -c 'chmod 600 /root/.ssh/authorized_keys'

#SCP
sshpass -p 'vagrant' scp -oStrictHostKeyChecking=no authorized_keys c1:
sshpass -p 'vagrant' scp -oStrictHostKeyChecking=no authorized_keys c2:


#Axustes c1 e c2
sshpass -p 'vagrant' ssh root@c1 'mkdir /root/.ssh'
sshpass -p 'vagrant' ssh root@c1 'touch /root/.ssh/authorized_keys'
sshpass -p 'vagrant' ssh root@c1 'cat ~vagrant/authorized_keys > /root/.ssh/authorized_keys'
sshpass -p 'vagrant' ssh root@c1 'chmod 600 .ssh/authorized_keys'

sshpass -p 'vagrant' ssh root@c2 'mkdir /root/.ssh'
sshpass -p 'vagrant' ssh root@c1 'touch /root/.ssh/authorized_keys'
sshpass -p 'vagrant' ssh root@c2 'cat ~vagrant/authorized_keys > /root/.ssh/authorized_keys'
sshpass -p 'vagrant' ssh root@c2 'chmod 600 .ssh/authorized_keys'


git clone https://github.com/Linaro/ansible-playbook-for-ohpc.git
cd ./ansible-playbook-for-ohpc/
sudo sed -i 's/enable_dhcpd_server: false/enable_dhcpd_server: true/' group_vars/all.yml
./scripts/run.sh
