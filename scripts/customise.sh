#!/bin/bash

set -ue

if [ $# -lt 3 ]; then
  echo "
USAGE:
    customise.sh <CUSTOM_SCRIPT> <SOURCE_IMG_ID/NAME> <DEST_IMG_NAME>

 You may need to quote options
"
  exit 1
fi

CUST_SCRIPT=$1
SOURCE_IMG=$2
DEST_IMG=$3

if [ ! -f $CUST_SCRIPT ]; then
  echo "ERROR: Failed to find script $CUST_SCRIPT"
  exit 1
fi

if [ "$SOURCE_IMG" == "$DEST_IMG" ]; then
  echo "ERROR: Source and dest image name can not be the same ($SOURCE_IMG, $DEST_IMG)"
  exit 1
fi

SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

source $SCRIPT_PATH/../env/shared.env
source $OS_CRED_FILE

set +e
SOURCE_IMG_ID=`openstack image show -f value -c id "$SOURCE_IMG"`
if [ $? -ne 0 ]; then
  echo "
ERROR: Failed to find image $SOURCE_IMG
 - Retry being extra careful when typing password
"
  exit 1
fi
set -e

## Tell user if the image already exists before deleting
set +e
openstack image show "$DEST_IMG"
EXIT=$?
set -e
if [ $EXIT -eq 0 ]; then
  echo -e "!!!!\t I found an existing image named: $DEST_IMG\t!!!!"
  SECS=5
  while [[ 0 -ne $SECS ]]; do
    echo -ne "\tDELETING IN: $SECS..\r"
    sleep 1
    SECS=$[$SECS-1]
  done
  echo -e "\tDELETING IN: $SECS.."
  openstack image delete "$DEST_IMG"
fi

SOURCE_IMG_DESC=`openstack image show -f value -c properties "$SOURCE_IMG_ID" | perl -nle 'm/description=.([^\x27]+)/; print $1;'`
OS_NETWORK_ID=`openstack network show -f value -c id ${OS_NETWORK_NAME}`

export OS_NETWORK_ID=$OS_NETWORK_ID
export BASE_IMAGE_ID=$SOURCE_IMG_ID
export CREATED_IMG_DESC="User customisation of $SOURCE_IMG_DESC"
export CREATED_IMG_NAME=$DEST_IMG
export CUST_SCRIPT=$CUST_SCRIPT

packer validate json/customise.json

packer build -machine-readable \
 json/customise.json \
 < /dev/null
