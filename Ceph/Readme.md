# Ceph

![Ceph](http://ceph.com/wp-content/uploads/2016/07/Ceph_Logo_Stacked_RGB_120411_fa.png)

# Topology

Ceph Deploy

| Item | Value |
| :---: | :---: |
| Hostname | ceph-deploy.example.com |
| IP | 192.168.73.40 |

Ceph Node 1

| Item | Value |
| :---: | :---: |
| Hostname | ceph-node-1.example.com |
| IP | 192.168.73.41 |

Ceph Node 2

| Item | Value |
| :---: | :---: |
| Hostname | ceph-node-2.example.com |
| IP | 192.168.73.42 |

Ceph Node 3

| Item | Value |
| :---: | :---: |
| Hostname | ceph-node-3.example.com |
| IP | 192.168.73.43 |

Ceph Client

| Item | Value |
| :---: | :---: |
| Hostname | ceph-client.example.com |
| IP | 192.168.73.44 |

# Vagrant

Launch machine

```bash
vagrant up
vagrant ssh deploy
```

Install Ceph

```bash
su - ceph
mkdir test-cluster
cp /vagrant/ceph.sh .
bash ceph.sh
```

## Client

![stack](http://docs.ceph.com/docs/hammer/_images/stack.png)

### Use as Block Device

Login client

```bash
vagrant ssh client
```

Create rbd

```bash
su - ceph
sudo chmod 644 /etc/ceph/ceph.client.admin.keyring
rbd create disk01 --size 10G --image-feature layering
rbd ls -l
sudo rbd map disk01
rbd showmapped
sudo mkfs.xfs /dev/rbd0
sudo mount /dev/rbd0 /mnt
df -hT
```

### Use as File System

Create MDS ( MetaData Server ) on `ceph-node-1`

```bash
vagrant ssh deploy
su - ceph
ceph-deploy mds create ceph-node-1 
```

Create two RADOS pools

```bash
vagrant ssh ceph-node-1
su - ceph
sudo chmod 644 /etc/ceph/ceph.client.admin.keyring 
ceph osd pool create cephfs_data 128
ceph osd pool create cephfs_metadata 128
ceph fs new cephfs cephfs_metadata cephfs_data
ceph fs ls
ceph mds stat
```

Use CephFS

```bash
vagrant ssh client
su - root
yum -y install ceph-fuse
ssh ceph@ceph-node-1.example.com "sudo ceph-authtool -p /etc/ceph/ceph.client.admin.keyring" > admin.key
chmod 600 admin.key
mount -t ceph ceph-node-1.example.com:6789:/ /mnt -o name=admin,secretfile=admin.key
df -hT
```

# Special Thanks
* [Server World](https://www.server-world.info/en/note?os=CentOS_7&p=ceph&f=1)