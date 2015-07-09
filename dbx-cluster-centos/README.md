# Xtremedata Inc dbX cluster template

Create dbX cluster (please be patient, deployment of a trial version takes about 30 minutes)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fxtremedata%2Fazure-quickstart-templates%2Fmaster%2Fdbx-cluster-centos%2Fazuredeploy.json) 

This template deploys Xtremedata dbX cluster (a parallel rational database) with provided configuration parameters.

##Requirements
Please make sure the subscription you use allows to create requested number of virtual machines of the selected size - otherwise the deployment will fail.

###Default cluster requirements
* 1 x DS1 helper VM
* 2 x DS14 dbX cluster nodes
* 2 x 2 x 128GB premium storage space

##Usage
After successful dbX cluster deployment you can manage your cluster SQL database:
* via console as 'azure-user' to control the cluster or as 'dbxdba' to process SQL requests (password as provided in parameters on template deployment)
