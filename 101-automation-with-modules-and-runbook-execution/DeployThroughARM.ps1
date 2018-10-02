
#Connect to your Azure account
Add-AzureRmAccount

#Select your subscription if you have more than one
#Select-AzureSubscription -SubscriptionName "My Subscription Name"
$JobGUID = [System.Guid]::NewGuid().toString()
#Set the parameter values for the template
#provide webapp name for which you want to set app settings as appId and key to access and manage resources through it.
#provide resource group name of the web app
$Params = @{
    WebAppName = "webappname";
    jobId = $JobGUID;
    WebAppResourceGroup = "WebAppResourceGroup";
    UserEmail = "MyUserName"; 
    Password = "MyPassword";
    regionId = "Japan East";
    SubscriptionName = "MySubsName";
}

$TemplateURI = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-automation-with-modules-and-runbook-execution/azuredeploy.json"

New-AzureRmResourceGroupDeployment -TemplateParameterObject $Params -ResourceGroupName "MyResourceGroup" -TemplateUri $TemplateURI

