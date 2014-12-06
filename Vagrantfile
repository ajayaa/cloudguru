VAGRANTFILE_API_VERSION = "2"
VM_ETH1_NETWORK = "192.168.10.0"
VM_ETH2_NETWORK = "192.168.11.0"
BOX = "trusty64"
LOCAL_MIRROR_IP="192.168.11.1"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Common configs
  config.vm.box = BOX
  config.vm.host_name = 'node1'
  config.vm.network "private_network", :type => "dhcp",
      :ip => VM_ETH1_NETWORK, :netmask => "255.255.255.0"
  config.vm.network "private_network", :type => "dhcp",
      :ip => VM_ETH2_NETWORK, :netmask => "255.255.255.0"
  config.vm.synced_folder("modules/", '/etc/puppet/modules/')
  config.vm.synced_folder("files/", '/etc/puppet/files/')
  config.vm.provision :shell,
      :inline => "cp /etc/puppet/files/sources.list.template /etc/apt/sources.list"
  config.vm.provision :shell,
      :inline => "sed -i s/mc_ip/#{LOCAL_MIRROR_IP}/g /etc/apt/sources.list"
  config.vm.provision :shell,
      :inline => "apt-get update --fix-missing -o Acquire::http::No-Cache=True"
  config.vm.provision "puppet" do |puppet|
      puppet.options = "--debug --verbose"
  end
end
