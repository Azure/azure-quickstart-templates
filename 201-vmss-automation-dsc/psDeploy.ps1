#  PowerShell deployment example
#  v0.1
#  This script can be used to test the ARM template deployment, or as a reference for building your own deployment script.
param (
	[Parameter(Mandatory=$true)]
	[int]$i,
	[Parameter(Mandatory=$true)]
	[pscredential]$Credential 
)  
$ResourceGroupName = "vmss$i"
$AccountName = "AutomationAccount$i"
$DomainNamePrefix = "demoapp$i"
$ResourceLocation = 'East US 2'
$VirtualMachineScaleSetName = 'webSrv'
$InstanceCount = 2

New-AzureRmResourcegroup -Name $ResourceGroupName -Location 'East US' -Verbose

New-AzureRMAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AccountName -Location 'East US 2' -Plan Free -Verbose

$RegistrationInfo = Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $ResourceGroupName -AutomationAccountName $AccountName

$NewGUID = [system.guid]::newguid().guid

$timestamp = (get-date).getdatetimeformats()[80]

New-AzureRmResourceGroupDeployment -Name TestDeployment -ResourceGroupName $ResourceGroupName -TemplateFile .\azuredeploy.json -registrationKey ($RegistrationInfo.PrimaryKey | ConvertTo-SecureString -AsPlainText -Force) -registrationUrl $RegistrationInfo.Endpoint -automationAccountName $AccountName -jobid $NewGUID -adminUsername $credential.UserName -adminPassword $credential.Password -domainNamePrefix $DomainNamePrefix -resourceLocation $ResourceLocation -vmssName $VirtualMachineScaleSetName -instanceCount $InstanceCount -timestamp $timestamp -Verbose