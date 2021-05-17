$ErrorActionPreference = 'Stop'

# TFS 2017 Update 3
$TfsDownloadUrl = 'https://go.microsoft.com/fwlink/?LinkId=857132'
$InstallDirectory = 'C:\Program Files\Microsoft Team Foundation Server 15.0'
$InstallKey = 'HKLM:\SOFTWARE\Microsoft\DevDiv\tfs\Servicing\15.0\serverCore'

# Checks if TFS is installed
function Ensure-TfsInstalled()
{
    # Check if TFS is already installed.
    $tfsInstalled = $false

    if(Test-Path $InstallKey)
    {
        $key = Get-Item $InstallKey
        $value = $key.GetValue("Install", $null)

        if(($value -ne $null) -and $value -eq 1)
        {
            $tfsInstalled = $true
        }
    }

    if(-not $tfsInstalled)
    {
        Write-Verbose "Installing TFS using ISO"
        # Download TFS and mount it
        $parent = [System.IO.Path]::GetTempPath()
        [string] $name = [System.Guid]::NewGuid()
        [string] $fullPath = Join-Path $parent $name

        try 
        {
            New-Item -ItemType Directory -Path $fullPath

            Invoke-WebRequest -UseBasicParsing -Uri $TfsDownloadUrl -OutFile $fullPath\tfsserver2017.3.1_enu.iso

            $mountResult = Mount-DiskImage $fullPath\tfsserver2017.3.1_enu.iso -PassThru
            $driveLetter = ($mountResult | Get-Volume).DriveLetter
            
            $process = Start-Process -FilePath $driveLetter":\TfsServer2017.3.1.exe" -ArgumentList '/quiet' -PassThru -Wait
            $process.WaitForExit()
            Start-Sleep -Seconds 90
        }
        finally 
        {
            Dismount-DiskImage -ImagePath $fullPath\tfsserver2017.3.1_enu.iso
            Remove-Item $fullPath\tfsserver2017.3.1_enu.iso -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    else
    {
        Write-Verbose "TFS is already installed"
    }
}
function Download-PsTools()
{
    [string] $downloadPath = Join-Path $PSScriptRoot "PSTools.zip"
    [string] $targetFolder = Join-Path $PSScriptRoot "PsTools"
    
    if (!(Test-Path $targetFolder))
    {
        try 
        {
            Invoke-WebRequest -UseBasicParsing -Uri $PsToolsDownloadUrl -OutFile $downloadPath
            
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $targetFolder)
        }
        finally
        {
            Remove-Item $downloadPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# Runs tfsconfig to configure TFS on the machine
function Configure-TfsRemoteSql {
     param(
         [string] $SqlInstance,
         [string] $userName,
         [string] $password
     )
    # Run tfsconfig to do the unattend install
    $path = Join-Path $InstallDirectory '\tools\tfsconfig.exe'

    Write-Verbose "Running tfsconfig..."

    # The System account running this script for the VM Extension is not allowed to impersonate, 
    # so we can't use Start-Process with the -Credential parameter to run setup as a domain user with access to SQL
    # Instead we'll use psexec.exe from the PsTools Suite (https://docs.microsoft.com/en-us/sysinternals/downloads/pstools)
    & $PSScriptRoot\PsTools\psexec.exe -h -accepteula -u $userName -p $password "$path" unattend /configure /type:Standard /inputs:"SqlInstance=$SqlInstance"
    
    if($LASTEXITCODE)
    {
        throw "tfsconfig.exe failed with exit code $LASTEXITCODE . Check the TFS logs for more information"
    }
}

Ensure-TfsInstalled
Download-PsTools
Configure-TfsRemoteSql