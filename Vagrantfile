# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # config.vm.network "public_network"
  
  config.vm.network "private_network", ip: "10.10.10.10"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.cpus = 4
    vb.memory = "1024"
  end
  
  config.vm.provision "shell", inline: <<-SHELL
    sudo yum update -y
    sudo yum upgrade -y
    sudo yum -y groupinstall 'Development Tools'
    sudo yum -y install wget epel-release gcc docker git
    sudo yum -y install debootstrap.noarch squashfs-tools openssl-devel libuuid-devel gpgme-devel libseccomp-devel cryptsetup-luks
    
    wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
    sudo tar --directory=/usr/local -xzvf go1.13.linux-amd64.tar.gz
    export PATH=/usr/local/go/bin:$PATH
    
    wget https://github.com/singularityware/singularity/releases/download/v3.5.3/singularity-3.5.3.tar.gz
    tar -xzvf singularity-3.5.3.tar.gz
    
    cd singularity
    ./mconfig
    cd builddir
    make
    sudo make install
    
    . etc/bash_completion.d/singularity
    sudo cp etc/bash_completion.d/singularity /etc/bash_completion.d/

  SHELL

end
