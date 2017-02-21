# Azure Container Service

This Microsoft Azure template creates an [Azure Container Service](https://azure.microsoft.com/en-us/services/container-service/) cluster with a Kubernetes orchestrator. There is also an option to use DC/OS or Docker Swarm as your orchestrator. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-acs-kubernetes%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

Click the "Deploy to Azure" button and then follow the relevant walkthrough linked below, alternatively you can view our [ACS documentation](https://azure.microsoft.com/en-us/documentation/services/container-service/) on the Azure website.

[Kubernetes](docs/kubernetes.md) - The Kubernetes orchestrator [walkthrough](https://github.com/Azure/acs-engine/blob/master/docs/kubernetes.md).

## Deployment Tips:
1. You will need to provide a service principal.  Follow these instructions to [generate your service principal](https://github.com/Azure/acs-engine/blob/master/docs/serviceprincipal.md)
2. You will need to provide an SSH RSA public key.  Follow instructions to generate SSH RSA keys in section [SSH Key Generation](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-dcos/docs/SSHKeyManagement.md#ssh-key-generation).  Your key should include three parts, for example ```ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm```
3. As a best practice, create a new resource group for every new container service you deploy.

# Learning More

Here are recommended links to learn more about Kubernetes:

1. [Azure Kubernetes documentation](https://azure.microsoft.com/en-us/documentation/services/container-service/)

## Kubernetes Community Documentation

1. [Kubernetes Bootcamp](https://kubernetesbootcamp.github.io/kubernetes-bootcamp/index.html) - shows you how to deploy, scale, update, and debug containerized applications.
2. [Kubernetes Userguide](http://kubernetes.io/docs/user-guide/) - provides information on running programs in an existing Kubernetes cluster.
3. [Kubernetes Examples](https://github.com/kubernetes/kubernetes/tree/master/examples) - provides a number of examples on how to run real applications with Kubernetes.