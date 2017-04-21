#!/bin/bash

set -ue

if [ $# -ne 4 ]; then
  echo "Execute as: pbuild.sh <trusty|xenial> <NETWORK_NAME> <SECURITY_GROUP> <XXX-openrc.sh>"
  exit 1
fi

UBUNTU_NAME=$1
OS_NETWORK_NAME=$2
OS_SECURITY_GRP=$3
OS_CRED_FILE=$4

SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

source $SCRIPT_PATH/../env/${UBUNTU_NAME}/build.env
source $SCRIPT_PATH/../env/platform.env
source $SCRIPT_PATH/../env/versions.env
source $OS_CRED_FILE

# build the names for artifacts
GIT_CID=`git describe --always --dirty`
GIT_CID_CLEAN=`git describe --always`
GEN_DATE=`date "+%Y-%m-%d"`
GIT_IMG_NAME="cgp-ds_${UBUNTU_NAME}_${GEN_DATE}_${GIT_CID}"

# turn the remote into a repo URL pointing to the commit.
GIT_REMOTE=`git config --get remote.origin.url`
CREATED_IMG_DESC=$GIT_REMOTE
if [[ $GIT_REMOTE == git@* ]]; then
  # strip the bit we don't want and replace :
  CREATED_IMG_DESC=`echo $GIT_REMOTE | cut -c 5- | sed -n 's|:|/|p'`
  CREATED_IMG_DESC="https://$CREATED_IMG_DESC"
fi
# now clean up the tail for http and git remotes
CREATED_IMG_DESC=`echo $CREATED_IMG_DESC | sed 's/....$//'`
CREATED_IMG_DESC="$CREATED_IMG_DESC/tree/$GIT_CID_CLEAN"

# get IDs needed for underlying build
BASE_IMAGE_ID=`openstack image show -f value -c id "$OS_BASE_IMAGE"`
OS_NETWORK_ID=`openstack network show -f value -c id "${OS_NETWORK_NAME}"`

export OS_SECURITY_GRP=$OS_SECURITY_GRP
export BASE_IMAGE_ID=$BASE_IMAGE_ID
export CREATED_IMG_NAME=$GIT_IMG_NAME
export CREATED_IMG_DESC=$CREATED_IMG_DESC
export OS_NETWORK_ID=$OS_NETWORK_ID
export UBUNTU_NAME=$UBUNTU_NAME

# re-export verion stuff
export DOCKSTORE_VERSION=$DOCKSTORE_VERSION
export PIP_SETUPTOOLS_VER=$PIP_SETUPTOOLS_VER
export PIP_CWLTOOL_VER=$PIP_CWLTOOL_VER
export PIP_SCHEMA_SALAD_VER=$PIP_SCHEMA_SALAD_VER
export PIP_AVRO_VER=$PIP_AVRO_VER

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

packer build -machine-readable \
 json/build.json \
 < /dev/null

exit 0
