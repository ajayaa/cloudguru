VM_ETH1_NETWORK = "192.168.100.0"
VM_ETH2_NETWORK = "192.168.110.0"
BOX = "trusty64"

Vagrant.configure("2") do |config|
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

  config.vm.synced_folder("modules/", '/etc/puppet/modules')
  config.vm.synced_folder("files/", '/home/vagrant/cloudguru/files')
  config.vm.synced_folder("scripts/", '/home/vagrant/cloudguru/scripts')
  config.vm.synced_folder("manifests/", '/home/vagrant/cloudguru/manifests')

  config.vm.define :controller  do |cfg|
      cfg.vm.hostname = "node1.example.com"
  end
end
