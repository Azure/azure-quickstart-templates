# Deploy Neo4J in Ubuntu VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/neo4j-ubuntu-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/neo4j-ubuntu-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/neo4j-ubuntu-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/neo4j-ubuntu-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/neo4j-ubuntu-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/neo4j-ubuntu-vm/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fneo4j%2Fneo4j-ubuntu-vm%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fneo4j%2Fneo4j-ubuntu-vm%2Fazuredeploy.json) 
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fneo4j%2Fneo4j-ubuntu-vm%2Fazuredeploy.json)

Built by: [helshabini](https://github.com/helshabini)

This template allows you to deploy an Ubuntu Server VM
and starts a Neo4J instance listening on ports 7687(bolt), 7474 (non-ssl), 7473 (ssl).

After the virtual machine is deployed you can access Neo4J by browsing to http://{hostname}:7474/

Default username: neo4j

Default password: neo4j

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| vmName | Virtual machine name. |
| vmSize | Virtual machine size. |
| vmUbuntuOSVersion | Ubuntu OS image version. |
| storageaccountPrefix | Storage account name prefix. |
| storageaccountType | Storage account type. Premium storage is recommended for graph databases. |
| vmAdminUsername  | User name for the virtual machine. |
| sshKeyData  | SSH rsa public key file as a string. |
| neo4jEdition | Neo4J edition and version to install. |
| publicIPAddressDns  | Unique DNS for public IP Address. |


