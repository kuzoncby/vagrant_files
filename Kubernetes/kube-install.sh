#!/usr/bin/env bash
# Install docker etcd flannel kubernetes and cockpit
sudo yum install docker -y
sudo systemctl start docker
sudo yum install kubernetes etcd flannel cockpit-* -y

# Disable selinux and Firewalld when installation
sudo setenforce 0
sudo systemctl disable firewalld
sudo systemctl stop firewalld

# Config kubernetes API server
#  __               __                                         __                 ___    ___                   
# /\ \             /\ \                                       /\ \__             /\_ \  /\_ \                  
# \ \ \/'\   __  __\ \ \____     __         ___    ___     ___\ \ ,_\  _ __   ___\//\ \ \//\ \      __   _ __  
#  \ \ , <  /\ \/\ \\ \ '__`\  /'__`\      /'___\ / __`\ /' _ `\ \ \/ /\`'__\/ __`\\ \ \  \ \ \   /'__`\/\`'__\
#   \ \ \\`\\ \ \_\ \\ \ \L\ \/\  __/     /\ \__//\ \L\ \/\ \/\ \ \ \_\ \ \//\ \L\ \\_\ \_ \_\ \_/\  __/\ \ \/ 
#    \ \_\ \_\ \____/ \ \_,__/\ \____\    \ \____\ \____/\ \_\ \_\ \__\\ \_\\ \____//\____\/\____\ \____\\ \_\ 
#     \/_/\/_/\/___/   \/___/  \/____/     \/____/\/___/  \/_/\/_/\/__/ \/_/ \/___/ \/____/\/____/\/____/ \/_/ 
#                                                                                                              
cat > kube-api.conf <<EOF
# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR="--logtostderr=true"

# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=0"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow-privileged=false"

# How the replication controller and scheduler find the kube-apiserver
# Use your own api-server url
KUBE_MASTER="--master=http://kube-master.example.com:8080"
EOF

sudo mv kube-api.conf /etc/kubernetes/config

# Config etcd cluster
#       __              __
#      /\ \__          /\ \
#    __\ \ ,_\   ___   \_\ \
#  /'__`\ \ \/  /'___\ /'_` \
# /\  __/\ \ \_/\ \__//\ \L\ \
# \ \____\\ \__\ \____\ \___,_\
#  \/____/ \/__/\/____/\/__,_ /
#
sudo sed -i 's/localhost/0.0.0.0/g' /etc/etcd/etcd.conf

# Config API Server
#  __  __           __                  ______  ____    ______      ____
# /\ \/\ \         /\ \                /\  _  \/\  _`\ /\__  _\    /\  _`\
# \ \ \/'/'  __  __\ \ \____     __    \ \ \L\ \ \ \L\ \/_/\ \/    \ \,\L\_\     __   _ __   __  __     __   _ __
#  \ \ , <  /\ \/\ \\ \ '__`\  /'__`\   \ \  __ \ \ ,__/  \ \ \     \/_\__ \   /'__`\/\`'__\/\ \/\ \  /'__`\/\`'__\
#   \ \ \\`\\ \ \_\ \\ \ \L\ \/\  __/    \ \ \/\ \ \ \/    \_\ \__    /\ \L\ \/\  __/\ \ \/ \ \ \_/ |/\  __/\ \ \/
#    \ \_\ \_\ \____/ \ \_,__/\ \____\    \ \_\ \_\ \_\    /\_____\   \ `\____\ \____\\ \_\  \ \___/ \ \____\\ \_\
#     \/_/\/_/\/___/   \/___/  \/____/     \/_/\/_/\/_/    \/_____/    \/_____/\/____/ \/_/   \/__/   \/____/ \/_/
#
cat > apiserver <<EOF
# The address on the local server to listen to.
KUBE_API_ADDRESS="--address=0.0.0.0"

# The port on the local server to listen on.
KUBE_API_PORT="--port=8080"

# Port kubelets listen on
KUBELET_PORT="--kubelet-port=10250"

# Comma separated list of nodes in the etcd cluster
# Use your own etcd server url
KUBE_ETCD_SERVERS="--etcd-servers=http://kube-master.example.com:2379"

# Address range to use for services
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"

# Add your own!
KUBE_API_ARGS=""
EOF

sudo mv apiserver /etc/kubernetes/apiserver

# Config flannel
#    ___  ___                                    ___       __
#  /'___\/\_ \                                  /\_ \     /\ \
# /\ \__/\//\ \      __      ___     ___      __\//\ \    \_\ \
# \ \ ,__\ \ \ \   /'__`\  /' _ `\ /' _ `\  /'__`\\ \ \   /'_` \
#  \ \ \_/  \_\ \_/\ \L\.\_/\ \/\ \/\ \/\ \/\  __/ \_\ \_/\ \L\ \
#   \ \_\   /\____\ \__/.\_\ \_\ \_\ \_\ \_\ \____\/\____\ \___,_\
#    \/_/   \/____/\/__/\/_/\/_/\/_/\/_/\/_/\/____/\/____/\/__,_ /
#

# Create a subnet
sudo systemctl start etcd
sudo etcdctl mkdir /kube-centos/network
sudo etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"

cat > flanneld <<EOF
# Flanneld configuration options

# etcd url location.  Point this to the server where etcd runs
# Use your own etcd server url
FLANNEL_ETCD_ENDPOINTS="http://kube-master.example.com:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/kube-centos/network"

# Any additional options that you want to pass
#FLANNEL_OPTIONS=""
EOF

sudo mv flanneld /etc/sysconfig/flanneld

#  __               __              ___           __
# /\ \             /\ \            /\_ \         /\ \__
# \ \ \/'\   __  __\ \ \____     __\//\ \      __\ \ ,_\
#  \ \ , <  /\ \/\ \\ \ '__`\  /'__`\\ \ \   /'__`\ \ \/
#   \ \ \\`\\ \ \_\ \\ \ \L\ \/\  __/ \_\ \_/\  __/\ \ \_
#    \ \_\ \_\ \____/ \ \_,__/\ \____\/\____\ \____\\ \__\
#     \/_/\/_/\/___/   \/___/  \/____/\/____/\/____/ \/__/
#
cat > kubelet <<EOF
# The address for the info server to serve on
KUBELET_ADDRESS="--address=0.0.0.0"

# The port for the info server to serve on
KUBELET_PORT="--port=10250"

# You may leave this blank to use the actual hostname
# Check the node number!
KUBELET_HOSTNAME="--hostname-override=kube-node"

# Location of the api-server
# Use your own api-server url
KUBELET_API_SERVER="--api-servers=http://kube-master.example.com:8080"

# Add your own!
KUBELET_ARGS=""
EOF

sudo mv kubelet /etc/kubernetes/kubelet

sudo sed -i "s/kube-node/$(hostname)/g" /etc/kubernetes/kubelet

sudo sed -i 's/registry.access.redhat.com/2535e21f.m.daocloud.io/g' /etc/sysconfig/docker
sudo sed -i 's/#ADD_REGISTRY/ADD_REGISTRY/g' /etc/sysconfig/docker

sudo sed -i 's/# INSECURE_REGISTRY/INSECURE_REGISTRY/g' /etc/sysconfig/docker
sudo sed -i 's/--insecure-registry/--insecure-registry registry.example.com/g' /etc/sysconfig/docker

sudo sed -i 's/# BLOCK_REGISTRY/BLOCK_REGISTRY/g' /etc/sysconfig/docker
sudo sed -i 's/--block-registry/--block-registry public/g' /etc/sysconfig/docker

# Start service at master or node
if [[ $(hostname) == *"master"* ]]; then
	for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld; do
		sudo systemctl restart ${SERVICES}
		sudo systemctl enable ${SERVICES}
		sudo systemctl status ${SERVICES}
	done
else
	for SERVICES in kube-proxy kubelet flanneld docker; do
		sudo systemctl restart ${SERVICES}
		sudo systemctl enable ${SERVICES}
		sudo systemctl status ${SERVICES}
	done
fi
