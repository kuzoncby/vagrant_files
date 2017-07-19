# Ceph

![Ceph](http://ceph.com/wp-content/uploads/2016/07/Ceph_Logo_Stacked_RGB_120411_fa.png)

# Environment

Ceph Deploy

| Name | Value |
| :---: | :---: |
| hostname | ceph-deploy.example.com |
| IP | 192.168.33.40 |

Ceph Node 1

| Name | Value |
| :---: | :---: |
| hostname | ceph-node-1.example.com |
| IP | 192.168.33.41 |

Ceph Node 2

| Name | Value |
| :---: | :---: |
| hostname | ceph-node-2.example.com |
| IP | 192.168.33.42 |

Ceph Node 3

| Name | Value |
| :---: | :---: |
| hostname | ceph-node-3.example.com |
| IP | 192.168.33.43 |

Ceph Client

| Name | Value |
| :---: | :---: |
| hostname | ceph-client.example.com |
| IP | 192.168.33.44 |

# Vagrant

Start machines 

```bash
vagrant up
vagrant ssh deploy
```

Install Ceph

```bash
su - ceph
mkdir test-cluster
cp /vagrant/ceph.sh .
chmod +x ceph.sh
./ceph.sh
```

## Client

### Use as Block Device

SSH into client

```bash
vagrant ssh client
```

Create disk

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

### RADOS

Create MDS ( MetaData Server )

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

Use file system

```bash
vagrant ssh client
su - root
yum -y install ceph-fuse
ssh ceph@ceph-node-1.example.com "sudo ceph-authtool -p /etc/ceph/ceph.client.admin.keyring" > admin.key
chmod 600 admin.key
mount -t ceph ceph-node-1.example.com:6789:/ /mnt -o name=admin,secretfile=admin.key
df -hT
```

# Special thanks to
* [Server World](https://www.server-world.info/en/note?os=CentOS_7&p=ceph&f=1)