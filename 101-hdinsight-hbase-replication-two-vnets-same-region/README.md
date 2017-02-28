# Deploy a HDInsight HBase replication using two VNets in one region

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-two-vnets-same-region%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-two-vnets-same-region%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a HDInsight HBase replication with two virtual networks in the same region. After it is done, you need to configure static IP addresses for the Zookeeper nodes before you can enable HBase replication using script action. For more information, see [Configure HBase replication](https://docs.microsoft.com/azure/hdinsight/hdinsight-hbase-replication).