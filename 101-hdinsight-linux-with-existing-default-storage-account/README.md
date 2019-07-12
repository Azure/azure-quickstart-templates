# Deploy an HDInsight cluster using existing default storage account

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-linux-with-existing-default-storage-account%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-linux-with-existing-default-storage-account%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an HDInsight cluster using an existing storage account as the default storage account. This scenario is not a typical usage case. This template is created for the <a href="https://docs.microsoft.com/azure/hdinsight/hdinsight-hadoop-create-linux-clusters-with-secure-transfer-storage">Create Hadoop cluster with secure transfer storage accounts in Azure HDInsight"</a> article.

In most cases, a blob container of an Azure storage account has been created. And the container has been uploaded with business data. You create an HDInsight cluster with a new storage account as the default storage account. The storage account with the business data is added to the cluster as a linked storage.  You can link the storage account at the creation time or after the cluster is created (using script action).

You don't want to use the default storage account container for storing business data because:

- A default storage account container can't be shared by two HDInsight clusters at the same time.
- It is not recommended to reuse a blob container for multiple times. 

If you want to create an HDInsight cluster with secure transfer enabled Azure storage accounts, make sure to use HDInsight version 3.6 or newer.  The default version is 3.5.  Only verion 3.6 or newer supports secure transfer enabled Azure Storage accounts.
