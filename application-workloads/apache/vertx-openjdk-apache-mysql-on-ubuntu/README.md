# Vert.x, OpenJDK, Apache, and MySQL Server on Ubuntu VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/vertx-openjdk-apache-mysql-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/vertx-openjdk-apache-mysql-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/vertx-openjdk-apache-mysql-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/vertx-openjdk-apache-mysql-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/vertx-openjdk-apache-mysql-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/vertx-openjdk-apache-mysql-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fapache%2Fvertx-openjdk-apache-mysql-on-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fapache%2Fvertx-openjdk-apache-mysql-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fapache%2Fvertx-openjdk-apache-mysql-on-ubuntu%2Fazuredeploy.json)

This template uses the Azure Linux CustomScript extension to deploy Vert.x, OpenJDK, Apache, and MySQL Server on Ubuntu 14.04 LTS to create a ready development environment using Vert.x.

It downloads Vert.x installation files from the location you specify and creates a symlink so you don't have to browse to Vert.x folder. It also install MySQL server in non-interactive mode with the password you specify.

All these parameters may be edited in install.sh script.


