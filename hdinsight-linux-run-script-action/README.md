# Create HDInsight Linux Cluster and run Custom Script Action

Create HDInsight Linux Cluster and run Custom Script Action -<br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fhdinsight-linux-run-script-action%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhdinsight-linux-run-script-action%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Template creates an HDInsight Linux cluster in a virtual network.<br />
Then custom script action is being executed on every node in the cluster.<br />
Default custom script sets the "myNodeType" environment variable on every node.<br />