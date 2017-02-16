#!/bin/bash

set -ue

SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`



source $SCRIPT_PATH/../env/${UBUNTU_NAME}/build.env
source $SCRIPT_PATH/../env/shared.env
source $OS_CRED_FILE

GIT_CID=`git describe --always --dirty`
GEN_DATE=`date "+%Y-%m-%d"`
GIT_IMG_NAME="cgp-wr-dockstore_${UBUNTU_NAME} ${GEN_DATE} (${GIT_CID})"

BASE_IMAGE_ID=`openstack image show -f value -c id $OS_BASE_IMAGE`

OS_NETWORK_ID=`openstack network show -f value -c id ${OS_NETWORK_NAME}`

export BASE_IMAGE_ID=$BASE_IMAGE_ID
export GIT_IMG_NAME=$GIT_IMG_NAME
export OS_NETWORK_ID=$OS_NETWORK_ID

packer validate json/build.json

packer build -machine-readable \
 json/build.json \
 < /dev/null

exit 0
