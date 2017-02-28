# Deploy a HDInsight HBase geo-repliction

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-geo%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-geon%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a geo-replicationed HDInsight HBase cluster. After it is done, you need to configure VPN and static IP addresses for the Zookeeper nodes before you can enable HBase replication using script action. For more information, see [Configure HBase replication](https://docs.microsoft.com/azure/hdinsight/hdinsight-hbase-replication).