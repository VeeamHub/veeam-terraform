#!/usr/bin/env bash

sudo yum update -yum
sudo yum install -y perl perl-Data-Dumper
sudo groupadd repos;
sudo useradd -m -G repos repo01;
sudo echo "repo01:repo01" | sudo chpasswd;
sudo su -c "echo '%repos ALL=(root) NOPASSWD: ALL' >> /etc/sudoers.d/repos;"