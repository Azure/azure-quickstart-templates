#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $(basename $0) cluster_name cluster_endpoint user_home_dir"
    exit -1
fi

while [[ $(/bin/curl -s -L http://127.0.0.1:8080/healthz) != ok ]]
do
  echo Waiting for cluster readiness
  sleep 5
 done

/bin/openssl genrsa -out ./admin-key.pem 2048
/bin/openssl req -new -key ./admin-key.pem -out ./admin.csr -subj "/CN=kube-admin"
/bin/openssl x509 -req -in ./admin.csr -CA /etc/kubernetes/certs/ca.pem -CAkey /etc/kubernetes/certs/ca-key.pem -CAcreateserial -out ./admin.pem -days 365

/opt/kubernetes/bin/kubectl config set-cluster $1 --server=https://$2 --certificate-authority=/etc/kubernetes/certs/ca.pem --embed-certs --kubeconfig=/home/$3/$1-kubeconfig.yaml
/opt/kubernetes/bin/kubectl config set-credentials $1-admin --certificate-authority=/etc/kubernetes/certs/ca.pem --client-key=./admin-key.pem --client-certificate=./admin.pem --embed-certs --kubeconfig=/home/$3/$1-kubeconfig.yaml
/opt/kubernetes/bin/kubectl config set-context $1-context --cluster=$1  --user=$1-admin --kubeconfig=/home/$3/$1-kubeconfig.yaml
/opt/kubernetes/bin/kubectl config use-context $1-context --kubeconfig=/home/$3/$1-kubeconfig.yaml
/bin/chown $3:$3 /home/$3/$1-kubeconfig.yaml