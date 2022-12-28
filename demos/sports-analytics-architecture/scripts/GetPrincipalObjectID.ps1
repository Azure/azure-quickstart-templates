<# Uncomment and run the following 2 lines of code if you are running the script locally and the AzureAD PowerShell module is not installed:

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

#>

# Enter your Azure AD username for the $name variable 
$name = "<AAD_Username>"

$null = Connect-AzureAD

$output = (Get-AzAdUser -UserPrincipalName $name).Id
Write-Host "Azure AD principal object ID is: $output"