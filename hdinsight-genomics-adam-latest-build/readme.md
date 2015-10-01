# Create HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1
Creates HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1<br>

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FExchMaster%2Fazure-quickstart-templates%2Fmaster%2Fhdinsight-genomics-adam-latest-build%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates an HDInsight Linux based cluster and then updates the cluster headnodes with the genomics analysis platoform ADAM.  It also deploys Apache Spark 1.4.1 with YARN in support of the platform.<br>
Additionally, it sets specific environment variables ($SPARK_HOME, updates $PATH) to allow for easy access to the Spark client binaries.<br>
<br>



