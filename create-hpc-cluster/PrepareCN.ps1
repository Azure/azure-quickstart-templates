param
(
    [Parameter(Mandatory=$true)]
    [String] $DomainFQDN, 
    
    [Parameter(Mandatory=$true)]
    [String] $ClusterName,

    [Parameter(Mandatory=$true)]
    [String] $AdminUserName,

    [Parameter(Mandatory=$true)]
    [String] $AdminBase64Password
)

function TraceInfo($log)
{
    if ($script:LogFile -ne $null)
    {
        "$(Get-Date -format 'MM/dd/yyyy HH:mm:ss') $log" | Out-File -Confirm:$false -FilePath $script:LogFile -Append
    }    
}

Set-StrictMode -Version 3
$datetimestr = (Get-Date).ToString("yyyyMMddHHmmssfff")        
$script:LogFile = "$env:windir\Temp\HpcPrepareCNLog-$datetimestr.txt"

$AdminPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($AdminBase64Password))
$domainNetBios = $DomainFQDN.Split(".")[0].ToUpper()
$domainUserCred = New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList @("$domainNetBios\$AdminUserName", (ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))

# 0 for Standalone Workstation, 1 for Member Workstation, 2 for Standalone Server, 3 for Member Server, 4 for Backup Domain Controller, 5 for Primary Domain Controller
$domainRole = (Get-WmiObject Win32_ComputerSystem).DomainRole
TraceInfo "Domain role $domainRole"
if($domainRole -ne 3)
{
    TraceInfo "$env:COMPUTERNAME does not join the domain, start to join domain $DomainFQDN"
    # join the domain
    while($true)
    {
        try
        {
            Add-Computer -DomainName $DomainFQDN -Credential $domainUserCred -ErrorAction Stop
            TraceInfo "Joined to the domain $DomainFQDN."
            break
        }
        catch
        {
            TraceInfo "Join domain failed, will try after 10 seconds, $_"
            Start-Sleep -Seconds 10
        }
    }
}

TraceInfo "Start to set cluster name to $ClusterName"
Set-HpcClusterName.ps1 -ClusterName $ClusterName
TraceInfo "Finish to set cluster name"

TraceInfo "Restart after 30 seconds"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c shutdown /r /t 30"