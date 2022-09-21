<# Uncomment and run the following 5 lines of code if you are running the script locally and the AzureAD PowerShell module is not installed:

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Name AzureAD -Scope CurrentUser -Repository PSGallery -Force
Get-InstalledModule -Name AzureAD -AllVersions
Find-Module -Name AzureAD

#>

# Enter your Azure AD username for the $name variable 
$name = "<AAD_Username>"

$null = Connect-AzureAD

$output = $(Get-AzureADUser -Filter "UserPrincipalName eq '$name'").ObjectId
Write-Host "Azure AD principal object ID is: $output"