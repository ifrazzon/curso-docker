#!/bin/sh
#
# curl -sSL https://raw.githubusercontent.com/marcelbirkner/docker-ci-tool-stack/master/setup.sh | bash -s

echo "Checkout Git Repository"
git clone https://github.com/ifrazzon/curso-docker.git
cd curso-docker

echo "Intall Programs"
bash postinstall.sh

echo "Start vagrant"

vagrant up 
