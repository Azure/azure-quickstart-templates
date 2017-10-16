<#
    .SYNOPSIS
        Generates a file contaning function stubs of all cmdlets from the module given as a parameter. 

    .PARAMETER ModuleName
        The name of the module to load and generate stubs from. This module must exist on the computer where this function is ran.

    .PARAMETER Path
         Path to where to write the stubs file. The filename will be generated from the module name.  

    .EXAMPLE
        Write-ModuleStubFile -ModuleName 'SQLServer' -Path 'C:\Source'
#>
function Write-ModuleStubFile {
    param
    (
        [Parameter( Mandatory )] 
        [System.String] $ModuleName,

        [Parameter( Mandatory )] 
        [System.String] $Path
    )

    Import-Module $ModuleName -DisableNameChecking -Force
 
    ( ( get-command -Module $ModuleName -CommandType 'Cmdlet' ) | ForEach-Object -Begin { 
        "# Suppressing this rule because these functions are from an external module"
        "# and are only being used as stubs",
        "[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]"
        "param()"
        ""
    } -Process {
        $signature = $null
        $command = $_
        $endOfDefinition = $false
        $metadata = New-Object -TypeName System.Management.Automation.CommandMetaData -ArgumentList $command
        $definition = [System.Management.Automation.ProxyCommand]::Create($metadata) 
        foreach ($line in $definition -split "`n")
        {
            $line = $line -replace '\[Microsoft.SqlServer.*.\]', '[object]'
            $line = $line -replace 'SupportsShouldProcess=\$true, ', ''

            if( $line.Contains( '})' ) )
            {
                $line = $line.Remove( $line.Length - 2 )
                $endOfDefinition = $true
            }
            
            if( $line.Trim() -ne '' ) {
                $signature += "    $line"
            } else {
                $signature += $line
            }

            if( $endOfDefinition )
            {
                $signature += "`n   )"
                break
            }
        }
        
        "function $($command.Name) {"
        "$signature"
        ""
        "   throw '{0}: StubNotImplemented' -f $`MyInvocation.MyCommand"
        "}"
        ""
    } ) | Out-String | Out-File ( Join-Path -Path $Path -ChildPath "$(( get-module $moduleName -ListAvailable).Name )Stub.psm1") -Encoding utf8 -Append
}
