#!/bin/bash

set -uxe

sudo -H pip install --upgrade pip

## CWLTOOLS ##
#
sudo -H pip install\
    setuptools==$PIP_SETUPTOOLS_VER
sudo -H pip install\
    cwl-runner\
    cwltool==$PIP_CWLTOOL_VER\
    schema-salad==$PIP_SCHEMA_SALAD_VER\
    avro==$PIP_AVRO_VER\
    ruamel.yaml==$PIP_RUAMEL\
    requests==$PIP_REQUESTS
#
## CWLTOOLS ##

sudo -H pip install --upgrade s3cmd
S3CMD=`which s3cmd`

## DOCKSTORE ##
#
sudo mkdir -p /opt/dockstore
sudo chmod ugo+rx /opt/dockstore
sudo bash -c "curl -sSL https://github.com/ga4gh/dockstore/releases/download/$DOCKSTORE_VERSION/dockstore > /opt/dockstore/dockstore"
sudo chmod ugo+rx /opt/dockstore/dockstore
sudo ln -s /opt/dockstore/dockstore /usr/local/bin/dockstore
## add dummy token (only change if you want to develop)
sudo -u $OS_USER mkdir -p /home/$OS_USER/.dockstore

sudo -u $OS_USER bash -c "echo 'token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
server-url: https://dockstore.org:8443

# cache stuff to save looking up:
use-cache = false
#cache-dir =

## enable to speedup - s3 gives md5 after upload, cwltool uses sha1
cwltool-extra-parameters: --no-compute-checksum

[dockstore-file-s3cmd-plugin]
client = $S3CMD
config-file-location = /home/$OS_USER/.s3cfg
' > /home/$OS_USER/.dockstore/config"

# plugins we want:
sudo -u $OS_USER bash -c "echo '[{
  \"name\": \"dockstore-file-s3cmd-plugin\",
  \"version\": \"$DOCKSTORE_S3CMD_VER\"
  }
]
' > /home/$OS_USER/.dockstore/plugins.json"

sudo -u $OS_USER /usr/local/bin/dockstore
sudo -u $OS_USER /usr/local/bin/dockstore plugin download
#
## DOCKSTORE ##
