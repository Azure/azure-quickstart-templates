# Azure Container Service

This Microsoft Azure template creates an [Azure Container Service](https://azure.microsoft.com/en-us/services/container-service/) cluster with a DC/OS orchestrator. There is also an option to use Docker Swarm as your orchestrator. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-acs-dcos%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

Click the "Deploy to Azure" button and then follow the relevant walkthrough linked below, alternatively you can view our [ACS documentation](https://azure.microsoft.com/en-us/documentation/services/container-service/) on the Azure website.

[DC/OS](https://github.com/Azure/acs-engine/blob/master/docs/dcos.md#walkthrough) - The DC/oS orchestrator [walkthrough](https://github.com/Azure/acs-engine/blob/master/docs/dcos.md#walkthrough).

## Deployment Tips:
1. You will need to provide an SSH RSA public key.  Follow instructions to generate SSH RSA keys in section [SSH Key Generation](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-dcos/docs/SSHKeyManagement.md#ssh-key-generation).  Your key should include three parts, for example ```ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm```
2. As a best practice, create a new resource group for every new container service you deploy.
3. The installation log for the masters, agents, and jumpbox are in /var/log/azure/cluster-bootstrap.log
4. Even though the agent VMs finish quickly DC/OS can take 5-15 minutes to install, check /var/log/azure/cluster-bootstrap.log for the completion status.

# Learning More

Here are recommended links to learn more about DC/OS:

1. [Azure DC/OS documentation](https://azure.microsoft.com/en-us/documentation/services/container-service/)

## DC/OS Community Documentation

1. [DC/OS Overview](https://dcos.io/docs/1.8/overview/) - provides overview of DC/OS, Architecture, Features, and Concepts.

2. [DC/OS Tutorials](https://docs.mesosphere.com/1.8/usage/tutorials/) - provides various tutorials for DC/OS. 