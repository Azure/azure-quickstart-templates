# Downloads the Visual Studio Team Services Build Agent and installs on the new machine
# and registers with the Visual Studio Team Services account and build agent pool

# Enable -Verbose option
[CmdletBinding()]
Param
(
	[Parameter(Mandatory=$true)]
	[string]$VSTSAccount,

	[Parameter(Mandatory=$true)]
	[string]$PersonalAccessToken,

	[Parameter(Mandatory=$true)]
	[string]$AgentName,

	[Parameter(Mandatory=$true)]
	[string]$PoolName,

	[Parameter(Mandatory=$true)]
	[int]$AgentCount,

	[Parameter(Mandatory=$true)]
	[string]$AdminUser,

	[boolean]$prerelease=$false
)

Write-Verbose "Entering InstallVSOAgent.ps1" -verbose

$currentLocation = Split-Path -parent $MyInvocation.MyCommand.Definition
Write-Verbose "Current folder: $currentLocation" -verbose

#Create a temporary directory where to download from VSTS the agent package (vsts-agent.zip) and then launch the configuration.
$agentTempFolderName = Join-Path $env:temp ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $agentTempFolderName
Write-Verbose "Temporary Agent download folder: $agentTempFolderName" -verbose

$serverUrl = "https://dev.azure.com/$VSTSAccount"
Write-Verbose "Server URL: $serverUrl" -verbose

$retryCount = 3
$retries = 1
Write-Verbose "Downloading Agent install files" -verbose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
do
{
  try
  {
    Write-Verbose "Trying to get download URL for latest VSTS agent release..."
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/Microsoft/vsts-agent/releases"
	$latestRelease = $latestRelease |  Where-Object prerelease -eq $prerelease |where-object assets -ne $null | Sort-Object created_at -Descending | Select-Object -First 1
    $assetsURL = ($latestRelease.assets).browser_download_url
    $latestReleaseDownloadUrl = ((Invoke-RestMethod -Uri $assetsURL) -match 'win-x64').downloadurl
    Invoke-WebRequest -Uri $latestReleaseDownloadUrl -Method Get -OutFile "$agentTempFolderName\agent.zip"
    Write-Verbose "Downloaded agent successfully on attempt $retries" -verbose
    break
  }
  catch
  {
    $exceptionText = ($_ | Out-String).Trim()
    Write-Verbose "Exception occured downloading agent: $exceptionText in try number $retries" -verbose
    $retries++
    Start-Sleep -Seconds 30 
  }
} 
while ($retries -le $retryCount)

for ($i=0; $i -lt $AgentCount; $i++)
{
	$Agent = ($AgentName + "-" + $i)

	# Construct the agent folder under the main (hardcoded) C: drive.
	$agentInstallationPath = Join-Path "C:" $Agent

	# Create the directory for this agent.
	New-Item -ItemType Directory -Force -Path $agentInstallationPath

	# Set the current directory to the agent dedicated one previously created.
	Push-Location -Path $agentInstallationPath
	
	Write-Verbose "Extracting the zip file for the agent" -verbose
	$destShellFolder = (new-object -com shell.application).namespace("$agentInstallationPath")
	$destShellFolder.CopyHere((new-object -com shell.application).namespace("$agentTempFolderName\agent.zip").Items(),16)

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
	.\config.cmd --unattended --url $serverUrl --auth PAT --token $PersonalAccessToken --pool $PoolName --agent $Agent --runasservice
	
	Write-Verbose "Agent install output: $LASTEXITCODE" -Verbose
	
	Pop-Location
}

Write-Verbose "Exiting InstallVSTSAgent.ps1" -Verbose
