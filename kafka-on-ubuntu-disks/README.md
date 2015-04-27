# Create Kafka 9.3 zookeeper-broker streaming replication on multiple Ubuntu 14.04 VMs and one jumpbox VM with a public IP

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates one zookeeper Kafka 9.3 server with streaming-replication to multiple (based on the T-Shirt size parameter) broker servers. Each database server is configured with multiple data disks that are striped into RAID-0 configuration using mdadm. The template also optionally creates one externally accessible VM to serve as a jumpbox for ssh into the backend database servers.

The template creates the following deployment resources:
* Virtual Network with two subnets: "dmz 10.0.0.0/24" for the jumpbox VM and "data 10.0.1.0/24" for the Kafka zookeeper and broker VMs
* Storage accounts to store VM data disks
* Public IP address for accessing the jumpbox via ssh
* Network interface card for each VM
* Multiple remotely-hosted CustomScriptForLinux extensions to strip the data disks and to install and configure Kafka services

NOTE: To access the Kafka servers, you need to use the externally accessible jumpbox VM and ssh from it into the backend servers.

Assuming your domainName parameter was "mykafkajumpbox" and region was "West US"
* zookeeper Kafka server will be deployed at the first available IP address in the subnet: 10.0.1.4
* broker Kafka servers will be deployed in the other IP addresses: 10.0.1.5, 10.0.1.6, 10.0.1.7, etc.
* From your computer, SSH into the jumpbox `ssh mykafkajumpbox.westus.cloudapp.azure.com`
* From the jumpbox, SSH into the zookeeper Kafka server `ssh 10.0.1.4`
* From the jumpbox, SSH into one of the broker Kafka servers `ssh 10.0.1.5` and use kafka to check that the data propaged properly

Template expects the following parameters

| Name   | Description    |
|:--- |:---|
| region | Location where the resources will be deployed |
| storageAccountNamePrefix  | Unique DNS name for the Storage Account where the Virtual Machines' disks will be placed |
| domainName | Domain name of the publicly accessible jumpbox VM {domainName}.{region}.cloudapp.azure.com (e.g. mydomainname.westus.cloudapp.azure.com)|
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| tshirtSize  | Size of deployment to provision |
| replicatorPassword | Password to use for the kafka replication user (replicator) |
| jumpbox | Enable jumpbox |
| virtualNetworkName | Virtual network name |

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Database VM Size | CPU Cores | Memory | Data Disks | # of Brokers | # of Storage Accounts |
|:--- |:---|:---|:---|:---|:---|:---|:---|:---|
| Small | Standard_A1 | 1 |1.75 GB | 2x1023 GB | 1 | 1 |
| Medium | Standard_A3 | 4 | 7 GB | 8x1023 GB | 1 | 2 |
| Large | Standard_A4 | 8 | 14 GB | 16x1023 GB | 2 | 2 |
| XLarge | Standard_A4 | 8 | 14 GB | 16x1023 GB | 3 | 4 |
