# Deploy OpenSIS Community Edition on Ubuntu as a cluster consisting of one or more frontend VM's and a single database backend VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvinhub%2Fazure-quickstart-templates%2Fmaster%2Fopensis-cluster-ubuntu%2FFazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template deploys OpenSIS Community Edition as a LAMP application on Ubuntu. It creates a one or more Ubuntu VM for the front end and a single VM for the backend. It does a silent install of Apache and PHP on the front end VM's and MySQL on the backend VM. Then it deploys OpenSIS Community Edition on the cluster.  After the deployment is successful, you can go to /opensis-ce to start congfiguting OpenSIS.
 