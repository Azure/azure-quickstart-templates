# Create a Managed Certificate (Free) for an APEX domain (aka root/naked domain)

[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-create-managed-certificate-apex%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-create-managed-certificate-apex%2Fazuredeploy.json)


To deploy this template, you need to have the following resources:

1. Create an App Service Plans (serverFarm)
2. Create a App Services on the previous App Service Plan
3. Add a root custom domain to the Web App. (i.e. contoso.com).  For that you will need:

    a. Go the the App Services => Custom Domains and take note of IP Address and Custom Domain Verification ID

    b. Under your dns zone (contoso.com) create 2 DNS records:

    | Record | Type | Value                           |
    | -------| ---- | ------------------------------- |
    | @      |   A  |  (IP Address from step a)       |
    | asuid  | TXT  |  (Custom Domain Verification ID)|
    |        |      |                                 |
 
    c. Add your root domain -> App Services => Custom Domains -> Add custom domain. (ie contoso.com).

    More information can be found [here](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain?tabs=cname).

4. **Make sure you Web App does not have any Network restriction or redirection (such as http to https or to another url).**

This arm deployment will:

1. Create a Managed Certificate (Free).

The operation is expected to take some time.