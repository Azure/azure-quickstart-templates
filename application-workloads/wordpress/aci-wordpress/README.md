# Create a WordPress site on a Container Instance

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Faci-wordpress%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Faci-wordpress%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Faci-wordpress%2Fazuredeploy.json)

Create a WordPress site (and its MySQL database) on a Container Instance

This template creates a WordPress website and its MySQL database on a Container Instance. The WordPress site content and MySQL database are persistently stored on an Azure Storage File Share.

`Tags: Azure Container Instance, WordPress`

## Solution overview and deployed resources

The following resources are deployed as part of the solution

+ **Azure Container Instance**: Azure Container Instance to host the WordPress site and the MySQL database.
+ **Azure Container Instance**: A [run-once](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-restart-policy#container-restart-policy) Azure Container Instance, where the az-cli is executed to create the file shares
+ **Storage Account**: Storage account for the file shares to store the WordPress site content and MySQL database
+ **File share**: Azure File shares to store WordPress site content and MySQL database.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo. 

#### Parameters:
+ **siteName**: The site name, the first segment of the WordPress site FQDN (e.g.  **`mywordpress`**`.westus.azurecontainer.io`)
+ **mysqlPassword**: The password to access the MySQL database.

#### Output:
+ **siteFQDN**: The WordPress site FQDN (e.g.  `mywordpress.westus.azurecontainer.io`)

## Usage

Use browser to access the site FQDN from deployment output. WordPress will guide you through the rest of the setup.

## Notes
Azure Container Instance is available in selected [locations](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quotas#region-availability). Please use one of the available location for Azure Container Instance resource.
