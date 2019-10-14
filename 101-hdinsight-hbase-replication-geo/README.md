# Deploy a HDInsight HBase replication across two regions

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-hdinsight-hbase-replication-geo/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-hdinsight-hbase-replication-geo/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-hdinsight-hbase-replication-geo/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-hdinsight-hbase-replication-geo/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-hdinsight-hbase-replication-geo/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-hdinsight-hbase-replication-geo/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-geo%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-hbase-replication-geo%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to create an Azure environment for HBase replication.  The template creates two virtual networks in two different regions, the VPN connections between the two VNets, and two Ubuntu virtual machines to be used as DNS servers. After it is done, you need to install and configure the BIND DNS services, install HBase clusters and enable replication. For more information, see [Configure HBase replication](https://docs.microsoft.com/azure/hdinsight/hdinsight-hbase-replication).

## Related templates

- [Deploy a HDInsight HBase cluster](https://azure.microsoft.com/resources/templates/101-hdinsight-hbase-linux/)
- [Deploy a HDInsight HBase cluster within a VNet](https://azure.microsoft.com/resources/templates/101-hdinsight-hbase-linux-vnet/)
- [Deploy a HDInsight HBase replication with the clusters in one VNet](https://azure.microsoft.com/resources/templates/101-hdinsight-hbase-replication-one-vnet/)
- [Deploy a HDInsight HBase replication with two VNets in one region](https://azure.microsoft.com/en-us/resources/templates/101-hdinsight-hbase-replication-two-vnets-same-region/)

