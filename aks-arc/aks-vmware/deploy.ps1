# Deploy AKS Arc clusters on vmware in batches
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    $ControlplaneStaticIPfile = "availip.txt",

    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]
    $ArmTemplateFile = "armtemplate.json",

    [Parameter(Mandatory=$true)]
    [string]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    $ArmTemplateParametersFile = "vmware.parameters.json",

    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroup = 'sarathys',

    [Parameter(Mandatory=$true)]
    [string]
    $ServicePrincipalId,

    [Parameter(Mandatory=$true)]
    [securestring]
    $ServicePrincipalSecret,

    [Parameter(Mandatory=$true)]
    [string]
    $TenantId = 'microsoft.onmicrosoft.com'
)

# Path: ARMtemplates/deploy.ps1

function Login {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $ServicePrincipalId,

        [Parameter(Mandatory=$true)]
        [securestring]
        $ServicePrincipalSecret,

        [Parameter(Mandatory=$true)]
        [string]
        $TenantId = 'microsoft.onmicrosoft.com'
    )

    $ErrorActionPreference = 'stop'
    $ServicePrincipalSecret = ConvertFrom-SecureString -SecureString $ServicePrincipalSecret
    az login --service-principal -u $ServicePrincipalId -p $ServicePrincipalSecret --tenant $TenantId
}


function Save-DeploymentInfo($deploymentName, $clusterName, $rg)
{
  $cluster = az aksarc show -n "$clusterName" -g $rg | ConvertFrom-Json
  Write-Verbose -Message "az deployment show deployment: $deploymentName" -Verbose
  $depInfo = az deployment group show -n $deploymentName -g $rg | ConvertFrom-Json
  $errorInfo = $null
  if($null -ne $depInfo) 
  {
    if($cluster.properties.provisioningState -eq 'Failed') 
    {
        Write-Verbose -Message "cluster $clusterName provisioning has failed" -Verbose
        $errorInfo = @{ClusterName = "$clusterName" 
                        Error = $cluster.properties.status.errorMessage 
                        AddOnNotReady = ($c.properties.status.controlPlaneStatus | ? {$_.ready -ne 'True'} ) 
                        ArmDeployment = $depInfo.name
                        ArmDeployError = ($depInfo.properties.error.details | select message).message
                        ArmDeployDuration = $depInfo.properties.duration
                      }
      }
      else 
      {
        Write-Verbose -Message "cluster $clusterName provisioning has succeeded." -Verbose
      }
  }

  $deployInfo = @{DeploymentName = $deploymentName; ClusterName = $clusterName; ErrorInfo = $errorInfo}

  Write-Verbose -Message "Deployment info for deployment: $deploymentName clusterName: $clusterName saved to $resultsFile" -Verbose
  $deployInfo | ConvertTo-Json | Out-File $resultsFile -Append
}


# main

$ErrorActionPreference = 'continue'

# get mmdd prefix
$prefix = (Get-Date).ToString("MMdd")
$armDeployPrefix = "a$prefix-"
$clusPrefix = "c$prefix-"

$ips = Get-Content $ControlplaneStaticIPfile -ErrorAction Stop

$batchSize = 10
$batchNum = 0
$r = [System.Random]::new()
$batchSize = $r.Next(1, 10)
$iteration = 0
$rg = 'sarathys'

mkdir c:\aksarc -Force
$resultsFile = "C:\aksarc\results.json"

Login -ServicePrincipalId $ServicePrincipalId -ServicePrincipalSecret $ServicePrincipalSecret -TenantId $TenantId

while($true) 
{
    $iteration++
    Write-Verbose -Message "[$(Get-Date)] START iteration $iteration" -Verbose
    for($i=0; $i -lt $ips.Count; $i = $i + $batchSize)
    {
        $batchNum++
        Write-Verbose -Message "[$(Get-Date)] START batch $batchNum deployment, batch size = $batchSize" -Verbose
        for($j=$i; ($j -lt ($i + $batchSize)) -and ($j -lt $ips.Count - 1); $j++) 
        {
            $controlPlaneIp = $ips[$j]
            $controlPlaneIpRes = $controlPlaneIp.Replace('.','-')
            $deploymentName = "$armDeployPrefix$controlPlaneIpRes"
            $clusterName = "$clusPrefix$controlPlaneIpRes"
            Write-Verbose -Message "[$(Get-Date)] Starting template deployment $deploymentName with control plane IP: $controlPlaneIp clusterName $clusterName" -Verbose
            az deployment group create --name $deploymentName --resource-group sarathys --template-file .\armtemplate.json --parameters `@vmware.parametersLoop.json `
                --parameters controlPlaneIp=$controlPlaneIp --parameters provisionedClusterName=$clusterName --no-wait
        }

        for($j=$i; ($j -lt ($i + $batchSize)) -and ($j -lt $ips.Count - 1); $j++) 
        {
            $controlPlaneIp = $ips[$j]
            $controlPlaneIpRes = $controlPlaneIp.Replace('.','-')
            $deploymentName = "$armDeployPrefix$controlPlaneIpRes"
    
            Write-Verbose -Message "[$(Get-Date)] WAIT for deployment $deploymentName to be created, timeout 1h." -Verbose
            az deployment group wait --name $deploymentName --resource-group sarathys --created 
        }


        for($j=$i; ($j -lt ($i + $batchSize)) -and ($j -lt $ips.Count - 1); $j++) 
        {
            $controlPlaneIp = $ips[$j]
            $controlPlaneIpRes = $controlPlaneIp.Replace('.','-')
            $deploymentName = "$armDeployPrefix$controlPlaneIpRes"
    
            Save-DeploymentInfo -deploymentName $deploymentName -clusterName $clusterName -rg $rg
            Write-Verbose -Message "[$(Get-Date)] DELETE deployment $deploymentName to be created, timeout 1h." -Verbose
            az deployment group delete --name $deploymentName --resource-group sarathys --no-wait
        }


        Write-Verbose -Message "[$(Get-Date)] END batch $batchNum" -Verbose
        $batchSize = $r.Next(1, 10)
    }
    Write-Verbose -Message "[$(Get-Date)] END iteration $iteration" -Verbose
}
