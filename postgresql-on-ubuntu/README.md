# Create PostgreSQL 9.3 master-slave streaming replication on multiple Ubuntu 14.04 VMs and one jumpbox VM with a public IP

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpostgresql-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpostgresql-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates one master PostgreSQL 9.3 server with streaming-replication to multiple (based on the T-Shirt size parameter) slave servers. Each database server is configured with multiple data disks that are striped into RAID-0 configuration using mdadm. The template also optionally creates one externally accessible VM to serve as a jumpbox for ssh into the backend database servers.

The template creates the following deployment resources:
* Virtual Network with two subnets: "dmz 10.0.0.0/24" for the jumpbox VM and "data 10.0.1.0/24" for the PostgreSQL master and slave VMs
* Storage accounts to store VM data disks
* Public IP address for accessing the jumpbox via ssh
* Network interface card for each VM
* Multiple remotely-hosted Custom Script Extensions to strip the data disks and to install and configure PostgreSQL services

NOTE: To access the PostgreSQL servers, you need to use the externally accessible jumpbox VM and ssh from it into the backend servers.

Assuming your domainName parameter was "mypsqljumpbox" and region was "West US"
* Master PostgreSQL server will be deployed at the first available IP address in the subnet: 10.0.1.4
* Slave PostgreSQL servers will be deployed in the other IP addresses: 10.0.1.5, 10.0.1.6, 10.0.1.7, etc.
* From your computer, SSH into the jumpbox `ssh mypsqljumpbox.westus.cloudapp.azure.com`
* From the jumpbox, SSH into the master PostgreSQL server `ssh 10.0.1.4`
* On the master (e.g. 10.0.1.4), use the following code to create table and some test data within your PostgreSQL master database.

```
sudo -u postgres psql
create table table1 (name varchar(100));
insert into table1 (name) values ('name1');
insert into table1 (name) values ('name2');
select * from table1;
```

* From the jumpbox, SSH into one of the slave PostgreSQL servers `ssh 10.0.1.5` and use psql to check that the data propaged properly

```
sudo -u postgres psql
select * from table1;
```

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Database VM Size | CPU Cores | Memory | Data Disks | # of Secondaries | # of Storage Accounts |
|:--- |:---|:---|:---|:---|:---|:---|:---|:---|
| Small | Standard_A1 | 1 |1.75 GB | 2x1023 GB | 1 | 1 |
| Medium | Standard_A3 | 4 | 7 GB | 8x1023 GB | 1 | 2 |
| Large | Standard_A4 | 8 | 14 GB | 16x1023 GB | 2 | 2 |
| XLarge | Standard_A4 | 8 | 14 GB | 16x1023 GB | 3 | 4 |
