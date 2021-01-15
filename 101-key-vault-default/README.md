# Create an Azure Key Vault with default settings

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-key-vault-default/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-key-vault-default/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-key-vault-default/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-key-vault-default/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-key-vault-default/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-key-vault-default/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-key-vault-default%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-key-vault-default%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-key-vault-default%2Fazuredeploy.json)

This template creates an Azure Key Vault with default settings that doesn't include any keys, secrets, or certificates and uses the standard pricing tier. When you run the template, only your account is added to the key vault's access policy and authorized to do vault operations. After deployment, you can update the key vault and add users to the access policies, change permissions for the keys, secrets, and certificates, and customize other settings.

## Prerequisite

The template requires the  _object ID_ of the person who runs the template and is in a GUID format: `11111111-aaaa-2222-bbbb-333333333333`. To get your _object ID_, open [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview) and run a CLI or PowerShell command with your email address as the `id` or `UserPrincipalName`. Or you can use the portal to find your _object ID_.

- **Azure CLI**: `az ad user show --id john@contoso.com`
- **Azure PowerShell**: `Get-AzADUser -UserPrincipalName john@contoso.com`
- **Portal**: Select **Azure Active Directory** > **Tenant information** > **More info** > **Profile**.

## Notes

For more information, see [About Azure Key Vault](https://docs.microsoft.com/azure/key-vault/general/overview).
