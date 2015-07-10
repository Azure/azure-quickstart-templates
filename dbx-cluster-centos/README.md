# Xtremedata Inc dbX cluster template

Create dbX cluster (please be patient, deployment of a trial version takes about 30 minutes)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fxtremedata%2Fazure-quickstart-templates%2Fmaster%2Fdbx-cluster-centos%2Fazuredeploy.json) 

This template deploys Xtremedata dbX cluster (a parallel relational database) with provided configuration parameters.

##Requirements
*   Please make sure the subscription you use allows to create requested number of virtual machines of the selected size - otherwise the deployment will fail.
*   Please change default names when deploying more then one dbX cluster per resource group.

###Default cluster requirements
* 1 x DS1 helper VM
* 2 x DS14 dbX cluster nodes
* 6 x 128GB premium storage space per node

##Usage
After successful dbX cluster deployment you can manage your cluster SQL database via console or www (the passwords for all the default users are as provided in parameters on template deployment).

dbX cluster head (the master node) is always the first created - with index '0'. Please use this node for cluster management and SQL queries. Access to this node can be:

*   either via public DNS name *{entered_domain_name}x16-0.{resource group}.{location}.cloudapp.azure.com*
*   or via public IP address (available on the Azure console)

dbX cluster management and SQL queries can be done:

* either via www
* or via console

_For www access please allow for secure certificate exception when asked._

###Cluster Management
*   via www please login as dbxdba using URL: https://{head IP or DNS}:2400/xdadm
*   via console please login as 'azure-user' to manage the cluster

###Database Query
*   via www please login as dbxdba using URL: https://{head IP or DNS}:2400/xdqry
*   via console please login as 'dbxdba' to process SQL requests

##Want to know more - visit our website
[![XtremeData Inc](https://raw.githubusercontent.com/xtremedata/azure-quickstart-templates/master/dbx-cluster-centos/XtremeDataLogo_woTag_RGB_sm.png)](http://xtremedata.com) 
