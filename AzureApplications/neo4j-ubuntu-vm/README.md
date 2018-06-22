# Deploy Neo4J in Ubuntu VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fneo4j-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fneo4j-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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
