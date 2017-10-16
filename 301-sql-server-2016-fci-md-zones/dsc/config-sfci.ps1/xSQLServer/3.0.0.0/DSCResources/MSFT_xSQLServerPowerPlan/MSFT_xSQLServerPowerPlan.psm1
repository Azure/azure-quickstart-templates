$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )
        try
        {
            $CurrPerf = $(powercfg -getactivescheme)
            $CurrStart = $CurrPerf.IndexOf("(")+1
            $CurrEnd = $CurrPerf.Length-$CurrStart-1
            $CurrPerfName =$CurrPerf.Substring($CurrStart,$CurrEnd)
        }
        catch
        {
            Write-Warning -Message "Unable to get power plan"
        }

        if ($Ensure -and ($CurrPerfName -eq "High performance"))
        {
            $returnValue =@{
                Ensure = $true
            }
        }
        else
        {
            $returnValue =@{
                Ensure = $false
            }
        }
    $returnValue
}



function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    Switch($Ensure)
    {
        "Present"
        {$PlanName = "High performance"}
        "Absent"
        {$PlanName = "Balanced"}    
    }

    Try 
    {
        $ReqPerf = powercfg -l | %{if($_.contains($PlanName)) {$_.split()[3]}}
        $CurrPlan = $(powercfg -getactivescheme).split()[3]
        if ($CurrPlan -ne $ReqPerf) {powercfg -setactive $ReqPerf}
        New-VerboseMessage -Message "Powerplan has been set to $PlanName" 
    }
    
    Catch 
    {
        Write-Warning -Message "Unable to set power plan"
    }


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )
    Switch($Ensure)
    {
        "Present"
        {$PlanName = "High performance"}
        "Absent"
        {$PlanName = "Balanced"}    
    }
    try
    {
        $ElementGuid = $(powercfg -getactivescheme).split()[3]
        $ReqPerfGuid = powercfg -l | %{if($_.contains($PlanName)) {$_.split()[3]}}
        $ReqPerf = powercfg -l | Where-Object {$_.contains($PlanName)}
        $ElementStart = $ReqPerf.IndexOf("(")+1
        $ElementEnd = $Reqperf.Length -$ElementStart -3
    
        $CurrPerf = $(powercfg -getactivescheme)
        $CurrStart = $CurrPerf.IndexOf("(")+1
        $CurrEnd = $CurrPerf.Length-$CurrStart-1
        $CurrPerfName =$CurrPerf.Substring($CurrStart,$CurrEnd)
    }
    catch
    {
        Write-Warning -Message "Unable to test power plan"
    }
    If($ElementGuid -eq $ReqPerfGuid)
    {
        New-VerboseMessage -Message "PowerPlan is set to $PlanName Already"
        return $true
    }
    else
    {
        New-VerboseMessage -Message "PowerPlan is $CurrPerfName Expect $PlanName"
        return $false
    }
}


Export-ModuleMember -Function *-TargetResource

