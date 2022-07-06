---
description: Deploys Azure mgmt with attached workload
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azmgmt-demo
languages:
- json
---
# Azure mgmt. demo

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azmgmt-demo/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azmgmt-demo/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azmgmt-demo/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azmgmt-demo/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azmgmt-demo/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/azmgmt-demo/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fazmgmt-demo%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fazmgmt-demo%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fazmgmt-demo%2Fazuredeploy.json)

>Note: The purpose of these templates, is to give you a kick-start, instantiating all of the Azure mgmt services in Azure.
The mgmt. services will be fully integrated, and you will have VM workloads (Windows or Linux) which will be attached - and fully managed as part of the deployment.
**Please note that this sample is for demo purposes only**

## What is being deployed

### Management services and artifacts

* Azure Log Analytics

A workspace is being created, with sample datasources for both Windows and Linux, together with multiple OMS solutions.

* Azure Automation

The automation account will include several DSC configurations, centered on management scenarios, such as keeping the OMS agent healthy and running, as well as deploying the ASR mobility agent. A PowerShell runbook is also created, which can iterate through the subscription to enable backup on unprotected virtual machines.

* Recovery Services

A recovery vault - to support both Azure 2 Azure DR protection, as well as IaaS backup. The automation account also includes multiple Runbooks that can be used as part of Recovery Plans for ASR.

### IaaS workload

You can specify the amount of virtual machines you want to create (1-10), where all the machines will be connected, protected, and attached to the management services.

## How to deploy

These templates should be deployed using PowerShell, as you need to create two resource groups prior to submitting the deployment.
The guidance below shows a sample script, where you only have to provide your unique values to the variables.

```powershell

# Create 2 resource groups, for mgmt and workload
$MgmtRgName = '' # Specify a name for the resource group containing the management services
$WorkloadRgName = '' # Specify a name for the resource group containing the virtual machine(s)

$MgmtRg = New-AzureRmResourceGroup -Name $MgmtRgName -Location eastus -Verbose
$WorkloadRg = New-AzureRmResourceGroup -Name $WorkloadRgName -Location eastus -Verbose

# Define parameters for template deployment - remember to change the values!f

$azMgmtPrefix = '' # Specify the prefix for the Azure mgmt. services that will be deployed
$Platform = '' # Select either 'WinSrv' or 'Linux'. If WinSrv, DSC will be enabled.
$userName = '' # username for the VM(s)
$vmNamePrefix = '' # Specify the prefix for the virtual machine(s) that will be created
$instanceCount = '' # You can create 1-10 VMs
$deploymentName = '' # Specify the name of the main ARM template deployment job
$templateuri = 'azuredeploy.json'

# Deploy template

New-AzureRmResourceGroupDeployment -Name $deploymentName `
                                   -ResourceGroupName $MgmtRg.ResourceGroupName `
                                   -TemplateUri $templateUri `
                                   -vmResourceGroup $WorkloadRg.ResourceGroupName `
                                   -azMgmtPrefix $azMgmtPrefix `
                                   -vmNamePrefix $vmNamePrefix `
                                   -userName $userName `
                                   -platform $platform `
                                   -instanceCount $instanceCount `
                                   -Verbose
```

Navigate to [Azure Portal](https://portal.azure.com) and find the newly created dashboard, which will have the following naming convention *AzureMgmt(uniqueString(deployment().name))*:

![media](./images/dashboard-new.png)

`Tags:Microsoft.Resources/deployments, Microsoft.Automation/automationAccounts, variables, Microsoft.Automation/automationAccounts/runbooks, Microsoft.Automation/automationAccounts/modules, Microsoft.Storage/storageAccounts, Microsoft.Network/virtualNetworks, Microsoft.RecoveryServices/vaults, Microsoft.RecoveryServices/vaults/replicationFabrics, Microsoft.RecoveryServices/vaults/replicationPolicies, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectedItems, Modules, Configurations, uri, Compilationjobs, Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/availabilitySets, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, [if(equals(parameters('platform'), 'WinSrv'), variables('windowsMgmtType'), variables('linuxMgmtType'))], [if(equals(parameters('platform'), 'WinSrv'), 'DependencyAgentWindows', 'DependencyAgentLinux')], DSC, Microsoft.Portal/dashboards, Extension[azure]/HubsExtension/PartType/MarkdownPart, Extension/HubsExtension/PartType/ResourceGroupMapPinnedPart, ResourceGroups, Extension/Microsoft_Azure_RecoveryServices/PartType/ResourcePart, RecoveryServicesResource, Extension/Microsoft_Azure_Automation/PartType/InferredBladePinPartAccountDashboardBlade, Account, Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/WorkspacePart, Workspace, Extension/Microsoft_Azure_RecoveryServices/Blade/ResourceBlade/Lens/BackupItemsLens/PartInstance/BackupProtectedItemsSummaryPart, Extension/Microsoft_Azure_Automation/Blade/AccountDashboardBlade/Lens/ResourcesLens/PartInstance/RunbooksCollectionPart, Extension/Microsoft_OperationsManagementSuite_Workspace/Blade/WorkspaceBlade/Lens/ManagementLens/PartInstance/LogSearchPart, Extension/Microsoft_Azure_Automation/Blade/AccountDashboardBlade/Lens/ResourcesLens/PartInstance/DsConfigurationsCollectionPart, Extension/Microsoft_OperationsManagementSuite_Workspace/Blade/WorkspaceBlade/Lens/ManagementLens/PartInstance/OverviewPart, MsPortalFx.Composition.Configuration.ValueTypes.TimeRange, string, runbooks, replicationFabrics, replicationPolicies, Microsoft.OperationalInsights/workspaces, datasources, Microsoft.OperationsManagement/solutions`
