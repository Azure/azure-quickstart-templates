###Deploy Instructions: Deploys resources to an RG

[Tutorial on ARM Template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-create-first-template?tabs=azure-powershell)
[Tutorial for Powershell Deploy Cmdlet](https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azresourcegroupdeployment?view=azps-4.5.0)

Preparation
```powershell
Connect-AzAccount
Set-AzContext [SubscriptionID/SubscriptionName]
(optional) New-AzResourceGroup -Name myResourceGroup -Location "Central US"
```

Deploy
```powershell

```
