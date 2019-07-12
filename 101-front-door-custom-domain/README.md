# Onboard a custom domain with HTTPS (AFD managed cert) with Front Door
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-front-door-custom-domain%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template configures a custom domain with HTTPS (AFD managed cert) with **Front Door**.

For the deployment of this template to succeed the specified domain will require a CNAME to the Front Door address.

An example would be:

AFD hostname: contoso.azurefd.net
CNAME www.contoso.com to contoso.azurefd.net