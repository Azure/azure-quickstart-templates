---
description: The Microsoft Azure Storage Account can now be used as a ILM Store to persist the Archive files and attachments from an SAP ILM system. An ILM Store is a component which fulfills the requirements of SAP ILM compliant storage systems. One can store archive files in a storage media using WebDAV interface standards while making use of SAP ILM Retention Management rules. For more information about SAP ILM Store, refer to the <a href='https&#58;//www.sap.com'> SAP Help Portal </a>.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sap-ilm-store
languages:
- json
---
# Deploy a Storage Account for SAP ILM Store

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-ilm-store/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-ilm-store/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-ilm-store/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-ilm-store/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-ilm-store/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sap/sap-ilm-store/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-ilm-store%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-ilm-store%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-ilm-store%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-ilm-store%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsap%2Fsap-ilm-store%2Fazuredeploy.json)

The Microsoft Azure Storage Account can now be used as a ILM Store to persist the Archive files and attachments from an SAP ILM system. An ILM Store is a component which fulfills the requirements of SAP ILM compliant storage systems. One can store archive files in a storage media using WebDAV interface standards while making use of SAP ILM Retention Management rules. For more information about SAP ILM Store, refer to the <a href='https://www.sap.com'> SAP Help Portal </a>.

## Overview of deployed resources

The following steps are executed as a part of this Quickstart Template:

+ Deployment of a Microsoft Azure Storage Account
+ Using an existing Built-in (or Custom) Role or creation of a new Custom Role for restricting access to the Microsoft Azure Storage Account
+ Assignment of the identified Role to a Microsoft Azure Active Directory Application

## Prerequisites

### Parameter: Use an existing Role or create a new custom Role Definition
You can decide to either use an existing Role definition or create a new custom Role Definition using this parameter.

To use an existing Role definition, use the parameter **"Role ID of an existing Role"** to provide the corresponding Role ID. Refer to the next section to find out how to fetch the value.

To create a new custom Role, use the parameter **"Name for a new Custom Role"** to provide a name for a new Custom Role Definition.

### Parameter: Role ID of an existing Role
Run the following command to get the Role ID for an existing Role Definition. Replace `role-name` with the name of an existing Role Definition. This role would be assigned to the Service Principal which is used to access the Microsoft Azure Storage Account.

**PowerShell:** `(Get-AzRoleDefinition -Name "role-name").Id`

**Command Line:** `az role definition list --name "role-name" --query "[].name" --output tsv`

### Parameter: Name for a new Custom Role
Ensure that you provide a new and unique value for this parameter.

### Parameter: Principal ID of the Azure AD App
Run the following command to get the Principal ID of an Azure Active Directory Application. Replace `name-of-service-principal` with the name of an Azure Active Directory Application. This application will enable  the SAP ILM access to the Microsoft Azure Storage Account.

**PowerShell:** `(Get-AzADServicePrincipal -DisplayName "name-of-service-principal").Id`

**Command Line:** `az ad sp list --display-name "name-of-service-principal" --query "[].objectId" --output tsv`

## Deployment steps

Click the [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://github.com/Azure/azure-quickstart-templates/tree/master/application-workloads/sap/sap-ilm-store/README.md#deploy-a-storage-account-for-sap-ilm-store) button at the beginning of this document.

## Error Handling

For deployment errors raised with Azure Resource Manager, refer to [Troubleshoot common Azure deployment errors with Azure Resource Manager](https://docs.microsoft.com/azure/azure-resource-manager/templates/common-deployment-errors).

Some of the errors are listed below:

**Error code:** `RoleScopeBeingRemovedContainsAssignments`
- **Error Description:** `Role assignments found under scope '/subscriptions/<<value>>/resourcegroups/<<value>>' which is being removed. Removing this scope from the role will orphan these assignments. Delete these assignments before removing the scope`
- **Deployment phase:** Deployment
- **Details:** The name of the Custom Role provided for the parameter **"Name for a new Custom Role"** may already be in use.
- **Solution:** Select a new and unique value for this parameter and try again.

**Error code:** `InvalidPrincipalId`
- **Error Description:** `A valid principal ID must be provided for role assignment`
- **Deployment phase:** Deployment
- **Details:** The Principal Id provided for the parameter **"Principal ID of the Azure AD App"** may be incorrect.
- **Solution:** Refer to the [Prerequisites section](https://github.com/Azure/azure-quickstart-templates/tree/master/application-workloads/sap/sap-ilm-store/README.md#prerequisites) above to determine the correct value for this parameter.

## Notes

The scripts are provided as-is without warranty of any kind, either expressed or implied, including any implied warranties of fitness for a particular purpose, mechantability, or non-infringement.

`Tags: SAP, Information Lifecycle Magagement, ILM, Store, Microsoft.Storage/storageAccounts, Microsoft.Authorization/roleDefinitions, customRole, Microsoft.Authorization/roleAssignments, Microsoft.ManagedIdentity/userAssignedIdentities`
