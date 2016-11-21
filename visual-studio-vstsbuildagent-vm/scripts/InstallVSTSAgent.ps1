
# Downloads the Visual Studio Team Services Build Agent and installs on the new machine
# and registers with the Visual Studio Team Services account and agent pool

# Enable -Verbose option
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]$VSTSAccount,
[Parameter(Mandatory=$true)]$VSTSPAT,
[Parameter(Mandatory=$true)]$AgentName,
[Parameter(Mandatory=$true)]$PoolName
)

Write-Verbose "Entering InstallVSTSAgent.ps1" -verbose

$currentLocation = Split-Path -parent $MyInvocation.MyCommand.Definition
Write-Verbose "Current folder: $currentLocation" -verbose


#Create a temporary directory where to download from VSTS the agent package (agent.zip) and then launch the configuration.
$agentTempFolderName = Join-Path $env:temp ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $agentTempFolderName
Write-Verbose "Temporary Agent download folder: $agentTempFolderName" -verbose

$serverUrl = "https://$VSTSAccount.visualstudio.com"
Write-Verbose "Server URL: $serverUrl" -verbose

#
# With this garbled code retrieve the most (probably) recent version of the archive containing the agent binaries for Windows.
$releasesListJson = (Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/repos/microsoft/vsts-agent/releases/latest" -Method Get).Content | ConvertFrom-Json
$VSTSAgentURL = $($releasesListJson.assets | ? {$_.browser_download_url -like "*win*"})[0].browser_download_url 

Write-Verbose "VSTS Agent URL: $VSTSAgentURL" -verbose


$retryCount = 3
$retries = 1
Write-Verbose "Downloading Agent install files" -verbose
do
{
  try
  {
    Invoke-WebRequest -Uri $VSTSAgentURL -Method Get -OutFile "$agentTempFolderName\agent.zip" 
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

# Construct the agent folder under the main (hardcoded) C: drive.
$agentInstallationPath = Join-Path "C:" $AgentName 
# Create the directory for this agent.
New-Item -ItemType Directory -Force -Path $agentInstallationPath 


Write-Verbose "Extracting the zip file for the agent" -verbose
$destShellFolder = (new-object -com shell.application).namespace("$agentInstallationPath")
$destShellFolder.CopyHere((new-object -com shell.application).namespace("$agentTempFolderName\agent.zip").Items(),16)

# Retrieve the path to the vstsAgent.exe file.
$agentExePath = [System.IO.Path]::Combine($agentInstallationPath, 'config.cmd')
Write-Verbose "Agent Location = $agentExePath" -Verbose
if (![System.IO.File]::Exists($agentExePath))
{
    Write-Error "File not found: $agentExePath" -Verbose
    return
}

# Call the agent with the configure command and all the options (this creates the settings file) without prompting
# the user or blocking the cmd execution

Write-Verbose "Configuring agent" -Verbose


# Set the current directory to the agent dedicated one previously created.
Push-Location -Path $agentInstallationPath
# The actual install of the agent. Using NetworkService as default service logon account, and some other values that could be turned into paramenters if needed 
&$agentExePath --unattended --url "$serverUrl" --auth PAT --token ""$VSTSPAT"" --pool ""$PoolName"" --agent ""$AgentName"" --runasservice

# Restore original current directory.
Pop-Location

if($LASTEXITCODE -ne 0)
{
  Write-Verbose "Agent installation failed! `$LASTEXITCODE=`"$LASTEXITCODE`"" -Verbose
}
else
{
  Write-Verbose "Agent installation successful! `$LASTEXITCODE=`"$LASTEXITCODE`"" -Verbose
}

Write-Verbose "Exiting InstallVSTSAgent.ps1" -Verbose

exit $LASTEXITCODE