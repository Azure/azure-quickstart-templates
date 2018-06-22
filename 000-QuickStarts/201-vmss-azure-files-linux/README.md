# Azure Files template for VM scale sets

This template demonstrates using Azure File with virtual machine scale sets on Ubuntu. Every VM in this scale set will have a mounted Azure Files file share at the location you specify, and a symbolic link will also be created in the user's home directory.

## Prerequisites
In order to run this template you need to create a storage account and file share in advance, which you will pass in as parameters. This template expects the following parameters (in addition to scale set name, capacity etc.):
1. Storage Account Name
2. Storage Account Key
3. File Share Name
4. Mount point

## Step1: To create an Azure Storage Account
* [How to create a Storage Account](https://docs.microsoft.com/en-us/azure/storage/storage-create-storage-account#create-a-storage-account)
* [How to create Azure File Share](https://docs.microsoft.com/en-us/azure/storage/storage-dotnet-how-to-use-files#use-the-azure-portal-to-manage-a-file-share)

## Step 2: Run this template with parameters

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-azure-files-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-azure-files-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
