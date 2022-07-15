[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Security

$MeEndpoint = "https://kessel-api.parsecgaming.com/me"
$userBinPath = "C:\ProgramData\Parsec\user.bin"
$configtxtdir = 'C:\ProgramData\Parsec\config.txt'

Class Post 
{
[String]$name
[String]$peer_id 
[int]$team_group_id 
[int]$user_id 
[string]$user_email
[string]$key
[string]$team_id
[bool]$is_guest_access = $false

    [void] Fill(){
        $config = fetchUserData
        foreach ($line in $config) {
        $this."$($line.split("=")[0])" = $($line.split("=")[1])
        $this.peer_id = $(PeerIDGetter)
        if (!$this.name) {$this.name =  $env:COMPUTERNAME}
        }
    }
} 


function fetchUserData { 
    $metadata = $null;
    $found = $false;
    #GCP
    try {
        $req = Invoke-WebRequest -uri http://metadata.google.internal/computeMetadata/v1/instance/attributes/parsec -Method GET -header @{'metadata-flavor'='Google'} -TimeoutSec 5;
        if($req.StatusCode -eq 200) {
            $metadata = [System.Text.Encoding]::ASCII.GetString($req.content).split(':');
            $found = $true;
        }
    }
    catch {}
    
    #Paperspace
    if(!$found) {
        Try {
            $req = Invoke-WebRequest -uri http://metadata.paperspace.com/meta-data/machine -TimeoutSec 5;
            if($req.StatusCode -eq 200) {
                $metadata = [System.Text.Encoding]::ASCII.GetString($req.content).split(':')
                $found = $true;
            }
        }
        catch {}
    }
    
    #AWS
    if(!$found) {
        Try {
            $req = Invoke-WebRequest -Uri "http://169.254.169.254/latest/user-data?api-version=2018-10-01" -Headers @{Metadata="true"} -TimeoutSec 5
            if($req.StatusCode -eq 200) {
                $metadata = [System.Text.Encoding]::ASCII.GetString($req.content).split(':')
                $found = $true;
            }
        }
        catch {}   
    }

    #Azure
    if(!$found) {
        Try {
            $userData = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET  -Uri "http://169.254.169.254/metadata/instance/compute/userData?api-version=2021-01-01&format=text" -TimeoutSec 5
            $base64 = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($userData));

            $metadata = $base64.split(':');
            $found = $true;
        }
        catch {}
    }

    if ($null -ne $metadata) {
        return $metadata;
    } else {
        #no userdata found, exiting...
        exit
    }
}


Function PeerIDGetter {
    $configfile = get-content $configtxtdir
    foreach ($configline in $configfile) {
        if ($configline -like 'app_host_peer_id*') {
            $peerid = $configline.Split(' = ')[-1]
                }
        }
    if ($peerid -eq $NULL) {$peerid = $NULL}
    return $peerid
    }


Function WritePeerID {
Param(
$peer_id
)
    $configfile = Get-Content $configtxtdir
    $File = Foreach ($configline in $configfile) { 
        if ($configline -like 'app_host_peer_id*') {
            }
        Else {$configline}
            }
    $file += "app_host_peer_id=$peer_id"
    $file | Out-File $configtxtdir -Encoding ascii
    }

Function WriteHostname {
Param(
$host_name
)
    $configfile = Get-Content $configtxtdir
    $File = Foreach ($configline in $configfile) { 
        if ($configline -like 'host_name*') {
            }
        Else {$configline}
            }
    $file += "host_name=$host_name"
    $file | Out-File $configtxtdir -Encoding ascii
    }


Function SessionIDFromUserBin {
    if (Test-Path $userBinPath) {
        Add-Type -AssemblyName System.Security
        $scope = [System.Security.Cryptography.DataProtectionScope]::LocalMachine
        [byte[]]$binbyte = Get-Content $userBinPath -encoding byte
        $decryptuserBin = [System.Security.Cryptography.ProtectedData]::Unprotect($binbyte, $null, $scope)
        $parseuserbin = [System.Text.Encoding]::ASCII.GetString($decryptuserBin)
        return $parseuserbin.Split('"')[-2]
        }
    Else {
        return 0
        }
    }

Function SessionIDToUserBin {
Param (
[string]$session
)
    $userBinJson = @{
	    "session_id" = $session
        } | ConvertTo-Json
    $scope = [System.Security.Cryptography.DataProtectionScope]::LocalMachine
    $input = [System.Text.UTF8Encoding]::UTF8.GetBytes($userBinJson)
    $userBin = [System.Security.Cryptography.ProtectedData]::Protect($input, $null, $scope)
    Set-Content $userBinPath -Value $userBin -Encoding Byte
    }


Function PostTeamEndpoint {
param (
[post]$Params
)
    $body = $Params | select * -ExcludeProperty key, team_id
    $TeamEndpointHeaders = @{
	    "Content-Type" = "application/json"
	    "X-Machine-Key" = $params.key
        }
    $TeamEndpointRequest = Invoke-RestMethod -Uri $TeamEndoint -Method POST -Headers $TeamEndpointHeaders -Body ($body | ConvertTo-Json)
    return $TeamEndpointRequest
}


Function GenerateMeData {
param(
[string]$Session
)
    $SessionHeader = @{
        "Authorization" = "Bearer $Session"
    }
    $array =  (Invoke-RestMethod -Uri $MeEndpoint -Method GET -Headers $SessionHeader).data
    $array
}


$RequestDetails = [Post]::new()
$RequestDetails.Fill()
$TeamEndoint = "https://kessel-api.parsecgaming.com/teams/{0}/machines" -f $RequestDetails.team_id
try {
    $TeamsEndpointRequest = PostTeamEndpoint -params $RequestDetails
} catch {
    Exit 1
}

WritePeerID -peer_id $TeamsEndpointRequest.data.host_peer_id
WriteHostname -host_name $RequestDetails.name
#$Details = GenerateMeData -Session $TeamsEndpointRequest.data.id
SessionIDToUserBin -session $TeamsEndpointRequest.data.id

Stop-Process -Name parsecd -Force

