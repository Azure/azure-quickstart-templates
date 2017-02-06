function Get-TargetResource
{
    [OutputType([hashtable])]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,
        [ValidateNotNullOrEmpty()]
        [string]
        $Params,    
        [ValidateNotNullOrEmpty()]
        [string]
        $Version,
        [ValidateNotNullOrEmpty()]
        [string]
        $Source
    )

    Write-Verbose -Message 'Start Get-TargetResource'

    if (-Not (Test-ChocoInstalled)) {
        throw "cChocoPackageInstall requires Chocolatey to be installed, consider using cChocoInstaller with 'dependson' in dsc config"
    }

    #Needs to return a hashtable that returns the current
    #status of the configuration component
    $Configuration = @{
        Name    = $Name
        Params  = $Params
        Version = $Version
        Source  = $Source
    }

    return $Configuration
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,   
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure='Present',
        [ValidateNotNullOrEmpty()]
        [string]
        $Params,    
        [ValidateNotNullOrEmpty()]
        [string]
        $Version,   
        [ValidateNotNullOrEmpty()]
        [string]
        $Source,
        [String]
        $chocoParams,
        [bool]
        $AutoUpgrade = $false
    )
    Write-Verbose -Message 'Start Set-TargetResource'
	
    if (-Not (Test-ChocoInstalled)) {
        throw "cChocoPackageInstall requires Chocolatey to be installed, consider using cChocoInstaller with 'dependson' in dsc config"
    }

    $isInstalled = IsPackageInstalled -pName $Name

    #Uninstall if Ensure is set to absent and the package is installed
    if ($isInstalled) {
        if ($Ensure -eq 'Absent') { 
            $whatIfShouldProcess = $pscmdlet.ShouldProcess("$Name", 'Remove Chocolatey package')
            if ($whatIfShouldProcess) {
                Write-Verbose -Message "Removing $Name as ensure is set to absent"
                UninstallPackage -pName $Name -pParams $Params
            }    
        } else {
            $whatIfShouldProcess = $pscmdlet.ShouldProcess("$Name", 'Installing / upgrading package from Chocolatey')
            if ($whatIfShouldProcess) {
                if ($Version) {
                    Write-Verbose -Message "Uninstalling $Name due to version mis-match"
                    UninstallPackage -pName $Name -pParams $Params
                    Write-Verbose -Message "Re-Installing $Name with correct version $version"
                    InstallPackage -pName $Name -pParams $Params -pVersion $Version -cParams $chocoParams            
                } elseif ($AutoUpgrade) {
                    Write-Verbose -Message "Upgrading $Name due to version mis-match"
                    Upgrade-Package -pName $Name -pParams $Params
                }
            }
        }
    } else {
        $whatIfShouldProcess = $pscmdlet.ShouldProcess("$Name", 'Install package from Chocolatey')
        if ($whatIfShouldProcess) {
            InstallPackage -pName $Name -pParams $Params -pVersion $Version -cParams $chocoParams 
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure='Present',
        [ValidateNotNullOrEmpty()]
        [string]
        $Params,    
        [ValidateNotNullOrEmpty()]
        [string]
        $Version,
        [ValidateNotNullOrEmpty()]
        [string]
        $Source,
        [ValidateNotNullOrEmpty()]
        [String]
        $chocoParams,
        [bool]
        $AutoUpgrade = $false
    )

    Write-Verbose -Message 'Start Test-TargetResource'

    if (-Not (Test-ChocoInstalled)) {
        return $false
    } 
    
    $isInstalled = IsPackageInstalled -pName $Name
    
    if ($ensure -eq 'Absent') {
         if ($isInstalled -eq $false) {
            return $true
         } else {
            return $false
         }
    }
    
    if ($version) {
        Write-Verbose -Message "Checking if $Name is installed and if version matches $version"
        $result = IsPackageInstalled -pName $Name -pVersion $Version
    } else {
        Write-Verbose -Message "Checking if $Name is installed"

        if ($AutoUpgrade -and $isInstalled) {
            $result = Test-LatestVersionInstalled -pName $Name
        } else {
            $result = $isInstalled
        }
    }
   
    Return $result
}
function Test-ChocoInstalled
{
    Write-Verbose -Message 'Test-ChocoInstalled'
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')

    Write-Verbose -Message "Env:Path contains: $env:Path"
    if (Test-Command -command choco)
    {
        Write-Verbose -Message 'YES - Choco is Installed'
        return $true
    }

    Write-Verbose -Message 'NO - Choco is not Installed'
    return $false
}

Function Test-Command
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param (
        [string]$command = 'choco' 
    )
    Write-Verbose -Message "Test-Command $command"
    if (Get-Command -Name $command -ErrorAction SilentlyContinue) {
        Write-Verbose -Message "$command exists"
        return $true
    } else {
        Write-Verbose -Message "$command does NOT exist"
        return $false
    } 
} 

function InstallPackage
{
    [Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingInvokeExpression','')]
    param(
        [Parameter(Position=0,Mandatory)]
        [string]$pName,
        [Parameter(Position=1)]
        [string]$pParams,
        [Parameter(Position=2)]
        [string]$pVersion,
        [Parameter(Position=3)]
        [string]$cParams
    ) 

    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    
    [string]$chocoinstallparams = '-y'
    if ($pParams) {
        $chocoinstallparams += " --params=`"$pParams`""
    }
    if ($pVersion) {
        $chocoinstallparams += " --version=`"$pVersion`""
    }
    if ($cParams) {
        $chocoinstallparams += " $cParams"
    }
    Write-Verbose -Message "Install command: 'choco install $pName $chocoinstallparams'"
    
    $packageInstallOuput = Invoke-Expression -Command "choco install $pName $chocoinstallparams"
    Write-Verbose -Message "Package output $packageInstallOuput "

    #refresh path varaible in powershell, as choco doesn"t, to pull in git
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
}

function UninstallPackage 
{
    param(
        [Parameter(Position=0,Mandatory)]
        [string]$pName,
        [Parameter(Position=1)]
        [string]$pParams
    )

    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    
    #Todo: Refactor
    if (-not ($pParams))
    {
        Write-Verbose -Message 'Uninstalling Package Standard'
        $packageUninstallOuput = choco uninstall $pName -y
    }
    elseif ($pParams)
    {
        Write-Verbose -Message "Uninstalling Package with params $pParams"
        $packageUninstallOuput = choco uninstall $pName --params="$pParams" -y            
    }
    
    
    Write-Verbose -Message "Package uninstall output $packageUninstallOuput "

    #refresh path varaible in powershell, as choco doesn"t, to pull in git
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
}


function IsPackageInstalled
{
    param(
        [Parameter(Position=0,Mandatory)][string]$pName,
        [Parameter(Position=1)][string]$pVersion
    ) 
    Write-Verbose -Message "Start IsPackageInstalled $pName"

    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    Write-Verbose -Message "Path variables: $env:Path"
    
    $installedPackages = Get-ChocoInstalledPackage
    
    if ($pVersion) {
        Write-Verbose 'Comparing version'
        $installedPackages = $installedPackages | Where-object { $_.Name -eq $pName -and $_.Version -eq $pVersion}
    } else {
        Write-Verbose "Finding packages -eq $pName"
        $installedPackages = $installedPackages | Where-object { $_.Name -eq $pName}
    }
	
    $count = @($installedPackages).Count
    Write-Verbose "Found $Count matching packages"
    if ($Count -gt 0)
    {
        $installedPackages | ForEach-Object {Write-Verbose -Message "Found: $($_.Name) with version $($_.Version)"}
        return $true
    }

    return $false
}

Function Test-LatestVersionInstalled {
    param(
        [Parameter(Position=0,Mandatory)]
        [string]$pName
    ) 
    Write-Verbose -Message "Testing if $pName can be upgraded"

    $queryres = choco upgrade $pName --noop | Select-String -Pattern $pName 
    $queryres | ForEach-Object {Write-Verbose -Message $_} 
    
    if ($queryres -match "$pName.*is the latest version available based on your source") {
        return $true
    } 
    return $false
}

##region - chocolately installer work arounds. Main issue is use of write-host
##attempting to work around the issues with Chocolatey calling Write-host in its scripts. 
function global:Write-Host
{
    Param(
        [Parameter(Mandatory, Position = 0)]
        [Object]
        $Object,
        [Switch]
        $NoNewLine,
        [ConsoleColor]
        $ForegroundColor,
        [ConsoleColor]
        $BackgroundColor

    )

    #Override default Write-Host...
    Write-Verbose -Message $Object
}

Function Upgrade-Package {
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseApprovedVerbs','')]
    [Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingInvokeExpression','')]
    param(
        [Parameter(Position=0,Mandatory)]
        [string]$pName,
        [Parameter(Position=1)]
        [string]$pParams,
        [Parameter(Position=2)]
        [string]$cParams
    ) 

    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    Write-Verbose -Message "Path variables: $env:Path"
    
    [string]$chocoupgradeparams = '-dv -y'
    if ($pParams) {
        $chocoupgradeparams += " --params=`"$pParams`""
    }
    if ($cParams) {
        $chocoupgradeparams += " $cParams"
    }
    $cmd = "choco upgrade -dv -y $pName $chocoupgradeparams"
    Write-Verbose -Message "Upgrade command: '$cmd'"

    if (-not (IsPackageInstalled -pName $pName))
    {
        throw "$pName is not installed, you cannot upgrade"
    }    
    
    $packageUpgradeOuput = Invoke-Expression -Command $cmd
    $packageUpgradeOuput | ForEach-Object { Write-Verbose -Message $_ }
}

function Get-ChocoInstalledPackage {
    $res = choco list -lo | ForEach-Object {
        $Obj = $_ -split '\s'
        [pscustomobject]@{
            'Name'    = $Obj[0]
            'Version' = $Obj[1]     
        }
    }
    Return $res
}

Export-ModuleMember -Function *-TargetResource