# Deploy Shibboleth sp on Centos on a single VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fshibboleth-sp-singlevm-centos%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmoodle-singlevm-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys Shibboleth SP on Centos. It creates a single centos VM, does a silent install of Apache, and then deploys Shibboleth SP on it. After the deployment is successful, you can go to https://your-domain/idp/Shibboleth.sso/status to check success. For further details, please refer to the Shibboleth SP documentation at https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLinuxInstall

# Certificate:

In order to support SSL, this template creates a self signed certificate as a part of the installation script. This allows the template to be deployed without having to create your own certificate. In production deployments, you will need to create and use your own certificate instead of the self signed certificate.

# Test Setup
Here are the steps you can follow to create a testing setup including Shibboleth SP deployed using this template.

## Deploy Shibboleth SP using this template.
Create a deployment of Shibboleth SP using this template and SSH into the VM deployed.

## TestShibboleth using <a href="http://www.testshib.org/">TestShib</a> 
1. To test shibboleth SP download metadata file from https://your-domain/idp/Shibboleth.sso/Metadata and rename metadata file with unique identifier.
2. Upload metadata file here: http://www.testshib.org/register.html 
3. Back up the existing configuration file then Generate and save the right shibboleth2.xml for your installation
4. Overrite generated configuration with **/etc/shibboleth/shibboleth2.xml**

## Restart apache and shibd service 
systemctl restart shibd
systemctl restart httpd
