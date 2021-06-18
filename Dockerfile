# Pull latest image of CentOS from Docker repo
FROM centos:7

RUN yum update -y
RUN yum upgrade -y 
RUN yum install -y yum-fastestmirror

# Add user and disable fastmirror plugin
RUN useradd -m openhpc
RUN sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf

# enable OpenHPC repository 
ENV REPO http://build.openhpc.community/OpenHPC:/1.3/
RUN yum install -y $REPO/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm

# Add some packages (from distro & OpenHPC)
RUN yum -y install openssh-clients
RUN yum -y install openmpi3-gnu8-ohpc
RUN yum -y install omb-gnu8-openmpi3-ohpc
RUN yum -y install likwid-gnu8-ohpc
RUN yum -y install lmod-defaults-gnu8-openmpi3-ohpc
RUN yum -y install examples-ohpc

# Set user and starting work directory
USER openhpc
WORKDIR /home/openhpc
