


# Install a Spark Environment on Suse Enterprise Server VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspark-on-suse%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fspark-on-suse%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


How to run this template from Powershell
----------------------------------------

Login with your account using Add-AzureRmAccount

List and select your subsription id Set-AzureRmContext -SubscriptionID <YourSubscriptionId>

Create a specific resource group New-AzureRmResourceGroup -Name sparkOnSuseRG -Location "East US"

Launch the deploy
New-AzureRmResourceGroupDeployment -ResourceGroupName sparkOnSuseRG -administratorLogin exampleadmin -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/spark-on-suse/azuredeploy.json 

When deploying from local use

New-AzureRmResourceGroupDeployment -ResourceGroupName sparkOnSuseRG -administratorLogin exampleadmin -TemplateFile C:\Azure\azure-quickstart-templates\master\spark-on-suse\azuredeploy.json 