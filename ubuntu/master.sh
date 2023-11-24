
#!/bin/bash
# Provisioning VM
# Git clone https://github.com/kodekloudhub/certified-kubernetes-administrator-course.git

echo "1. Set forwarding ip table" &&
sudo swapoff -a &&
sudo tee -a /etc/modules-load.d/k8s.conf <<< "overlay" &&
sudo tee -a /etc/modules-load.d/k8s.conf <<< "br_netfilter" &&

sudo modprobe overlay &&
sudo modprobe br_netfilter &&
# sysctl params required by setup, params persist across reboots

sudo tee -a /etc/sysctl.d/k8s.conf <<< "net.bridge.bridge-nf-call-iptables  = 1"
sudo tee -a /etc/sysctl.d/k8s.conf <<< "net.bridge.bridge-nf-call-ip6tables = 1"
sudo tee -a /etc/sysctl.d/k8s.conf <<< "net.ipv4.ip_forward                 = 1"

# Apply sysctl params without reboot
sudo sysctl --system &&
#Verify 
lsmod | grep br_netfilter &&
lsmod | grep overlay &&
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward &&

echo "------------------------2. Install containerd------------------------------" &&
sudo apt-get update &&
sudo apt-get install -y ca-certificates curl gnupg &&

# Add Docker’s official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
sudo chmod a+r /etc/apt/keyrings/docker.gpg &&

#set up the repository
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
#install
sudo apt-get update &&
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&
#sudo apt-get install -y containerd.io &&

sudo usermod -aG docker $USER &&
newgrp docker &&


# Configuring the systemd cgroup driver
sudo rm /etc/containerd/config.toml &&
sudo tee -a /etc/containerd/config.toml <<< "[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]" &&
sudo tee -a /etc/containerd/config.toml <<< " [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]" &&
sudo tee -a /etc/containerd/config.toml <<< "  systemdCgroup = true" &&

sudo systemctl restart containerd &&
sudo systemctl status containerd &&
echo "----------------------------Installing kubeadm, kubelet and kubectl---------------------------" &&
# 4. Installing kubeadm, kubelet and kubectl 
#sudo apt-get update 
sudo apt-get install -y apt-transport-https ca-certificates curl &&
sudo curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg &&
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list &&
sudo apt-get update &&
sudo apt-get install -y kubelet kubeadm kubectl &&
sudo apt-mark hold kubelet kubeadm kubectl &&
# Create cluster
echo "---------------------------initial cluster-------------------------------------" &&
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.100.2 &&
mkdir -p $HOME/.kube &&
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config &&
sudo chown $(id -u):$(id -g) $HOME/.kube/config &&
#kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml &&
kubectl get pod -A
echo "---------------------------Install Master Node successfully-------------------------------------"