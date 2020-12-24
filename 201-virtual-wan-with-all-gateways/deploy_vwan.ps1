# Deploy vWAN environment using ARM template and parameter file #

#region INIT

# Subscription variables #: 
$subscriptionId = '<< INSERT YOUR VALUE HERE>>'
$TenantId = '<< INSERT YOUR VALUE HERE>>'

# Login to Azure AAD 
Connect-AzAccount -Tenant $TenantId -SubscriptionId $subscriptionId

# Resource Variables: #
$RGname = '<< INSERT YOUR VALUE HERE>>' # resource group name 
$location = '<< INSERT YOUR VALUE HERE>>' # resource group location 
$vWanName = "<< INSERT YOUR VALUE HERE>>" #vWAN name 
$vhub1Name = '<< INSERT YOUR VALUE HERE>>' #vWAN Hub1 name 
$vhub2Name = '<< INSERT YOUR VALUE HERE>>' #vWAN Hub2 name 
$templatefilepath = '<< INSERT YOUR VALUE HERE>>' # ARM template downloaded from GitHub

# Create home resource group: #
New-AzResourceGroup -Name $RGname -Location $location

#endregion 

#region FIRST DEPLOYMENT

# Create and set a timer: #
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$stopwatch.Start()

# First deployment attempt, expected to fail, we'll silently continue: #
$suffix = Get-Random -Maximum 1000
$deploymentName = "vWANdeployment" + $suffix

$ErrorActionPreference = "SilentlyContinue"
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $RGname -TemplateFile $templatefilepath -vWANname $vWanName
$ErrorActionPreference = "Stop"

$stopwatch.Stop()
$elapsed = $stopwatch.Elapsed.TotalMinutes
Write-Host "First Deployment execution Completed in [$elapsed] minutes, Hub Routing Services NOT READY YET...." -ForegroundColor Green
# NOTE: First execution should fail in 4-5 minutes, as expected #

# Look to vWAN state: #
$vWan = Get-AzVirtualWan -Name $vWanName -ResourceGroupName $RGname
$vWan

#endregion

#region SECOND DEPLOYMENT

# Run the same script again in a second deployment, after checking vWAN routing services in both Hubs are in provisioned state #
$stopwatch.Reset()
$stopwatch.Start()
do {
     $vHub1 = Get-AzVirtualHub -ResourceGroupName $RGname -Name $vhub1Name
     $vHub2 = Get-AzVirtualHub -ResourceGroupName $RGname -Name $vhub2Name
     Write-Host "Hub Routing Services NOT READY YET...." -ForegroundColor Yellow 
     Start-Sleep -Seconds 60
   }
while ($vHub1.RoutingState -eq "Provisioning" -or $vHub2.RoutingState -eq "Provisioning")

$stopwatch.Stop()
$elapsed = $stopwatch.Elapsed.TotalMinutes
Write-Host "Execution Completed in [$elapsed] minutes, Hub Routing Services NOW ready...." -ForegroundColor Green
# NOTE: Execution should be completed in 10-12 minutes #

$stopwatch.Reset()
$stopwatch.Start()
Write-Host "Now creating VNET connections and deploying VPN S2S, VPN P2S and Express Route gateways in both Hubs...." -ForegroundColor Green
New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $RGname -TemplateFile $templatefilepath -vWANname $vWanName
$stopwatch.Stop()
$elapsed = $stopwatch.Elapsed.TotalMinutes
Write-Host "vWAN deployment execution completed in [$elapsed] minutes, Routing Services and all Gateways deployed...." -ForegroundColor Green
# NOTE: Execution should be completed in 80-90 minutes #

#endregion
