---
description: This template allows you to create an HDInsight cluster running Linux with an empty edge node. For more information, see https&#58;//docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apps-use-edge-node
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: hdinsight-linux-with-edge-node
languages:
- json
---
# Deploy a HDInsight cluster with an edge node

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-edge-node/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-edge-node/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-edge-node/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-edge-node/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-edge-node/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-edge-node/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-linux-with-edge-node%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-linux-with-edge-node%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-linux-with-edge-node%2Fazuredeploy.json)

This template allows you to create a Linux-based HDInsight cluster and an empty edge node. An empty edgeNode is a Linux virtual machine with the same client tools installed and configured as in the headNode. You can use the edge node for accessing the cluster, testing your client applications, and hosting your client applications.

`Tags: Microsoft.Storage/storageAccounts, Microsoft.HDInsight/clusters, Microsoft.HDInsight/clusters/applications`
