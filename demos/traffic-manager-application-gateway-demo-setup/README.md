# Azure Traffic Manager over Application Gateways Demo Setup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/traffic-manager-application-gateway-demo-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/traffic-manager-application-gateway-demo-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/traffic-manager-application-gateway-demo-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/traffic-manager-application-gateway-demo-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/traffic-manager-application-gateway-demo-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/traffic-manager-application-gateway-demo-setup/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Ftraffic-manager-application-gateway-demo-setup%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Ftraffic-manager-application-gateway-demo-setup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Ftraffic-manager-application-gateway-demo-setup%2Fazuredeploy.json)

This template allows you to quickly deploy Azure Traffic Manager on top of Application Gateways demo to test distribution of the traffic between the endpoints in different regions.

## To Deploy Demo Setup:

1. Push Deploy to Azure button.
2. Enter DNS name for Traffic Manager profile.
3. If needed change traffic routing method (you can re-configure later).
4. Select locations for the endpoints.
5. Choose admin credentials for the backend Web servers.
6. Start template deployment.

## Testing Your Setup

Once your demo setup is ready use can access it using the DNS name entered (example: http://mytestserver.trafficmanager.net).

In order to try your test setup in action you can re-send your requests, bring down/up the VMs/Web servers created as a part of the deployment, change Azure Traffic Manager profile settings.

When your HTTP request hits backend server, you should be able to see a page like the one below:

![alt text](images/serverhit.png "Backend server response")




