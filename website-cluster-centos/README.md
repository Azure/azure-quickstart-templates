# Install Website Cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F251744647%2Fazure-quickstart-templates%2Fmaster%2Fwebsite-cluster-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="
http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2F251744647%2Fazure-quickstart-templates%2Fmaster%2Fwebsite-cluster-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template deploys a website cluster and enables Zabbix monitoring, and allows user to define the number of web servers. The website cluster contains 1 load balancer, 3 web servers, 1 redis master with 1 redis slave, 1 MySQL master with 1 MySQL slave by default.

This template also allows you to input your existing zabbix server IP address to monitor these servers.

The load balancer exposes on public IP addresses that you can access through SSH on the standard port, also port 80 open so that you can access your website through browsers.

The servers are under the same net 10.0.0.0/24, there are 4 subnets under this net: web subnet, haproxy subnet, redis subnet, mysql subnet. The details are below:

- web: 10.0.0.0/28

- mysql: 10.0.0.16/28

- redis: 10.0.0.32/28

- haproxy: 10.0.0.48/28


Each server has dynamic private ip address. Web servers belong to web subnet, the ip addresses usually start from 10.0.0.4; MySQL servers belong to mysql subnet, the ip addresses start from 10.0.0.20; redis servers belong to redis subnet, the ip addresses start from 10.0.0.36; load balancer belongs to haproxy subnet, the ip address start from 10.0.0.52.


##Important Notice
Each server uses raid0 to improve performance. We use 4 data disks on each server for raid0. The size of data disks(setup raid0) on each server are determined by yourself. However, there is size of data disks limit per the server size. Before you set the size of data disks, please refer to the link https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-sizes/ for the correct choice.



##After deployment, you can do below to verify if the website cluster really works or not:

1. Open the URL http://your load balancer public ip/mysql.php to see if can connect to MySQL DB successfully.


2. Check MySQL data replication status. SSH connect to load balancer, then SSH connect to MySQL slave(usually 10.0.0.21), then execute below:
  ```
  $mysql -uroot -p<mysqlpassword>

  use testdb;

  select * from test01;
  ```

  You should see some records in the test01 table.

  
3. Check redis data replication status. SSH connect to load balancer, then SSH connect to redis master(usually 10.0.0.36), then execute below:
  ```
  $/usr/local/redis/src/redis-cli

  set hello world

  get hello
  ```

  SSH connect to redis slave(usually 10.0.0.37), then execute below:
  ```
  $/usr/local/redis/src/redis-cli

  get hello
  ```
  
  You should get the output as same as redis master does.


##Known Limitations
- The website uses one load balancer and the load balancer uses haproxy software. You can create more load balancers and you can even use Azure's traffic manager to do the load balanceing.
- You can add more web servers and database servers after the deployment.
