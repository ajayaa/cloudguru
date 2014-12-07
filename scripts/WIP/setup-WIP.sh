#! /bin/bash
set -eux

HOST_MC_IP=192.168.100.1

USE_LOCAL_MIRROR=y
LOCAL_MIRROR_IP=$HOST_MC_IP

# Options if you want to download modules from local host machine
USE_LOCAL_MODULES=y
LOCAL_MODULES_IP=$HOST_MC_IP
LOCAL_MODULES_USER=r
LOCAL_MODULES_DIR=/home/r/src/cloudguru/modules

LOCAL_CIRROS_IMG=y
CIRROS_IMG_PATH=/home/r/src/cloudguru/cirros-0.3.2-x86_64-disk.img

INSTALL_CERTS=y
echo $USE_LOCAL_MIRROR
if [ "$USE_LOCAL_MIRROR" == "n" ]; then
    echo "no"
elif [ "$USE_LOCAL_MIRROR" == "y" ]; then
    echo "yes"
else
    echo "error"
fi
