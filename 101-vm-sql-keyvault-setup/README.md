# This template setup Azure Key Vault on any existing Azure Virtual machine with SQL Server Standard or Enterprise edition.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-keyvault-setup%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-keyvault-setup%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template setup Azure Key Vault on any existing Azure Virtual machine with SQL Server Standard or Enterprise edition. Azure Key Vault provider is configured on SQL Server as an EKM provider and a new credential is created on the SQL Server that with its keys secured in Azure Key Vault provided in the parameters. User can also create credentials on the server using the same provider and store.

