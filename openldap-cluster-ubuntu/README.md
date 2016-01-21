# Deploy OpenLDAP cluster on Ubuntu.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenldap-cluster-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template deploys an OpenLDAP cluster on Ubuntu. It creates multiple Ubuntu VMs and does a silent install of OpenLDAP on them. It also installs TLS support and PhpLDAPAdmin. Then it sets up N-way multi-master replication on them. After the deployment is successful, you can go to /phpldapadmin to start working with OpenLDAP or access it directly from the LDAP endpoint.

This template can instantiate up to 5 front end VM's. This number can be increased easily by copying and pasting the related parts of the template. 

## Port Details:
The template opens HTTP port 80 for web access and 389 for LDAP on all the front end VM's. These port are load-balanced using the load balancer.
It also opens ports 2200 to 2204 on the load balancer which are mapped to port 22 for SSH admin access on the respective VM's.

## Certificates:
In order to support TLS, this template creates self signed certificates as a part of the installation script. This allows the template to be deployed without having to create your own certificates. In production deployments, you will need to create and use your own certificates instead of the self signed certificates.