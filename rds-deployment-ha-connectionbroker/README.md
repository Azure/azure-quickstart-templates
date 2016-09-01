﻿# Provide High Availability to RDG and RDWA Server on top of Remote Desktop Session Collection deployment

This template deploys the following resources:

<ul><li>a connection broker vm</li></ul>

The template will join all new VM’s to the domain.
•	Deploy RDS roles in the deployment.
•	Join new VM's to the existing web and Gateway farm of basic RDS deployment.
•	Change the existing connection broker to HA mode and install the SQL clients

Prerequisites:
RDS-deployment-HA-CB is an extension to the Basic-RDS-Deployment and it is mandatory to deploy any one of the template as prerequisite “rds-deployment”, “rds-deployment-custom-image-rdsh”, “rds-deployment-existing-ad”
This template expects the same names of resources from RDS deployment, if resource names are changed in your deployment then please edit the parameters and resources accordingly, example of such resources are below:
StorageAccountName: Resource must be exact same to existing RDS deployment.
publicIpRef : Resource must be exact same to existing RDS deployment.
availabilitySets : Resource must be exact same to existing RDS deployment.
Load-balancer : Load balancer name, Backend pool, LB-rules, Nat-Rule and NIC.
VM’s – VM name classification which is using copy index function.
NIC – NIC naming convention.


Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frds-deployment-HA%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frds-deployment-HA%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
