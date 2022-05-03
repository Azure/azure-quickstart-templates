# Deploy Azure Cloud Shell storage to a virtual network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/cloud-shell-vnet-storage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/cloud-shell-vnet-storage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/cloud-shell-vnet-storage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/cloud-shell-vnet-storage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/cloud-shell-vnet-storage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/cloud-shell-vnet-storage/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcloud-shell-vnet-storage%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcloud-shell-vnet-storage%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcloud-shell-vnet-storage%2Fazuredeploy.json)

This template deploys the necessary storage to run Azure Cloud Shell inside a customer owned virtual network. Azure Cloud Shell is a browser-based, authenticated, command-line experience based in the Azure Portal for managing cloud resources. Running Cloud Shell in a customer virtual network allows the customer to manage resources that may be isolated from the public internet in a private virtual network. For more information, view our documentation: https://aka.ms/cloudshell/docs/vnet.

## Prerequisites

In order to use this deployment there must be an existing resource group and a virtual network. Most users will already have a deesired resource group and virtual network they would like to connect to. If these resources do not exist, they must be created prior to running this template. Both the resource group and the virtual network must be in the same location.
Important! While this functionality is in preview, only the following locations may be used: WestCentralUS, WestUS 

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

After deploying this template and the 101-cloud-shell-vnet template, navigate to Cloud Shell in the Azure Portal or on shell.azure.com.
If Cloud Shell has been used in the past, the existing clouddrive must be unmounted. To do this run `clouddrive unmount` from an active Cloud Shell session.
Reconnect to Cloud Shell, you will be prompted with the first run experience. Select your preferred shell experience, then navigate to the advanced settings and select the show isolated VNET settings box. Fill in the fields with the desired resources create with this template.
