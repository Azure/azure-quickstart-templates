# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
    ModuleNotFound = Please ensure that the PowerShell module for role {0} is installed.
'@
}

<#
        .SYNOPSIS
        Internal function to throw terminating error with specified 
        errroCategory, errorId and errorMessage
        .PARAMETER ErrorId
        Specifies the Id error message.
        .PARAMETER ErrorMessage
        Specifies full Error Message to be returned.
        .PARAMETER ErrorCategory
        Specifies Error Category.
#>
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String] $ErrorId,

        [Parameter(Mandatory)]
        [String] $ErrorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory] $ErrorCategory
    )

    $exception = New-Object System.InvalidOperationException $ErrorMessage
    $errorRecord = New-Object System.Management.Automation.ErrorRecord `
                       $exception, $ErrorId, $ErrorCategory, $null
    throw $errorRecord
}

<#
    .SYNOPSIS
        Internal function to assert if the module exists
    .PARAMETER ModuleName
        Module to test
#>
function Assert-Module
{
    [CmdletBinding()]
    param
    (
        [String]$ModuleName = 'WebAdministration'
    )

    if(-not(Get-Module -Name $ModuleName -ListAvailable))
    {
        $errorMsg = $($LocalizedData.ModuleNotFound) -f $ModuleName
        New-TerminatingError -ErrorId 'ModuleNotFound' `
                             -ErrorMessage $errorMsg `
                             -ErrorCategory ObjectNotFound
    }
}
