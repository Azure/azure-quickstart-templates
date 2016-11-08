# Azure Container Service

This Microsoft Azure template creates an [Azure Container Service](https://azure.microsoft.com/en-us/services/container-service/) cluster with a Docker Swarm orchestrator. There is also an option to use DC/OS as your orchestrator.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-acs-swarm%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

Click the "Deploy to Azure" button and then follow the relevant walkthrough linked below, alternatively you can view our [ACS documentation](https://azure.microsoft.com/en-us/documentation/services/container-service/) on the Azure website.

[Swarm](https://github.com/Azure/acs-engine/blob/master/docs/swarm.md#walkthrough) - The Docker Swarm orchestrator [walkthrough](https://github.com/Azure/acs-engine/blob/master/docs/swarm.md#walkthrough).

## Deployment Tips:
1. You will need to provide an SSH RSA public key.  Follow instructions to generate SSH RSA keys in section [SSH Key Generation](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-dcos/docs/SSHKeyManagement.md#ssh-key-generation).  Your key should include three parts, for example ```ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm```
2. As a best practice, create a new resource group for every new container service you deploy.
3. The installation log for the masters, agents, and jumpbox are in /var/log/azure/cluster-bootstrap.log

# Learning More

1. [Azure Swarm documentation](https://azure.microsoft.com/en-us/documentation/services/container-service/)

## Community Documentation

1. [Docker](https://docs.docker.com/) - learn more through Docker documentation.

2. [Docker Swarm](https://docs.docker.com/swarm/overview/) - learn more about Docker Swarm.

3. [Docker Compose](https://docs.docker.com/compose/overview/) - Learn more about Docker Compose.