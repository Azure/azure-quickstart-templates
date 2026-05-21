# Simple Storage Account

This template creates a basic Azure Storage Account.

## Parameters

| Name | Description | Default |
|------|-------------|---------|
| location | Location for the storage account | Resource group location |
| storageAccountName | Name of the storage account | Auto-generated |

## Usage

Deploy using Azure CLI:

```bash
az deployment group create --resource-group myRG --template-file main.bicep
```
