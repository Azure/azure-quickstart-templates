<#
    .SYNOPSIS
        Creates a file at the given file path with the specified content through the xScript resource.

    .PARAMETER FilePath
        The path at which to create the file.

    .PARAMETER FileContent
        The content to set for the new file.
#>
Configuration xScriptExample {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FileContent
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xScript ScriptExample
        {
            SetScript = {
                $streamWriter = New-Object -TypeName 'System.IO.StreamWriter' -ArgumentList @( $using:FilePath )
                $streamWriter.WriteLine($using:FileContent)
                $streamWriter.Close()
            }
            TestScript = {
                if (Test-Path -Path $using:FilePath)
                {
                    $fileContent = Get-Content -Path $using:filePath -Raw
                    return $fileContent -eq $using:FileContent
                }
                else
                {
                    return $false
                }
            }
            GetScript = {
                $fileContent = $null

                if (Test-Path -Path $using:FilePath)
                {
                    $fileContent = Get-Content -Path $using:filePath -Raw
                }

                return @{
                    Result = Get-Content -Path $fileContent
                }
            }
        }
    }
}
