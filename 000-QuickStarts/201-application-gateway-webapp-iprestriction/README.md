# Creates an application gateway in front of an Azure Web App with IP restriction enabled on the Web App.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-application-gateway-webapp-iprestriction%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-application-gateway-webapp-iprestriction%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys an Application Gateway in front of an Azure Web App with IP restriction on the public IP of the Application Gateway. The IP restriction is set on the IP of the Application Gateway when the deployment is made. This public IP address can change if the Application Gateway is stopped and should be modified manually on the Web App afterwards.
