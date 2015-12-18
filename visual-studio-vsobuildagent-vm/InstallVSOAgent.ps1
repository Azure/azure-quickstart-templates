
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

    Invoke-WebRequest -Uri $VSOAgentURL -headers $headers -Method Get -OutFile "$currentLocation\agent.zip"
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

Write-Verbose "Extracting the zip file for the agent" -verbose
(new-object -com shell.application).namespace($currentLocation).CopyHere((new-object -com shell.application).namespace("$currentLocation\agent.zip").Items(),16)

# Removing the ZoneIdentifier from files downloaded from the internet so the plugins can be loaded
# Don't recurse down _work or _diag, those files are not blocked and cause the process to take much longer
Write-Verbose "Unblocking files" -verbose
Get-ChildItem -Path $currentLocation | Unblock-File | out-null
Get-ChildItem -Recurse -Path $currentLocation\Agent | Unblock-File | out-null

$agentLocation = [System.IO.Path]::Combine($currentLocation, 'Agent', 'vsoAgent.exe')
Write-Verbose "Agent Location = $agentLocation" -Verbose
if (![System.IO.File]::Exists($agentLocation))
{
    Write-Error "File not found: $agentLocation" -Verbose
    return
}

# Call the agent with the configure command and all the options (this creates the settings file) without prompting the user or blocking the cmd execution
Write-Verbose "Configuring agent" -Verbose

$WorkFolder = "c:\work"

# Create a folder for the build work
New-Item -ItemType Directory -Force -Path $WorkFolder

# The actual install of the agent. Using NetworkService as default service logon account, and some other values that could be turned into paramenters if needed 
&start cmd.exe "/k $agentLocation /configure /RunningAsService /login:$VSOUser,$VSOPass /serverUrl:$serverUrl ""/WindowsServiceLogonAccount:NT AUTHORITY\NetworkService"" /WindowsServiceLogonPassword /WindowsServiceDisplayName:VsoBuildAgent /name:$AgentName /PoolName:$PoolName /WorkFolder:$WorkFolder /StartMode:Automatic /force /NoPrompt &exit"

Write-Verbose "Agent install output: $LASTEXITCODE" -Verbose

Write-Verbose "Exiting InstallVSOAgent.ps1" -Verbose