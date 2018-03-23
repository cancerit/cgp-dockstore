#!/bin/ash

set -uxe

sudo apk add --no-cache bash

sudo bash -c 'echo "http://liskamm.alpinelinux.uk/v3.7/community" >> /etc/apk/repositories'

sudo apk add --no-cache docker
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
