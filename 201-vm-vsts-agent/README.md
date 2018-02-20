# 201-vm-vsts-agent

With Visual Studio Enterprise you can create applications across devices and services, using an integrated, end-to-end DevOps solution for productivity and coordination across teams of any size. You get the tools you need to design, build, deploy and manage desktop, Windows Store, Windows Phone, and Office apps, as well as mobile and web apps across any device, web site, cloud service, and more. This image contains the recommended prodct install of the originally released (or 'RTW') version of Visual Studio Enterprise 2017 on Windows Server 2016. It allows you to easily and quickly set up a development environment in Azure to build and test applications using Visual Studio.

The Infrastructure Pattern Template **201-vm-vsts-agent** builds the following:
 * Uses the Workload Subscription Virtual Network (vn-ss1-0)
 * Creates 1 Availability Set
 * Creates a Public IP Address
 * Creates a Virtual Network
 * Creates 1 Nic for the Virtual Machine
 * Creates 1 Virtual Machine with OS Disk with Windows 2016 including Visual Studio Enterprise 2017.
 * Installs and configures upto 4 VSTS agents 

## Usage

Click on the **Deploy to Azure** button below. This will open the Azure Portal (login if necessary) and start a Custom Deployment. The following Parameters will be shown and must be updated / selected accordingly. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-vsts-agent%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-vsts-agent%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Parameters

- publicIPDnsName
  - Specify the DNS Name for the Public IP Address. e.g. pipnameexample-dev

- omsWorkspaceName
  - Name for the Log Analytics workspace to which metrics and diagnostic logs will be sent to e.g. oms-sub-au-ssinf-0
   
- omsWorkspaceSubId
  - The Azure subscription ID for the Log Analytics workspace to which metrics and diagnostic logs will be sent to.

- vmAdminUser
 - The name of the Administrator Account to be used to access the server(s)

- vmAdminPassword
 - The password for the Admin Account. Must be at least 12 characters long

- vmSize
  - Specify the size of VM required for the VM(s)
  - Default is Standard_D1_v2 unless overridden.
  - Allowed Values are:
```
	Standard_A0
	Standard_A1
	Standard_A2
	Standard_A3
	Standard_A5
	Standard_A4
	Standard_A6
	Standard_A7
	Basic_A0
	Basic_A1
	Basic_A2
	Basic_A3
	Basic_A4
	Standard_D1_v2
	Standard_D2_v2
	Standard_D3_v2
	Standard_D4_v2
	Standard_D5_v2
	Standard_D11_v2
	Standard_D12_v2
	Standard_D13_v2
	Standard_D14_v2
	Standard_D15_v2
	Standard_D2_v2_Promo
	Standard_D3_v2_Promo
	Standard_D4_v2_Promo
	Standard_D5_v2_Promo
	Standard_D11_v2_Promo
	Standard_D12_v2_Promo
	Standard_D13_v2_Promo
	Standard_D14_v2_Promo
	Standard_A1_v2
	Standard_A2m_v2
	Standard_A2_v2
	Standard_A4m_v2
	Standard_A4_v2
	Standard_A8m_v2
	Standard_A8_v2
	Standard_DS1_v2
	Standard_DS2_v2
	Standard_DS3_v2
	Standard_DS4_v2
	Standard_DS5_v2
	Standard_DS11_v2
	Standard_DS12_v2
	Standard_DS13-2_v2
	Standard_DS13-4_v2
	Standard_DS13_v2
	Standard_DS14-4_v2
	Standard_DS14-8_v2
	Standard_DS14_v2
	Standard_DS2_v2_Promo
	Standard_DS3_v2_Promo
	Standard_DS4_v2_Promo
	Standard_DS5_v2_Promo
	Standard_DS11_v2_Promo
	Standard_DS12_v2_Promo
	Standard_DS13_v2_Promo
	Standard_DS14_v2_Promo
	Standard_D2_v3
	Standard_D4_v3
	Standard_D8_v3
	Standard_D16_v3
	Standard_D32_v3
	Standard_D64_v3
	Standard_D2s_v3
	Standard_D4s_v3
	Standard_D8s_v3
	Standard_D16s_v3
	Standard_D32s_v3
	Standard_D64s_v3
	Standard_DS15_v2
	Standard_D1
	Standard_D2
	Standard_D3
	Standard_D4
	Standard_D11
	Standard_D12
	Standard_D13
	Standard_D14
	Standard_DS1
	Standard_DS2
	Standard_DS3
	Standard_DS4
	Standard_DS11
    Standard_DS12
    Standard_DS13
    Standard_DS14
```
- vstsAccount
 - The Visual Studio Team Services account name, that is, the first part of your VSTS Account e.g. {account}.visualstudio.com

- vstsAgentCount
 - The number of Visual Studio Team Services agents to be coonfigured on the Virtual Machine. Defialt is 3

- vstsPersonalAccessToken
 - The personal access token (PAT) used to authenticate to VSTS

- vstsPoolName
 - The Visual Studio Team Services build agent pool for this build agent to join. Use 'Default' if you don't have a separate pool.

- _artifactsLocation
  - Storage account name to receive post-build staging folder upload.

- _artifactsLocationSasToken
  - SAS token to access Storage account name 


## Prerequisites

Access to Azure

## Versioning

We use [Github](https://github.com/) for version control.

## Authors

**Paul Towler** - *Initial work* - [vm-vsts-agent](https://github.com/azure-quickstart-templates/201-vm-vsts-agent)