# Azure Container Service

This Microsoft Azure template creates an Azure Container Service cluster with a Mesos or Swarm orchestrator.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Facs-swarm%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

Click the "Deploy to Azure" button and then choose from the list of walkthrough depending on the orchestrator that you have chosen:

1. [Mesos](docs/MesosWalkthrough.md) - The Mesos orchestrator [walkthrough](MesosWalkthrough.md).
2. [SwarmPreview](docs/SwarmPreviewWalkthrough.md) - The Docker Swarm orchestrator [walkthrough](docs/SwarmPreviewWalkthrough.md).

## Deployment Tips:
1. You will need to provide an SSH RSA public key.  Follow instructions to generate SSH RSA keys in section [SSH Key Generation](#ssh-key-generation).  Your key should include three parts, for example ```ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm```
2. As a best practice, create a new resource group for every new container service you deploy.

## SSH Key Generation

When creating container services, you will need an SSH RSA key for access.  Use the following articles to create your SSH RSA Key:

1. Windows - https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
2. Linux - https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys
3. Mac - https://help.github.com/articles/generating-ssh-keys/#platform-mac
