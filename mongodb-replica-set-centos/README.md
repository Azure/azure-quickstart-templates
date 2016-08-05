# Install MongoDB Replica Set

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-replica-set-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-replica-set-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template deploys a MongoDB Replica Set on CentOS and enables Zabbix monitoring, and allows user to define the number of secondary nodes. The replica set has a primary node, 2 secondary nodes by default.

This template also allows you to input your existing zabbix server IP address to monitor these MongoDB nodes.

The replica set nodes are exposed on public IP addresses that you can access through SSH on the standard port, also mongodb port 27017 open.

The nodes are under the same subnet 10.0.1.0/24. The primary node ip is 10.0.1.240, the secondary nodes ip address start from 10.0.1.4. For example:

- primary node ip: 10.0.1.240

- secondary node 1 ip: 10.0.1.4

- secondary node 2 ip: 10.0.1.5


##Important Notice
Each VM of the replica set uses raid0 to improve performance. We use 4 data disks on each VM for raid0. The size of data disks(setup raid0) on each VM are determined by yourself. However, there is size of data disks limit per the VM size. Before you set the size of data disks, please refer to the link https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/ for the correct choice.



##After deployment, you can do below to verify if the replica set really works or not:

1. SSH connect to primary node, execute below
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin"

  rs.status()

  exit
  ```

  Upper rs.status() command will show the replica set details. 


2. You can also check the data replication status. SSH connect to primary node, execute below:
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin"

  use test

  db.mycol.insert({"title":"MongoDB Overview"})

  db.mycol.find()
  ```

- 2.1 SSH connect to secondary nodes, execute below
  ```
  $mongo -u "<mongouser>" -p "<mongopassword>" "admin"

  use test

  db.getMongo().setSlaveOk()

  show collections

  db.mycol.find()
  ```

- 2.2 If db.mycol.find() command can show the result like primary node does, then means the replica set works.




##Known Limitations
- The MongoDB version is 3.2.
- We expose all the nodes on public addresses so that you can access MongoDB service through internet directly.
- MongoDB suggests that the replica set has an odd number of voting members. So the number of secondary nodes is better to set to even number, like 2, 4 or 6, then plus the primary node, fill the requirement that the replica set has an odd number of voting members.
- A replica set can have up to 50 members, but only 7 voting members. So the maximum number of secondary nodes is 6.
- The replica set doesn't have arbiter nodes.
- The replica set enables internal authentication. Check /etc/mongokeyfile for details.
- More MongoDB usage details please visit MongoDB website https://www.mongodb.org/ .
