# XtremeData dbX Cluster [Preview on Azure] Template

This template deploys XtremeData dbX cluster (MPP data warehouse) with the provided configuration parameters in the West US region.

*The template is using a custom CentOS 6 image that includes the XtremeData dbX software and relevant scripts. Since currently it is not possible to create VMs using a custom "user image" that is located in a different storage account, this template demonstrates a workaround to use a small helper VM and simple bash script using Azure CLI to copy the image from the XtremeData's storage account to the newly created storage account defined in the template prior to the creation of the rest of the VMs from that image.*

Create the dbX cluster (Please be patient - this is preview of deployment on Azure. It takes about 30 minutes)

NOTE: You may need to be already logged into your Azure account before hitting the below "deploy" button in order for the Azure deployment screen to come up.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fxtremedata%2Fazure-quickstart-templates%2Fmaster%2Fxtremedata-dbx-cluster-centos%2Fazuredeploy.json) 


##Requirements
*   Please make sure the subscription you use allows creation of the requested number of virtual
machines of the selected size - otherwise the deployment will fail. Note: the DS series VMs have their own core limits in your account.
*   Please change the default names when deploying more then one dbX cluster.

###Default cluster configuration
*   1 x DS1 helper VM (can be shutdown after deployment completes)
*   2 x DS14 dbX cluster nodes (can be 2,4,8 of DS12, DS13, DS14)
*   6 x 128GB premium storage space per node (fixed)

##Usage
After successful cluster deployment you can manage your dbX database via ssh login or
web management console (the passwords for all the default users are as provided in parameters on template deployment).

dbX cluster head (the master node) is always the first created - with index '0'. Please use this node for cluster management and SQL queries. Access to this node can be:

*   either via public DNS name *{entered_domain_name}.{location}.cloudapp.azure.com* (e.g. mydomain.westus.cloudapp.azure.com)
*   or via public IP address (browse for it in the Azure console)

_For web management console please accept the secure certificate exception when asked._

###Management
*   for the xdadm web management console please login as _dbxdba_ using URL: _https://{head IP or DNS}:2400/xdadm_
*   for the Linux database administrator please login via ssh as _dbxdba_
*   for the Linux user with root permissions, please login via ssh as _azure-user_

###Query Tool
*   for the xdqry web SQL query tool please login as _dbxdba_ using URL: _https://{head IP or DNS}:2400/xdqry_

###Working with dbX
*   to use dbX one has to first create and start a DB server
*   the created DB server acquires the role name and password as the user-name of user who created it (typically _dbxdba_)
*   to create a new database one has to first connect to one of the DB server's default databases (e.g. _postgres_)
*   only local (linux command line) connections are allowed by default
*   connections from the web interfaces or a remote tool require adding an appropriate client authentication record
*   please review the full documentation on our website

##For more information - visit our website
[![XtremeData Inc](https://raw.githubusercontent.com/xtremedata/azure-quickstart-templates/master/xtremedata-dbx-cluster-centos/XtremeDataLogo_woTag_RGB_sm.png)](http://xtremedata.com) 