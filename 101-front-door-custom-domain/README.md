# Onboard a custom domain with Front Door

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-front-door-custom-domain%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-front-door-custom-domain%2Fazuredeploy.json)

This template Creates a Front Door configuration with a single backend, onboards a custom domain with a path match '/*' for default frontend host and custom domain, and then secures custom domain with a Front Door managed certificate.

Parameters for this template are
frontDoorName - Name of the frontdoor (ex: contoso)
customDomainName - FQDN name of the custom domain (ex: www.contoso.com)
backendaddress - FQDN of the backend (ex: www.contoso-backend.azurewebsites.com)

For the deployment of this template to succeed the specified custom domain will require a CNAME to the Front Door's default frontend host (say contoso.azurefd.net).

For example, for a frontdoor named "contoso", default frontend host name would be "contoso.azurefd.net". To add a custom domain "www.contoso.com", CNAME www.contoso.com to contoso.azurefd.net

For more details - https://docs.microsoft.com/en-us/azure/frontdoor/front-door-custom-domain


