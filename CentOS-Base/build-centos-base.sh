#!/usr/bin/env bash
vagrant destroy -f
vagrant box update
vagrant up
vagrant package --output centos-base.box
vagrant box add centos-base centos-base.box --force
#vagrant destroy -f