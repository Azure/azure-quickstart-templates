param 
 ( 
     # The cloud security agent user name     
     [Parameter(Mandatory=$true)] 
     [String] $infoUsername, 
  
     # The cloud security agent password 
     [Parameter(Mandatory=$true)] 
     [String] $infoPassword
) 
 
if(($username -eq "") -and ($password -eq ""))
{
 Write-Host "Please provide valid UserName and Password"
 exit
}
else
{
Write-Host "Installing Informatica Cloud Secure Agent............" 
cd 'C:\Program Files (x86)\Informatica Cloud Secure Agent\main\agentcore'
cmd.exe /C consoleAgentManager.bat configure $infoUsername $infoPassword
cmd.exe /C consoleAgentManager.bat isConfigured
cmd.exe /C exit 
}
