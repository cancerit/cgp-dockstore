#!/bin/bash

set -uxe

# setup our network config, works for trusty and xenial
sudo mkdir -p /etc/docker
sudo bash -c "echo '{ \"bip\": \"192.168.64.3/18\", \"dns\": [\"8.8.8.8\",\"8.8.4.4\"], \"mtu\": 1380 }' > /etc/docker/daemon.json"
# can check this takes with: docker network inspect bridge

# New docker-ce install method: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
sudo apt-get -y install --no-install-recommends apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -yq update
sudo apt-get -y install docker-ce=$DOCKER_VERSION
sudo usermod -aG docker ubuntu

## JAVA for DOCKSTORE - no jre8 in apt by default
sudo add-apt-repository -y ppa:openjdk-r/ppa
#sudo bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
#sudo bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections'
sudo apt-get -yq update
sudo apt-get -yq install --no-install-recommends openjdk-8-jre-headless

# useful tools and python deps
sudo apt-get -yq install --no-install-recommends nano less python-dev python-pip
