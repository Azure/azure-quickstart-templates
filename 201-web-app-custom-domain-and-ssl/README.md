# Create a Web App with a Custom Domain and Optional SSL Binding

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-web-app-custom-domain-and-ssl/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-web-app-custom-domain-and-ssl/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-web-app-custom-domain-and-ssl/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-web-app-custom-domain-and-ssl/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-web-app-custom-domain-and-ssl/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-web-app-custom-domain-and-ssl/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f201-web-app-custom-domain-and-ssl%2fazuredeploy.json)
[![Deploy to Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f201-web-app-custom-domain-and-ssl%2fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f201-web-app-custom-domain-and-ssl%2fazuredeploy.json)

This template will create a web app with a custom domain. You can optionally add a SSL certificate to the custom domain.  If you want to add the SSL certficate you must complete the following steps before deployment:

- Upload a certificate to KeyVault [here](https://github.com/Azure/azure-quickstart-templates/tree/master/201-web-app-certificate-from-key-vault)
- Create the required DNS record for adding custom hostname as described [here](https://docs.microsoft.com/en-us/azure/app-service-web/web-sites-custom-domain-name)
