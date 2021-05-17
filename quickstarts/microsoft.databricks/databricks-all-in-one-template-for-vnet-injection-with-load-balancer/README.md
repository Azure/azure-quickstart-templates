# Deploy a Load Balancer, Network Security Group, a Virtual Network and an Azure Databricks Workspace with the Virtual Network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-with-load-balancer/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-with-load-balancer/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-with-load-balancer/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-with-load-balancer/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-with-load-balancer/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-with-load-balancer/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-vnet-injection-with-load-balancer%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-vnet-injection-with-load-balancer%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-vnet-injection-with-load-balancer%2Fazuredeploy.json)

This template allows you to create a network security group, a virtual network and an Azure Databricks workspace with the virtual network.
For more information, see the [Azure Databricks Documentation](https://docs.microsoft.com/en-us/azure/azure-databricks/).

### What is Azure Databricks?

Azure Databricks is an Apache Spark-based analytics platform optimized for the Microsoft Azure cloud services platform. Designed with the founders of Apache Spark, Databricks is integrated with Azure to provide one-click setup, streamlined workflows, and an interactive workspace that enables collaboration between data scientists, data engineers, and business analysts.

Azure Databricks is a fast, easy, and collaborative Apache Spark-based analytics service. For a big data pipeline, the data (raw or structured) is ingested into Azure through Azure Data Factory in batches, or streamed near real-time using Kafka, Event Hub, or IoT Hub. This data lands in a data lake for long term persisted storage, in Azure Blob Storage or Azure Data Lake Storage. As part of your analytics workflow, use Azure Databricks to read data from multiple data sources such as Azure Blob Storage, Azure Data Lake Storage, Azure Cosmos DB, or Azure SQL Data Warehouse and turn it into breakthrough insights using Spark.

This template allows you to install the following options

+ DataBricks 14 day trial
+ DataBricks Standard
+ DataBricks Premium

### DataBricks Resources

[Getting Started with DataBricks](https://docs.microsoft.com/en-us/azure/databricks/getting-started/index)
[Data Bricks Admin Guide](https://docs.azuredatabricks.net/administration-guide/index.html)
[Quickstart: Create an Azure Databricks workspace by using an ARM template](https://docs.microsoft.com/azure/databricks/scenarios/quickstart-create-databricks-workspace-resource-manager-template)

### Microsoft Learn Modules

[Data Bricks Microsoft Learn Modules](https://docs.microsoft.com/en-us/learn/browse/?term=Databricks)

## The Template

Don't let the size of the template scares you. The structure is very intuitive and once that you get the gist of it, you will see how much easier your life will be deploying resources to Azure.

These are the parameters on the template, most of them already have values inserted, the ones that you need to inform are: **adminUsername**, **adminPassword** and **resourceGroup**.

Parameter         | Suggested value     | Description
:--------------- | :-------------      |:---------------------
**WorkspaceName** |  | The name of your DataBricks Workspace.
**Pricing Tier** | 14 Day Trial, Standard or Premium
**Resource Group** The Resource Group which you wish to deploy your DataBricks Environment. 
**Disable Public Ip** | Default is false | Set this to true to disable Public IP address

All the other parameters can be left as default.

+ **Nsg Name** Name of the network Security Group
+ **Vnet Name** Name of the Virtual Network
+ **Private Subnet Name** Name of the Private Subnet
+ **Public Subnet Name** Name of the Public Subnet
+ **Location** Location of Data Center
+ **Vnet Cidr** Cidr Range of the Vnet
+ **Private Subnet Cidr** Cidr Range of the Private Subnet
+ **Public Subnet Cidr** Cidr Range of the Public Subnet
+ **Load Balancer Backend Pool Name** Name of the Backend Pool of the Load Balancer
+ **Load Balancer Frontend Config Name** Name of the Frontend Load Balancer configuration
+ **Load Balancer Name** Name of the Load Balancer
+ **Load Balancer Public IP Name** Name of the outbound Load Balancer Public IP
