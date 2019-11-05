# Vert.x, OpenJDK, Apache, and MySQL Server on Ubuntu VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vertx-openjdk-apache-mysql-on-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vertx-openjdk-apache-mysql-on-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vertx-openjdk-apache-mysql-on-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vertx-openjdk-apache-mysql-on-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vertx-openjdk-apache-mysql-on-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/vertx-openjdk-apache-mysql-on-ubuntu/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvertx-openjdk-apache-mysql-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fvertx-openjdk-apache-mysql-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template uses the Azure Linux CustomScript extension to deploy Vert.x, OpenJDK, Apache, and MySQL Server on Ubuntu 14.04 LTS to create a ready development environment using Vert.x.

It downloads Vert.x installation files from the location you specify and creates a symlink so you don't have to browse to Vert.x folder. It also install MySQL server in non-interactive mode with the password you specify.

All these parameters may be edited in install.sh script.

