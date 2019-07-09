# Downloads the Azure DevOps Build Agent and installs on the new machine
# and registers with the Azure DevOps account and agent pool

# Enable -Verbose option
[CmdletBinding()]
Param
(
	[Parameter(Mandatory=$true)]
	[string]$DevOpsOrg,

	[Parameter(Mandatory=$true)]
	[string]$DevOpsPAT,

	[Parameter(Mandatory=$true)]
	[string]$AgentName,

	[Parameter(Mandatory=$true)]
	[string]$PoolName,

	[Parameter(Mandatory=$true)]
	[int]$AgentCount,
	
	[Parameter(Mandatory=$false)]
	[object]$Modules = @(
		@{ Name = "Az"; Version = "2.4.0" },
		@{ Name = "Az.Blueprint"; Version = "0.2.1" },
		@{ Name = "Pester"; Version = "4.8.1" }
	),

	[Parameter(Mandatory=$false)]
	[object]$Packages = @(
		@{ Name = "powershell-core"; Version = "6.2.1.20190704" },
		@{ Name = "azure-cli"; Version = "2.0.68" },
		@{ Name = "terraform"; Version = "0.12.3"}		
	)
)

#region Functions
Function Invoke-FileDownLoad
{
	param
	(
		[Parameter(Mandatory=$true)]
		[string]$Name,

		[Parameter(Mandatory=$true)]
		[string]$Uri,

		[Parameter(Mandatory=$true)]
		[string]$TempFolderName
	)

	$retryCount = 3
	$retries = 1
	Write-Verbose "Downloading $Name files" -verbose

	do
	{
		try
		{
			Invoke-WebRequest -Uri $Uri -Method GET -OutFile "$($TempFolderName)\$($Name).zip"
			Write-Verbose "Downloaded $($Name) successfully on attempt $retries" -verbose
			break
		} catch
		{
			$exceptionText = ($_ | Out-String).Trim()
			Write-Verbose "Exception occured downloading $($Name).zip: $($exceptionText) in try number $($retries)" -verbose
			$retries++
			Start-Sleep -Seconds 30 
		}
	} while ($retries -le $retryCount)
}

Function Expand-ZipFile
{
	param
	(
		[Parameter(Mandatory=$true)]
		[string]$Name,

		[Parameter(Mandatory=$true)]
		[string]$Path,

		[Parameter(Mandatory=$true)]
		[string]$TempFolderName
	)

	Write-Verbose "Extracting the zip file for $($Name)" -Verbose
	$destShellFolder = (new-object -com shell.application).namespace("$($Path)")
	$destShellFolder.CopyHere((new-object -com shell.application).namespace("$($TempFolderName)\$($Name).zip").Items(),16)
}
#endregion

#region Variables
$currentLocation = Split-Path -parent $MyInvocation.MyCommand.Definition
$tempFolderName = Join-Path $env:temp ([System.IO.Path]::GetRandomFileName())
$serverUrl = "https://dev.azure.com/$($DevOpsOrg)"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#endregion

#region Register Repositories, Install Chocgeolately
# Register Respositories
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install and Upgrade Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco upgrade chocolatey
#endregion

#region Install Packages
foreach ($Package in $Packages)
{
	choco install $Package.Name --version $Package.Version --force -y
} 
#endregion

#region DevOps Agent
Write-Verbose "Current folder: $($currentLocation)" -verbose

#Create a temporary directory where to download from Azure DevOps the agent package and then launch the configuration.
New-Item -ItemType Directory -Force -Path $tempFolderName
Write-Verbose "Temporary download folder: $($tempFolderName)" -verbose
Write-Verbose "Server URL: $($serverUrl)" -Verbose

Write-Verbose "Trying to get download URL for latest Azure DevOps agent release..."
$header = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$DevOpsPAT"))}
$devopsUrl = "{0}/_apis/distributedtask/packages/agent?platform={1}&`$top=1" -f $serverUrl, "win-x64"
$response = Invoke-WebRequest -UseBasicParsing -Headers $header -Uri $devopsUrl 
$response = ConvertFrom-Json $response.Content
$uri = $response.value[0].downloadUrl

Invoke-FileDownLoad -Name "devops-agent" -Uri $uri -TempFolderName $tempFolderName

for ($i=0; $i -lt $AgentCount; $i++)
{
	$Agent = ($AgentName + "-" + $i)

	# Construct the agent folder under the main (hardcoded) C: drive.
	$agentInstallationPath = Join-Path "C:\Agents" $Agent
	
	# Create the directory for this agent.
	New-Item -ItemType Directory -Force -Path $agentInstallationPath
	
	# Set the current directory to the agent dedicated one previously created.
	Push-Location -Path $agentInstallationPath
	
	# Extract Download File
	Expand-ZipFile -Name "devops-agent" -Path $agentInstallationPath -TempFolderName $tempFolderName

	# Removing the ZoneIdentifier from files downloaded from the internet so the plugins can be loaded
	# Don't recurse down _work or _diag, those files are not blocked and cause the process to take much longer
	Write-Verbose "Unblocking files" -verbose
	Get-ChildItem -Recurse -Path $agentInstallationPath | Unblock-File | out-null

	# Retrieve the path to the config.cmd file.
	$agentConfigPath = [System.IO.Path]::Combine($agentInstallationPath, 'config.cmd')
	Write-Verbose "Agent Location = $agentConfigPath" -Verbose
	if (![System.IO.File]::Exists($agentConfigPath))
	{
		Write-Error "File not found: $agentConfigPath" -Verbose
		return
	}

	# Call the agent with the configure command and all the options (this creates the settings file) without prompting
	# the user or blocking the cmd execution
	Write-Verbose "Configuring agent '$($Agent)'" -Verbose		
	.\config.cmd --unattended --url $serverUrl --auth PAT --token $DevOpsPAT --pool $PoolName --agent $Agent --runasservice
	
	Write-Verbose "Agent install output: $LASTEXITCODE" -Verbose
	
	Pop-Location
}
#endregion

#region Install Modules
# Installing Modules using PowerShell Core
$scriptBlock = {
    $Modules = $args

    foreach ($Module in $Modules)
    {	
	    Install-Module -Name $Module.Name -RequiredVersion $Module.Version -Repository PSGallery -Scope AllUsers -Force -Confirm:$false -SkipPublisherCheck -AllowClobber -Verbose
    }

    # Checking for multiple versions of modules 
    $Mods = Get-InstalledModule

    foreach ($Mod in $Mods)
    {
  	    $latest = Get-InstalledModule $Mod.Name -AllVersions | Select-Object -First 1
  	    $specificMods = Get-InstalledModule $Mod.Name -AllVersions

	    if ($specificMods.count -gt 1)
	    {
		    write-output "$($specificMods.count) versions of this module found [ $($Mod.Name) ]"
		    foreach ($sm in $specificMods)
		    {
			    if ($sm.version -ne $latest.version)
			    { 
				    write-output " $($sm.name) - $($sm.version) [highest installed is $($latest.version)]" 
				    $sm | uninstall-module -force
			    }
		    }
	    }
    }
}

pwsh -Command $scriptBlock -Args $Modules -NonInteractive -ExecutionPolicy Unrestricted

# Uninstalling old Azure PowerShell Modules
$programName = "Microsoft Azure PowerShell"
if ($app = Get-WmiObject -Class Win32_Product -Filter "Name Like '$($programName)%'" -Verbose) 
{ $app.Uninstall() }

Write-Verbose "Exiting InstallDevOpsAgent.ps1" -Verbose
Restart-Computer -Force
#endregion
