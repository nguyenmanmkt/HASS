#!/bin/bash

sudo hostnamectl set-hostname master-node1

echo "192.168.200.230 master-node1 master1" | sudo tee -a /etc/hosts
echo "192.168.200.231 master-node2 master2" | sudo tee -a /etc/hosts
echo "192.168.200.232 master-node3 master3" | sudo tee -a /etc/hosts
echo "192.168.200.235 worker-node1 worker1" | sudo tee -a /etc/hosts
echo "192.168.200.236 worker-node2 worker2" | sudo tee -a /etc/hosts
echo "192.168.200.237 worker-node3 worker2" | sudo tee -a /etc/hosts

