# Lamp stack on Ubuntu VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F251744647%2Fazure-quickstart-templates%2Fmaster%2Flamp-stack-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template uses the Azure Linux CustomScript extension to deploy the lamp stack. The template creates an Ubuntu VM, installs Apache2, php5, mysql server 5.5 and creates two simple php files. Go to ../info.php to see php deploy status; go to ../mysql.php to see mysql deploy status.
The mysql server 5.5 user root has empty password, and it is accessible only from localhost. You can set the root password and grant privileges later.
