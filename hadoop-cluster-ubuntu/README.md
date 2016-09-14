# Install Hadoop Cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhadoop-cluster-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="
http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhadoop-cluster-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template deploys a hadoop cluster and enables Zabbix monitoring, and allows user to define the number of data nodes. The hadoop cluster contains 1 name node, 2 data nodes by default.

This template also allows you to input your existing zabbix server IP address to monitor these servers.

Only the name node exposes on public IP addresses that you can access through SSH on the standard port, also ports 8088, 50070 open so that you can check hadoop cluster information through URL http://name node public ip:8088/ and http://name node public ip:50070/

Name node has static private ip address 10.0.0.240. Each data node has dynamic private ip address. The ip addresses usually start from 10.0.0.4.


##Important Notice
Each server uses raid0 to improve performance. We use 4 data disks on each server for raid0. The size of each data disk is set to 100GB. Execute the command "df -h" to find out the mount details, /dev/md0 is for the data disks. The VM size is set to Standard_A3. You can check the VM size details by clicking the URL https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/ .



##After deployment, you can do below to verify if the hadoop cluster really works or not:

1. Open the URL http://your name node public ip:8088/ to check hadoop cluster information.


2. Check each server's hadoop processes by executing below command:
  ```
  $jps
  ```

  You should see the processes similar to below in name node:
  ```
  28568 Jps
  28210 ResourceManager
  28046 SecondaryNameNode
  27801 NameNode
  ```
  
  You should see the processes similar to below in data nodes:
  ```
  27621 DataNode
  27786 NodeManager
  27973 Jps
  ```



##Known Limitations
- The hadoop version is stable 2.7.3.

