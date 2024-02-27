#!/bin/bash

# Configure hostname and /etc/hosts
sudo hostnamectl set-hostname master-node1
echo "192.168.200.230 master-node1 master1" | sudo tee -a /etc/hosts
echo "192.168.200.231 master-node2 master2" | sudo tee -a /etc/hosts
echo "192.168.200.232 master-node3 master3" | sudo tee -a /etc/hosts
echo "192.168.200.235 worker-node1 worker1" | sudo tee -a /etc/hosts
echo "192.168.200.236 worker-node2 worker2" | sudo tee -a /etc/hosts
echo "192.168.200.237 worker-node3 worker2" | sudo tee -a /etc/hosts

# Install dependencies
sudo apt update
sudo apt install -y nano
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt install docker.io -y

sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml



# Check Docker status
sudo systemctl status docker

# Add Kubernetes repository
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Add Kubernetes GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/kubernetes-archive-keyring.gpg add -
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt-get update

# Install Kubernetes components
sudo apt update
sudo apt install -y kubelet kubectl kubeadm
# Auto update
sudo apt-mark hold kubeadm kubelet kubectl
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Initialize Kubernetes cluster
sudo kubeadm init --pod-network-cidr=10.10.0.0/16

# Enable kubelet service
# sudo systemctl enable kubelet
# sudo systemctl start kubelet
# sudo systemctl status kubelet

# Create kubeconfig directory cluser
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico network plugin - cluster
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml


# Check cluster status
sudo kubectl get nodes
sudo kubectl get pods --all-namespaces

# Configure firewall cluster
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10251/tcp
sudo ufw allow 10252/tcp
sudo ufw allow 10255/tcp
sudo ufw --force enable

# For Worker Nodes
# sudo ufw allow 10251/tcp
# sudo ufw allow 10255/tcp

# Print join command for worker nodes master
sudo kubeadm token create --print-join-command

# Join on worker
# kubeadm join 172.24.200.201:6443 --token jnb80l.jjp6td8jfaof0pct --discovery-token-ca-cert-hash sha256:20882a6b3ea7f38b3122e705452c8566cada55077ccf35e0770a993eb745f6c3
