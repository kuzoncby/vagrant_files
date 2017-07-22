#!/usr/bin/env bash
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
for host in ceph-deploy ceph-node-1 ceph-node-2 ceph-node-3 ceph-client;
do
    sshpass -p ceph ssh-copy-id ceph@${host}
done
cp /vagrant/ssh-config ~/.ssh/config
chmod 0600 ~/.ssh/config
sudo yum install ceph-deploy -y
ceph-deploy new ceph-node-1
echo "osd pool default size = 2" >> ./ceph.conf
echo "mon_clock_drift_allowed = 1" >> ./ceph.conf
echo "osd max object name len = 256" >> ./ceph.conf
echo "osd max object namespace len = 64" >> ./ceph.conf
ceph-deploy install --repo-url https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-luminous/el7/ ceph-deploy ceph-node-1 ceph-node-2 ceph-node-3 ceph-client
ceph-deploy mon create-initial
ceph-deploy osd prepare ceph-node-1:/var/local/osd ceph-node-2:/var/local/osd ceph-node-3:/var/local/osd
ceph-deploy osd activate ceph-node-1:/var/local/osd ceph-node-2:/var/local/osd ceph-node-3:/var/local/osd
ceph-deploy admin ceph-deploy ceph-node-1 ceph-node-2 ceph-node-3 ceph-client
sudo chmod 644 /etc/ceph/ceph.client.admin.keyring
ceph health
