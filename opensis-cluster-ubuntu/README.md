# Deploy OpenSIS Community Edition cluster on Ubuntu

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fopensis-cluster-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopensis-cluster-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys OpenSIS Community Edition as a LAMP application on Ubuntu in a clustered configuration. It creates a one or more Ubuntu VM for the front end and a single VM for the backend. It does a silent install of Apache and PHP on the front end VM's and MySQL on the backend VM. Then it deploys OpenSIS Community Edition on the cluster. After the deployment is successful, you can go to /opensis on each frontend VM (using web admin access described below) to start congfiguring OpenSIS.
 
# Notes

## Front end VM's:
This template can instantiate up to 5 front end VM's. This number can be increased easily by copying and pasting the related parts of the template. 

## Port Details:
The template opens HTTP port 80 for normal end user access on all the front end VM's. This port is then load-balanced using the load balancer.
It also opens ports 8080 to 8084 on the load balancer which are mapped to the port 8080 on each of the front end VM's respectively. These can be used for web admin access to individual front end VM's.
Similarly it opens ports 2200 to 2204 on the load balancer which are mapped to port 22 for SSH admin access on the respective VM's.

## Workaround for OpenSIS installer issue
The OpenSIS installer expects to create a database from scratch. when you run the installer on the first front end VM, it will create the database. When you run the installer on subsequent VM's, it will complain that the database already exists. There is no option to tell it to simply reuse the existing database. To get around this issue, let the installer recreate the database for each new front end VM and perform any further operations on the database after the last VM is configured.
