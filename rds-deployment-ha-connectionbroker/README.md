# Provide High Availability to RDG and RDWA Server on top of Remote Desktop Session Collection deployment

This template deploys the following resources:

<ul><li>a connection broker vm</li></ul>

The template will join all new VM’s to the domain.
•	Deploy RDS roles in the deployment.
•	Join new VM's to the existing connection broker of the basic RDS deployment.
•	Change the existing connection broker to HA mode and install the SQL clients
•	Update the DNS server to add a new entry for the HA connection brokers


Prerequisites:
An SQL or Azure Database server must be created and a table for the Connection broker must be setup
RDS-deployment-HA-ConnectionBroker is an extension to the Basic-RDS-Deployment and it is mandatory to deploy any one of the template as prerequisite “rds-deployment”, “rds-deployment-custom-image-rdsh”, “rds-deployment-existing-ad”
This template expects the same names of resources from RDS deployment, if resource names are changed in your deployment then please edit the parameters and resources accordingly, example of such resources are below:
StorageAccountName: Resource must be the exact same in the existing RDS deployment.
ConnectionBrokerMachine: Resource must be exact same connection broker in the existing RDS deployment.
cb-AvailabilitySet : Resource must be the exact same as the availability set that the existing connection broker is in.
adminUsername : Name of the domain admin that has privileges on the existing deployment and can add a DNS entry.
adminPassword : Password of the domain admin
domainNetbios : the domain of the admin user, will be concated in the script to domain\adminUsername
imageSKU : The windows SKU to use for the ConnectionBroker must match the existing Connection Broker
clientURL : The web url to the Native SQL install msi, by default this is pulled from Microsoft servers.
PrimaryDBConstring :  The primary database connection string that is used to connect to the SQL or Azure SQL table that the connection brokers will use.
SecondaryDBConString : The secondary database connection string that is used to connect to the SQL or Azure SQL table that the connection brokers will use.
clientAccessName : The DNS entry that will be inserted into the AD DNS server for the HA connection brokers.
DNSServer : The name of the existing DNS server where the clientAccessName will be added.
adDomainName : The domain to join the server to

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fklondon71%2Fazure-quickstart-templates%2Fmaster%2Frds-deployment-ha-connectionbroker%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fklondon71%2Fazure-quickstart-templates%2Fmaster%2Frds-deployment-ha-connectionbroker%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>