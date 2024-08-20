#!/bin/bash 
# 시스템 업데이트 및 필요한 패키지 설치
echo "Updating system and installing necessary packages"
sudo apt-get update && apt-get upgrade -y
sudo apt-get install -y unzip curl wget jq

echo "Installing AWS CLI"
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

echo "Installing kubectl"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "Installing aws-iam-authenticator"
sudo curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64
sudo chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin/

echo "Configuring AWS CLI"
mkdir -p /home/ubuntu/.aws
echo "[default]" > /home/ubuntu/.aws/config
echo "region = ${region}" >> /home/ubuntu/.aws/config

sleep 10

echo "Configuring kubeconfig"
aws eks get-token --cluster-name ${cluster_name} --region ${region}
aws eks update-kubeconfig --name ${cluster_name} --region ${region}


echo "Setting permissions"
chown -R ubuntu:ubuntu /home/ubuntu/.kube /home/ubuntu/.aws

echo "Setting environment variables"
echo "export KUBECONFIG=/home/ubuntu/.kube/config" >> /home/ubuntu/.bashrc
echo "source <(kubectl completion bash)" >> /home/ubuntu/.bashrc

echo "Testing kubectl"
kubectl version --client
kubectl get nodes || echo "Failed to get nodes"

echo "User data script execution completed"