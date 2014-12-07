VAGRANTFILE_API_VERSION = "2"
VM_ETH1_NETWORK = "192.168.100.0"
VM_ETH2_NETWORK = "192.168.110.0"
BOX = "trusty64"
USE_LOCAL_MIRROR=true
# NOTE: currently, local mirror is supposed to be running at
# http://10.0.2.2/ubuntu
LOCAL_MIRROR_IP="192.168.1.139"

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

  config.vm.synced_folder("modules/", '/home/vagrant/cloudguru/modules')
  config.vm.synced_folder("files/", '/home/vagrant/cloudguru/files')
  config.vm.synced_folder("scripts/", '/home/vagrant/cloudguru/scripts')
  config.vm.synced_folder("manifests/", '/home/vagrant/cloudguru/manifests')

#  if USE_LOCAL_MIRROR
#      #TODO(rushiagr): if no local mirror IP is specified, use 10.0.2.2
#     config.vm.provision :shell, :inline =>
#         "cp /etc/puppet/files/sources.list.template /etc/apt/sources.list"
#     config.vm.provision :shell,
#         :inline => "sed -i s/mc_ip/#{LOCAL_MIRROR_IP}/g /etc/apt/sources.list"
#  end
#
#  config.vm.provision :shell,
#      :inline => "apt-get update --fix-missing -o Acquire::http::No-Cache=True"
# NOTE: somehow, vagrant's not taking these vars from here, when we're running
# puppet again
#  config.vm.provision "puppet" do |puppet|
#      puppet.options = "--debug --verbose"
#  end

  config.vm.define :controller  do |cfg|
      cfg.vm.hostname = "node1.example.com"
#      cfg.vm.provision "puppet" do |puppet|
#        puppet.options = "--debug --verbose"
#        puppet.facter = {
#            "fqdn" => "node1.example.com",
#            "hack=hack LANG=en_US.UTF-8 hack" => "hack", #ugly hack
#        }
#        puppet.manifest_file = "controller.pp"
#      end
  end
#  config.vm.define :compute do |cfg|
#      cfg.vm.provider :virtualbox do |vb|
#          vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
#      end
#      cfg.vm.host_name = "node2"
#  end
end
