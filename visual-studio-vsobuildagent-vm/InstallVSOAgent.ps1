
# Downloads the Visual Studio Online Build Agent and installs on the new machine
# and registers with the Visual Studio Online account and build agent pool

# Enable -Verbose option
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]$VSOAccount,
[Parameter(Mandatory=$true)]$VSOUser,
[Parameter(Mandatory=$true)]$VSOPass,
[Parameter(Mandatory=$true)]$AgentName,
[Parameter(Mandatory=$true)]$PoolName
)

Write-Verbose "Entering InstallVSOAgent.ps1" -verbose

$currentLocation = Split-Path -parent $MyInvocation.MyCommand.Definition
Write-Verbose "Current folder: $currentLocation" -verbose

#Create a temporary directory where to download from VSTS the agent package (agent.zip) and then launch the configuration.
$agentTempFolderName = Join-Path $env:temp ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $agentTempFolderName
Write-Verbose "Temporary Agent download folder: $agentTempFolderName" -verbose

$serverUrl = "https://$VSOAccount.visualstudio.com"
Write-Verbose "Server URL: $serverUrl" -verbose

$VSOAgentURL = "$serverUrl/_apis/distributedtask/packages/agent"
Write-Verbose "VSO Agent URL: $VSOAgentURL" -verbose


$retryCount = 3
$retries = 1
Write-Verbose "Downloading Agent install files" -verbose
do
{
  try
  {
    $basicAuth = ("{0}:{1}" -f $VSOUser,$VSOPass) 
    $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
    $basicAuth = [System.Convert]::ToBase64String($basicAuth)
    $headers = @{Authorization=("Basic {0}" -f $basicAuth)}

    Invoke-WebRequest -Uri $VSOAgentURL -headers $headers -Method Get -OutFile "$agentTempFolderName\agent.zip"
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

# Create a folder for the build work
New-Item -ItemType Directory -Force -Path (Join-Path $agentInstallationPath $WorkFolder)


Write-Verbose "Extracting the zip file for the agent" -verbose
$destShellFolder = (new-object -com shell.application).namespace("$agentInstallationPath")
$destShellFolder.CopyHere((new-object -com shell.application).namespace("$agentTempFolderName\agent.zip").Items(),16)

# Removing the ZoneIdentifier from files downloaded from the internet so the plugins can be loaded
# Don't recurse down _work or _diag, those files are not blocked and cause the process to take much longer
Write-Verbose "Unblocking files" -verbose
Get-ChildItem -Path $agentInstallationPath | Unblock-File | out-null
Get-ChildItem -Recurse -Path $agentInstallationPath\Agent | Unblock-File | out-null

# Retrieve the path to the vsoAgent.exe file.
$agentExePath = [System.IO.Path]::Combine($agentInstallationPath, 'Agent', 'vsoAgent.exe')
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
&start cmd.exe "/k $agentExePath /configure /RunningAsService /login:$VSOUser,$VSOPass /serverUrl:$serverUrl ""/WindowsServiceLogonAccount:NT AUTHORITY\NetworkService"" /WindowsServiceLogonPassword /WindowsServiceDisplayName:VsoBuildAgent /name:$AgentName /PoolName:$PoolName /WorkFolder:$WorkFolder /StartMode:Automatic /force /NoPrompt &exit"
# Restore original current directory.
Pop-Location


Write-Verbose "Agent install output: $LASTEXITCODE" -Verbose

Write-Verbose "Exiting InstallVSOAgent.ps1" -Verbose
