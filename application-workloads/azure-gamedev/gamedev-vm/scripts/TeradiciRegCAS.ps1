
# Copyright (c) 2021 Teradici Corporation
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
[CmdletBinding(DefaultParameterSetName = "_AllParameterSets")]
param(
    [Parameter(Mandatory = $true)]
    [string]
    $pcoip_registration_code
)
$InstalledAgentPath = 'C:\Program Files\Teradici\PCoIP Agent\'
$destPath= "C:\Teradici\"
$LOG_FILE = $destPath +'CSELog.txt'

$global:restart = $false

if (!(Test-Path $destPath))
{
  try { New-Item -Path $destPath -ItemType Directory -ErrorAction Stop }
  catch {  Write-Error -Message "Unable to Create Directory: $destPath " }
}
function Log([string] $String){
    $TimeStamp="[{0:dd-MMM-yy} {0:HH:mm:ss}]" -f (Get-Date)
    Write-Output "$TimeStamp $String" | Out-File -FilePath  $LOG_FILE  -Append -Force
}

Log "START----------------------> Input Parameters:"
Log "pcoip_registration_code:    $pcoip_registration_code"

#-------------------------------------------------------------------------
# Retry function, defaults to try 30 times with 10s intervals = 5min
#--------------------------------------------------------------------------
function Retry([scriptblock]$Action, $Interval = 10, $Attempts = 30) {
    $Current_Attempt = 0
    while ($true) {
        $Current_Attempt++
        $rc = $Action.Invoke()
       
        #If successful return Action Invoke return
        if ($?) { return $rc }
        if ($Current_Attempt -ge $Attempts) {
            Log "--> ERROR: Failed after $Current_Attempt attempt(s)." -InformationAction Continue
            #throw ??? this would throw off my Try-catch block ...
        }
        Log "--> Attempt $Current_Attempt failed. Retrying in $Interval seconds..." -InformationAction Continue
        Start-Sleep -Seconds $Interval
    }
}
function IS_PCoIPAgent_Installed {
    $arrService = Get-Service "PCoIPAgent*"
    if(($null -eq $arrService)){
        return  $false 
    }
    return $true
}

#################################################################
Log "MAIN ---------------->Custom Script Extension "
Log  "---> Script running as user '$(whoami)'."
#################################################################

try {
    if (IS_PCoIPAgent_Installed){
        if(!([string]::IsNullOrEmpty($pcoip_registration_code))){

            Set-Location $InstalledAgentPath
            Log "--> Checking for existing PCoIP License at: $InstalledAgentPath "
            & powershell .\pcoip-validate-license.ps1 *>$null

            if ( $LastExitCode -eq 0 ) {
                Log "--> Found a valid license"
            }
            else {
                Log "--> Retry action to register PCoIP Agent with register-host.ps1"
                Retry -Action { powershell .\pcoip-register-host.ps1 -RegistrationCode $pcoip_registration_code *>$null }
                Log "--> Retry Returned "  
                
                if ($LastExitCode -ne 0) {
                    $errMsg = "Teradici registration failed for the provided code. You can try to register the PCoIP Agent manually by connecting to the VM via RDP and following Teradici's instructions at https://www.teradici.com/web-help/pcoip_agent/standard_agent/windows/2.15.0/admin-guide/licensing/licensing"
                    throw $errMsg
                }
                
                #Agent Restart
                Log "--> PCoIP Agent Restart "    
                Restart-Service -Name PCoIPAgent        
            }
     
        }
    }
}
catch [Exception]{
    Log $_.Exception.Message
    Add-Content 'C:\Users\Public\Desktop\INSTALLED_SOFTWARE.txt' "ERROR: $($_.Exception.Message)"
    throw $_.Exception.Message
}