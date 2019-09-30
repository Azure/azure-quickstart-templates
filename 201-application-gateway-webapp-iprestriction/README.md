# Creates an application gateway in front of an Azure Web App with IP restriction enabled on the Web App.

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-application-gateway-webapp-iprestriction/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-application-gateway-webapp-iprestriction/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-application-gateway-webapp-iprestriction/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-application-gateway-webapp-iprestriction/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-application-gateway-webapp-iprestriction/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-application-gateway-webapp-iprestriction/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-application-gateway-webapp-iprestriction%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-application-gateway-webapp-iprestriction%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys an Application Gateway in front of an Azure Web App with IP restriction on the public IP of the Application Gateway. The IP restriction is set on the IP of the Application Gateway when the deployment is made. This public IP address can change if the Application Gateway is stopped and should be modified manually on the Web App afterwards.

