# Deploy OpenLDAP cluster on Ubuntu.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openldap/openldap-cluster-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openldap/openldap-cluster-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openldap/openldap-cluster-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openldap/openldap-cluster-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openldap/openldap-cluster-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openldap/openldap-cluster-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopenldap%2Fopenldap-cluster-ubuntu%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopenldap%2Fopenldap-cluster-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopenldap%2Fopenldap-cluster-ubuntu%2Fazuredeploy.json)

This template deploys an OpenLDAP cluster on Ubuntu. It creates multiple Ubuntu VMs and does a silent install of OpenLDAP on them. It also installs TLS support and PhpLDAPAdmin. Then it sets up N-way multi-master replication on them. After the deployment is successful, you can go to /phpldapadmin to start working with OpenLDAP or access it directly from the LDAP endpoint.

This template can instantiate up to 5 front end VM's. This number can be increased easily by copying and pasting the related parts of the template. 

## Port Details:
The template opens HTTP port 80 for web access and 389 for LDAP on all the front end VM's. These port are load-balanced using the load balancer.
It also opens ports 2200 to 2204 on the load balancer which are mapped to port 22 for SSH admin access on the respective VM's.

## Certificates:
In order to support TLS, this template creates self signed certificates as a part of the installation script. This allows the template to be deployed without having to create your own certificates. In production deployments, you will need to create and use your own certificates instead of the self signed certificates.


