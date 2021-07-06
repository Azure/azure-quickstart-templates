# Datalake on Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/yash-datalake/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/yash-datalake/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/yash-datalake/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/yash-datalake/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/yash-datalake/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datalakestore/yash-datalake/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datalakestore%2Fyash-datalake%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datalakestore%2Fyash-datalake%2Fazuredeploy.json)

## Overview

The aim of the Yash Azure quickstart solution is to showcase the capabilities of serverless Data Lake in the Azure Cloud.

- Yash Data Lake in Azure Cloud showcases features such as
  - Data Ingestion
    - Batch
    - Streaming
  - Data Processing
    - Batch
    - Real Time
  - Data Governance
    - Meta data management
    - Data Lineage
    - Data Security
    - Ad-Hoc analytics for exploring different data insights and visualization

The deployment also includes an optional wizard and a sample dataset that is used to demonstrate data lake capabilities

![alt text](https://raw.githubusercontent.com/ajos1993/YASH-Azure-DataLake-Quickstart/master/scripts/images/Architecture.png)

## Pre-Requisites

- Register application in AAD with the following steps and note the application id and app secret key:
  1. Assign following permissions:-
    -Azure Data Lake
    -Azure Analysis Services
  2. Set Reply URL :https://your-function-app-name.azurewebsites.net/.auth/login/aad/callback
    [Note = your-function-app-name : The function name which you would be giving while deploying Yash Data Lake]
- Add following permissions to Application registered in AAD :
  1. Azure Analysis Services
  2. Azure Data Lake
  3. Windows Azure Active Directory

- Add Application in IAM of subscription.

- Open Elasticsearch function app to load data to Elasticsearch for first time

--------------------------------------------------------------------------
The following section provide steps for running the Quickstart.

## Run and monitor the deployment

After you deploy the template, to run Quickstart, do the following steps:

- Go to the Output section of ARM template deployment services.
- Copy URL from output section.
- Open this URL in new tab
- After successful deployment do the following steps,
  1.Add Application and user in IAM of ADL store and in data explorer access.
  2.Add application and user in IAM of Azure Data Factory.
- After completing the above procedure return to the tab and follow the quickstart guide
