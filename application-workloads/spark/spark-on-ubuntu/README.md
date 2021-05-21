# Install a Spark cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/spark-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/spark-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/spark-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/spark-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/spark-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/spark/spark-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fspark%2Fspark-on-ubuntu%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fspark%2Fspark-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fspark%2Fspark-on-ubuntu%2Fazuredeploy.json) 

Apache Spark is a fast and general engine for large-scale data processing.
Spark has an advanced DAG execution engine that supports cyclic data flow and in-memory computing.

This template deploys a Spark cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.
The template also creates 1 publicly accessible VM acting as a "jumpbox" and allowing to ssh into the Spark nodes for diagnostics or troubleshooting purposes.

How to Run the scripts
----------------------

You can use the Deploy to Azure button or use the below methor with powershell

Creating a new deployment with powershell:

Remember to set your Username, Password and Unique Storage Account name in azuredeploy-parameters.json

Create a resource group:

    PS C:\Users\azureuser1> New-AzureResourceGroup -Name "AZKFRGSPARKEA3" -Location 'EastAsia'

Start deployment

    PS C:\Users\azureuser1> New-AzureResourceGroupDeployment -Name AZKFRGSPARKV2DEP1 -ResourceGroupName "AZKFRGSPARKEA3" -TemplateFile C:\gitsrc\azure-quickstart-templates\spark-on-ubuntu\azuredeploy.json -TemplateParameterFile C:\gitsrc\azure-quickstart-templates\spark-on-ubuntu\azuredeploy-parameters.json -Verbose

    On successful deployment results will be like this
    DeploymentName    : AZKFRGSPARKV2DEP1
    ResourceGroupName : AZKFRGSPARKEA3
    ProvisioningState : Succeeded
    Timestamp         : 4/27/2015 2:00:48 PM
    Mode              : Incremental
    TemplateLink      :
    Parameters        :
                        Name             Type                       Value
                        ===============  =========================  ==========
                        adminUsername    String                     adminuser
                        adminPassword    SecureString
                        imagePublisher   String                     Canonical
                        imageOffer       String                     UbuntuServer
                        imageSKU         String                     14.04.5-LTS
                        storageAccountName  String                     spkldeploysparknnuu1
                        region           String                     West US
                        virtualNetworkName  String                     sparkClustVnet
                        dataDiskSize     Int                        100
                        addressPrefix    String                     10.0.0.0/16
                        subnetName       String                     Subnet1
                        subnetPrefix     String                     10.0.0.0/24
                        sparkVersion     String                     3.0.0
                        sparkClusterName  String                     spark-arm-cluster
                        sparkNodeIPAddressPrefix  String                     10.0.0.1
                        sparkSlaveNodeIPAddressPrefix  String                     10.0.0.3
                        jumpbox          String                     enabled
                        tshirtSize       String                     S

Check Deployment
----------------
To access the individual Spark nodes, you need to use the publicly accessible jumpbox VM and ssh from it into the VM instances running Spark.

To get started connect to the public ip of Jumpbox with username and password provided during deployment.
From the jumpbox connect to any of the Spark workers eg: ssh 10.0.0.30 ,ssh 10.0.0.31, etc.
Run the command ps-ef|grep spark to check that kafka process is running ok.
To connect to master node you can use ssh 10.0.0.10

To access spark shell:

cd /usr/local/spark/bin/

sudo ./spark-shell

Topology
--------

The deployment topology is comprised of Master and Slave Instance nodes running in the cluster mode.
Spark version 1.2.1 is the default version and can be changed to any pre-built binaries avaiable on Spark repo.
There is also a provision in the script to uncomment the build from source.

 A static IP address will be assigned to each Spark Master node 10.0.0.10
 A static IP address will be assigned to each Spark Slave node in order to work around the current limitation of not being able to dynamically compose a list of IP addresses from within the template (by default, the first node will be assigned the private IP of 10.0.0.30, the second node - 10.0.0.31, and so on)

To check deployment errors go to the new azure portal and look under Resource Group -> Last deployment -> Check Operation Details

##Known Issues and Limitations
- The deployment script is not yet idempotent and cannot handle updates
- SSH key is not yet implemented and the template currently takes a password for the admin user
- The deployment script is not yet handling data disks and using local storage. There will be a separate checkin for disks as per T shirt sizing.
- Spark cluster is current enabled for one master and multi slaves.


