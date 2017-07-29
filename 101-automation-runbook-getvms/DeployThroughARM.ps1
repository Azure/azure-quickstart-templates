
#Connect to your Azure account
Add-AzureRmAccount

#Select your subscription if you have more than one
#Select-AzureSubscription -SubscriptionName "My Subscription Name"

#Create a GUID for the job
$JobGUID = [System.Guid]::NewGuid().toString()

#Set the parameter values for the template
$Params = @{
    accountName = "MyAccount" ;
    jobId = $JobGUID;
    regionId = "Japan East";
    credentialName = "DefaultAzureCredential";
    userName = "MyUserName"; 
    password = "MyPassword";
}

$TemplateURI = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-automation-runbook-getvms/azuredeploy.json"

New-AzureRmResourceGroupDeployment -TemplateParameterObject $Params -ResourceGroupName "MyResourceGroup" -TemplateUri $TemplateURI

