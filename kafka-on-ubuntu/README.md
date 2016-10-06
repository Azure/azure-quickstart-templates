# Install a Kafka cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkafka-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkafka-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Apache Kafka is publish-subscribe messaging rethought as a distributed commit log.

Kafka is designed to allow a single cluster to serve as the central data backbone for a large organization. It can be elastically and transparently expanded without downtime. Data streams are partitioned and spread over a cluster of machines to allow data streams larger than the capability of any single machine and to allow clusters of co-ordinated consumers

Kafka has a modern cluster-centric design that offers strong durability and fault-tolerance guarantees.

This template deploys a Kafka cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.
The template also creates 1 publicly accessible VM acting as a "jumpbox" and allowing to ssh into the Kafka nodes for diagnostics or troubleshooting purposes.

How to Run the scripts
----------------------

You can use the Deploy to Azure button or use the below methor with powershell

Creating a new deployment with powershell:

Remember to set your Username, Password and Unique Storage Account name in azuredeploy-parameters.json

Create a resource group:

    PS C:\Users\azureuser1> New-AzureResourceGroup -Name "AZKFRKAFKAEA3" -Location 'EastAsia'

Start deployment

    PS C:\Users\azureuser1> New-AzureResourceGroupDeployment -Name AZKFRGKAFKAV2DEP1 -ResourceGroupName "AZKFRGKAFKAEA3" -TemplateFile C:\gitsrc\azure-quickstart-templates\kafka-on-ubuntu\azuredeploy.json -TemplateParameterFile C:\gitsrc\azure-quickstart-templates\kafka-on-ubuntu\azuredeploy-parameters.json -Verbose

    On successful deployment results will be like this
    DeploymentName    : AZKFRGKAFKAV2DEP1
    ResourceGroupName : AZKFRGKAFKAEA3
    ProvisioningState : Succeeded
    Timestamp         : 4/26/2015 4:40:51 PM
    Mode              : Incremental
    TemplateLink      :
    Parameters        :

                    Name             Type                       Value
                    ===============  =========================  ==========
                    adminUsername    String                     adminuser
                    adminPassword    SecureString
                    imagePublisher   String                     Canonical
                    imageOffer       String                     UbuntuServer
                    imageSKU         String                     14.04.2-LTS
                    storageAccountName  String                     armdeploykafkastr1
                    region           String                     West US
                    virtualNetworkName  String                     kafkaClustVnet
                    dataDiskSize     Int                        100
                    addressPrefix    String                     10.0.0.0/16
                    subnetName       String                     Subnet1
                    subnetPrefix     String                     10.0.0.0/24
                    kafkaVersion     String                     3.0.0
                    kafkaClusterName  String                     kafka-arm-cluster
                    kafkaZooNodeIPAddressPrefix  String                     10.0.0.4
                    kafkaNodeIPAddressPrefix  String                     10.0.0.1
                    jumpbox          String                     enabled
                    tshirtSize       String                     S

Check Deployment
----------------

To access the individual Kafka nodes, you need to use the publicly accessible jumpbox VM and ssh from it into the VM instances running Kafka.

To get started connect to the public ip of Jumpbox with username and password provided during deployment.
From the jumpbox connect to any of the Kafka brokers eg: ssh 10.0.0.10 ,ssh 10.0.0.11, etc.
Run the command ps-ef|grep kafka to check that kafka process is running ok.
You can run the kafka commands like this:

cd /usr/local/kafka/kafka_2.10-0.8.2.1/

bin/kafka-topics.sh --create --zookeeper 10.0.0.40:2181  --replication-factor 2 --partitions 1 --topic my-replicated-topic1

bin/kafka-topics.sh --describe --zookeeper 10.0.0.40:2181  --topic my-replicated-topic1

Topology
--------

The deployment topology is comprised of Kafka Brokers and Zookeeper nodes running in the cluster mode.
Kafka version 0.8.2.1 is the default version and can be changed to any pre-built binaries avaiable on Kafka repo.
A static IP address will be assigned to each Kafka node in order to work around the current limitation of not being able to dynamically compose a list of IP addresses from within the template (by default, the first node will be assigned the private IP of 10.0.0.10, the second node - 10.0.0.11, and so on)
A static IP address will be assigned to each Zookeeper node in order to work around the current limitation of not being able to dynamically compose a list of IP addresses from within the template (by default, the first node will be assigned the private IP of 10.0.0.40, the second node - 10.0.0.41, and so on)

To check deployment errors go to the new azure portal and look under Resource Group -> Last deployment -> Check Operation Details

##Known Issues and Limitations
- The deployment script is not yet handling data disks and using local storage.
- There will be a separate checkin for persistant disks as per T shirt sizing.
- Health monitoring of the Kafka instances is not currently enabled
- SSH key is not yet implemented and the template currently takes a password for the admin user
