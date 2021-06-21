#!/bin/sh

sudo su
echo "192.168.44.11 sms" >> /etc/hosts
systemctl disable firewalld
systemctl stop firewalld

yum install http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm


# Install base meta-packages
systemctl enable ntpd.service
echo "server pool.ntp.org" >> /etc/ntp.conf
systemctl restart ntpd

yum -y install ohpc-slurm-server

sed -i 's/ControlMachine=/ControlMachine=sms/g' /etc/slurm/slurm.conf
sed -i 's/NodeName=c\[1\-4\] Sockets=2 CoresPerSocket=8 ThreadsPerCore=2/NodeName=c\[1\-2\] Sockets=1 CoresPerSocket=1 ThreadsPerCore=1/g' /etc/slurm/slurm.conf
sed -i 's/Nodes=c\[1\-4\]/Nodes=c\[1\-2\]/g' /etc/slurm/slurm.conf

#3.7
perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
ifconfig eth1 192.168.44.11 netmask 255.255.255.0 up

systemctl restart xinetd
systemctl enable mariadb.service
systemctl restart mariadb
systemctl enable httpd.service
systemctl restart httpd
systemctl enable dhcpd.service


#3.8.1
export CHROOT=/opt/ohpc/admin/images/centos7.7
wwmkchroot centos-7 $CHROOT

#3.8.2
yum -y --installroot=$CHROOT install ohpc-base-compute
cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf

# O --installroot instala na ruta concreta 
yum -y --installroot=$CHROOT install ohpc-slurm-client
yum -y --installroot=$CHROOT install ntp
yum -y --installroot=$CHROOT install kernel
yum -y --installroot=$CHROOT install lmod-ohpc

#3.8.3
wwinit database
wwinit ssh_keys

echo "192.168.44.11:/home /home nfs nfsvers=3,nodev,nosuid 0 0" >> $CHROOT/etc/fstab
echo "192.168.44.11:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0" >> $CHROOT/etc/fstab

echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports

exportfs -a
systemctl restart nfs-server
systemctl enable nfs-server

chroot $CHROOT systemctl enable ntpd
echo "server 192.168.44.11" >> $CHROOT/etc/ntp.conf


#3.8.5
wwsh file import /etc/passwd
wwsh file import /etc/group
wwsh file import /etc/shadow

wwsh file import /etc/slurm/slurm.conf
wwsh file import /etc/munge/munge.key

# Opcional (infini band)
# wwsh file import /opt/ohpc/pub/examples/network/centos/ifcfg-ib0.ww
# wwsh -y file set ifcfg-ib0.ww --path=/etc/sysconfig/network-scripts/ifcfg-ib0

# 3.9

# 3.9.1
wwbootstrap `uname -r`

# 3.9.2
wwvnfs --chroot $CHROOT

# 3.9.2
# Set provisioning interface as the default networking device
echo "GATEWAYDEV=eth1" > /tmp/network.$$
wwsh -y file import /tmp/network.$$ --name network
wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0

# Add nodes to Warewulf data store
c_name=(c1 c2)
num_computes=2
c_mac=(08:00:27:CB:72:6A 08:00:27:6A:56:7B)
c_ip=(192.168.44.21 192.168.44.22)

for ((i=0; i<$num_computes; i++)) ; do
	wwsh -y node new ${c_name[i]} --ipaddr=${c_ip[i]} --hwaddr=${c_mac[i]} -D eth1
done

wwsh -y provision set "c*" --vnfs=centos7.7 --bootstrap=`uname -r` --files=dynamic_hosts,passwd,group,shadow,slurm.conf,munge.key,network

# Restart dhcp /update PXE
systemctl restart dhcpd
wwsh pxe update

# Inicio manual das máquinas

# 4.2
yum -y install ohpc-autotools
yum -y install EasyBuild-ohpc
yum -y install hwloc-ohpc
yum -y install spack-ohpc
yum -y install valgrind-ohpc


# 4.2
yum -y install gnu8-compilers-ohpc
yum -y install llvm5-compilers-ohpc


# 4.3
yum -y install openmpi3-gnu8-ohpc mpich-gnu8-ohpc
yum -y install mvapich2-gnu8-ohpc
yum -y install mvapich2-psm2-gnu8-ohpc



# 5

# Start munge and slurm controller on master host
systemctl enable munge
systemctl enable slurmctld
systemctl start munge
systemctl start slurmctld
# Start slurm clients on compute hosts
# pdsh -w c[1-4] systemctl start slurmd
