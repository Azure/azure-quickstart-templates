Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Your Subscription Name"

$AdminPassword = ConvertTo-SecureString -String "VerySecure@1234" -AsPlainText -Force
$ResourceGroupName = "avlvmss2"
$SshPublicKey = "ssh-rsa AAAAB3N..."
$Region = "East US"

# Deploy ======================================================================================================================
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Region

New-AzureRmResourceGroupDeployment -Name "deploy" -ResourceGroupName $ResourceGroupName -TemplateFile .\azuredeploy.json `
    -artifactsBaseUrl "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/intel-lustre-clients-vmss-centos" `
    -location $Region `
    -clientVmSize "Standard_D1" `
    -imageSku "6.6" `
    -vmssName $ResourceGroupName `
    -clientCount 2 `
    -adminUsername "azureuser" `
    -authenticationType password `
    -adminPassword $AdminPassword `
    -filesystemName "scratch" `
    -mgsIpAddress "10.1.0.4" `
    -existingVnetResourceGroupName "avlustre123001" `
    -existingVnetName "vnet-lustre" `
    -existingSubnetClientsName "subnet-lustre-clients"

# Scale ======================================================================================================================
New-AzureRmResourceGroupDeployment -Name "scale" -ResourceGroupName $ResourceGroupName -TemplateFile .\scale.json `
    -existingVMSSName "avlvmss2" `
    -clientVmSize "Standard_D1" `
    -newClientCount 10

