#!/bin/bash

CGP_DS_VERSION=2.2.0

set -ue

if [ $# -ne 4 ]; then
  echo "Execute as: pbuild.sh <ubuntu|alpine> <NETWORK_NAME> <SECURITY_GROUP> <XXX-openrc-v2.sh>"
  exit 1
fi

OS_NAME=$1
OS_NETWORK_NAME=$2
OS_SECURITY_GRP=$3
OS_CRED_FILE=$4
OS_USER=`echo "$OS_NAME" | tr '[:upper:]' '[:lower:]'`

CLONE_BASE=`dirname $0`
CLONE_BASE=`(cd $CLONE_BASE/.. && pwd)`
SCRIPT_PATH=$CLONE_BASE/scripts
JSON_PATH=$CLONE_BASE/json

# build the names for artifacts
if [ -d $SCRIPT_PATH/../.git ]; then
  GIT_CID=`(cd $SCRIPT_PATH && git describe --always --dirty)`
  GIT_CID_CLEAN=`(cd $SCRIPT_PATH && git describe --always)`
  GIT_REMOTE=`(cd $SCRIPT_PATH && git config --get remote.origin.url)`
else
  GIT_CID=$CGP_DS_VERSION
  GIT_CID_CLEAN=$CGP_DS_VERSION
  GIT_REMOTE="https://github.com/cancerit/cgp-dockstore.git"
fi

GEN_DATE=`date "+%Y-%m-%d"`
GIT_IMG_NAME="cgp-ds_${OS_NAME}_${GEN_DATE}_${GIT_CID}"

# turn the remote into a repo URL pointing to the commit.
CREATED_IMG_DESC=$GIT_REMOTE
if [[ $GIT_REMOTE == git@* ]]; then
  # strip the bit we don't want and replace :
  CREATED_IMG_DESC=`echo $GIT_REMOTE | cut -c 5- | sed -n 's|:|/|p'`
  CREATED_IMG_DESC="https://$CREATED_IMG_DESC"
fi
# now clean up the tail for http and git remotes
CREATED_IMG_DESC=`echo $CREATED_IMG_DESC | sed 's/....$//'`
CREATED_IMG_DESC="$CREATED_IMG_DESC/tree/$GIT_CID_CLEAN"

source $CLONE_BASE/env/${OS_NAME}/build.env
source $CLONE_BASE/env/platform.env
source $CLONE_BASE/env/versions.env
source $OS_CRED_FILE

# get IDs needed for underlying build
BASE_IMAGE_ID=`openstack image show -f value -c id "$OS_BASE_IMAGE"`
OS_NETWORK_ID=`openstack network show -f value -c id "${OS_NETWORK_NAME}"`

export OS_SECURITY_GRP=$OS_SECURITY_GRP
export BASE_IMAGE_ID=$BASE_IMAGE_ID
export CREATED_IMG_NAME=$GIT_IMG_NAME
export CREATED_IMG_DESC=$CREATED_IMG_DESC
export OS_NETWORK_ID=$OS_NETWORK_ID
export OS_NAME=$OS_NAME
export OS_USER=$OS_USER
export CLONE_BASE=$CLONE_BASE

# re-export verion stuff
export DOCKER_VERSION=$DOCKER_VERSION
export DOCKSTORE_VERSION=$DOCKSTORE_VERSION
export DOCKSTORE_S3CMD_VER=$DOCKSTORE_S3CMD_VER
export PIP_SETUPTOOLS_VER=$PIP_SETUPTOOLS_VER
export PIP_CWLTOOL_VER=$PIP_CWLTOOL_VER
export PIP_SCHEMA_SALAD_VER=$PIP_SCHEMA_SALAD_VER
export PIP_AVRO_VER=$PIP_AVRO_VER
export PIP_RUAMEL=$PIP_RUAMEL
export PIP_REQUESTS=$PIP_REQUESTS

# check that the json validates before moving on
packer validate $JSON_PATH/build.json

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

packer build -machine-readable $JSON_PATH/build.json < /dev/null

exit 0
