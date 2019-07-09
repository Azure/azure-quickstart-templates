# Install Multiple Azure DevOps Agents with latest Az Modules with PowerShell Core

With Visual Studio Enterprise you can create applications across devices and services, using an integrated, end-to-end DevOps solution for productivity and coordination across teams of any size. You get the tools you need to design, build, deploy and manage desktop, Windows Store, Windows Phone, and Office apps, as well as mobile and web apps across any device, web site, cloud service, and more. This image contains the recommended prodct install of the originally released (or 'RTW') version of Visual Studio Enterprise 2019 on Windows Server 2019. It allows you to easily and quickly set up a development environment in Azure to build and test applications using Visual Studio.

This Template **201-vm-vsts-agent** builds the following:
 * Creates 1 Availability Set
 * Creates a Public IP Address
 * Creates a Virtual Network
 * Creates 1 Nic for the Virtual Machine
 * Creates 1 Virtual Machine with OS Disk with Windows 2016 including Visual Studio Enterprise 2017.
 * Installs and configures upto 4 VSTS agents
 * Installs modules and packages from PowerShell Gallery and Chocolately   

## Usage

Click on the **Deploy to Azure** button below. This will open the Azure Portal (login if necessary) and start a Custom Deployment. The following Parameters will be shown and must be updated / selected accordingly. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-vsts-agent%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-vsts-agent%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Parameters

- script_url </br>
  URL for the PowerShell Script. NOTE: Can be a Github url (raw) to the ps1 file. </br>
  Default: Standard_DS1_v2 unless overridden.

- vm_admin_user </br>
  The name of the Administrator Account to be used to access the server(s).

- vm_admin_password </br>
  The password for the Admin Account. Must be at least 12 characters long.

- vm_size </br>
  The size of VM required. </br>
  Default: Standard_DS1_v2 unless overridden.

- devops_org </br>
  The Azure DevOps Organisation name, that is, the last part of your Azure DevOps Url e.g. http://dev.azure.com/{OrgName}

- devops_agent_count </br>
  The number of Azure DevOps agents to be coonfigured on the Virtual Machine. </br>
  Default: 3.

- devops_pat </br>
  The personal access token (PAT) used to authenticate to Azure DevOps.

- devops_pool_name </br>
  The Azure DevOps build agent pool for this build agent to join. </br>
  Default: Default

## Prerequisites

Access to Azure
## Versioning

We use [Github](https://github.com/) for version control.

## Authors

**Paul Towler** - *Initial work* - [201-vm-vsts-agent](https://github.com/azure-quickstart-templates/201-vm-vsts-agent)
