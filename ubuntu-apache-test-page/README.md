# Ubuntu Apache2 Web server with your test page

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-apache-test-page/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-apache-test-page/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-apache-test-page/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-apache-test-page/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-apache-test-page/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-apache-test-page/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fubuntu-apache-test-page%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fubuntu-apache-test-page%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to quickly create an Ubuntu VM running Apache2 with the test page content you define as a parameter. This can be useful for quick validation/demo/prototyping.

## Static Test Page

To deploy a static test page:

1. Push Deploy to Azure button.
2. Choose admin credentials for the new Web server.
3. Choose DNS name for the new Web server.
4. Enter page name, title and static HTML body markup.
5. Enter resource group name and location for it.
6. Start template deployment.

## PHP Test Page

To deploy a PHP test page:

1. Push Deploy to Azure button.
2. Choose admin credentials for the new Web server.
3. Choose DNS name for the new Web server.
4. Enter page name, title and PHP body markup.
5. Set INSTALLPHP to "true".
6. Enter resource group name and location for it.
7. Start template deployment.

## After Deployment

Once your test Web server is created use domain name and page name you entered to access the Web page with your markup. 
Full URL to the test page will be: http://\<DNS name entered\>.\<resource group location\>.cloudapp.azure.com/\<page name or none for index page\>
(example: http://mytestserver.westeurope.cloudapp.azure.com)





