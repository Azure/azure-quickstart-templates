. "$PSScriptRoot\New-SqlServerVirtualMachine.ps1"


$PlainPassword = "Pa55word1"
$AdminPassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

New-SqlServerVirtualMachine -SubscriptionId "e192531b-7c84-4681-aff9-644e1db18774" `
                            -ResourceGroupName "ojtestvmcsmvrg" `
                            -TemplatePath "azuredeploy.json" `
                            -VmName "ojtestvmcsmvt" `
                            -VmSize "Standard_D4" `
                            -VmLocation "westus" `
                            -Username "zodaicman" `
                            -Password $AdminPassword `
                            -StorageName "ojtestvmcsmvstore" `
                            -StorageType "Standard_GRS" `
                            -VnetName "ojtestvmcsmvnet" `
                            -NetworkAddressSpace "10.10.0.0/26" `
                            -SubnetName "Subnet-1" `
                            -SubnetAddressPrefix "10.10.0.0/28"
