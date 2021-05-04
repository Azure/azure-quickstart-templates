[CmdletBinding()]
param(

)

$ErrorActionPreference = 'Stop'

# TFS 2017 Update 3
$TfsDownloadUrl = 'https://go.microsoft.com/fwlink/?LinkId=857132'
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

        if(($null -ne $value) -and $value -eq 1)
        {
            $tfsInstalled = $true
        }
    }

    if(-not $tfsInstalled)
    {
        Write-Verbose "Installing TFS using ISO"
        # Download TFS install to a temp folder, then run it
        $parent = [System.IO.Path]::GetTempPath()
        [string] $name = [System.Guid]::NewGuid()
        [string] $fullPath = Join-Path $parent $name

            New-Item -ItemType Directory -Path $fullPath

            Invoke-WebRequest -UseBasicParsing -Uri $TfsDownloadUrl -OutFile $fullPath\tfsserver2017.3.1_enu.iso

            $mountResult = Mount-DiskImage $fullPath\tfsserver2017.3.1_enu.iso -PassThru
            $driveLetter = ($mountResult | Get-Volume).DriveLetter
            
            Start-Job -Name "InstallTfs" -ScriptBlock {
               & $driveLetter":\TfsServer2017.3.1.exe" -ArgumentList '/quiet'
            }
            Write-Output $LASTEXITCODE

            Get-Job -Name "InstallTfs" | Wait-Job | Receive-Job
    }

# Runs tfsconfig to configure TFS on the machine
function Configure-TfsWorkgroup()
{
    # Run tfsconfig to do the unattend install
    $path = Join-Path $InstallDirectory '\Tools\tfsconfig.exe'
    $tfsConfigArgs = 'unattend /configure /type:Basic /inputs:"InstallSqlExpress=True"'

    Write-Verbose "Running tfsconfig..."

    Invoke-Expression "& '$path' $tfsConfigArgs"

    if($LASTEXITCODE)
    {
        throw "tfsconfig.exe failed with exit code $LASTEXITCODE . Check the TFS logs for more information"
    }
}

Ensure-TfsInstalled
Start-Sleep -Seconds 300
Configure-TfsWorkgroup