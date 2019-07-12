# Deploy an HDInsight cluster using existing default storage account

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-linux-with-existing-linked-storage-account%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-linux-with-linked-default-storage-account%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an HDInsight cluster and the default storage account, and link to an existing storage account. This scenario shall be the most common usage case. 

In most cases, a blob container of an Azure storage account has been created. And the container has been uploaded with business data. You create an HDInsight cluster with a new storage account as the default storage account. The storage account with the business data is added to the cluster as a linked storage.  You can link the storage account at the creation time (as this template) or after the cluster is created (using script action).

You don't want to use the default storage account container for storing business data because:

- A default storage account container can't be shared by two HDInsight clusters at the same time.
- It is not recommended to reuse a blob container for multiple times. 

After you have completed your Hadoop jobs, you can safely delete the cluster and the default storage account. The business data is retained in the linked storage account.  Before you delete the default storage account, make sure to retrieve the logs.

If you want to create an HDInsight cluster with secure transfer enabled Azure storage accounts, make sure to use HDInsight version 3.6 or newer.  The default version is 3.5.  Only verion 3.6 or newer supports secure transfer enabled Azure Storage accounts.
