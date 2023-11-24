#!/bin/bash
mkdir -p $HOME/.kube &&
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config &&
sudo chown $(id -u):$(id -g) $HOME/.kube/config &&
#kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml &&
kubectl get pod -A
echo "---------------------------Install Master Node successfully-------------------------------------"