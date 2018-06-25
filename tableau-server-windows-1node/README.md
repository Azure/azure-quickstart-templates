# Tableau Server on Windows - Single Node   
<img src="https://github.com/maddyloo/tableau-server-windows-1node/blob/master/Images/tableau_rgb.png"/>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo: 

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'west us' -ArtifactsStagingDirectory 'tableau-server-windows-1node' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a tableau-server-windows-1node -l eastus -u
```

This template has artifacts that need to be "staged" for deployment (Configuration Script) so you have to set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script (think of this as "temp" storage for AzureRM) and reused by subsequent deployments.

This template deploys a **single node Tableau Server instance on a Windows, Standard_D16_v3 VM instance** in its own Virtual Network.

`Tags: Tableau, Tableau Server, Windows Server, Analytics, Self-Service, Data Visualization, Windows`

## Solution overview and deployed resources

Tableau Server on Azure is browser and mobile-based visual analytics anyone can use.  Publish interactive dashboards with Tableau Desktop and share them throughout your organization. Embedded or as a stand-alone application, you can empower your business to find answers in minutes, not months.  By deploying Tableau Server on Azure with this quickstart you can take full advantage of the power and flexibility of Azure Cloud infrastructure.  

Tableau helps tens of thousands of people see and understand their data by making it simple for the everyday data worker to perform ad-hoc visual analytics and data discovery as well as the ability to seamlessly build beautiful dashboards and reports. Tableau is designed to make connecting live to data of all types a simple process that doesn't require any coding or scripting. From cloud sources like Azure SQL Data Warehouse, to on-premise Hadoop clusters, to local spreadsheets, Tableau gives everyone the power to quickly start visually exploring data of any size to find new insights.

<img src="https://github.com/maddyloo/tableau-server-windows-1node/blob/master/Images/azure_single_node.png">

The following resources are deployed as part of the solution

#### Tableau

Business Intelligence Software Provider

+ **Tableau Server Installer**: Hosted collaboration software where users can share and manage Tableau Dashboards and data sources.
+ **ScriptedInstaller.py**: Python script that performs a silent Tableau Server install
+ **config_script.ps1**: Powershell script isntalls dependancies and calls python installer

#### Microsoft Azure

Public Cloud Platform

+ **Virtual Network**: New (or existing) virtual network that contains all relevant resources required by the Tableau Server install
+ **Virtual Machine**: Standard_D16-v3 instance
+ **Network Interface**: Allows Azure VM to communicate with the internet
+ **Public IP Address**: Static Public IP that allows users to access Tableau Server
+ **Network Security Group**: Limits traffic to Azure VM (RDP & port 80 only)

## Prerequisites

By default this template will install a 12-day free trial of Tableau Server.  To switch to a licensed version please contact your Tableau Sales representative.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

#### Connect

Navigate to Tableau Server using the public IP address: http://- Public IP -:80

#### Management

Manage your Azure resources directly from your Azure portal.  Use the web UI and Desktop Interface to adminsitrate your Tableau Server instance: https://onlinehelp.tableau.com/current/server/en-us/admin.htm  

## Notes

Follow these requirements when setting parameters: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm

This template is intended as a sample for how to install Tableau Server.  If you choose to run a production version of Tableau Server you are responsible for managing the cost & security of your Azure & Tableau deployment.  This version has been written by Madeleine Corneli and is not officially endorsed by Tableau Software.