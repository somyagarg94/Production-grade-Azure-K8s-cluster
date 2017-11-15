#!/bin/bash


echo "Upgrade and install build-essential and other necessary packages."
sudo apt-get update -y
sudo apt-get install -y build-essential git wget
#sudo apt-get install -qq python2.7 && ln -s /usr/bin/python2.7 /usr/bin/python