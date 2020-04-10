# Kubernetes cluster with VMSS Cluster Autoscaler using Kubeadm

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/kubernetes-on-ubuntu-vmss/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/kubernetes-on-ubuntu-vmss/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/kubernetes-on-ubuntu-vmss/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/kubernetes-on-ubuntu-vmss/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/kubernetes-on-ubuntu-vmss/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/kubernetes-on-ubuntu-vmss/CredScanResult.svg" />&nbsp;


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkubernetes-on-ubuntu-vmss%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkubernetes-on-ubuntu-vmss%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>


This template deploys a vanilla kubernetes cluster initialized using kubeadm. It deploys a configured master node with a [cluster autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/azure). A pre-configured Virtual Machine Scale Set (VMSS) is also deployed and automatically attached to the cluster. The cluster autoscaler can then automatically scale up/down the cluster depending on the workload of the cluster.

# Prerequisites 
A Service Principal is required for this template which gives the master node sufficient permissions to scale the Virtual Machine Scale Set. To create a new Service Principal run:
```
az ad sp create-for-rbac --name ServicePrincipalName
```

Both the Service Principal Client ID and Client Secret need to be passed as parameters.
