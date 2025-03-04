---
description: This template creates a network security perimeter and it's associated resource for protecting an Azure key vault.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: network-security-perimeter-create
languages:
- json
- bicep
---

# Create a network security perimeter

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/network-security-perimeter-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetwork-security-perimeter-create-service%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetwork-security-perimeter-create-service%2Fazuredeploy.json)

## Notes

[Azure Private Link FAQ](https://docs.microsoft.com/azure/private-link/private-link-faq)

[Network security perimeter service template format](https://docs.microsoft.com/azure/templates/microsoft.network/networksecurityperimeters)

`Tags: Microsoft.Network/networkSecurityPerimeters, Microsoft.Network/networkSecurityPerimeters/profiles, Microsoft.Network/networkSecurityPerimeters/profiles/accessRules, Microsoft.Network/networkSecurityPerimeters/resourceAssociations, Microsoft.KeyVault/vaults`







-----
QuickStart: Create a network security perimeter - Azure ARM template 

 

 

Get started with network security perimeter by creating a network security perimeter for an Azure key vault using Azure ARM template. An Azure Resource Manager template is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax. You describe your intended deployment without writing the sequence of programming commands to create the deployment.  

A network security perimeter allows Azure PaaS resources to communicate within an explicit trusted boundary.  you create and update a PaaS resources’ association in a network security perimeter profile. Then you create and update network security perimeter access rules. When you're finished, you delete all resources created in this quickstart. 

If your environment meets the prerequisites and you're familiar with using ARM templates, select the Deploy to Azure button here. The ARM template will open in the Azure portal. (Azure Portal) 

Prerequisites 

An Azure account with an active subscription. Create an account for free. 

[!INCLUDE network-security-perimeter-add-preview] 

 

 

Review the template 

This template creates a network security perimeter for an instance of Azure key vault. 

The template that this QuickStart uses is from Azure Quickstart Templates. 

Arm Template - ArmTemplate.json 

 

 

The template defines multiple Azure resources: 

Microsoft.KeyVault/vaults: 

Deploys a Key Vault with the specified name, enabling secure storage and management of secrets. 

Microsoft.Network/networkSecurityPerimeters: 

Creates a network security perimeter resource to define and manage 	security policies. 

Microsoft.Network/networkSecurityPerimeters/profiles: 

Configures a network security perimeter profile that contains a set of security rules applied to the 	perimeter. 

Microsoft.Network/networkSecurityPerimeters/profiles/accessRules: 

Defines access rules for the network security perimeter profile: 

Inbound IPv4 Rule: Permits inbound traffic from specified IPv4 address prefixes (e.g., 100.10.0.0/16). 

Outbound FQDN Rule: Allows outbound traffic to fully qualified domain names (e.g., abc.com). 

Microsoft.Network/networkSecurityPerimeters/resourceAssociations: 

Associates the network security perimeter profile with the Key Vault, enabling enforced access controls. 

 

Deploy the ARM Template 

To deploy your ARM template to Azure and provision the resources, follow these steps: 

Sign in to Azure: 

Ensure you are signed in to the Azure portal with sufficient permissions to create resources. 

Open the Template Deployment Interface: 

Use the "Deploy to Azure" button below to open the template deployment interface. This interface allows you to review and customize the parameters for the deployment. 

Review Parameters: 

Enter the required parameter values, such as the Key Vault Name, Network security perimeter Name, Profile Name, and other resource-specific configurations. 

Leave default values as they are or adjust them based on your requirements. 

Deploy the Resources: 

Once all parameters are configured, click Review + Create and then Create to start the deployment. 

Verify Deployment: 

After the deployment completes, navigate to the Azure portal to verify that the 	following resources have been created: 

Key Vault for managing secrets. 

Network Security Perimeter and its associated profile and rules. 

Access Rules for inbound and outbound traffic management. 

Resource Association linking the network security perimeter profile to the Key Vault. 

 

 

 

Clean Up Resources 

When you no longer need the resources created with this deployment, it's a good practice to clean up by deleting the resource group. This action removes all the resources associated with the deployment, such as the Key Vault, Network Security Perimeter, access rules, and resource associations. 

To delete the resource group, follow these steps: 

Sign in to Azure: 

Ensure you're signed in to the Azure portal or Azure PowerShell with appropriate permissions. 

Identify the Resource Group: 

Note the name of the resource group used during deployment. 

Delete the Resource Group: 

Use the following PowerShell command to delete the resource group. This will remove all resources contained within it. 

Remove-AzResourceGroup -Name <ResourceGroupName> -Force 

 

 

 

 

 

{ 

    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#", 

    "contentVersion": "1.0.0.0", 

    "parameters": { 

        "location": { 

            "defaultValue": "[resourceGroup().location]", 

            "type": "String" 

        }, 

        "keyVaultName": { 

            "type": "String", 

            "metadata": { 

                "description": "Name of the Key Vault" 

            } 

        }, 

        "nspName": { 

            "defaultValue": "myNsp", 

            "type": "String", 

            "metadata": { 

                "description": "Name of the Network Security Perimeter" 

            } 

        }, 

        "profileName": { 

            "defaultValue": "myProfile", 

            "type": "String", 

            "metadata": { 

                "description": "Name of the NSP Profile" 

            } 

        }, 

        "inboundIpv4AccessRuleName": { 

            "defaultValue": "nspAccessRule1", 

            "type": "String", 

            "metadata": { 

                "description": "Name of the NSP Inbound Access Rule 1" 

            } 

        }, 

        "outboundFqdnAccessRuleName": { 

            "defaultValue": "nspAccessRule2", 

            "type": "String", 

            "metadata": { 

                "description": "Name of the NSP Outbound Access Rule 2" 

            } 

        }, 

        "associationName": { 

            "defaultValue": "myAssociation", 

            "type": "String", 

            "metadata": { 

                "description": "Name of the NSP Resource Association" 

            } 

        } 

    }, 

    "variables": { 

        "nspApiVersion": "2023-07-01-preview", 

        "paasRpApiVersion": "2021-11-01-preview" 

    }, 

    "resources": [ 

        { 

            "type": "Microsoft.KeyVault/vaults", 

            "apiVersion": "[variables('paasRpApiVersion')]", 

            "name": "[parameters('keyVaultName')]", 

            "location": "[parameters('location')]", 

            "properties": { 

                "sku": { 

                    "family": "A", 

                    "name": "Standard" 

                }, 

                "tenantId": "[subscription().tenantId]", 

                "accessPolicies": [], 

                "enabledForDeployment": false, 

                "enabledForDiskEncryption": false, 

                "enabledForTemplateDeployment": false, 

                "enableSoftDelete": true, 

                "softDeleteRetentionInDays": 90, 

                "enableRbacAuthorization": false 

            } 

        }, 

        { 

            "type": "Microsoft.Network/networkSecurityPerimeters", 

            "apiVersion": "[variables('nspApiVersion')]", 

            "name": "[parameters('nspName')]", 

            "location": "[parameters('location')]", 

            "properties": {} 

        }, 

        { 

            "type": "Microsoft.Network/networkSecurityPerimeters/profiles", 

            "apiVersion": "[variables('nspApiVersion')]", 

            "name": "[format('{0}/{1}', parameters('nspName'), parameters('profileName'))]", 

            "location": "[parameters('location')]", 

            "dependsOn": [ 

                "[resourceId('Microsoft.Network/networkSecurityPerimeters', parameters('nspName'))]" 

            ], 

            "properties": {} 

        }, 

        { 

            "type": "Microsoft.Network/networkSecurityPerimeters/profiles/accessRules", 

            "apiVersion": "[variables('nspApiVersion')]", 

            "name": "[format('{0}/{1}/{2}', parameters('nspName'), parameters('profileName'), parameters('inboundIpv4AccessRuleName'))]", 

            "location": "[parameters('location')]", 

            "dependsOn": [ 

                "[resourceId('Microsoft.Network/networkSecurityPerimeters/profiles', parameters('nspName'), parameters('profileName'))]" 

            ], 

            "properties": { 

                "direction": "Inbound", 

                "addressPrefixes": [ 

                    "100.10.0.0/16" 

                ], 

                "fullyQualifiedDomainNames": [], 

                "subscriptions": [], 

                "emailAddresses": [], 

                "phoneNumbers": [] 

            } 

        }, 

        { 

            "type": "Microsoft.Network/networkSecurityPerimeters/profiles/accessRules", 

            "apiVersion": "[variables('nspApiVersion')]", 

            "name": "[format('{0}/{1}/{2}', parameters('nspName'), parameters('profileName'), parameters('outboundFqdnAccessRuleName'))]", 

            "location": "[parameters('location')]", 

            "dependsOn": [ 

                "[resourceId('Microsoft.Network/networkSecurityPerimeters/profiles', parameters('nspName'), parameters('profileName'))]" 

            ], 

            "properties": { 

                "direction": "Outbound", 

                "addressPrefixes": [], 

                "fullyQualifiedDomainNames": [ 

                    "abc.com" 

                ], 

                "subscriptions": [], 

                "emailAddresses": [], 

                "phoneNumbers": [] 

            } 

        }, 

        { 

            "type": "Microsoft.Network/networkSecurityPerimeters/resourceAssociations", 

            "apiVersion": "[variables('nspApiVersion')]", 

            "name": "[format('{0}/{1}', parameters('nspName'), parameters('associationName'))]", 

            "location": "[parameters('location')]", 

            "dependsOn": [ 

                "[resourceId('Microsoft.Network/networkSecurityPerimeters/profiles', parameters('nspName'), parameters('profileName'))]", 

                "[resourceId('Microsoft.KeyVault/vaults', parameters('keyVaultName'))]" 

            ], 

            "properties": { 

                "network-security-perimeter-createResource": { 

                    "id": "[resourceId('Microsoft.KeyVault/vaults', parameters('keyVaultName'))]" 

                }, 

                "profile": { 

                    "id": "[resourceId('Microsoft.Network/networkSecurityPerimeters/profiles', parameters('nspName'), parameters('profileName'))]" 

                }, 

                "accessMode": "Enforced" 

            } 

        } 

    ] 

} 

 

 

Input -  
 
 