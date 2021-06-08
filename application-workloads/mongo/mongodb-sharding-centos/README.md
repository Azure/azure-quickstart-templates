# Install MongoDB Sharding Cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-sharding-centos/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-sharding-centos/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-sharding-centos/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-sharding-centos/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-sharding-centos/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-sharding-centos/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmongo%2Fmongodb-sharding-centos%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmongo%2Fmongodb-sharding-centos%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmongo%2Fmongodb-sharding-centos%2Fazuredeploy.json)
  

This template deploys a MongoDB Sharding Cluster on CentOS. It deploys 2 router servers, one config server replica set with 3 nodes, and 2 shards which both are replica set with 3 nodes. So it totally deploys 11 nodes.

The 2 router server nodes are exposed on public IP addresses that you can access through SSH on the standard port, also mongodb port 27017 open. You can access any one of them for MongoDB data write and read. If one router server is down, you can still access the other one.

The config server replica set stores sharding cluster metadata. MongoDB suggests to use a replica set for the metadata store in the production environment, in case one of the config server is down, there will still be other 2 config server nodes offer the service.

2 shards each is a 3 node replica set. You can shard the data on the two replica sets. You can also add more replica sets into the sharding cluster.

The nodes are under the same subnet 10.0.0.0/24. Except the 2 router server nodes, the other nodes only have private IP address.

This template also allows you to input your existing zabbix server IP address to monitor these MongoDB router servers.

##Important Notice
Each VM of the shard uses raid0 to improve performance. The number and the size of data disks(setup raid0) on each shard VM are determined by yourself. However, there is number and size of data disks limit per the VM size. Before you set number and size of data disks, please refer to the link https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/ for the correct choice.

##After deployment, you can do below to verify if the sharding cluster really works or not:

1. SSH connect to one of the router server, execute below:
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin"

  db.runCommand( { listshards : 1 } )

  exit
  ```

  Upper db.runCommand( { listshards : 1 } ) command will show the sharding cluster details. 

2. You can "shard" any database and collections you want. SSH connect to one of the router server, execute below:
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin"

  db.runCommand({enableSharding: "<database>" })

  sh.status()

  sh.shardCollection("<database>.<collection>", shard-key-pattern)

  exit
  ```

3. You can add more shards into this sharding cluster. SSH connect to one of the router server, execute below:
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin"

  sh.addShard("<replica set name>/<primary ip>:27017")   

  exit
  ```

  Before adding your own replica set into the sharding cluster, you should enable internal authentication in your replica set first, and make sure the replica set is accessiable through this sharding cluster.

##Known Limitations
- The MongoDB version is 3.2.
- We expose 2 router server nodes on public addresses so that you can access MongoDB service through internet directly.
- This cluster only has 2 shards, you can add more shards after the deployment. 
- The nodes use internal authentication. So if you want to add your own replica set into this sharding cluster, you should enable the internal authentication in your replica set first. Check any node /etc/mongokeyfile for more details.
- The replica set is composed with 1 primary node, 2 secondary nodes.
- More MongoDB usage details please visit MongoDB website https://www.mongodb.org/ .


