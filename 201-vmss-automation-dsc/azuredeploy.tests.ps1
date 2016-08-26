#Requires -Modules Pester
<#
.SYNOPSIS
    Tests a specific ARM template
.EXAMPLE
    Invoke-Pester 
.NOTES
    This file has been created as an example of using Pester to evaluate ARM templates
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = Split-Path -Leaf $here

Describe "Template: $template" -Tags Unit {
    
    Context "Template Syntax" {
        
        It "Has a JSON template" {        
            "$here\azuredeploy.json" | Should Exist
        }
        
        It "Has a parameters file" {        
            "$here\azuredeploy.parameters.json" | Should Exist
        }
        
        It "Has a metadata file" {        
            "$here\metadata.json" | Should Exist
        }

        It "Converts from JSON and has the expected properties" {
            $expectedProperties = '$schema',
                                  'contentVersion',
                                  'parameters',
                                  'variables',
                                  'resources',                                
                                  'outputs'
            $templateProperties = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | % Name
            $templateProperties | Should Be $expectedProperties
        }
        
        It "Creates the expected Azure resources" {
            $expectedResources = 'Microsoft.Storage/storageAccounts',
                                 'Microsoft.Network/virtualNetworks',
                                 'Microsoft.Network/publicIPAddresses',
                                 'Microsoft.Network/loadBalancers',
                                 'Microsoft.Compute/virtualMachineScaleSets',
                                 'Microsoft.Automation/automationAccounts',
                                 'Microsoft.Insights/autoscaleSettings'
            $templateResources = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type
            $templateResources | Should Be $expectedResources
        }
        
        It "Contains the expected DSC extension properties" {
            $expectedDscExtensionProperties = 'RegistrationKey',
                                              'RegistrationUrl',
                                              'NodeConfigurationName',
                                              'ConfigurationMode',
                                              'ConfigurationModeFrequencyMins',
                                              'RefreshFrequencyMins',
                                              'RebootNodeIfNeeded',
                                              'ActionAfterReboot',
                                              'AllowModuleOverwrite',
                                              'Timestamp'
            $dscExtensionProperties = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources | ? type -eq Microsoft.Compute/virtualMachineScaleSets | % properties | % virtualMachineProfile | % extensionProfile | % extensions | ? name -eq dscExtension | % properties | % settings | % Properties | % Name
            $dscExtensionProperties | Should Be $expectedDscExtensionProperties
        }
    }
}