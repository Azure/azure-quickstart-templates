param(
    [string] $ResourceGroupName = 'AFDX-AppGW-Pub-Https-302',
    [string] $ResourceGroupLocation = 'eastus'
)

. ../_shared/script-wrapper-for-managed-identity/run.ps1 -ResourceGroupName $ResourceGroupName -ResourceGroupLocation $ResourceGroupLocation -BicepTemplateFilePath (Get-ChildItem .\main.bicep).FullName
