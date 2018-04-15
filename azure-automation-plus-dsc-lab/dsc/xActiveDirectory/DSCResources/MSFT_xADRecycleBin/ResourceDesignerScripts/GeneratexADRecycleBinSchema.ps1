New-xDscResource -Name MSFT_xADRecycleBin -FriendlyName xADRecycleBin -ModuleName xActiveDirectory -Path . -Force -Property @(
    New-xDscResourceProperty -Name ForestFQDN -Type String -Attribute Key
    New-xDscResourceProperty -Name EnterpriseAdministratorCredential -Type PSCredential -Attribute Required
    New-xDscResourceProperty -Name RecycleBinEnabled -Type Boolean -Attribute Read
    New-xDscResourceProperty -Name ForestMode -Type String -Attribute Read
)
