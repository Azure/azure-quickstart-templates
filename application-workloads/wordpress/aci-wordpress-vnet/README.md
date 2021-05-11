# Create an Azure Container Instance with VNet
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/aci-wordpress-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Faci-wordpress-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Faci-wordpress-vnet%2Fazuredeploy.json)    

This template creates a WordPress website and its MySQL database on container instance in a virtual network. The WordPress site content and MySQL database are persistently stored on an Azure Storage File Share.
Also creates an Application gateway with WordPress container instance as Backend server. The application gateway exposes public network access to WordPress site in virtual network.

`Tags: Azure Container Instance, WordPress`

## Solution overview and deployed resources

The following resources are deployed as part of the solution

+ **Azure Container Instance**: Azure Container Instance to host the WordPress site.
+ **Azure Container Instance**: Azure Container Instance to host the MySQL database.
+ **Azure Container Instance**: A [run-once](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-restart-policy#container-restart-policy) Azure Container Instance, where the az-cli is executed to create the file shares
+ **Storage Account**: Storage account for the file shares to store the WordPress site content and MySQL database.
+ **File share**: Azure File shares to store WordPress site content and MySQL database.
+ **Application gateway**: Application gateway for WordPress site. It exposes public network access to WordPress site in VNet.
+ **Virtual network**: Virtual network for WordPress site, MySQL database, Application gateway.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo. 

#### Parameters:
+ **mysqlPassword**: The password to access the MySQL database.

## Usage

Use browser to access the SiteFQDN from output. WordPress will guide you through the rest of the setup.

## Notes
Azure Container Instance is available in selected [locations](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quotas#region-availability). Please use one of the available location for Azure Container Instance resource.
