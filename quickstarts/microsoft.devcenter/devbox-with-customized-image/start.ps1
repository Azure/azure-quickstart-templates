$userPrincipalName = Read-Host "Please enter user principal name e.g. alias@xxx.com"
$resourceGroupName = Read-Host "Please enter resource group name e.g. rg-devbox-dev"
$location = Read-Host "Please enter region name e.g. eastus"
$userPrincipalId=(Get-AzADUser -UserPrincipalName $userPrincipalName).Id
if($userPrincipalId){
    Write-Host "Start provisioning..."
    az group create -l $location -n $resourceGroupName
    az group deployment create -g $resourceGroupName -f main.bicep --parameters userPrincipalId=$userPrincipalId
}else {
    Write-Host "User Principal Name cannot be found."
}

Write-Host "Provisioning Completed."