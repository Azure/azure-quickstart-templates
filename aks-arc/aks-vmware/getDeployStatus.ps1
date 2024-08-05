# script to obtain errors from ARM template deployments
# az login --service-principal -u adf4852b-132b-443d-81b0-c50493735ab9 -p ... --tenant microsoft.onmicrosoft.com 
$ErrorActionPreference = 'continue'

#todo parameterize
$start = 7
$end = 206
$armDeployPrefix = "armdep-0317-a"
$clusPrefix = "clus-0317-a"
$rg = 'sarathys'
$success = 0
$fail = 0
$errorInfo = @()

for($i=$start; $i -lt $end; $i++) 
{
  Write-Verbose -Message "AksArc show cluster: $clusPrefix$i " -Verbose
  $cluster = az aksarc show -n "$clusPrefix$i" -g $rg | ConvertFrom-Json
  Write-Verbose -Message "az deployment show deployment: $armDeployPrefix$i " -Verbose
  $depInfo = az deployment group show -n "$armDeployPrefix$i" -g $rg | ConvertFrom-Json
  if($null -ne $depInfo) 
  {
    if($cluster.properties.provisioningState -eq 'Failed') 
    {
        Write-Verbose -Message "cluster $clusPrefix$i provisioning has failed" -Verbose
        $fail++
        $errorInfo += @{ClusterName = "$clusPrefix$i" 
                        Error = $cluster.properties.status.errorMessage 
                        AddOnNotReady = ($c.properties.status.controlPlaneStatus | ? {$_.ready -ne 'True'} ) 
                        ArmDeployment = $depInfo.name
                        ArmDeployError = ($depInfo.properties.error.details | select message).message
                        ArmDeployDuration = $depInfo.properties.duration
                      }
      }
      else 
      {
        Write-Verbose -Message "cluster $clusPrefix$i provisioning has succeeded." -Verbose
        $success++
      }
  }
}

Write-Verbose -Message "Success: $success failed: $fail" -Verbose
mkdir c:\temp -Force
$errorLogFile = "c:\temp\aksvmwareerr2.txt"
$errorInfo | ConvertTo-Json | Out-File $errorLogFile -Force
Write-Verbose -Message "Error info written $errorLogFile" -Verbose

 


