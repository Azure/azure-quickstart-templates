# parameters 
$rgName = "AzureDNSExample"

#  set ARM mode
Switch-AzureMode AzureResourceManager

#  login and select subscription context
Add-AzureAccount


# create the resource from the template - pass names as parameters
$scriptDir = Split-Path $MyInvocation.MyCommand.Path
New-AzureResourceGroup -Verbose -Force -Name $rgName -Location "northeurope" -TemplateFile "$scriptDir\azuredeploy.json" -TemplateParameterFile "$scriptDir\azuredeploy.parameters.json"

#  display the end result - creation is async so may need to wait
$zones = Get-AzureDnsZone -ResourceGroupName $rgName
"--------------"
$zones
"--------------"
foreach ($zone in $zones)
{
    $recs = Get-AzureDnsRecordSet -ResourceGroupName $rgName -ZoneName $zone.Name
    "$($zone.name)"
    $recs | Select Name, TTL, RecordType, Records | Format-Table
    "----------------"
}
