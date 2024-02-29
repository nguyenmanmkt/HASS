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
sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "overlay" | sudo tee -a /etc/modules-load.d/k8s.conf
echo "br_netfilter" | sudo tee -a /etc/modules-load.d/k8s.conf

sudo modprobe overlay
sudo modprobe br_netfilter

echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/k8s.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/k8s.conf

sudo sysctl --system


# Update and install Docker
sudo apt update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Add Kubernetes repository and install kubeadm, kubelet, kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
# sudo apt-mark hold kubelet kubeadm kubectl

# Initialize Kubernetes master
sudo kubeadm init --pod-network-cidr=10.10.0.0/16

# Create kubeconfig directory and configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network overlay (Calico in this case)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Print join command for worker nodes
echo "Cluster initialization complete. Save the following command to join worker nodes:"
sudo kubeadm token create --print-join-command
kubectl get nodes

# For Worker Nodes
# sudo ufw allow 10251/tcp
# sudo ufw allow 10255/tcp

# Configure firewall for the cluster
# sudo ufw allow 6443/tcp
# sudo ufw allow 2379:2380/tcp
# sudo ufw allow 10250/tcp
# sudo ufw allow 10251/tcp
# sudo ufw allow 10252/tcp
# sudo ufw allow 10255/tcp
# sudo ufw --force enable