$userPrincipalName = Read-Host "Please enter user principal name e.g. alias@xxx.com"
$resourceGroupName = Read-Host "Please enter resource group name e.g. rg-devbox-dev"
$userPrincipalId=(Get-AzADUser -UserPrincipalName $userPrincipalName).Id
if($userPrincipalId){
    Write-Host "Start provisioning..."
    az group deployment create -g $resourceGroupName -f grant-user-permission.bicep --parameters userPrincipalId=$userPrincipalId
}else {
    Write-Host "User Principal Name cannot be found."
}

Write-Host "Provisioning Completed."