# Copy multiple tables in bulk by using Azure Data Factory

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-azure-sql-database-to-sql-data-warehouse-copy/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-azure-sql-database-to-sql-data-warehouse-copy/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-azure-sql-database-to-sql-data-warehouse-copy/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-azure-sql-database-to-sql-data-warehouse-copy/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-azure-sql-database-to-sql-data-warehouse-copy/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-v2-azure-sql-database-to-sql-data-warehouse-copy/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-azure-sql-database-to-sql-data-warehouse-copy%2Fazuredeploy.json)
[![Deploy to Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-azure-sql-database-to-sql-data-warehouse-copy%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-v2-azure-sql-database-to-sql-data-warehouse-copy%2Fazuredeploy.json)

This template creates a data factory that copies a number of tables from Azure SQL Database to Azure SQL Data Warehouse. 

When you deploy this Azure Resource Manager template, a data factory of version 2 is created with the following entities: 

- Azure Storage linked service
- Azure SQL Database linked service
- Azure Blob input datasets
- Azure SQL Datbase output dataset
- Pipeline with a copy activity

## Prerequisites
The prerequisites for this template are mentioned in the [Tutorial: Copy multiple tables in bulk by using Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-bulk-copy-portal) article.

The template creates the Azure SQL database that's based on the Adventure Works LT sample template. It also creates a SQL data warehouse. You need to use the Migration Utility to migrate schema from the SQL database to the SQL data warehouse. 

## Next steps
1. Click the **Deployment succeeded** message.
2. Click **Go to resource group**.
3. Search for *datafactory that's created. Click the data factory in the list to launch the home page for the data factory.
5. Click **Author & Monitor** tile to launch the Data Factory UI in a separate tab. 
6. Follow instructions in the [tutorial](https://docs.microsoft.com/en-us/azure/data-factory/tutorial-bulk-copy-portal#trigger-a-pipeline-run) article to run and monitor the pipeline. 



