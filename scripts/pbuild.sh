#!/bin/bash

set -ue

SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

source $SCRIPT_PATH/../env/${UBUNTU_NAME}/build.env
source $SCRIPT_PATH/../env/shared.env
source $OS_CRED_FILE

# build the names for artifacts
GIT_CID=`git describe --always --dirty`
GIT_CID_CLEAN=`git describe --always`
GEN_DATE=`date "+%Y-%m-%d"`
GIT_IMG_NAME="cgp-wr-ds_${UBUNTU_NAME} ${GEN_DATE} (${GIT_CID})"
CREATED_IMG_DESC="https://gitlab.internal.sanger.ac.uk/CancerIT/cgp-dockstore/tree/$GIT_CID_CLEAN"

# get IDs needed for underlying build
BASE_IMAGE_ID=`openstack image show -f value -c id "$OS_BASE_IMAGE"`
OS_NETWORK_ID=`openstack network show -f value -c id "${OS_NETWORK_NAME}"`

export BASE_IMAGE_ID=$BASE_IMAGE_ID
export CREATED_IMG_NAME=$GIT_IMG_NAME
export CREATED_IMG_DESC=$CREATED_IMG_DESC
export OS_NETWORK_ID=$OS_NETWORK_ID
export DOCKER_BUILD_SCRIPT=$DOCKER_BUILD_SCRIPT

# check that the json validates before moving on
packer validate json/build.json

## if the image exists from an earlier build delete and continue (only going to occur on '-dirty' git repo)
set +e
openstack image show "$GIT_IMG_NAME"
EXIT=$?
set -e
if [ $EXIT -eq 0 ]; then
  echo -e "!!!!\t I found an existing image with the same commit ID (${GIT_CID})\t!!!!"
  SECS=5
  while [[ 0 -ne $SECS ]]; do
    echo -ne "\tDELETING IN: $SECS..\r"
    sleep 1
    SECS=$[$SECS-1]
  done
  echo -e "\tDELETING IN: $SECS.."
  openstack image delete "$GIT_IMG_NAME"
fi

#packer build -debug \
# json/build.json \
# < /dev/null

packer build -machine-readable \
 json/build.json \
 < /dev/null

exit 0
