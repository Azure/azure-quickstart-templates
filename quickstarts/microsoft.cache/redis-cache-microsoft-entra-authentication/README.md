---
description: This template creates a Redis Cache. Then assigns a built-in access policy to a redis user. Then creates a custom access policy. And then assigns the custom access policy to another Redis user.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: redis-cache-microsoft-entra-authentication
languages:
- bicep
- json
---
# Create a Redis Cache with Microsoft Entra Authentication.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cache%2Fredis-cache-microsoft-entra-authentication%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cache%2Fredis-cache-microsoft-entra-authentication%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cache%2Fredis-cache-microsoft-entra-authentication%2Fazuredeploy.json)

Create an Azure Cache for Redis instance with Microsoft Entra authentication using a template. Microsoft Entra authentication allows you to use Microsoft Entra authentication to access data in your Azure Cache for Redis instance using Microsoft Entra Service Principal, Managed Identity or User Principal based on configuration. This template also creates custom access policy and assigns two Microsoft Entra principals to a built-in access policy and the created custom access policy. Hence, to use this template, keep two different Microsoft Entra Service Principals or Managed Identities or User Principals ready which ever combination you prefer to use.

> [!IMPORTANT]
>
> If you are applying multiple access policies, they must be deployed serially. In this sample, that is done by setting one assignment as dependent on the other with `dependsOn`. If you are using a loop to add multiple assignments, use [`@batchSize(1)`](https://learn.microsoft.com/azure/azure-resource-manager/bicep/loops#deploy-in-batches) annotation to ensure only one assignment is deployed at a time.

For information about using this template, see [Create an Azure Cache for Redis using an ARM template](https://azure.microsoft.com/documentation/articles/cache-redis-cache-arm-provision/), [Configure role based data access control in Azure Ache for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-configure-role-based-access-control#permissions-for-your-data-access-policy), [Use Microsoft Entra Authentication in Azure Cache for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication), [Create Microsoft Entra Application and Service Principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and [Learn about Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/).

`Tags: Microsoft.Cache/redis, Microsoft.Cache/redis/accessPolicies, Microsoft.Cache/redis/accessPolicyAssignments`
