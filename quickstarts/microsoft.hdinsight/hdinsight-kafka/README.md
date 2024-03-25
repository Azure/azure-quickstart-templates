---
description: This template allows you to create an Azure Virtual Network and a Kafka on HDInsight cluster in the virtual network. The SSH authentication method for the cluster is username and password. For a template using SSH public key authentication, see https&#58;//learn.microsoft.com/samples/azure/azure-quickstart-templates/hdinsight-linux-ssh-publickey/
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: hdinsight-kafka
languages:
- bicep
- json
---
# Deploy Kafka on HDInsight in a virtual network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-kafka/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-kafka/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-kafka/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-kafka/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-kafka/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-kafka/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-kafka/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-kafka%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-kafka%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-kafka%2Fazuredeploy.json)

This template deploys a Kafka HDInsight cluster within an Azure Virtual Network. Azure Virtual Network allows you to extend your Hadoop solutions to incorporate resources such as multiple HDInsight cluster types, or to create secure private networks between resources in the cloud. The template creates a virtual network, a Kafka on HDInsight cluster, and an Azure Storage account.

To learn more about how to deploy the template, see the [quickstart](https://learn.microsoft.com/azure/hdinsight/kafka/apache-kafka-quickstart-resource-manager-template) article. If you're new to template deployment, see the [Azure Resource Manager documentation](https://learn.microsoft.com/azure/azure-resource-manager/).

`Tags: Standard_LRS, Microsoft.Storage/storageAccounts, Microsoft.HDInsight/clusters`
