# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.7"
  config.vm.box_check_update = false

  config.vm.provision "file", source: "./provisioning/bootstrap.sh", destination: "/home/vagrant/bootstrap.sh"

  config.vm.define "sms" do |sms|
    sms.vm.hostname = "sms"

    sms.vm.network :private_network, ip:"192.168.44.11", virtualbox__intnet: true, virtualbox__intnet: "management"
    
  end

  config.vm.provider :virtualbox do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

end