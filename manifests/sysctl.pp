#blah
sysctl::value { 'net.ipv4.conf.all.rp_filter': value => 0 }
sysctl::value { 'net.ipv4.conf.default.rp_filter': value => 0 }
sysctl::value { "net.ipv4.conf.eth0.rp_filter": value => 0 }
sysctl::value { 'net.ipv4.conf.eth1.rp_filter': value => 0 }
sysctl::value { 'net.ipv4.conf.eth2.rp_filter': value => 0 }
sysctl::value { 'net.ipv4.conf.lo.rp_filter': value => 0 }

sysctl::value { 'net.ipv4.ip_forward': value => 1 }
