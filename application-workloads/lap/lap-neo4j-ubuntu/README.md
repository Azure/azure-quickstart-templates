# Install a LAP node and another Neo4J node on Ubuntu Virtual Machines using Custom Script Linux Extension

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-neo4j-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-neo4j-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-neo4j-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-neo4j-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-neo4j-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/lap/lap-neo4j-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Flap%2Flap-neo4j-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Flap%2Flap-neo4j-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Flap%2Flap-neo4j-ubuntu%2Fazuredeploy.json)

This template deploys a LAP(linux+apache2+php5) node on an Ubuntu virtual machine and a Neo4J(Latest stable Neo4J) node on an additional VM. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

This template deploys a LAP node and a Neo4J node, will create simple info.php and neo4jtest.php (test if can connect to Neo4J server on Neo4J node) on LAP node to test if the deployment is successful or not.
 
The LAP node is exposed on a public IP address that you can access through a browser on port :80 as well as SSH on the standard port. 
The Neo4J node only has private ip address, and it's static ip address, the Neo4J database only allows to be accessed from LAP node.
The Neo4J server username and password are 'neo4j' and 'neo4j' respectively.
Only support one Neo4j node for now.

# LAP Configuration
- LAP configuration is done by the custom script extension, code is present in install-lap.sh.
- This script installs apache and PHP.
- Creates file info.php for testing php.  
- Installs Composer in /var/www/html directory.
- Add the composer.json and the required Neo4J client library for PHP from https://github.com/neoxygen/neo4j-neoclient 
- Add the neo4jtest.php which uses the Neoxygen client library and tries to connect to the remote Neo4J server available at 10.0.0.10 (port 7474) and prints "Connected Successfully" if it can connect, otherwise prints it couldn't connect.
- At the end of file command "php composer.phar install" is ran to download all the dependencies.  

# Neo4J Configuration
- Neo4J is installed by the custom script extension, code is present in file install-neo4j.sh
- This script installs the Java8 and Neo4J server.
- Update the apt-key and add link to repo of Neo4J for Debian
- Update the apt-get 
- Install the Java8 - silently
- Install Neo4J
- Change the configuration to allow remote connections

## Known Issues and Limitations
- The template does not currently configure SSL on the nodes.
- The template uses username/password for provisioning and would ideally use an SSH key.
- The template only support one LAP node and one Mysql node now.
- The deployment scripts are not currently idempotent and this template should only be used for provisioning new.
- The Password for neo4j server must be changed from default, but the only way to do so could be is to open the Neo4J interface on browser using http://<serverip>:7474 which may not be as straight forward as the only means to access this server could be is from the LAP node, possible LYNX browser could be used to do so.



