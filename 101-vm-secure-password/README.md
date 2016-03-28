# Very simple deployment of a Windows VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-secure-password%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-secure-password%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a simple Windows VM by retrieving the password that is stored in a Key Vault. Therefore the password is never put in plain text in the template parameter file.

## Add Secret to the Key Vault
You can add the password to the Key Vault using the below commands:

#### PowerShell
```
$Secret = ConvertTo-SecureString -String 'Password' -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName 'Contoso' -Name 'ITSecret' -SecretValue $Secret
```
#### CLI
```
azure keyvault secret set --vault-name Contoso --secret-name ITSecret --value azurepass
```

## Enable Key Vault for VM and Template secret access
After this you'll need to enable the Key Vault for template deployment. You can do this using the following commands:

## PowerShell
```
Set-AzureRmKeyVaultAccessPolicy -VaultName Contoso -EnabledForTemplateDeployment
```

### CLI
```
azure keyvault set-policy --vault-name Contoso --enabled-for-template-deployment true
```
