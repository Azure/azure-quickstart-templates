# Install a Spark cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspark-ubuntu-multidisks%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspark-ubuntu-multidisks%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Apache Spark is a fast and general engine for large-scale data processing.
Spark has an advanced DAG execution engine that supports cyclic data flow and in-memory computing.

This template deploys a Spark cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.
The template also creates 1 publicly accessible VM acting as a "jumpbox" and allowing to ssh into the Spark nodes for diagnostics or troubleshooting purposes.

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Database VM Size | CPU Cores | Memory | Data Disks | # of Secondaries | # of Storage Accounts |
|:--- |:---|:---|:---|:---|:---|:---|:---|:---|
| Small | Standard_A1 | 1 |1.75 GB | 2x1023 GB | 1 | 1 |
| Medium | Standard_A3 | 4 | 7 GB | 8x1023 GB | 1 | 2 |
| Large | Standard_A4 | 8 | 14 GB | 16x1023 GB | 2 | 2 |
| XLarge | Standard_A4 | 8 | 14 GB | 16x1023 GB | 3 | 4 |

How to Run the scripts
----------------------

You can use the Deploy to Azure button or use the below methor with powershell

Creating a new deployment with powershell:

Remember to set your Username, Password and Unique Storage Account name in azuredeploy-parameters.json

Create a resource group:

    PS C:\Users\azureuser1> New-AzureResourceGroup -Name "AZKFRGSPARKEA3" -Location 'EastAsia'

Start deployment

    PS C:\Users\azureuser1> New-AzureResourceGroupDeployment -Name AZKFRGSPARKV2DEP1 -ResourceGroupName "AZKFRGSPARKEA3" -TemplateFile C:\gitsrc\azure-quickstart-templates\spark-ubuntu-multidisks\azuredeploy.json -TemplateParameterFile C:\gitsrc\azure-quickstart-templates\spark-ubuntu-multidisks\azuredeploy-parameters.json -Verbose

    On successful deployment results will be like this
	DeploymentName    : AZKFRGSPARKV2DEP1
	ResourceGroupName : AZKFRGSPARKEA1
	ProvisioningState : Succeeded
	Timestamp         : 4/28/2015 11:36:27 PM
	Mode              : Incremental
	TemplateLink      :
	Parameters        :
			    Name             Type                       Value
			    ===============  =========================  ==========
			    region           String                     West US
			    storageAccountNamePrefix  String                     cgnsparkstorev1
			    domainName       String                     cgnsparkv1
			    adminUsername    String                     adminuser
			    adminPassword    SecureString
			    tshirtSize       String                     Small
			    sparkversion     String                     1.2.1
			    jumpbox          String                     Enabled
			    virtualNetworkName  String                     vnet

Check Deployment
----------------
To access the individual Spark nodes, you need to use the publicly accessible jumpbox VM and ssh from it into the VM instances running Spark.

To get started connect to the public ip of Jumpbox with username and password provided during deployment.
From the jumpbox connect to any of the Spark workers eg: ssh 10.0.0.5 ,ssh 10.0.0.6, etc.
Run the command ps-ef|grep spark to check that kafka process is running ok.
To connect to master node you can use ssh 10.0.0.4

To access spark shell:

cd /usr/local/spark/bin/

sudo ./spark-shell

Topology
--------

The deployment topology is comprised of Master and Slave Instance nodes running in the cluster mode.
Spark version 1.2.1 is the default version and can be changed to any pre-built binaries avaiable on Spark repo.
There is also a provision in the script to uncomment the build from source.

Assuming your domainName parameter was "mypsqljumpbox" and region was "West US"
* Master Spark server will be deployed at the first available IP address in the subnet: 10.0.1.4
* Slave Spark servers will be deployed in the other IP addresses: 10.0.1.5, 10.0.1.6, 10.0.1.7, etc.
* From your computer, SSH into the jumpbox `ssh sparkjumpbox.westus.cloudapp.azure.com`
* From the jumpbox, SSH into the master Spark server `ssh 10.0.1.4`

To check deployment errors go to the new azure portal and look under Resource Group -> Last deployment -> Check Operation Details

##Known Issues and Limitations
- The deployment script is not yet idempotent and cannot handle updates
- SSH key is not yet implemented and the template currently takes a password for the admin user
- Spark cluster is current enabled for one master and multi slaves.
