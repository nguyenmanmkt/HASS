#!/bin/bash

# Stop and disable Docker service
sudo systemctl stop docker
sudo systemctl disable docker
sudo yum remove -y docker-ce docker-ce-cli containerd.io

# Reset Kubernetes
sudo kubeadm reset --force
sudo rm -rf /etc/kubernetes

# Remove kubectl
sudo yum remove -y kubectl

# Remove kubelet and kubeadm
sudo yum remove -y kubelet kubeadm

# Remove the kubelet directories
sudo rm -rf /var/lib/kubelet /var/lib/etcd /etc/cni /var/run/kubernetes /var/lib/cni

echo "Docker and Kubernetes have been uninstalled."
