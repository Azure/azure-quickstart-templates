# Create a Storage Spaces Direct (S2D) Scale-Out File Server (SOFS) Cluster with Windows Server 2016 on an existing VNET

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fazresiliency.blob.core.windows.net%2Fmysql-ha-pxc-zones%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fresiliency.blob.core.windows.net%2Fmysql-ha-pxc-zones%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template lets you create a 3 node Percona XtraDB Cluster 5.6 on Azure.  It's tested on Ubuntu 12.04 LTS and CentOS 6.5.  

To verify the cluster, type in "mysql -h your_public_ip_dns_name -u test -p".  The password is what you set for sstuser in my.cnf. Run MySQL command "show status like 'wsrep%'".  You should see that wsrep_cluster_size is 3 by default and wsrep_ready is "ON". 

To gain root access to MySQL, you must ssh into a node and sudo to run mysql.   

