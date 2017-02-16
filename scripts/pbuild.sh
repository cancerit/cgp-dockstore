#!/bin/bash

set -ue

SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

source $SCRIPT_PATH/../env/${UBUNTU_NAME}/build.env
source $SCRIPT_PATH/../env/shared.env
source $OS_CRED_FILE

GIT_CID=`git describe --always --dirty`
GIT_CID_CLEAN=`git describe --always`
GEN_DATE=`date "+%Y-%m-%d"`
GIT_IMG_NAME="cgp-wr-dockstore_${UBUNTU_NAME} ${GEN_DATE} (${GIT_CID})"

## if the image exists delete and continue
set +e
openstack image show "$GIT_IMG_NAME"
set -e
if [ $? -eq 0 ]; then
  openstack image delete "$GIT_IMG_NAME"
fi

BASE_IMAGE_ID=`openstack image show -f value -c id $OS_BASE_IMAGE`
OS_NETWORK_ID=`openstack network show -f value -c id ${OS_NETWORK_NAME}`
CREATED_IMG_DESC="https://gitlab.internal.sanger.ac.uk/kr2/cgp-dockstore/tree/$GIT_CID_CLEAN"

export BASE_IMAGE_ID=$BASE_IMAGE_ID
export CREATED_IMG_NAME=$GIT_IMG_NAME
export CREATED_IMG_DESC=$CREATED_IMG_DESC
export OS_NETWORK_ID=$OS_NETWORK_ID

packer validate json/build.json

packer build -machine-readable \
 json/build.json \
 < /dev/null

exit 0
