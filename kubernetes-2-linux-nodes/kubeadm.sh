## Kubernetes ADM Installation script
## Author: Mahendra Shinde (MahendraShinde@synergetics-india.com)
## Reference https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl 
# Updating package cache
apt update -y
# Installing Docker CE
apt install -y docker.io
# Setting docker group for current user
usermod -aG docker $USER
# Enable docker.service to start on boot
systemctl enable docker
#Start docker service now!
systemctl start docker
#Install pre-requisites for kubeadm package
apt install -y apt-transport-https curl
#Get Kubernetes package key (apt-key)
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg  > key.temp
apt-key add key.temp
#Add APT Repository for kubernetes
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
#Install kubernetes packages
apt update -y
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
# reload the systemctl daemon and kubelet
systemctl daemon-reload
systemctl restart kubelet 