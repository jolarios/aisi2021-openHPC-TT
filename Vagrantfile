# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.7"
  config.vm.box_check_update = false

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.vbguest.auto_update = false

  config.vm.provision "file", source: "./provisioning/bootstrap.sh", destination: "/home/vagrant/bootstrap.sh"

  config.vm.define "sms" do |sms|
    sms.vm.hostname = "sms"

    sms.vm.network :private_network, ip:"192.168.44.11", virtualbox__intnet: true, virtualbox__intnet: "management"
    sms.vm.network :private_network, ip:"192.168.33.11", virtualbox__intnet: true, virtualbox__intnet: "computing"
    sms.vm.network :private_network, ip:"192.168.66.11", virtualbox__intnet: true, virtualbox__intnet: "bmc"
    
  end


  config.vm.define "c1" do |c1|
    c1.vm.hostname = "c1"

    c1.vm.network :private_network, ip:"192.168.44.21", virtualbox__intnet: true, virtualbox__intnet: "management"
    c1.vm.network :private_network, ip:"192.168.33.21", virtualbox__intnet: true, virtualbox__intnet: "computing"
    c1.vm.network :private_network, ip:"192.168.66.21", virtualbox__intnet: true, virtualbox__intnet: "bmc"

    c1.vm.provision "shell", inline: <<-SHELL
      echo "hola"
    SHELL
  end


  config.vm.define "c2" do |c2|
    c2.vm.hostname = "c2"

    c2.vm.network :private_network, ip:"192.168.44.22",virtualbox__intnet: true, virtualbox__intnet: "management"
    c2.vm.network :private_network, ip:"192.168.33.22",virtualbox__intnet: true, virtualbox__intnet: "computing"
    c2.vm.network :private_network, ip:"192.168.66.22",virtualbox__intnet: true, virtualbox__intnet: "bmc"

    c2.vm.provision "shell", inline: <<-SHELL
      echo "hola"
    SHELL
  end

  config.vm.provider :virtualbox do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end

end