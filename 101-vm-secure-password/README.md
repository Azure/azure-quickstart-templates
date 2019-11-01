# Very simple deployment of a Windows VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-secure-password/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-secure-password/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-secure-password/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-secure-password/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-secure-password/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-vm-secure-password/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-secure-password%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-secure-password%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy a simple Windows VM by retrieving the password that is stored in a Key Vault. Therefore the password is never put in plain text in the template parameter file.

## Add Secret to the Key Vault
You can add the password to the Key Vault using the below commands:

#### PowerShell
```
$Secret = ConvertTo-SecureString -String 'Password' -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName 'Contoso' -Name 'ITSecret' -SecretValue $Secret
```
#### CLI
```
az keyvault secret set --vault-name Contoso --name ITSecret --value 'password'
```

## Enable Key Vault for VM and Template secret access
After this you'll need to enable the Key Vault for template deployment. You can do this using the following commands:

## PowerShell
```
Set-AzKeyVaultAccessPolicy -VaultName Contoso -EnabledForTemplateDeployment
```

### CLI
```
az keyvault update  --name Contoso --enabled-for-template-deployment true
```

