# params
$location = "LOCATION"
$ResourceGroupName = "GEN-KEYVAULT-RESOURCEGROUP-NAM"
$KeyVaultName = "GEN-KEYVAULT-NAME"
$KeyName = "GEN-KEYVAULT-ENCRYPTION-KEY"

#Connect to your Azure account
# Add-AzureAccount

#Select your subscription if you have more than one
# Select-AzureSubscription -SubscriptionName "My Subscription Name"

# Create a new Key vault, with enable soft delete (prerequisites to use a stored key as encryption protector for SQL)
New-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $location -EnableSoftDelete

# Generate a key
Add-AzureKeyVaultKey -VaultName $KeyVaultName -Name $KeyName -Destination 'Software'