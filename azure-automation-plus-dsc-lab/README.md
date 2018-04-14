# Azure Automation Plus DSC lab

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="![alt text](images/deploytoazure.png "Deploy to Azure button"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="![alt text](images/visualizebutton.png "Visualize resources button"/>
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

## Deploying The Template

You can deploy this template directly through the Azure Portal or by using the scripts supplied in the root of this repository.

To deploy the template using hte Azure Portal, click the Deploy to Azure button at the top of the article.

To deploy the template via the command line (using Azure PowerShell or the Azure CLI) you can use the scripts shown below.

Execute the script from the root folder and pass in the folder name of the sample (azure-automation-plus-dsc-lab). For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus2' -ArtifactsStagingDirectory 'azure-automation-plus-dsc-lab' -UploadArtifacts
```
```bash
azure-group-deploy.sh -a 'azure-automation-plus-dsc-lab' -l eastus2 -u
```
## Solution overview and deployed resources

This solution creates a consolidated training and demo lab environment for Azure Automation, Desired State Configuration and PowerShell topics.

The following resources are deployed as part of the solution

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

#### Connect

To connect to this lab after it is deployed, RDP to the development/jump server AZRDEV##01 VM using the connect icon from the VM overview blade in the portal.

## After Deploying the Template (Usage)

The recommended outline of training objectives for this lab follows as a basic guide, but you may deviate, ommit, add or re-sequnce these steps as necessary to meet your or your organizations own requirements.
A. Build the AZRDEV##01 server as a jump/dev DSC pull server using desired state configuration in local push configuration mode.
B. Build the AZRWEB##01 web server as a web server using push mode remotely from AZRDEV##01.
C. Build the AZRADS##01 domain controller as a domain controller using push mode remotely from AZRDEV##01.
D. Build the AZRSQL##01 SQL 2016 server as an SQL server using push mode remotely from AZRDEV##01.
E. Apply a configuration to AZRWEB##01 using the DSC Pull server AZRDEV##01.
F. Apply a configuration to AZRADS##01 using the DSC Pull server AZRDEV##01.
G. Apply a configuration to AZRSQL##01 using the DSC Pull server AZRDEV##01.
H. Build the AZRWEB##02 web server as a web server using Azure Automation DSC (AA DSC).
I. Build the AZRADS##02 domain controller as a domain controller using AA DSC.
J. Build the AZRSQL##02 SQL 2016 server as an SQL server using AA DSC.
K. Apply a configuration to the AZRLNX##01 Linux CentOS server using the push mode remotely from AZRDEV##01.
L. Apply a configuration to the AZRLNX##01 Linux CentOS server using AA DSC.
M. Create a runbook to convert all server private IP addresses from dynamic to static.

#### Management

To complete the recommended training objectives after this solutin is deployed, you can either RDP to the AZRDEV##01 jump VM or use the Azure portal.

## Notes

*-This solution does not include a hybrid connection to an on-premises environment.*
*-All Windows VMs are domain joined during the deployment.*

## Tags

`Tags: Azure, Automation, Powershell, DSC`