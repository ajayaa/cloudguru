HOST_MC_IP=192.168.100.1
HOST_MC_USER=r
HOST_MODULES_SOURCE=/home/r/src/cloudguru/modules


# assumes librarian-puppet is already installed
# assumes cloudguru directory is placed directly under home dir
cd ~/cloudguru

mkdir modules
rsync -r $HOST_MC_USER@$HOST_MC_IP:$HOST_MODULES_SOURCE modules
