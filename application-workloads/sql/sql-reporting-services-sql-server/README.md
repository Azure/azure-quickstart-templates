# Create a new SSRS Server with a SQL catalog (2 Machines) 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-reporting-services-sql-server/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-reporting-services-sql-server/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-reporting-services-sql-server/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-reporting-services-sql-server/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-reporting-services-sql-server/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sql-reporting-services-sql-server/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsql-reporting-services-sql-server%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsql-reporting-services-sql-server%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsql-reporting-services-sql-server%2Fazuredeploy.json)   

This template creates two new Azure VMs, each with a public IP address, it configures one VM to be an SSRS Server, one with SQL Server mixed auth for the SSRS Catalog with the SQL Agent Started. All VMs have public facing RDP and diagnostics enabled , the diagnostics is stored in a consolidated diagnostics storage account different than the vm disk
 
By Default it will create the SQL machines using the image ***SQL2014SP1-WS2012R2*** and the ***Enterprise*** sku, the full list of available images and their SKUs can be obtained running

    Get-AzureRmVMImageOffer -Location "westus" -Publisher "MicrosoftSQLServer" | Select Offer
    Get-AzureRmVMImageSku -Location "westus"-Publisher "MicrosoftSQLServer" -Offer "SQL2014SP1-WS2012R2" | Select Skus

For example
* **sqlImageVersion:** SQL2014SP1-WS2012R2 **sku:** Enterprise 
* **sqlImageVersion:** SQL2016RC1-WS2012R2 **sku:** Evaluation

***For CTP Versions of SQL the only SKU available is Evaluation*** 

***
It contains a modified version of xSQLServerRSConfig that supports machines that are non domain join and uses SQL authentication for connecting SSRS with the database 
based on the DSC package http://www.powershellgallery.com/packages/xSQLServer/1.4.0.0.

It contains the DSC scripts from https://sqlvmgroup.blob.core.windows.net/singlevm/PrepareSqlServer.ps1.zip used by the Azure marketplace to create SQL Machines

        


