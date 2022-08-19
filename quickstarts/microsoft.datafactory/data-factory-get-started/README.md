---
description: This template creates a data factory pipeline for a copy activity from Azure Blob into an Azure SQL Database
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: data-factory-blob-to-sql-copy
languages:
- json
---
# Create a Data Factory, Blob source, SQL sink and Pipeline

When you deploy this Azure Resource Template, a data factory is created with the following entities:

- Azure Storage linked service
- Azure SQL Database linked service
- Azure Blob dataset
- Pipeline with a copy activity

## Deploying sample
You can deploy this sample directly through the Azure Portal or by using the scripts supplied in the root of the repository.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button at the top of the article.

`Tags: Microsoft.DataFactory/datafactories, linkedservices, AzureStorage, datasets, AzureBlob, string, TextFormat, datapipelines, Copy, BlobSource, TabularTranslator`
