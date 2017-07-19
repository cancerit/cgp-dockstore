#!/bin/bash

set -uxe

# setup our network config, works for trusty and xenial
sudo mkdir -p /etc/docker
sudo bash -c "echo '{ \"bip\": \"192.168.64.3/18\", \"dns\": [\"8.8.8.8\",\"8.8.4.4\"], \"mtu\": 1380 }' > /etc/docker/daemon.json"
# can check this takes with: docker network inspect bridge

# New docker-ce install method: https://store.docker.com/editions/community/docker-ce-server-ubuntu?tab=description
sudo apt-get -y install apt-transport-https ca-certificates curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -yq update
sudo apt-get -y install docker-ce
sudo usermod -aG docker ubuntu

## JAVA for DOCKSTORE - no jre8 in apt by default
sudo add-apt-repository -y ppa:webupd8team/java
sudo bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
sudo bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections'
sudo apt-get -yq update
sudo apt-get -yq install oracle-java8-installer

# useful tools
sudo apt-get -yq install nano less samtools build-essential

## CWLTOOLS ##
#
sudo apt-get -yq install python-dev python-pip
sudo -H pip install --upgrade pip
sudo -H pip install setuptools==$PIP_SETUPTOOLS_VER
sudo -H pip install cwl-runner cwltool==$PIP_CWLTOOL_VER schema-salad==$PIP_SCHEMA_SALAD_VER avro==$PIP_AVRO_VER
#
## CWLTOOLS ##

# uptodate s3cmd
sudo -H pip install --upgrade s3cmd

## DOCKSTORE ##
#
sudo mkdir /opt/dockstore
sudo chmod ugo+rx /opt/dockstore
sudo bash -c "curl -sSL https://github.com/ga4gh/dockstore/releases/download/$DOCKSTORE_VERSION/dockstore > /opt/dockstore/dockstore"
sudo chmod ugo+rx /opt/dockstore/dockstore
sudo ln -s /opt/dockstore/dockstore /usr/local/bin/dockstore
## add dummy token (only change if you want to develop)
sudo -u ubuntu mkdir -p /home/ubuntu/.dockstore
sudo -u ubuntu bash -c 'echo "token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
server-url: https://dockstore.org:8443

[dockstore-file-s3cmd-plugin]
client = /usr/local/bin/s3cmd
config-file-location = /home/ubuntu/.s3cfg
" > /home/ubuntu/.dockstore/config'
# plugins we want:
sudo -u ubuntu bash -c 'echo "[{
  \"name\": \"dockstore-file-s3cmd-plugin\",
  \"version\": \"0.0.6\"
  }
]
" > /home/ubuntu/.dockstore/plugins.json'
sudo -u ubuntu dockstore
sudo -u ubuntu dockstore plugin download
#
## DOCKSTORE ##
