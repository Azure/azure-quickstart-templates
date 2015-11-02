# Azure Traffic Manager External Endpoints

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FGarethBradshawMSFT%2Fazure-quickstart-templates%2Fmaster%2F101-traffic-manager-external-endpoint%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This is a template that shows how to create an Azure Traffic Manager profile using external endpoints and the performance routing method.  To enable performance-based routing each endpoint needs an "endpointLocation" that specifies the closes Azure region.

The accompanying PowerShell script shows how to create a resource group from a template and read back the Traffic Manager profile.
