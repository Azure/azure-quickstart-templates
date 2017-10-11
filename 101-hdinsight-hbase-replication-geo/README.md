# Deploy a HDInsight HBase replication across two regions

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-geo%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-geo%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a HDInsight HBase replication with two virtual networks in two different regions and the VPN connections between the two VNets. After it is done, you need to configure static IP addresses for the Zookeeper nodes before you can enable HBase replication using script action. For more information, see [Configure HBase replication](https://docs.microsoft.com/azure/hdinsight/hdinsight-hbase-replication).

## Related templates

- [Deploy a HDInsight HBase cluster](https://azure.microsoft.com/resources/templates/101-hdinsight-hbase-linux/)
- [Deploy a HDInsight HBase cluster within a VNet](https://azure.microsoft.com/resources/templates/101-hdinsight-hbase-linux-vnet/)
- [Deploy a HDInsight HBase replication with the clusters in one VNet](https://azure.microsoft.com/resources/templates/101-hdinsight-hbase-replication-one-vnet/)
- [Deploy a HDInsight HBase replication with two VNets in one region](https://azure.microsoft.com/en-us/resources/templates/101-hdinsight-hbase-replication-two-vnets-same-region/)