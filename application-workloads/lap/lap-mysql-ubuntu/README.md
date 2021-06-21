# Install a LAP node and another MYSQL node on Ubuntu Virtual Machines using Custom Script Linux Extension

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-mysql-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-mysql-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-mysql-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-mysql-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-mysql-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-mysql-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Flap%2Flap-mysql-ubuntu%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Flap%2Flap-mysql-ubuntu%2Fazuredeploy.json)   
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Flap%2Flap-mysql-ubuntu%2Fazuredeploy.json)

This template deploys a LAP(linux+apache2+php5) node on an Ubuntu virtual machine and a MYSQL(mysql server 5.5) node on an additional VM. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

This template deploys a LAP node and a MYSQL node, will create simple info.php, mysql.php and remotemysql.php(test if can connect to mysql server on MYSQL node) on LAP node to test if the deployment is successful or not.
 
The LAP node is exposed on a public IP address that you can access through a browser on port :80 as well as SSH on the standard port. 
The MYSQL node only has private ip address, and it's static ip address, the mysql database only allows to be accessed from LAP node.
The Mysql server user root has empty password, you can set the password later.
Only support one MYSQL node now.

##Known Issues and Limitations
- The template does not currently configure SSL on the nodes.
- The template uses username/password for provisioning and would ideally use an SSH key.
- The template only support one LAP node and one Mysql node now.
- The deployment scripts are not currently idempotent and this template should only be used for provisioning new.


