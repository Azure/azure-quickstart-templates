# This module should not write any verbose or error messages unless a localization file for it is added

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

<#
    .SYNOPSIS
        Builds a string of the common parameters shared across all resources in a set.

    .PARAMETER KeyParameterName
        The name of the key parameter for the resource.

    .PARAMETER Parameters
        The hashtable of all parameters to the resource set (PSBoundParameters).

    .EXAMPLE
        $parameters = @{
            KeyParameter = @( 'MyKeyParameter1', 'MyKeyParameter2' )
            CommonParameter1 = 'CommonValue1'
            CommonParameter2 = 2
        }

        New-ResourceSetCommonParameterString -KeyParameterName 'KeyParameter' -Parameters $parameters

        OUTPUT (as string):
        CommonParameter1 = "CommonValue1"`r`nCommonParameter2 = $CommonParameter2
#>
function New-ResourceSetCommonParameterString
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyParameterName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Parameters
    )

    $stringBuilder = New-Object -TypeName 'System.Text.StringBuilder'

    foreach ($parameterName in $Parameters.Keys) 
    {
        # All composite resources have an extra parameter 'InstanceName'
        if ($parameterName -ine $KeyParameterName -and $parameterName -ine 'InstanceName')
        {
            $parameterValue = $Parameters[$parameterName]

            if ($null -ne $parameterValue)
            {
                if ($parameterValue -is [String])
                {
                    $null = $stringBuilder.AppendFormat('{0} = "{1}"', $parameterName, $parameterValue)
                }
                else
                {
                    $null = $stringBuilder.Append($parameterName + ' = $' + $parameterName)
                }

                $null = $stringBuilder.AppendLine()
            }
        }
    }

    return $stringBuilder.ToString()
}

<#
    .SYNOPSIS
        Creates a string representing a configuration script for a set of resources.

    .PARAMETER ResourceName
        The name of the resource to create a set of.

    .PARAMETER ModuleName
        The name of the module to import the resource from.

    .PARAMETER KeyParameterName
        The name of the key parameter that will differentiate each resource.

    .PARAMETER KeyParameterValues
        An array of the values of the key parameter that will differentiate each resource.

    .PARAMETER CommonParameterString
        A string representing the common parameters for each resource.
        Can be retrieved from New-ResourceSetCommonParameterString.

    .EXAMPLE
        New-ResourceSetConfigurationString `
            -ResourceName 'xWindowsFeature' `
            -ModuleName 'xPSDesiredStateConfiguration' `
            -KeyParameterName 'Name' `
            -KeyParameterValues @( 'Telnet-Client', 'Web-Server' ) `
            -CommonParameterString 'Ensure = "Present"`r`nIncludeAllSubFeature = $true'

        OUTPUT (as a String):
            Import-Module -Name xWindowsFeature -ModuleName xPSDesiredStateConfiguration

            xWindowsFeature Resource0
            {
                Name = "Telnet-Client"
                Ensure = "Present"
                IncludeAllSubFeature = $true
            }  

            xWindowsFeature Resource1
            {
                Name = "Web-Server"
                Ensure = "Present"
                IncludeAllSubFeature = $true
            }
#>
function New-ResourceSetConfigurationString
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ModuleName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyParameterName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $KeyParameterValues, 
    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CommonParameterString
    )

    $stringBuilder = New-Object -TypeName 'System.Text.StringBuilder'

    $null = $stringBuilder.AppendFormat('Import-DscResource -Name {0} -ModuleName {1}', $ResourceName, $ModuleName)
    $null = $stringBuilder.AppendLine()

    $resourceCount = 0
    foreach ($keyParameterValue in $KeyParameterValues)
    {
        $null = $stringBuilder.AppendFormat('{0} Resource{1}', $ResourceName, $resourceCount)
        $null = $stringBuilder.AppendLine()
        $null = $stringBuilder.AppendLine('{')
        $null = $stringBuilder.AppendFormat($KeyParameterName + ' = "{0}"', $keyParameterValue)
        $null = $stringBuilder.AppendLine()
        $null = $stringBuilder.Append($CommonParameterString)
        $null = $stringBuilder.AppendLine('}')
        
        $resourceCount++
    }

    return $stringBuilder.ToString()
}

<#
    .SYNOPSIS
        Creates a configuration script block for a set of resources.

    .PARAMETER ResourceName
        The name of the resource to create a set of.

    .PARAMETER ModuleName
        The name of the module to import the resource from.

    .PARAMETER KeyParameterName
        The name of the key parameter that will differentiate each resource.

    .PARAMETER Parameters
        The hashtable of all parameters to the resource set (PSBoundParameters).

    .EXAMPLE
        # From the xGroupSet composite resource

        $newResourceSetConfigurationParams = @{
            ResourceName = 'xGroup'
            ModuleName = 'xPSDesiredStateConfiguration'
            KeyParameterName = 'GroupName'
            CommonParameterNames = @( 'Ensure', 'MembersToInclude', 'MembersToExclude', 'Credential' )
            Parameters = $PSBoundParameters
        }
    
        $configurationScriptBlock = New-ResourceSetConfigurationScriptBlock @newResourceSetConfigurationParams

    .NOTES
        Only allows one key parameter to be defined for each node.
        For resources with multiple key parameters, only one key can be different for each resource.
        See xProcessSet for an example of a resource set with two key parameters.
#>
function New-ResourceSetConfigurationScriptBlock
{
    [OutputType([ScriptBlock])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ModuleName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $KeyParameterName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Parameters
    )

    $commonParameterString = New-ResourceSetCommonParameterString -KeyParameterName $KeyParameterName -Parameters $Parameters

    $newResourceSetConfigurationStringParams = @{
        ResourceName = $ResourceName
        ModuleName = $ModuleName
        KeyParameterName = $KeyParameterName
        KeyParameterValues = $Parameters[$KeyParameterName]
        CommonParameterString = $commonParameterString
    }

    $resourceString = New-ResourceSetConfigurationString @newResourceSetConfigurationStringParams

    return [ScriptBlock]::Create($resourceString)
}

Export-ModuleMember -Function @( 'New-ResourceSetConfigurationScriptBlock' )
