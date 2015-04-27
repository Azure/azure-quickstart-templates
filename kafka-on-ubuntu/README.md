# Install a Kafka cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Apache Kafka is publish-subscribe messaging rethought as a distributed commit log.

Kafka is designed to allow a single cluster to serve as the central data backbone for a large organization. It can be elastically and transparently expanded without downtime. Data streams are partitioned and spread over a cluster of machines to allow data streams larger than the capability of any single machine and to allow clusters of co-ordinated consumers

Kafka has a modern cluster-centric design that offers strong durability and fault-tolerance guarantees.

This template deploys a Kafka cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.
The template also creates 1 publicly accessible VM acting as a "jumpbox" and allowing to ssh into the Kafka nodes for diagnostics or troubleshooting purposes.

The example expects the following parameters:

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| adminUsername  | Admin user name for the Virtual Machines  |
| adminPassword  | Admin password for the Virtual Machine  |
| region | Region name where the corresponding Azure artifacts will be created |
| virtualNetworkName | Name of Virtual Network |
| dataDiskSize | Size of each disk attached to Kafka nodes (in GB) - This will be available in with Disk templates separately |
| subnetName | Name of the Virtual Network subnet |
| addressPrefix | The IP address mask used by the Virtual Network |
| subnetPrefix | The subnet mask used by the Virtual Network subnet |
| kafkaVersion | Kafka version number to be installed |
| kafkaClusterName | Name of the Kafka cluster |
| kafkaNodeIPAddressPrefix | The IP address prefix that will be used for constructing a static private IP address for each Kafka broker node in the cluster |
| kafkaZooNodeIPAddressPrefix | The IP address prefix that will be used for constructing a static private IP address for each Zookeeper node in the cluster |
| jumpbox | The flag allowing to enable or disable provisioning of the jumpbox VM that can be used to access the Kafka nodes |
| tshirtSize | The t-shirt size of the Kafka node (small, medium, large) |

Topology
--------

The deployment topology is comprised of Kafka Brokers and Zookeeper nodes running in the cluster mode.
Kafka version 0.8.2.1 is the default version and can be changed to any pre-built binaries avaiable on Kafka repo.
A static IP address will be assigned to each Kafka node in order to work around the current limitation of not being able to dynamically compose a list of IP addresses from within the template (by default, the first node will be assigned the private IP of 10.0.0.10, the second node - 10.0.0.11, and so on)
A static IP address will be assigned to each Zookeeper node in order to work around the current limitation of not being able to dynamically compose a list of IP addresses from within the template (by default, the first node will be assigned the private IP of 10.0.0.40, the second node - 10.0.0.41, and so on)

NOTE: To access the individual Kafka nodes, you need to use the publicly accessible jumpbox VM and ssh from it into the VM instances running Kafka.

To get started connect to the public ip of Jumpbox with username and password provided during deployment.
From the jumpbox connect to any of the Kafka brokers eg: ssh 10.0.0.10 ,ssh 10.0.0.11, etc.
Run the command ps-ef|grep kafka to check that kafka process is running ok.
You can run the kafka commands like this:
 
cd /usr/local/kafka/kafka_2.10-0.8.2.1/

bin/kafka-topics.sh --create --zookeeper 10.0.0.40:2181  --replication-factor 2 --partitions 1 --topic my-replicated-topic1

bin/kafka-topics.sh --describe --zookeeper 10.0.0.40:2181  --topic my-replicated-topic1

##Known Issues and Limitations
- The deployment script is not yet handling data disks and using local storage. There will be a separate checkin for disks as per T shirt sizing.
- Health monitoring of the Kafka instances is not currently enabled
- SSH key is not yet implemented and the template currently takes a password for the admin user
