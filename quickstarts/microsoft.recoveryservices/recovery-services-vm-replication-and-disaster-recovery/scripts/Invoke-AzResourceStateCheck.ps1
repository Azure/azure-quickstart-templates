[CmdletBinding()]
param (
  [string]
  $azDnsResourceResourceId,
  $azRsvResourceResourceId
)

$startTime = Get-Date
$azRsvResourcePropertyStateGet = Get-AzRecoveryServicesVault -ResourceGroupName "$($azRsvResourceResourceId.Split("/")[4])" -Name "$($azRsvResourceResourceId.Split("/")[8])"
$vaultPELinkId = ($azRsvResourcePropertyStateGet.Properties.PrivateEndpointConnections.Name).Split(".")[1]
$vaultPERecordCheck = "$($vaultPELinkId)-asr-pod01-rcm1"

$rcm1Check = @()
do {
  $GetDnsRecordSet = Get-AzPrivateDnsRecordSet -ParentResourceId $azDnsResourceResourceId | Where-Object {$_.Name -match $vaultPERecordCheck}
  foreach($name in $GetDnsRecordSet.Name){
    if($rcm1Check -notcontains $name){
      $rcm1Check += $GetDnsRecordSet.Name
    }
  }

  $ElapsedTime = New-TimeSpan -Start $StartTime -End (Get-Date)
  if ($ElapsedTime.TotalSeconds -ge (1800)) {
    break
  }

  Start-Sleep -Seconds 60 # Wait for 1 minute
} 
while (
  $rcm1Check.Length -le 1
)