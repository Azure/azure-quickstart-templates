# On an existing Web App, add a custom domain, create the DNS record to validate, Create a Managed Certificate (Free) and Secure the Web App

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/asp-webapp-customdomain-asmc-certificate/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/asp-webapp-customdomain-asmc-certificate/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/asp-webapp-customdomain-asmc-certificate/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/asp-webapp-customdomain-asmc-certificate/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/asp-webapp-customdomain-asmc-certificate/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/asp-webapp-customdomain-asmc-certificate/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fasp-webapp-customdomain-asmc-certificate%2Fazuredeploy.json) [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fasp-webapp-customdomain-asmc-certificate%2Fazuredeploy.json)


To deploy this template, you need to have the following resources:

1. The App Service Plan (serverFarm) resource name where you are running your Web App.
2. An existing Web App.
3. A domain purchased that has a DNS zone hosted at Azure DNS and that you have permission to write it.
   You can confirm the Name Server records (NS type) querying the domain at https://digwebinterface.com

   If you see DNS servers with hostname with  .azure-dns.com,  .azure-dns.net, .azure-dns.org, azure-dns.info, it confirms that your DNS server is hosted at Azure DNS.

   This requirement is because the template will create the DNS records needed to Bind the custom domain and validate the Managed Certificate ownership as part of it's process.

   In case your DNS is not hosted at Azure or you don't have permission  on the DNS zone, the Bind operation will fail *"A TXT record pointing from domain.com to 1111 was not found."*

   You can bypass it creating the record manually or customizing the template as needed.

4. **Make sure you Web App does not have any Network restriction or redirection (such as http to https or to another url). When generating certificate to the apex/root domain**

This arm deployment will:

1. Create DNS record with ASUID, CNAME or A at your Azure DNS zone responsible to resolve names at this domain. This will be used to validate your custom domain while adding to the Web App.
2. Add a Custom Domain to the Web App.
3. Create a Managed Certificate (Free).
4. Bind the Managed Certificate to the Web App.