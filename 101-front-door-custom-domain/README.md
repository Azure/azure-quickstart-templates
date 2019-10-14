# Onboard a custom domain with Front Door

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-front-door-custom-domain/CredScanResult.svg" />&nbsp;
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-front-door-custom-domain%2Fazuredeploy.json" target="_blank">
    
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

This template Creates a Front Door configuration with a single backend, onboards a custom domain with a path match '/*' for default frontend host and custom domain

Parameters for this template are
frontDoorName - Name of the frontdoor (ex: contoso)
customDomainName - FQDN name of the custom domain (ex: www.contoso.com)
backendaddress - FQDN of the backend (ex: www.contoso-backend.azurewebsites.com)

For the deployment of this template to succeed the specified custom domain will require a CNAME to the Front Door's default frontend host (say contoso.azurefd.net).

For example, for a frontdoor named "contoso", default frontend host name would be "contoso.azurefd.net". To add a custom domain "www.contoso.com", CNAME www.contoso.com to contoso.azurefd.net

For more details - https://docs.microsoft.com/en-us/azure/frontdoor/front-door-custom-domain

