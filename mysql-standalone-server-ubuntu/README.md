# MySQL Server 5.6 on Ubuntu VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmysql-standalone-server-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template uses the Azure Linux CustomScript extension to deploy a MySQL server. It creates an Ubuntu VM, does a silent install of MySQL server, version:5.6

The root password is defined by yourself during the deployment.

The MySQL server database can be accessed only from localhost by default, you should update the privileges settings based on your own requirement.