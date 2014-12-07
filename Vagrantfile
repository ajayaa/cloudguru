VAGRANTFILE_API_VERSION = "2"
VM_ETH1_NETWORK = "192.168.100.0"
VM_ETH2_NETWORK = "192.168.110.0"
BOX = "trusty64"
USE_LOCAL_MIRROR=true
# NOTE: currently, local mirror is supposed to be running at
# http://10.0.2.2/ubuntu
# LOCAL_MIRROR_IP="http://10.0.2.2/ubuntu"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Common configs
  config.vm.box = BOX
  config.vm.provider "virtualbox" do |vbox|
      vbox.memory = 2048
      vbox.cpus = 1
  end

  config.vm.network "private_network", :type => "dhcp",
      :ip => VM_ETH1_NETWORK, :netmask => "255.255.255.0"
  config.vm.network "private_network", :type => "dhcp",
      :ip => VM_ETH2_NETWORK, :netmask => "255.255.255.0"

  config.vm.synced_folder("modules/", '/etc/puppet/modules/')
  config.vm.synced_folder("files/", '/etc/puppet/files/')

  if USE_LOCAL_MIRROR
    config.vm.provision :shell, :inline =>
        "cp /etc/puppet/files/sources.list.vagrant.eth0 /etc/apt/sources.list"
  end

#  config.vm.provision :shell,
#      :inline => "sed -i s/mc_ip/#{LOCAL_MIRROR_IP}/g /etc/apt/sources.list"
  config.vm.provision :shell,
      :inline => "apt-get update --fix-missing -o Acquire::http::No-Cache=True"
#  config.vm.provision "puppet" do |puppet|
#      puppet.options = "--debug --verbose"
#  end

  config.vm.define :controller  do |cfg|
      cfg.vm.host_name = "node1"
  end
  config.vm.define :compute do |cfg|
      cfg.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
      end
      cfg.vm.host_name = "node2"
  end
end
