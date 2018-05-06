# Install Multiple Visual Studio Team Services (VSTS) Agents

With Visual Studio Enterprise you can create applications across devices and services, using an integrated, end-to-end DevOps solution for productivity and coordination across teams of any size. You get the tools you need to design, build, deploy and manage desktop, Windows Store, Windows Phone, and Office apps, as well as mobile and web apps across any device, web site, cloud service, and more. This image contains the recommended prodct install of the originally released (or 'RTW') version of Visual Studio Enterprise 2017 on Windows Server 2016. It allows you to easily and quickly set up a development environment in Azure to build and test applications using Visual Studio.

This Template **201-vm-vsts-agent** builds the following:
 * Creates 1 Availability Set
 * Creates a Public IP Address
 * Creates a Virtual Network
 * Creates 1 Nic for the Virtual Machine
 * Creates 1 Virtual Machine with OS Disk with Windows 2016 including Visual Studio Enterprise 2017.
 * Installs and configures upto 4 VSTS agents
 * Installs named versions of modules  

## Usage

Click on the **Deploy to Azure** button below. This will open the Azure Portal (login if necessary) and start a Custom Deployment. The following Parameters will be shown and must be updated / selected accordingly. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-vsts-agent%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-vsts-agent%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Parameters

- modules
  Enter the Names and Versions of the Modules to be installed in C:\Modules. This Parameter is a Json Array 
  Default Modules and Versions are the following unless overridden:
   - AzureRM 5.6.0
   - AzureAD 2.0.1.3
   - Bitbucket.v2 1.1.2
   - GetPassword 1.0.0.0
   - posh-git 0.7.1
  Example:
  ```Json
  [
    {"name": "AzureRM", "version": "5.6.0"},
    {"name": "AzureAD", "version": "2.0.1.3"},
    {"name": "Bitbucket.v2", "version": "1.1.2"},
    {"name": "GetPassword", "version": "1.0.0.0"},
    {"name": "posh-git", "version": "0.7.1"}
  ]
  ```

- publicIPDnsName
  The DNS Name for the Public IP Address. e.g. pipnameexample-dev.

- vmAdminUser
  The name of the Administrator Account to be used to access the server(s).

- vmAdminPassword
  The password for the Admin Account. Must be at least 12 characters long.

- vmSize
  The size of VM required.
  Default is Standard_D1_v2 unless overridden.

- vstsAccount
  The Visual Studio Team Services account name, that is, the first part of your VSTS Account e.g. {account}.visualstudio.com

- vstsAgentCount
  The number of Visual Studio Team Services agents to be coonfigured on the Virtual Machine. Default is 3.

- vstsPersonalAccessToken
  The personal access token (PAT) used to authenticate to VSTS.

- vstsPoolName
  The Visual Studio Team Services build agent pool for this build agent to join. Use 'Default' if you don't have a separate pool.

- _artifactsLocation
  Storage account name to receive post-build staging folder upload.
- _artifactsLocationSasToken
  SAS token to access Storage account name

## Prerequisites

Access to Azure
## Versioning

We use [Github](https://github.com/) for version control.

## Authors

**Paul Towler** - *Initial work* - [vm-vsts-agent](https://github.com/azure-quickstart-templates/201-vm-vsts-agent)