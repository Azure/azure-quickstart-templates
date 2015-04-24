Param(
  [string]$resourceGroupName,
  [string]$region,
  [string]$keyVaultName,
  [string]$keyName,
  [string]$pfxFile
)

# Import the key vault management scripts, will most likely become part of the Azure PowerShell tools at some point
# import-module .\KeyVaultManager

# Switch to ARM mode in PowerShell
Switch-AzureMode -Name AzureResourceManager

# Create a new Util resource group in the correct region
$resourceGroup = Get-AzureResourceGroup -ResourceGroupName $resourceGroupName 2>$null
if (!$resourceGroup) {
	Write-Host "Creating new resource group with name '$resourceGroupName'."
	New-AzureResourceGroup -Name $resourceGroupName -Location $region
} 
else {
	Write-Host "Resource group '$resourceGroupName' already exists."
}

# Create a new key vault in the Util resource group
$keyVault = Get-AzureKeyVault -VaultName $keyVaultName 2>$null
if (!$keyVault) {
	Write-Host "Creating new key vault with name '$keyVaultName'."
	New-AzureKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $region -EnabledForDeployment
}
else {
	Write-Host "Key vault '$keyVaultName' already exists."
}

# Format and upload the .pfx certificate to the Key Vault
$fileContentBytes = get-content $pfxFile -Encoding Byte
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)

$jsonObject = @"
{
"data": "$filecontentencoded",
"dataType" :"pfx",
"password": ""
}
"@

$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes)

$secret = ConvertTo-SecureString -String $jsonEncoded -AsPlainText -Force
$key = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name $keyName -SecretValue $secret
$url = $key.Id

Write-Host "Key has been uploaded successfully"
Write-Host " - Url: $url"
