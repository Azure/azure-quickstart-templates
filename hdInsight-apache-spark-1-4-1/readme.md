# Create HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1
Creates HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1<br>

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FExchMaster%2Fazure-quickstart-templates%2Fmaster%2FhdInsight-apache-spark-1-4-1%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates an HDInsight Linux based cluster and then updates the cluster headnodes with the Apache Spark 1.4.1 binaries(including YARN support).<br>
Additionally, it sets specific environment variables ($SPARK_HOME, updates $PATH) to allow for easy access to the Spark client binaries.<br>
<br>
Please be sure to utlize appropriate Spark core, memory, and executor settings based on your chosen deployment size.<Br>

To launch Spark interactivly, please SSH into the cluster (<clustername>-ssh.azurehdinsight.net) and execute the following commands:<br>

Sudo -i<Br>
$SPARK_HOME/bin/spark-shell<br>

You should see output similar to the following:<br>


15/10/01 15:21:34 INFO util.Utils: Successfully started service 'HTTP class server' on port 47985.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 1.4.1
      /_/

Using Scala version 2.10.4 (OpenJDK 64-Bit Server VM, Java 1.7.0_79)
Type in expressions to have them evaluated.
Type :help for more information.
15/10/01 15:21:40 INFO spark.SparkContext: Running Spark version 1.4.1


