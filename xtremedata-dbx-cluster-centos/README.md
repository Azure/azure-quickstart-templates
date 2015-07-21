# XtremeData Inc dbX cluster template

*This template is using a custom CentOS 6 image that includes the XtremeData dbX software and relevant scripts. Since currently it is not possible to create VMs using a custom "user image" that is located in a different storage account, this template demonstrates a workaround to use a small helper VM and simple bash script using Azure CLI to copy the image from the XtremeData's storage account to the newly created storage account defined in the template prior to the creation of the rest of the VMs from that image.*

Create dbX cluster (please be patient, deployment of a trial version takes about 30 minutes)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fxtremedata%2Fazure-quickstart-templates%2Fmaster%2Fxtremedata-dbx-cluster-centos%2Fazuredeploy.json) 

This template deploys XtremeData dbX cluster (a parallel relational database) with provided configuration parameters.

##Requirements
*   Please make sure the subscription you use allows creation of the requested number of virtual
machines of the selected size - otherwise the deployment will fail.
*   Please change the default names when deploying more then one dbX cluster.

###Default cluster requirements
* 1 x DS1 helper VM
* 2 x DS14 dbX cluster nodes
* 6 x 128GB premium storage space per node

##Usage
After successful cluster deployment you can manage your dbX database via ssh login or
web management console (the passwords for all the default users are as provided in parameters on template deployment).

dbX cluster head (the master node) is always the first created - with index '0'. Please use this node for cluster management and SQL queries. Access to this node can be:

*   either via public DNS name *{entered_domain_name}.{location}.cloudapp.azure.com*
*   or via public IP address (available on the Azure console)

_For web management console please accept the secure certificate exception when asked._

###Cluster Management
*   via web management console please login as _dbxdba_ using URL: _https://{head IP or DNS}:2400/xdadm_
*   via ssh please login as _azure-user_ to manage the cluster

###Database Query
*   via web management console please login as _dbxdba_ using URL: _https://{head IP or DNS}:2400/xdqry_
*   via ssh please login as _dbxdba_ to process SQL requests

###Working with dbX
*   to use dbX one has to first create a server using one of the defined node sets
*   created server acquires role name and password as the user-name of user who created it
*   to create a database one has to connect to the server's primary database (_postgres_) first
*   to use the web query console not locally one has to add a proper access control rule (by default only local access is allowed)

##Want to know more - visit our website
[![XtremeData Inc](https://raw.githubusercontent.com/xtremedata/azure-quickstart-templates/master/xtremedata-dbx-cluster-centos/XtremeDataLogo_woTag_RGB_sm.png)](http://xtremedata.com) 
