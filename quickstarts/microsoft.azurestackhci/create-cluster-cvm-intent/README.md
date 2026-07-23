---
description: This template creates a Confidential VM (CVM) ready Azure Stack HCI cluster using an ARM template.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cluster-cvm-intent
languages:
- json
---
# Deploy a Confidential VM (CVM) ready Azure Stack HCI Cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-cvm-intent/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-cvm-intent/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-cvm-intent/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-cvm-intent/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-cvm-intent/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster-cvm-intent/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster-cvm-intent%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster-cvm-intent%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster-cvm-intent%2Fazuredeploy.json)

## Introduction

Confidential VMs (CVM) offer strong security and confidentiality benefits over standard VMs. CVMs provide a robust hardware-based isolation between other virtual machines, the hypervisor, and host management code.

This template deploys an Azure Stack HCI cluster configured with the `confidentialVmIntent` parameter, set to **Enable** for deploying Confidential VMs on Azure Local.

## Deploy CVM Ready Azure Local Cluster

To ensure the cluster is configured with the prescribed configuration to enable deployment of confidential VM (CVM), we need to include an additional parameter in the ARM (Azure Resource Manager) deployment specification. Without specifying this parameter, the creation of the CVM will fail. Additionally, setting this parameter may slightly impact the CPU performance for some workloads. This impact could be observed for CVMs as well as standard VMs. 

This additional parameter is called "confidentialVmIntent" and should be included in the ARM template and set in the ARM parameter file. Use api version 2026-04-01-preview API where applicable. 

The examples of ARM template (azuredeploy.json) and parameterized json (azuredeploy.parameterized.json) will be provided separately.  

This parameter (“confidentialVmIntent”) should be added to your AzureDeploy.json and will be represented as below: 
 
* Please refer AzureDeploy.json attached. 

The steps to deploy the Azure local cluster are described here: Azure Resource Manager template deployment for Azure Local, version 23H2 - Azure Local | Microsoft Learn. Following are the  few things to customize in the deployment steps: 

Select the template spec in step 3. Since this is a private preview, the “confidentialVmIntent” field is not available in the standardized Quickstart templates 

On step #6, edit the template and ensure the “confidentialVmIntent” is set to “Enable” and then load the file 

The parameterized file should be set with enable 

Users can verify if the intent has been passed to the cluster deployment using properties. The property description can be found on the cluster page on the Azure portal. 

 "OptionalServices":{  
               "ConfidentialVmIntent": [Enable]  
                 }

The other option is to verify via the portal,  
 
Once the intent is declared via the template and verified, the operator can deploy the cluster by clicking on Review +Create as highlighted above. 
 

## Verify cluster deployment 

Option 1: Use the rest API for checking if the cluster is deployed successfully with CVM intent by checking Status Details and "ConfidentialVmStatus": “[Enabled]”  

 

az rest --method get --url https://management.azure.com/subscriptions/$subscription/resourceGroups/$resourceGroup/providers/Microsoft.AzureStackHCI/clusters/$($clustername)?api-version=2026-04-01-preview 


Option 2: Once the cluster deployment is completed, users can again verify if the cluster is CVM capable and the following regkey is set for each node. 

HKLM:SOFTWARE\Microsoft\AszIGVmAgent\ConfidentialVMHardwareCapability 

And finally, if the MAA resource details are set, all nodes have “igvmStatus”: “Enabled” and the cluster resource will have CVM capability enabled as below. User should select 2026-04-01-preview API version to find below cvm properties in clusters json view in portal.  