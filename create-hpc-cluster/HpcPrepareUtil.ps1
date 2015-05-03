function TraceInfo($log)
{
    if((Test-Path variable:PrepareNodeLogFile) -eq $false)
    {
        $datetimestr = (Get-Date).ToString('yyyyMMddHHmmssfff')
        $script:PrepareNodeLogFile = "$env:windir\Temp\HpcNodePrepareOrCheckLog-$datetimestr.txt"
    }

    "$(Get-Date -format 'MM/dd/yyyy HH:mm:ss') $log" | Out-File -Confirm:$false -FilePath $script:PrepareNodeLogFile -Append
}

function PrintNodes
{
    Param(
    $nodes = @()
    )
    $formatString = '{0,16}{1,12}{2,15}{3,10}';
    TraceInfo ($formatString -f 'NetBiosName','NodeState','NodeHealth','Groups')
    TraceInfo ($formatString -f '-----------','---------','----------','------')
    foreach ($node in $nodes)
    {
        TraceInfo ($formatString -f $node.NetBiosName,$node.NodeState,$node.NodeHealth,$node.Groups)
    }
}

function ExecuteCommandWithRetry
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [String] $Command,

        [Parameter(Mandatory=$false)]
        [Int] $RetryTimes = 20
    )

    $retry = 0
    while($true)
    {
        try
        {
            $ret = Invoke-Expression -Command $Command -ErrorAction Stop
            return $ret
        }        
        catch
        {
            $errMsg = $_
            TraceInfo ("Failed to execute command '$Command': " + ($_ | Out-String))
        }

        if($retry -lt $RetryTimes)
        {
            TraceInfo $errMsg
            TraceInfo "Retry to execute command '$Command' after 3 seconds"
            Start-Sleep -Seconds 3
            $retry++
        }
        else
        {
            throw "Failed to execute command '$Command'"
        }
    }
}
