# Create a Managed Certificate (Free) for an APEX domain (aka root/naked domain)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-managed-certificate-apex/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-managed-certificate-apex/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-managed-certificate-apex/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-managed-certificate-apex/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-managed-certificate-apex/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-managed-certificate-apex/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fapp-service-managed-certificate-apex%2Fazuredeploy.json) [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fapp-service-managed-certificate-apex%2Fazuredeploy.json)

To deploy this template, you need to have the following resources:

1. Create an App Service Plan (serverFarm).
2. Create a App Services on the previous App Service Plan.
3. Add a APEX custom domain to the App Services. (i.e. contoso.com).  For that you will need:

    a. Go the the App Services => Your App => Custom Domains and take note of IP Address and Custom Domain Verification ID

    b. Under your dns zone (contoso.com) create 2 DNS records:

    | Record | Type | Value                           |
    | -------| ---- | ------------------------------- |
    | @      |   A  |  (IP Address from step a)       |
    | asuid  | TXT  |  (Custom Domain Verification ID)|
    |        |      |                                 |

    c. Add your root domain going to -> App Services => Custom Domains -> Add custom domain. (ie contoso.com).

    More information can be found [here](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain?tabs=cname).

4. **Make sure you Web App does not have any Network restriction or redirection (such as http to https or to another url).**

This arm deployment will:

1. Create a Managed Certificate (Free).

The operation is expected to take some time.
