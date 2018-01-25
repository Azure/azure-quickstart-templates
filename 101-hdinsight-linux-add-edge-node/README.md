# Deploy an empty edge node to a HDInsight cluster.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-linux-add-edge-node%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-hdinsight-linux-add-edge-node%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to add an empty edge node to an existing HDInsight cluster . An empty edge node is a Linux virtual machine with the same client tools installed and configured as in the headnodes. You can use the edge node for accessing the cluster, testing your client applications, and hosting your client applications. 

The empty edge node virtual machine size must meet the worker node vm size requirements. The worker node vm size requirements are different from region to region. For more information, see Create HDInsight clusters.

The template uses a simple "dummy" script to simulate application installation and prepare a clean empty edgenode and attach it to the cluster.

For more information about creating and using edge node, see <a href="https://docs.microsoft.com/azure/hdinsight/hdinsight-apps-use-edge-node">Use empty edge nodes in HDInsight</a>