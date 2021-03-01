[CmdletBinding()]
param(

)
$ErrorActionPreference = 'Stop'

# TFS 2017 Update 2
$TfsDownloadUrl = 'https://go.microsoft.com/fwlink/?LinkId=850949'
$InstallDirectory = 'C:\Program Files\Microsoft Team Foundation Server 15.0'
$InstallKey = 'HKLM:\SOFTWARE\Microsoft\DevDiv\tfs\Servicing\15.0\serverCore'

# Checks if TFS is installed, if not downloads and runs the web installer
function Ensure-TfsInstalled()
{
    # Check if TFS is already installed
    $tfsInstalled = $false

    if(Test-Path $InstallKey)
    {
        $key = Get-Item $InstallKey
        $value = $key.GetValue("Install", $null)

        if(($value -ne $null) -and ($value -eq 1))
        {
            $tfsInstalled = $true
        }
    }

    if(-not $tfsInstalled)
    {
        Write-Verbose "Installing TFS using web installer"
        # Download TFS install to a temp folder, then run it
        $parent = [System.IO.Path]::GetTempPath()
        [string] $name = [System.Guid]::NewGuid()
        [string] $fullPath = Join-Path $parent $name

        try 
        {
            New-Item -ItemType Directory -Path $fullPath
            $serverLocation = Join-Path $fullPath 'tfsserver.exe'

            Invoke-WebRequest -UseBasicParsing -Uri $TfsDownloadUrl -OutFile $serverLocation
            
            $process = Start-Process -FilePath $serverLocation -ArgumentList '/quiet' -PassThru
            $process.WaitForExit()
        }
        finally 
        {
            Remove-Item $fullPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    else
    {
        Write-Verbose "TFS is already installed"
    }
}

# Runs tfsconfig to configure TFS on the machine
function Configure-TfsWorkgroup()
{
    # Run tfsconfig to do the unattend install
    $path = Join-Path $InstallDirectory '\tools\tfsconfig.exe'
    $tfsConfigArgs = 'unattend /configure /type:Basic /inputs:"InstallSqlExpress=True"'

    Write-Verbose "Running tfsconfig..."

    Invoke-Expression "& '$path' $tfsConfigArgs"

    if($LASTEXITCODE)
    {
        throw "tfsconfig.exe failed with exit code $LASTEXITCODE . Check the TFS logs for more information"
    }
}

Ensure-TfsInstalled
Configure-TfsWorkgroup