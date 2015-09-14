<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fliupeirong%2Fazure-quickstart-templates%2Fmaster%2Fwordpress-mysql-replication%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

# MySQL Replication Template

This template deploys a WordPress site in Azure backed by MySQL replication with one master and one slave servers.  It has the following capabilities:

  - Installs and configures GTID based MySQL replication on CentOS 6
  - Deploys a load balancer in front of the 2 MySQL VMs.  MySQL, SSH, and MySQL probe ports are exposed through the load balancer using Network Security Group rules.  WordPress accesses MySQL through the load balancer. 
  - Configures a http based health probe for each MySQL instance that can be used to monitor MySQL health

### How to Deploy
* This template takes a dependency on [MySQL-replication](http://https://github.com/liupeirong/azure-quickstart-templates/tree/master/mysql-replication) in this repo. Refer to the README of MySQL-Replication template to customize MySQL deployment as necessary and how to failover, backup, and restore.



License
----

MIT

