#!/bin/sh
export no_proxy="127.0.0.1,localhost,192.168.50.10,192.168.50.11"
export HTTP_PROXY="http://10.0.2.3:3128"
export HTTPS_PROXY="http://10.0.2.3:3128"
export http_proxy="http://10.0.2.3:3128"
export https_proxy="http://10.0.2.3:3128"
yum install nfs-utils -y
systemctl enable firewalld --now
systemctl daemon-reload 
systemctl restart remote-fs.target
sudo mount -o proto=udp,vers=3 192.168.50.10:/srv/share/ /mnt/
