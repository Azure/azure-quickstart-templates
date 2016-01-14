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
$DomainNameLabel = "demoapp$i"

New-AzureRmResourcegroup -Name $ResourceGroupName -Location 'East US' -Verbose

New-AzureRMAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AccountName -Location 'East US 2' -Plan Free -Verbose

$RegistrationInfo = Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $ResourceGroupName -AutomationAccountName $AccountName

New-AzureRmResourceGroupDeployment -Name TestDeployment -ResourceGroupName $ResourceGroupName -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json -registrationKey ($RegistrationInfo.PrimaryKey | ConvertTo-SecureString -AsPlainText -Force) -registrationUrl $RegistrationInfo.Endpoint -automationAccountName $AccountName -jobId (New-GUID) -adminUsername $credential.UserName -adminPassword $credential.Password -domainNameLabel $DomainNameLabel -Verbose