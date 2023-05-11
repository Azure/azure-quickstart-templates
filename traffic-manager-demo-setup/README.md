# Azure Traffic Manager Demo Setup

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/traffic-manager-demo-setup/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/traffic-manager-demo-setup/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/traffic-manager-demo-setup/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/traffic-manager-demo-setup/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/traffic-manager-demo-setup/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/traffic-manager-demo-setup/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftraffic-manager-demo-setup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftraffic-manager-demo-setup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to quickly deploy Azure Traffic Manager demo to test distribution of the traffic between the endpoints in different regions.

## To Deploy Demo Setup

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
