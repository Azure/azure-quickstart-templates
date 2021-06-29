# Ubuntu Apache2 Web server with your test page

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/ubuntu-apache-test-page/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/ubuntu-apache-test-page/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/ubuntu-apache-test-page/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/ubuntu-apache-test-page/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/ubuntu-apache-test-page/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/apache/ubuntu-apache-test-page/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fapache%2Fubuntu-apache-test-page%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fapache%2Fubuntu-apache-test-page%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fapache%2Fubuntu-apache-test-page%2Fazuredeploy.json)

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





