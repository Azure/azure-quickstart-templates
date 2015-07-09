# Xtremedata Inc dbX cluster template

Create dbX cluster 
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fxtremedata%2Fazure-quickstart-templates%2Fmaster%2Fdbx-cluster-centos%2Fazuredeploy.json) 

This template deploys Xtremedata dbX cluster (a parallel rational database) with provided configuration parameters.

##Requirements
Please make sure the subscription you use allows to create requested number of virtual machines, otherwise deployment will fail.

##Default cluster configuration
* 1 x DS1 helper VM
* 2 x DS12 nodes
