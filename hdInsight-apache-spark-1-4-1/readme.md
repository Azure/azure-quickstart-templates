# Create HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1
Creates HDInsight Linux cluster and run custom script action to install Apache Spark 1.4.1<br>

This template creates an HDInsight Linux based cluster and then updates the cluster headnodes with the Apache Spark 1.4.1 binaries(including YARN support).<br>
Additionally, it sets specific environment variables ($SPARK_HOME, updates $PATH) to allow for easy access to the Spark client binaries.<br>
<br>
Please be sure to utlize appropriate Spark core, memory, and executor settings based on your chosen deployment size.
