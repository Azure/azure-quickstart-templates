# Install MySQL MHA + Haproxy Solution

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-mha-haproxy-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-mha-haproxy-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-mha-haproxy-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-mha-haproxy-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-mha-haproxy-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-mha-haproxy-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmysql%2Fmysql-mha-haproxy-ubuntu%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmysql%2Fmysql-mha-haproxy-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmysql%2Fmysql-mha-haproxy-ubuntu%2Fazuredeploy.json)

This template deploys a MySQL MHA + Haproxy solution:  the objective of MHA is automating master failover and slave promotion within short (usually 10-30 seconds) downtime, without suffering from replication consistency problems, without spending money for lots of new servers, without performance penalty, without complexity (easy-to-install), and without changing existing deployments; Haproxy is the interface which apps access mysql.

This template deploys 4 nodes: 3 mysql nodes and 1 haproxy node. Os is Ubuntu 14.04.

Haproxy node opens 3306 port for apps write request; opens 3307 port for apps read request.

3 mysql nodes contains 1 master node and two slave nodes. Master node provides write service, slave nodes provide read service. They are configured data replication. All install mysql server 5.5. MySQL MHA software will help to do the auto master failover and slave promotion.

The Haproxy node is exposed on a public IP address that you can access through SSH on the standard port, also 3306, 3307 ports open.
The mysql nodes only has private ip address, and it's static ip address. 

The 4 nodes are under the same subnet. Their IP info is below:

haproxy ip: 10.0.0.9

mysql master ip: 10.0.0.10

mysql slave01 ip: 10.0.0.11

mysql slave02 ip: 10.0.0.12

##After deployment, you must do the follow things:

1 configure ssh trust connection on the 4 nodes. 

1.1. connect to haproxy node, execute below

$ssh-keygen -t rsa

$ssh-copy-id 10.0.0.10

$ssh-copy-id 10.0.0.11

$ssh-copy-id 10.0.0.12

1.2. connect to master node. through haproxy node to connect to master node, then execute below

$ssh-keygen -t rsa

$ssh-copy-id 10.0.0.11

$ssh-copy-id 10.0.0.12

1.3. connect to slave01 node. through haproxy node to connect to slave01 node, then execute below

$ssh-keygen -t rsa

$ssh-copy-id 10.0.0.10

$ssh-copy-id 10.0.0.12

1.4. connect to slave02 node. through haproxy node to connect to slave02 node, then execute below

$ssh-keygen -t rsa

$ssh-copy-id 10.0.0.10

$ssh-copy-id 10.0.0.11

2 check ssh configurations. at haproxy node, execute below

$masterha_check_ssh --conf=/etc/app1.cnf

if the result is pass, then go to step 3, otherwise you need to fix ssh connection configuration issues first.

3 check master-slave replication configuration. at haproxy node, execute below

$masterha_check_repl --conf=/etc/app1.cnf

if the result is pass, then go to step 4

4 at haproxy node, start haproxy 

$sudo /usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg

5 at haproxy node, start mha manager

$nohup masterha_manager --conf=/etc/app1.cnf < /dev/null > /var/log/masterha/app1/app1.log 2>&1 &

6 at haproxy node, start master ip check script. the script 1st parameter is master ip, the 2nd parameter is the candidate master ip(will take over master role when the original master fails), the order is very important!

$sudo nohup bash /usr/local/haproxy/master_ip_check.sh 10.0.0.10 10.0.0.11 &

7 at haproxy node, start slave ip check script. the parameters mean slave server ip addresses.

$sudo nohup bash /usr/local/haproxy/slave_ip_check.sh 10.0.0.11 10.0.0.12 &

Now the mha plus haproxy works. Once the master fails, the candidate master 10.0.0.11 will become the new master automatically, the slave02 will change master to 10.0.0.11 automatically. So then you fix original master issue, sync the data with new master, then brings it online, it must become the slave role. Then you go to haproxy node, delete /var/log/masterha/app1/app1.failover.complete file, start mha manager, master ip check script and slave ip check script again. Remember this time for the master ip check script, you execute sudo nohup bash /usr/local/haproxy/master_ip_check.sh 10.0.0.11 10.0.0.10 & 

##Known Limitations
- The mysql nodes don't replicate mysql db. If you want to replicate mysql db too, please stop haproxy, mha manager, the mater and slave ip check scripts, re-configure master-slave data replication, then start haproxy, mha manager, the mater and slave ip check scripts again.
- The mysql root password is the same on all 3 mysql nodes.
- Every time you start mha manager, must delete /var/log/masterha/app1/app1.failover.complete file first.
- sudo nohup bash /usr/local/haproxy/master_ip_check.sh masterip candidatemasterip &     Here the script 1st parameter is master ip, the 2nd parameter is the candidate master ip(will take over master role when the original master fails). The order is very important!
- sudo nohup bash /usr/local/haproxy/slave_ip_check.sh slave01ip slave02ip &    Here the parameters mean slave server ip addresses. The order is irrelevant.
- haproxy node /var/log/masterha/app1/app1.log records the master failover details. 
- haproxy node current directory/nohup.out records master and slave ip check info.


