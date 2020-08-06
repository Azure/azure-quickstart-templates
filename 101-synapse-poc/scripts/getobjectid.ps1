Connect-AzAccount
$userUPN = Read-Host -Prompt 'Enter your User Principal Name'

$userOID = (Get-AzADUser -UserPrincipalName $userUPN).Id

Write-Host "Your User Object ID for the ARM Template is $userOID"
pause