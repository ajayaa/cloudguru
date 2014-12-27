sudo sed -i s/identity_uri/#identity_uri/g /etc/glance/glance-api.conf
sudo sed -i s/identity_uri/#identity_uri/g /etc/glance/glance-registry.conf

sudo service glance-api restart
sudo service glance-registry restart
