
<#PSScriptInfo

.VERSION 1.0.0

.GUID 4e07bb61-3d86-4150-8436-73d420d34457

.AUTHOR Michael Greene

.COMPANYNAME Microsoft Corporation

.COPYRIGHT 2019

.TAGS DSC AzureAutomation Runbook VMSS ScaleSet

.LICENSEURI https://github.com/mgreenegit/tombstonedscnodes/license

.PROJECTURI https://github.com/mgreenegit/tombstonedscnodes

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/mgreenegit/tombstonedscnodes/readme.md

.PRIVATEDATA 

#>

#Requires -Module AzureRM

<# 

.DESCRIPTION 
 This script provides an example for how to use a Runbook in Azure Automation to tombstone stale DSC nodes from State Configuration. 

#> 
Param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$AutomationAccountName
)
#Variables
$TombstoneAction = $false
$TombstoneDays = 1
$UnregisterAction = $false
$UnregisterDays = 3

# Authenticate with Azure.
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $ServicePrincipalConnection.TenantId `
    -ApplicationId $ServicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose
$Context = Set-AzureRmContext -SubscriptionId $ServicePrincipalConnection.SubscriptionID | Write-Verbose

# Get and Log information (no action)
$SetTombstonedNodes = Get-AzureRMAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object {$_.Status -eq 'Unresponsive' -AND $_.LastSeen -lt (get-date).AddDays(-$TombstoneDays) -AND $_.NodeConfigurationName -notlike "Tombstoned.*"}
Write-Output "Nodes to be tombstoned:"
if ($null -eq $SetTombstonedNodes) {Write-Output "0 nodes"}
else {
    $SetTombstonedNodes | % Name | Write-Output
}

Write-Output ""

$UnregisterNodes = Get-AzureRMAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object {$_.Status -eq 'Unresponsive' -AND $_.LastSeen -lt (get-date).AddDays(-$UnregisterDays) -AND $_.NodeConfigurationName -like "Tombstoned.*" }
Write-Output "Nodes to be unregistered:"
if ($null -eq $UnregisterNodes) {Write-Output "0 nodes"}
else {
    $UnregisterNodes | % Name | Write-Output
}

Write-Output ""

# Act on tombstone nodes (actions commented out by default)

if ($true -eq $TombstoneAction) {
    Write-Output "Taking action: Tombstone nodes"
    if ($null -eq $SetTombstonedNodes) {Write-Output "0 nodes"}
    else {
        foreach ($SetTombstonedNode in $SetTombstonedNodes) {
            Write-Output "Setting node configuration to "Tombstoned.$($SetTombstonedNode.NodeConfigurationName)" for node $($SetTombstonedNode.Name) with Id $($SetTombstonedNode.Id) from account $($SetTombstonedNode.AutomationAccountName)"
            $SetTombstonedNode | Set-AzureRmAutomationDscNode -NodeConfigurationName "Tombstoned.$($SetTombstonedNode.NodeConfigurationName)" -Force
        }
    }
}

Write-Output ""

if ($true -eq $UnregisterAction) {
    Write-Output "Taking action: Unregister nodes"
    if ($null -eq $UnregisterNodes) {Write-Output "0 nodes"}
    else {
        foreach ($UnregisterNode in $UnregisterNodes) {
            Write-Output "Unregistering node $($UnregisterNode.Name) with Id $($UnregisterNode.Id) from account $($UnregisterNode.AutomationAccountName)"
            $UnregisterNode | Unregister-AzureRMAutomationDscNode -Force
        }
    }
}
