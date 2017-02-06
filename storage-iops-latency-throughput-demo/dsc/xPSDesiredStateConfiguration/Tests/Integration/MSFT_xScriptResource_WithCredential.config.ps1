param
(
    [Parameter(Mandatory = $true)]
    [String]
    $ConfigurationName
)

Configuration $ConfigurationName
{
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
        $FileContent,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node localhost
    {
        xScript Script1
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
            Credential = $Credential
        }
    }
}
