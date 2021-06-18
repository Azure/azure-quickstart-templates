# Deploy an HDInsight cluster using existing default storage account

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-existing-default-storage-account/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-existing-default-storage-account/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-existing-default-storage-account/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-existing-default-storage-account/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-existing-default-storage-account/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.hdinsight/hdinsight-linux-with-existing-default-storage-account/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-linux-with-existing-default-storage-account%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-linux-with-existing-default-storage-account%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.hdinsight%2Fhdinsight-linux-with-existing-default-storage-account%2Fazuredeploy.json)

This template allows you to create an HDInsight cluster using an existing storage account as the default storage account. This scenario is not a typical usage case. This template is created for the [Create Hadoop cluster with secure transfer storage accounts in Azure HDInsight](https://docs.microsoft.com/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-with-secure-transfer-storage) article.

In most cases, a blob container of an Azure storage account has been created. And the container has been uploaded with business data. You create an HDInsight cluster with a new storage account as the default storage account. The storage account with the business data is added to the cluster as a linked storage.  You can link the storage account at the creation time or after the cluster is created (using script action).

You don't want to use the default storage account container for storing business data because:

- A default storage account container can't be shared by two HDInsight clusters at the same time.
- It is not recommended to reuse a blob container for multiple times.

If you want to create an HDInsight cluster with secure transfer enabled Azure storage accounts, make sure to use HDInsight version 3.6 or newer.  The default version is 3.5.  Only version 3.6 or newer supports secure transfer enabled Azure Storage accounts.