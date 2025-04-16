---
description: This template allows you to create SQL server in Azure with the Azure AD admin set and Azure AD-only authentication feature enabled.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sql-logical-server-aad-only-auth
languages:
- json
---
# SQL server with Azure AD-only authentication.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-logical-server-aad-only-auth/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-logical-server-aad-only-auth/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-logical-server-aad-only-auth/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-logical-server-aad-only-auth/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-logical-server-aad-only-auth/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-logical-server-aad-only-auth/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-logical-server-aad-only-auth%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-logical-server-aad-only-auth%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-logical-server-aad-only-auth%2Fazuredeploy.json)

This template allows you to create an [Azure SQL logical server](https://docs.microsoft.com/azure/sql-database/sql-database-logical-servers) with [Azure AD-only authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication) enabled.

`Tags: Azure, SQL logical server, Azure AD-only authentication, Microsoft.Sql/servers`

## Deployment steps

- Click the **Deploy to Azure** button and fill in the parameters to deploy a sample Azure SQL logical server with [Azure AD-only authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication) enabled.
- An Azure AD admin will need to be set in order to enable [Azure AD-only authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication).
- Choose an Azure AD admin for the deployment. You will find the user Object ID by going to the [Azure portal](https://portal.azure.com) and navigating to your **Azure Active Directory** resource. Under **Manage**, select **Users**. Search for the user you want to set as the Azure AD admin for your Azure SQL server. Select the user, and under their **Profile** page, you will see the **Object ID**.
- The Tenant ID can be found in the **Overview** page of your **Azure Active Directory** resource.
