# Min.io Azure Gateway

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/minio/minio-azure-gateway/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/minio/minio-azure-gateway/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/minio/minio-azure-gateway/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/minio/minio-azure-gateway/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/minio/minio-azure-gateway/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/minio/minio-azure-gateway/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fminio%2Fminio-azure-gateway%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fminio%2Fminio-azure-gateway%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fminio%2Fminio-azure-gateway%2Fazuredeploy.json)


## Overview and deployed resources

This template deploys an AKS cluster running [min.io](https://min.io/) configured as an Azure storage gateway to provision a private S3 API into a VNET to enable the deployment of solutions which have a dependency on S3 object storage. 

The deployment provides the following:

+ Storage account with Private Endpoint
+ Private DNS zone to enable Private Link
+ AKS cluster with cluster autoscaler enabled
+ Installation of min.io Helm chart
+ Internal Standard Load Balancer exposing the min.io S3 endpoint

This is an overview of the solution

The following resources are deployed as part of the solution

### Storage

+ **min.io Storage Account**: Storage account backing the S3 endpoint presented by min.io
+ **Deployment Script Storage Account**: Storage account used as file share for deployment script resource, including inputs and logs

### Network

+ **Virtual Network**: Virtual Network within which all resources are provisioned
+ **Private Endpoint**: Private Endpoint to enable private access to min.io Storage Account
+ **Private Endpoint Network Interface**: Network Interface bound to Private Endpoint
+ **Private DNS Zone**: Private DNS zone to support private connectivity to Storage Account

### Compute

+ **AKS Cluster**: Managed Kubernetes cluster as runtime environment for min.io containers
+ **Azure Container Instance**: Container Instance used as Deployment Script runtime for installation of min.io

### Identity

+ **Managed Identity**: Managed Identity bound to Deployment Script resource
+ **Role Assignment**: Provides roles required for execution of Deployment Script

## Prerequisites

An Azure subscription with available compute quota to deploy the AKS cluster

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.


## Usage

The deployment contains an output which provides the private IP address of the S3 endpoint.  This API requires the storage account name and key for authentication.

### Connect

As connectivity to the min.io service is fully private within the VNET, you must follow these steps to access the min.io web UI from your client device:

+ Use the Azure CLI to [obtain the storage account key](https://docs.microsoft.com/en-us/cli/azure/storage/account/keys?view=azure-cli-latest#az_storage_account_keys_list)
+ Use the Azure CLI to [authenticate with the AKS cluster](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_get_credentials)
+ Execute **kubectl get pods** and capture one of the pod names, such as **minio-55c5f4ccd5-7t9t7**
+ Execute **kubectl port-forward [pod name] 9000** to establish a tunnel to the pod
+ Browse to http://localhost:9000 to access the web UI
+ Use the storage account name and key to authenticate with the web UI

`Tags: splunk, min.io, minio, smartstore, s3`
