# Azure Container Service

This Microsoft Azure template creates an Azure Container Service cluster with a Mesos or Swarm orchestrator.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Facs%2Facs-mesos-full-template%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a> |ACS

## Deployment Tips:
1. You will need to provide an SSH RSA public key.  Follow instructions to generate SSH RSA keys in section [SSH Key Generation](#ssh-key-generation).  Your key should include three parts, for example ```ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm```
2. As a best practice, create a new resource group for every new container service you deploy.

# Summary

Click the above link to deploy your service and then choose from the list of walkthrough depending on the orchestrator that you have chosen:

1. [Mesos](https://github.com/rgardler/azure-quickstart-templates/blob/acs/acs-mesos-full-template/docs/MesosWalkthrough.md) - The Mesos orchestrator [walkthrough](https://github.com/rgardler/azure-quickstart-templates/blob/acs/acs-mesos-full-template/docs/MesosWalkthrough.md).
2. [SwarmPreview](https://github.com/rgardler/azure-quickstart-templates/blob/acs/acs-swarm-full-template/docs/SwarmPreviewWalkthrough.md) - The Docker Swarm orchestrator [walkthrough](https://github.com/rgardler/azure-quickstart-templates/blob/acs/acs-swarm-full-template/docs/SwarmPreviewWalkthrough.md).

# SSH Key Generation

When creating container services, you will need an SSH RSA key for access.  Use the following articles to create your SSH RSA Key:

1. Windows - https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
2. Linux - https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys
3. Mac - https://help.github.com/articles/generating-ssh-keys/#platform-mac
