#!/bin/bash

set -uxe

# setup our network config
sudo mkdir -p /etc/docker
sudo bash -c "echo '{ \"bip\": \"192.168.64.3/18\", \"dns\": [\"8.8.8.8\",\"8.8.4.4\"], \"mtu\": 1380 }' > /etc/docker/daemon.json"
sudo bash -c "curl -sSL $DOCKER_BUILD_SCRIPT | sh"
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
sudo -H pip install --upgrade setuptools
sudo -H pip install --upgrade futures
sudo -H pip install --upgrade requests # needed to work directly with cwltool instead of dockstore tool
sudo -H pip install cwl-runner cwltool==1.0.20161114152756 schema-salad==1.18.20161005190847 avro==1.8.1
#
## CWLTOOLS ##

# uptodate s3cmd
sudo -H pip install --upgrade s3cmd

## DOCKSTORE ##
#
sudo mkdir /opt/dockstore
sudo chmod ugo+rx /opt/dockstore
sudo bash -c "curl -sSL https://github.com/ga4gh/dockstore/releases/download/1.1.5/dockstore > /opt/dockstore/dockstore"
sudo chmod ugo+rx /opt/dockstore/dockstore
sudo ln -s /opt/dockstore/dockstore /usr/local/bin/dockstore
## add dummy token (only change if you want to develop)
sudo -u ubuntu mkdir -p /home/ubuntu/.dockstore
sudo -u ubuntu bash -c 'echo "token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
server-url: https://dockstore.org:8443
" > /home/ubuntu/.dockstore/config'
sudo -u ubuntu dockstore
#
## DOCKSTORE ##
