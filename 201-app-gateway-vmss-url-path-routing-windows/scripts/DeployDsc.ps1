#  Script to create the DSC on a storage account

Publish-AzureRmVMDscConfiguration -ConfigurationPath "< CorpWeb.ps1 full path>" -ResourceGroupName Demo-Set -StorageAccountName <Storage Account Name> -Force