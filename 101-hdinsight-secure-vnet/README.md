# Deploy an Azure VNet and an HDInsight Hadoop cluster within the VNet

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-secure-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-secure-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an secure Azure VNet and a HDInsight cluster within the VNet. Azure Virtual Network allows you to extend your Hadoop solutions to incorporate on-premises resources such as SQL Server, combine multiple HDInsight cluster types, or to create secure private networks between resources in the cloud. The template creates a network security group (including the inbound security rules), a virtual network, an HDInsight Hadoop cluster and the default storage account. Please note the rules are "all other regions" listed in Extend HDInsight capabilities by using Azure Virtual Network( https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-extend-hadoop-virtual-network). You can either use a region other than Brazil South, Canada East, Canada Central, West Central US, and West US 2, or modify the IP addresses defined in the rules.