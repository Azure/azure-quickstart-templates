# Create a Managed Certificate (Free) for an APEX domain (aka root/naked domain)

[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-create-managed-certificate-apex%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-create-managed-certificate-apex%2Fazuredeploy.json)


To deploy this template, you need to have the following resources:

1. The App Service Plan (serverFarm) resource name that the Web App is running.
2. The domain should already be bound under Web App Custom Domain.
3. Use the Resource Group where the App Service Plan is located to create the Managed Certificate.
4. **Make sure you Web App does not have any Network restriction or redirection (such as http to https or to another url).**

This arm deployment will:

1. Create a Managed Certificate (Free).

The operation is expected to take some time.


You can also deploy using the powershell:

````
#Connect-AzureRmAccount

$subscription = "XXXXX-XXXX-XXX-XXXX-XXXXXXX"
$resourceGroupName = "MyResourceGroupwheretheASPislocated"
$appServicePlanName = "ASP-TEST-CERT"
$subjectName = "contoso.com"

Set-AzureRmContext -SubscriptionId $subscription

$appServicePlan = Get-AzureRmResource `
    | Where-Object {$_.ResourceGroupName -eq $resourceGroupName } `
    | Where-Object {$_.Name -eq $appServicePlanName}

New-AzureRMResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -SubjectName $subjectName `
    -AppServicePlanName $appServicePlanName `
    -Location $appServicePlan.Location `
    -TemplateFile "azuredeploy.json" 
````