# Ceph

![Ceph](http://ceph.com/wp-content/uploads/2016/07/Ceph_Logo_Stacked_RGB_120411_fa.png)

# 机器

Ceph Deploy

| 名称 | 值 |
| :---: | :---: |
| 机器名 | ceph-deploy.example.com |
| IP | 192.168.33.40 |

Ceph Node 1

| 名称 | 值 |
| :---: | :---: |
| 机器名 | ceph-node-1.example.com |
| IP | 192.168.33.41 |

Ceph Node 2

| 名称 | 值 |
| :---: | :---: |
| 机器名 | ceph-node-2.example.com |
| IP | 192.168.33.42 |

Ceph Node 3

| 名称 | 值 |
| :---: | :---: |
| 机器名 | ceph-node-3.example.com |
| IP | 192.168.33.43 |

Ceph Client

| 名称 | 值 |
| :---: | :---: |
| 机器名 | ceph-client.example.com |
| IP | 192.168.33.44 |

# 概念验证环境

启动机器

```bash
vagrant up
vagrant ssh deploy
```

安装 Ceph

```bash
su - ceph
mkdir test-cluster
cp /vagrant/ceph.sh .
chmod +x ceph.sh
./ceph.sh
```

## 客户机验证

### 作为块存储使用

进入机器

```bash
vagrant ssh client
```

创建磁盘

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

### 作为文件系统使用

创建 MDS ( MetaData Server )

```bash
vagrant ssh deploy
su - ceph
ceph-deploy mds create ceph-node-1 
```

创建两个 RADOS 池

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

使用文件系统

```bash
vagrant ssh client
su - root
yum -y install ceph-fuse
ssh ceph@ceph-node-1.example.com "sudo ceph-authtool -p /etc/ceph/ceph.client.admin.keyring" > admin.key
chmod 600 admin.key
mount -t ceph ceph-node-1.example.com:6789:/ /mnt -o name=admin,secretfile=admin.key
df -hT
```

# 鸣谢

* [Server World](https://www.server-world.info/en/note?os=CentOS_7&p=ceph&f=1)