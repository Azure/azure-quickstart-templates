# Create HDInsight Linux Cluster and run Custom Script Action

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/hdinsight-linux-run-script-action/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/hdinsight-linux-run-script-action/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/hdinsight-linux-run-script-action/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/hdinsight-linux-run-script-action/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/hdinsight-linux-run-script-action/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/hdinsight-linux-run-script-action/CredScanResult.svg" />&nbsp;

Create HDInsight Linux Cluster and run Custom Script Action -<br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fhdinsight-linux-run-script-action%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhdinsight-linux-run-script-action%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

Template creates an HDInsight Linux cluster in a virtual network.<br />
Then custom script action is being executed on every node in the cluster.<br />
Default custom script sets the "myNodeType" environment variable on every node.<br />

