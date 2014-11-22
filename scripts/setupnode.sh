# assumes librarian-puppet is already installed
# assumes cloudguru directory is placed directly under home dir
cd ~/cloudguru
librarian-puppet install

# setup FQDN
HOSTNAME=$(hostname)
echo "127.0.1.1 $HOSTNAME.example.com $HOSTNAME" | sudo tee --append /etc/hosts
