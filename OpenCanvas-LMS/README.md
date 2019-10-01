# OpenCanvas Installation on Azure

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/OpenCanvas-LMS/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/OpenCanvas-LMS/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/OpenCanvas-LMS/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/OpenCanvas-LMS/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/OpenCanvas-LMS/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/OpenCanvas-LMS/CredScanResult.svg" />&nbsp;
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2FOpenCanvas-LMS%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2FOpenCanvas-LMS%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## OpenCanvas template 

This template deploys OpenCanvas on Ubuntu 16.04
* Deploys on a Ubuntu VM 16.04
* The template installs postgres9.5 version and a new database is created

### Deployment steps

You can click the "deploy to Azure" button at the beginning of this document.

### Parameters to provide while deploying

+ **adminVMUsername**: Provide admin VM username
+ **adminVMPassword**: Provide admin VM password
+ **dnsNameForPublicIP**: Provide unique name for public IP
+ **smtpEmail**: Provide SMTP email for mail configuration
+ **postgresPassword**: Provide postgres password
+ **adminLoginEmail**: Provide admin login email for OpenCanvas LMS
+ **adminLoginPassword**: Provide admin login password for OpenCanvas LMS
+ **adminAccountName**: Provide admin account name for eg: your organization name
+ **lms_stat_coll**: Provide CANVAS_LMS_STATS_COLLECTION value. Options are "opt_in", "opt_out", or "anonymized"
+ **smtp_type**: Provide SMTP type for mail configuration
+ **smtp_port**: Provide SMTP port for mail configuration
+ **smtp_pass**: Provide SMTP password for mail configuration

### How to access the OpenCanvas Site
* You can access the site using the domain/host name you provide as the paramater while deploying the template. 

