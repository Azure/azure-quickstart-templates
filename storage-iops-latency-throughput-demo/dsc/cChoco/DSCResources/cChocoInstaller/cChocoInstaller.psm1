function Get-TargetResource
{
    [OutputType([hashtable])]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallDir,
        [parameter()]
        [string]
        $ChocoInstallScriptUrl = 'https://chocolatey.org/install.ps1'
    )
    Write-Verbose 'Start Get-TargetResource'

    #Needs to return a hashtable that returns the current status of the configuration component
    $Configuration = @{
        InstallDir            = $env:ChocolateyInstall
        ChocoInstallScriptUrl = $ChocoInstallScriptUrl
    }

    Return $Configuration
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallDir,

        [parameter()]
        [string]
        $ChocoInstallScriptUrl = 'https://chocolatey.org/install.ps1'
    )
    Write-Verbose 'Start Set-TargetResource'
    $whatIfShouldProcess = $pscmdlet.ShouldProcess('Chocolatey', 'Download and Install')
    if ($whatIfShouldProcess) {
        Install-Chocolatey @PSBoundParameters
    }
}

function Test-TargetResource
{
    [OutputType([bool])]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallDir,
        [parameter()]
        [string]
        $ChocoInstallScriptUrl = 'https://chocolatey.org/install.ps1'
    )

    Write-Verbose 'Test-TargetResource'
    if (-not (Test-ChocoInstalled))
    {
        Write-Verbose 'Choco is not installed, calling set'
        Return $false
    }
  
    ##Test to see if the Install Directory is correct.
    $env:ChocolateyInstall = [Environment]::GetEnvironmentVariable('ChocolateyInstall','Machine')
    if(-not ($InstallDir -eq $env:ChocolateyInstall)) 
    {
        Write-Verbose "Choco should be installed in $InstallDir but is installed to $env:ChocolateyInstall calling set"
        Return $false
    }

    Return $true
}

function Test-ChocoInstalled
{
    Write-Verbose 'Test-ChocoInstalled'
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')

    Write-Verbose "Env:Path contains: $env:Path"
    if (Test-Command -command choco)
    {
        Write-Verbose 'YES - Choco is Installed'
        return $true
    }

    Write-Verbose "NO - Choco is not Installed"
    return $false
}

Function Test-Command
{
    Param (
        [string]$command = 'choco' 
    )
    Write-Verbose "Test-Command $command"
    if (Get-Command -Name $command -ErrorAction SilentlyContinue) {
        Write-Verbose "$command exists"
        return $true
    } else {
        Write-Verbose "$command does NOT exist"
        return $false
    } 
} 

#region - chocolately installer work arounds. Main issue is use of write-host
function global:Write-Host
{
    Param(
        [Parameter(Mandatory,Position = 0)]
        $Object,
        [Switch]
        $NoNewLine,
        [ConsoleColor]
        $ForegroundColor,
        [ConsoleColor]
        $BackgroundColor
    )
    #Redirecting Write-Host -> Write-Verbose. 
    Write-Verbose $Object
}
#endregion

function Get-FileDownload {
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$url,
        
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$file
    )
    Write-Verbose "Downloading $url to $file"
    $downloader = new-object -TypeName System.Net.WebClient
    $downloader.DownloadFile($url, $file)
}

Function Install-Chocolatey {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallDir,

        [parameter()]
        [string]
        $ChocoInstallScriptUrl = 'https://chocolatey.org/install.ps1'
    )    
    Write-Verbose 'Install-Chocolatey'

    #Create install directory if it does not exist
    If(-not (Test-Path -Path $InstallDir)) {
        Write-Verbose "[ChocoInstaller] Creating $InstallDir"
        New-Item -Path $InstallDir -ItemType Directory
    }

    #Set permanent EnvironmentVariable
    Write-Verbose 'Setting ChocolateyInstall environment variables'
    [Environment]::SetEnvironmentVariable('ChocolateyInstall', $InstallDir, [EnvironmentVariableTarget]::Machine)
    $env:ChocolateyInstall = [Environment]::GetEnvironmentVariable('ChocolateyInstall','Machine')   
    Write-Verbose "Env:ChocolateyInstall has $env:ChocolateyInstall" 
    
    #Download an execute install script    
    $file = Join-Path -Path $InstallDir -ChildPath 'install.ps1'
    Get-FileDownload -url $ChocoInstallScriptUrl -file $file
    . $file

    #refresh after install
    Write-Verbose 'Adding Choco to path'
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')   
    if ($env:path -notlike "*$InstallDir*") {
        $env:Path += ";$InstallDir"
    }
    
    Write-Verbose "Env:Path has $env:path"    
    #InstallChoco $InstallDir
    $Null = Choco
    Write-Verbose 'Finish InstallChoco'
}

Export-ModuleMember -Function *-TargetResource