# Deploying an Azure Web App with Managed Identity to access Key Vault and Azure Storage

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-webapp-storage-keyvault-msi%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-webapp-storage-keyvault-msi%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys an **Azure Web App** with an Azure AD managed identity that is granted permission to get secrets from **Azure Key Vault**. An **Azure Storage** account is created and its key is stored in the Azure Key Vault. The Azure Web App configuration is updated with the URL to Azure Key Vault and Azure Storage account, and a sample web application is deployed from GitHub.

## Solution overview and deployed resources
An Azure Storage account and Azure Key Vault are deployed, and the key for the storage account is stored as a secret in Azure Key Vault. 
An Azure Web App is deployed, and its managed identity is granted permission to the Azure Key Vault. The configuration for the 
Azure Web App is updated with the URL of the Azure Storage account and Azure Key Vault, and a sample application that
demonstrates using Azure Storage APIs to manage blobs is deployed.

The following resources are deployed as part of the solution:

#### Storage account

Deploys an LRS blob storage account using the Hot access tier.

#### Key Vault

New Azure Key Vault using Standard SKU. 

+ **secrets**: Stores the storage account key as a secret

#### Hosting Plan

Azure App Service hosting plan

#### Web App

Creates a new Azure Web App using the assigned hosting plan. Creates a system-assigned managed identity for the web app. 

+ **appsettings**: Updates the appSettings for the web application.
+ **sourceControls**: Deploys a sample web application.

#### Key Vault Access Policy

Updates the Azure Key Vault with an access policy allowing the managed identity of the Web App to get secrets from the Key Vault. 


## Deployment steps

Click the "Deploy to Azure" button at the beginning of this document. Once deployed, copy the URL for the web application and update the Azure Active Directory application registration with the Reply URL of the web app suffixed with `/signin-oidc`.

ex. `https://demo.azurewebsites.net/signin-oidc`

## Usage

#### Connect

Open a browser to the URL of the deployed Azure Web App. 
Sign in as a user from the Azure Active Directory tenant used to configure the application. 
Click the Manage Storage menu item in the web page to list, create, and delete blobs.

`Tags: Storage, KeyVault, AppService`