

# Provision a Spark 2.0 Cluster on Suse Linux Enterprise Server

This template creates a Spark 2.0 Cluster on SUSE Linux Enterprise Server.  This is a starting point for learning Spark and in-memory computation on SUSE’s enterprise linux distribution.

In Memory Cluster Computing to solve query optimization, slow Machine Learning and many other BI problems.

To master this template and Spark 2.0 on SUSE Linux Enterprise Server you can leverage hands on workshop from [Value Amplify](http://www.valueamplify.com) 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspark-2.0-on-suse%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspark-2.0-on-suse%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

### To deploy this sample using a script in the root of this repo

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory 'spark-2.0-on-suse' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a 'spark-2.0-on-suse' -l eastus -u
```
This template deploys a **spark-2.0-on-suse** infrastructure. The **spark-2.0-on-suse** template is a Spark 2.0 environment based on Spark Standalone Cluster Manager; the template setup one master node and N worker nodes installing and configuring Spark 2.0.
Details about installation are available on all the nodes under /tmp/ director


## Solution overview and deployed resources

This template deploys a **spark-2.0-on-suse** infrastructure. The **spark-2.0-on-suse** is a Spark 2.0 environment based on Spark Standalone Cluster Manager; the template setup 1 master node and N worker nodes installing and configuring spark.
Spark Master is accessible using a dedicated public IP (resource **sparkMasterPublicIP**): from here you can connect via **spark-shell** or **spark-submit**
Details about installation are available on all the nodes under /tmp/ directory.

The following resources are deployed as part of the solution

#### Virtual network

The internal network that delimits the cluster environment

#### Storage Account

The storage account associated to the cluster for, automatically referenced on Spark using **wasb://** address

#### Virtual Machine

VMs will be used as spark master or N-th worker on the cluster

+ **sparkmaster**: The master node from the cluster
+ **sparkslave[i]**: the i-th worker node of the cluster

#### Network Interface Card

+ **ni_master/nislave[i]**: master and worker network interfaces

#### Public IP

+ **sparkMasterPublicIP**: the public IP of the master node

#### Custom Script Example

+ **configuresparkonmaster/slave[i]**: The bash script that will install and configure the Spark 2.0 cluster

#### Network Security group

+ **ns_spark**: The network security group for the Spark Cluster


## Usage

#### Launch Spark 2.0 Application from local machine

From your local machine (take care of Spark version, use 2.0) you can run the following command

```bash
spark-shell --master=spark://YOUR_MASTER_PUBLIC_IP:7077
```

#### Launch Spark 2.0 Application from master VM

Connect with ssh to your master node using username and password provided at deploy time
```bash
ssh yourusername@YOUR_MASTER_PUBLIC_IP
```

Then you can run spark-shell using a predefined and pre-configured **spark** user account (spark master and other conf are already configured on the cluster)

```bash
sudo su spark
cd /home/spark
spark-shell
```

#### Management

You can see how application are executed consulting Spark Web UI at **http://YOUR_MASTER_PUBLIC_IP:8080**

If running application on sparkmaster you can reach Spark Application UI at **http://YOUR_MASTER_PUBLIC_IP:4040**


#### Different Artifact Location

The Artifact Location Parameters points to the place where artifact are located (scripts, data, etc.. etc..)

You would use for instance a "work in progress" github location; you can specify it when providing template parameters
<pre>
artifactsLocation -> https://raw.githubusercontent.com/valueamplify/azure-quickstart-templates/fixsetupscripts/spark-2.0-on-suse/
</pre>

#### Azure Blob Storage

This spark standalone cluster is already bound to the Azure Blob Storage Account created with the cluster.

You can use a tool such as [Microsoft Azure Storage Explorer](http://storageexplorer.com) to connect and create a specific container for your data.

Then you can access your data from spark using

<pre>
val data = sc.textFiles("wasb://YOUR_CONTAINER_NAME@YOUR_STORAGE_ACCOUNT_NAME.blob.core.windows.net/text.txt")
data.count
</pre>

## Notes

Spark 2.0 logs are provided under **/srv/spark/logs** directory

You can see on VM Spark 2.0 processes running

<pre>
sudo jps -l -m
<pre>