# RDO OpenStack PackStack Ocata
![RDO OpenStack PackStack Ocata](https://hguemar.fedorapeople.org/slides/rdo-packaging-kilo/img/RDO-logo.jpg)

# Pre-requirement

Modify those part in `answer.txt` to your environment.

* `CONFIG_NTP_SERVERS` 

# Install

Login your controller machine and run `answer.txt`.

```bash
vagrant ssh master
su - root
```

root password is `redhat`

```bash
packstack --answer-file=/home/vagrant/answer.txt
```