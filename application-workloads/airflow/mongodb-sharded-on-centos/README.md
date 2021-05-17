# Install MongoDB Sharding Cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/airflow/mongodb-sharded-on-centos/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/airflow/mongodb-sharded-on-centos/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/airflow/mongodb-sharded-on-centos/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/airflow/mongodb-sharded-on-centos/FairfaxDeployment.svg)
    
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/airflow/mongodb-sharded-on-centos/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/airflow/mongodb-sharded-on-centos/CredScanResult.svg)
   
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fairflow%2Fmongodb-sharded-on-centos%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fairflow%2Fmongodb-sharded-on-centos%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fairflow%2Fmongodb-sharded-on-centos%2Fazuredeploy.json)
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>

This template deploys a MongoDB Sharding Cluster on CentOS. It deploys 1 router server, one config server replica set with 3 nodes, and 1 shard which is a replica set with 4 nodes. So it totally deploys 8 nodes.

The router server is exposed on public IP address that you can access through SSH on the standard port, also mongodb port 27017 open. You can access it for MongoDB data write and read.

The config server replica set stores sharding cluster metadata. MongoDB suggests to use a replica set for the metadata store in the production environment, in case one of the config server is down, there will still be other 2 config server nodes offer the service.

1 shard is a 4 node replica set. You can shard the data on the replica set. You can also add more replica sets into the sharding cluster.

The nodes are under the same subnet 10.0.0.0/24. Except the router server, the other nodes only have private IP address.

<img src="https://raw.githubusercontent.com/cjsingh8512/azure-cosmosdb-mongodbshardedcluster/users/chsi/images/Mongo Sharded Cluster.png" />

## Important Notice
1. Each VM of the shard uses managed ssd's to improve performance. The number and the size of data disks on each shard VM are determined by yourself. However, there is number and size of data disks limit per the VM size. Before you set number and size of data disks, please refer to the link https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/ for the correct choice
2. Mongo router server is enabled with SSL. The certificate used for SSL has the same subject name as the FQDN of the server. Therefore, if you want to connect to the server from a driver or desktop client without enabling the setting **IngnoreInvalidHostnames** please use the FQDN as part of the connection string

## After deployment, you can do below to verify if the sharding cluster really works or not:

1. Connect to the router server using mongo shell and execute below:
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin" --host <Mongos fqdn>

  db.runCommand( { listshards : 1 } )

  exit
  ```

2. You can "shard" any database and collections you want. Execute below command from mongo shell:
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin" --host <Mongos fqdn>

  db.runCommand({enableSharding: "<database>" })

  sh.status()

  sh.shardCollection("<database>.<collection>", shard-key-pattern)

  exit
  ```

3. You can add more shards into this sharding cluster. Execute below command from mongo shell:
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin" --host <Mongos fqdn>

  sh.addShard("<replica set name>/<primary ip>:27017")

  exit
  ```

  Before adding your own replica set into the sharding cluster, you should enable internal authentication in your replica set first, and make sure the replica set is accessible through this sharding cluster.

## Note
- The MongoDB version is 3.6.
- We expose 1 router server on public address so that you can access MongoDB service through internet directly.
- This cluster only has 1 shard, you can add more shards after the deployment. 
- The nodes use internal authentication and ssl. So if you want to add your own replica set into this sharding cluster, you should enable the internal authentication and bring it up in ssl mode first. Check any node /etc/mongokeyfile for more details.
- The replica set is composed with 1 primary node, 3 secondary nodes.
- More MongoDB usage details please visit MongoDB website https://www.mongodb.org/ .


