#!/bin/ash

set -uxe

sudo apk add --no-cache bash

sudo bash -c 'echo "http://liskamm.alpinelinux.uk/v3.7/community" >> /etc/apk/repositories'

sudo apk add --no-cache docker=$DOCKER_VERSION
# setup our network config, works for trusty and xenial
sudo mkdir -p /etc/docker
sudo bash -c "echo '{ \"bip\": \"192.168.64.3/18\", \"dns\": [\"8.8.8.8\",\"8.8.4.4\"], \"mtu\": 1380 }' > /etc/docker/daemon.json"
# can check this takes with: docker network inspect bridge
sudo adduser alpine docker
sudo rc-update add docker boot
sudo service docker start

## JAVA for DOCKSTORE - base has no gui support
sudo apk add --no-cache openjdk8-jre-base

# useful tools and python deps
sudo apk add --no-cache curl nano less g++ python2-dev py2-pip
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

## DOCKSTORE ##
#
sudo mkdir -p /opt/dockstore
sudo chmod ugo+rx /opt/dockstore
sudo bash -c "curl -sSL https://github.com/ga4gh/dockstore/releases/download/$DOCKSTORE_VERSION/dockstore > /opt/dockstore/dockstore"
sudo chmod ugo+rx /opt/dockstore/dockstore
sudo ln -s /opt/dockstore/dockstore /usr/local/bin/dockstore
## add dummy token (only change if you want to develop)
sudo -u alpine mkdir -p /home/alpine/.dockstore
sudo -u alpine bash -c 'echo "token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
server-url: https://dockstore.org:8443

[dockstore-file-s3cmd-plugin]
client = /usr/local/bin/s3cmd
config-file-location = /home/alpine/.s3cfg
" > /home/alpine/.dockstore/config'
# plugins we want:
sudo -u alpine bash -c 'echo "[{
  \"name\": \"dockstore-file-s3cmd-plugin\",
  \"version\": \"0.0.6\"
  }
]
" > /home/alpine/.dockstore/plugins.json'
sudo -u alpine /usr/local/bin/dockstore
sudo -u alpine /usr/local/bin/dockstore plugin download
#
## DOCKSTORE ##
