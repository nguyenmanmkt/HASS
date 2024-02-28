#!/bin/bash

# Stop and disable Docker service
sudo systemctl stop docker
sudo systemctl disable docker
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
sudo apt-get autoremove -y
sudo rm -rf /var/lib/docker

# Reset Kubernetes
sudo kubeadm reset --force
sudo rm -rf /etc/kubernetes

# Remove kubectl
sudo apt-get purge -y kubectl
sudo apt-get autoremove -y

# Remove kubelet and kubeadm
sudo apt-get purge -y kubelet kubeadm
sudo apt-get autoremove -y

# Remove the kubelet directories
sudo rm -rf /var/lib/kubelet /var/lib/etcd /etc/cni /var/run/kubernetes /var/lib/cni

echo "Docker and Kubernetes have been uninstalled."
