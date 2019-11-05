# Deploy OpenLDAP on Ubuntu on a single VM.

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openldap-singlevm-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openldap-singlevm-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openldap-singlevm-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openldap-singlevm-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openldap-singlevm-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openldap-singlevm-ubuntu/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenldap-singlevm-ubuntu%2Fazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenldap-singlevm-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys OpenLDAP on Ubuntu. It creates a single Ubuntu VM and does a silent install of OpenLDAP on it. It also installs TLS support and PhpLDAPAdmin. After the deployment is successful, you can go to /phpldapadmin to start working with OpenLDAP or access it directly from the LDAP endpoint.

## Certificates:
In order to support TLS, this template creates self signed certificates as a part of the installation script. This allows the template to be deployed without having to create your own certificates. In production deployments, you will need to create and use your own certificates instead of the self signed certificates.

