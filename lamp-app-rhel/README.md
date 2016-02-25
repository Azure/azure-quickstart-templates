# Deploy a LAMP app on RHEL.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F251744647%2Fazure-quickstart-templates%2Fmaster%2Flamp-app-rhel%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template uses the Azure Linux CustomScript extension to deploy a LAMP application on RHEL. It creates an RHEL VM, does a silent install of MySQL 5.6, Apache 2.4 and PHP5, then creates 2 simple PHP scripts.  Go to /info.php to see the php page, go to /mysql.php to see mysql status.
