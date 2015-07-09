# Xtremedata Inc dbX cluster template

Create dbX cluster (please be patient, deployment of a trial version takes about 30 minutes)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fxtremedata%2Fazure-quickstart-templates%2Fmaster%2Fdbx-cluster-centos%2Fazuredeploy.json) 

This template deploys Xtremedata dbX cluster (a parallel relational database) with provided configuration parameters.

##Requirements
Please make sure the subscription you use allows to create requested number of virtual machines of the selected size - otherwise the deployment will fail.

###Default cluster requirements
* 1 x DS1 helper VM
* 2 x DS14 dbX cluster nodes
* 6 x 128GB premium storage space per node

##Usage
After successful dbX cluster deployment you can manage your cluster SQL database via console or www (the passwords for all the default users are as provided in parameters on template deployment).

_For www access please allow for secure certificate exception when asked._

###Cluster Management
* via www please login as dbxdba using URL: https://*head_node_name*.*location*.cloudapp.azure.com:2400/xdadm
* via console please login as 'azure-user' to control the cluster

###Database Query
* via www please login as dbxdba using URL: https://*head_node_name*.*location*.cloudapp.azure.com:2400/xdqry
* via console please login as 'dbxdba' to process SQL requests
