try {
    Import-Module AzureAD
    Write-Host "Azure Active Directory Module exists"
} 
catch {
    Write-Host "Module does not exist - installing Azure Active Directory Module"
    Install-Module AzureAD -AllowClobber
    Import-Module AzureAD
}

$user = Connect-AzureAD

$userObjectID = (Get-AzureADUser -ObjectId $user.account.id).ObjectId

Write-Host "Your User Object ID for the ARM Template is $userObjectID"
pause