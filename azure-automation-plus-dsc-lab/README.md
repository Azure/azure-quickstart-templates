# Azure Automation Plus DSC lab

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fazure-automation-plus-dsc-lab%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fazure-automation-plus-dsc-lab%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a new lab environment that can be used for training, practice and demonstrations of the following technologies:
1. Azure Automation
2. Azure Automation Desired State Configuration
3. Windows PowerShell
4. Windows PowerShell Desired State Configuration
5. PowerShell Core 6.0
6. Powershell DSC for Linux.

The lab infrastructure includes the following components:

1. 1 x resource group named rgAdatumDev##, where ## represents a one or two-digit number between 0 to 16.
2. 3 x Windows 2016 Data Center Core domain controllers
3. 1 x Widnows 2016 Data Center Development/Jump/DSCPull/DSCPush server w/the Visual Studio 2017 Community Edition VM image.
4. 2 x Windows 2016 Data Center Core servers, initially deployed as standalone servers but which can be configured after deployment as web servers using DSC.
5. 2 x Widnows 2016 Data Center servers, initially deployed as standalone servers but which can be configured after deployment as SQL 2016 servers using DSC.
6. 1 x CentOS 7 server, which can be used to demonstrate or practice PowerShell Core 6.0 or PowerShell DSC for Linux concepts.
7. 1 x Automation account for Azure automation topics
8. 1 x OMS Workspace for Runbook monitoring integration
9. 2 x storage accounts, 1 for automatically staging deployment artifacts and the other for user specified artifacts for DSC.
10.1 x recovery services vault for VM backup and recovery.

## Prerequisites

Decscription of the prerequistes for the deployment
1. An Azure subscription
2. A web browser
3. Internet connection

## Deploying The Template

You can deploy this template directly through the Azure Portal or by using the scripts supplied in the root of this repository.

To deploy the template using hte Azure Portal, click the Deploy to Azure button at the top of the article.

## Solution overview and deployed resources

This solution creates a consolidated training and demo lab environment for Azure Automation, Desired State Configuration and PowerShell topics.

The following resources are deployed as part of the solution

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

#### Connect

To connect to this lab after it is deployed, RDP to the development/jump server AZRDEV##01 VM using the connect icon from the VM overview blade in the portal.

## After Deploying the Template (Usage)

The recommended outline of training objectives for this lab follows as a basic guide, but you may deviate, ommit, add or re-sequnce these steps as necessary to meet your or your organizations own requirements.
1. Build the AZRDEV##01 server as a jump/dev DSC pull server using desired state configuration in local push configuration mode.
2. Build the AZRWEB##01 web server as a web server using push mode remotely from AZRDEV##01.
3. Build the AZRADS##01 domain controller as a domain controller using push mode remotely from AZRDEV##01.
4. Build the AZRSQL##01 SQL 2016 server as an SQL server using push mode remotely from AZRDEV##01.
5. Apply a configuration to AZRWEB##01 using the DSC Pull server AZRDEV##01.
6. Apply a configuration to AZRADS##01 using the DSC Pull server AZRDEV##01.
7. Apply a configuration to AZRSQL##01 using the DSC Pull server AZRDEV##01.
8. Build the AZRWEB##02 web server as a web server using Azure Automation DSC (AA DSC).
9. Build the AZRADS##02 domain controller as a domain controller using AA DSC.
10. Build the AZRSQL##02 SQL 2016 server as an SQL server using AA DSC.
11. Apply a configuration to the AZRLNX##01 Linux CentOS server using the push mode remotely from AZRDEV##01.
12. Apply a configuration to the AZRLNX##01 Linux CentOS server using AA DSC.
13. Create a runbook to convert all server private IP addresses from dynamic to static.

#### Management

To complete the recommended training objectives after this solutin is deployed, you can either RDP to the AZRDEV##01 jump VM or use the Azure portal.

## Notes

1. *This solution does not include a hybrid connection to an on-premises environment.*
2. *All Windows VMs are domain joined during the deployment.*

## Tags

`Tags: Azure, Automation, Powershell, DSC`