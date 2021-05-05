# Create HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/hdinsight-apache-spark/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/hdinsight-apache-spark/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/hdinsight-apache-spark/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/hdinsight-apache-spark/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/hdinsight-apache-spark/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/hdinsight-apache-spark/CredScanResult.svg)
Creates HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1<br>

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fspark%2Fhdinsight-apache-spark%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fspark%2Fhdinsight-apache-spark%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fspark%2Fhdinsight-apache-spark%2Fazuredeploy.json)

This template creates an HDInsight Linux based cluster and then updates the cluster headnodes with the Apache Spark 1.4.1 binaries(including YARN support).<br>
Additionally, it sets specific environment variables ($SPARK_HOME, updates $PATH) to allow for easy access to the Spark client binaries.<br>
<br>
Please be sure to utlize appropriate Spark core, memory, and executor settings based on your chosen deployment size.<Br>

To launch Spark interactivly, please SSH into the cluster (clustername-ssh.azurehdinsight.net) and execute the following commands:<br>

Sudo -i<Br>
$SPARK_HOME/bin/spark-shell<br>

You should see output similar to the following:<br>
<br>
15/10/01 15:21:34 INFO util.Utils: Successfully started service 'HTTP class server' on port 47985.<br>
Welcome to version 1.4.1<br>
<br>
Using Scala version 2.10.4 (OpenJDK 64-Bit Server VM, Java 1.7.0_79)<br>
Type in expressions to have them evaluated.<br>
Type :help for more information.<br>
15/10/01 15:21:40 INFO spark.SparkContext: <b>Running Spark version 1.4.1</b><br>
<br>...Output Snipped...<br><br>
scala>

To deploy alternative versions of Apache Spark as published by the HDInsight team, please review follow this link: <a href="https://azure.microsoft.com/en-us/documentation/articles/hdinsight-hadoop-customize-cluster-linux/" target="_blank"><b>Click Me</b>




