# HDInsight (custom Ambari + Hive Metastore DB with existing SQL Sever, storage account, vnet)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-custom-ambari-db%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhdinsight-custom-ambari-db%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an HDInsight cluster in an existing virtual network with a new S2 SQL DB that serves as both a custom Ambari DB and Hive Metastore. This assumes you have an exising SQL Sever, storage account, and VNET.
