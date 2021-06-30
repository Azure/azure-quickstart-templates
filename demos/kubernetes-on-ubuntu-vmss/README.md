# Kubernetes cluster with VMSS Cluster Autoscaler using Kubeadm

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/kubernetes-on-ubuntu-vmss/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/kubernetes-on-ubuntu-vmss/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/kubernetes-on-ubuntu-vmss/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/kubernetes-on-ubuntu-vmss/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/kubernetes-on-ubuntu-vmss/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/kubernetes-on-ubuntu-vmss/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fkubernetes-on-ubuntu-vmss%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fkubernetes-on-ubuntu-vmss%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fkubernetes-on-ubuntu-vmss%2Fazuredeploy.json)

This template deploys a vanilla kubernetes cluster initialized using kubeadm. It deploys a configured master node with a [cluster autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/azure). A pre-configured Virtual Machine Scale Set (VMSS) is also deployed and automatically attached to the cluster. The cluster autoscaler can then automatically scale up/down the cluster depending on the workload of the cluster.

# Prerequisites 
A Service Principal is required for this template which gives the master node sufficient permissions to scale the Virtual Machine Scale Set. To create a new Service Principal run:
```
az ad sp create-for-rbac --name ServicePrincipalName
```

Both the Service Principal Client ID and Client Secret need to be passed as parameters.


