#!/bin/sh
export no_proxy="127.0.0.1,localhost,192.168.50.10,192.168.50.11"
export HTTP_PROXY="http://10.0.2.3:3128"
export HTTPS_PROXY="http://10.0.2.3:3128"
export http_proxy="http://10.0.2.3:3128"
export https_proxy="http://10.0.2.3:3128"
yum install nfs-utils -y
systemctl enable firewalld --now
firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent
firewall-cmd --reload
systemctl enable nfs --now
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
cat << EOF > /etc/exports 
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
exportfs -r
exportfs -s
