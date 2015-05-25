param
(
    [Parameter(Mandatory=$true)]
    [String] $DomainFQDN, 
    
    [Parameter(Mandatory=$true)]
    [String] $ClusterName,

    [Parameter(Mandatory=$true)]
    [String] $AdminUserName,

    [Parameter(Mandatory=$true)]
    [String] $AdminPassword,

    [Parameter(Mandatory=$false)]
    [String] $PostConfigScript="",

    [Parameter(Mandatory=$false)]
    [switch] $FromCustomImage
)

function TraceInfo($log)
{
    if ($script:LogFile -ne $null)
    {
        "$(Get-Date -format 'MM/dd/yyyy HH:mm:ss') $log" | Out-File -Confirm:$false -FilePath $script:LogFile -Append
    }    
}

function InstallComputeNode
{
    param($clustername, $nodetype)

    if(Test-Path -Path "C:\HPCPatches")
    {
        Remove-Item -Path "C:\HPCPatches" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    New-Item -ItemType directory -Path "C:\HPCPatches" -Force | Out-Null
    
    # 0 for Standalone Workstation, 1 for Member Workstation, 2 for Standalone Server, 3 for Member Server, 4 for Backup Domain Controller, 5 for Primary Domain Controller
    $domainRole = (Get-WmiObject Win32_ComputerSystem).DomainRole
    if($domainRole -lt 3)
    {
        throw "$nodetype $env:COMPUTERNAME is not domain joined"
    }
    
    # Test the connection to head node
    TraceInfo "Testing the connection to $ClusterName ..."
    $maxRetries = 50
    $retry = 0
    while($true)
    {
        # Flush the DNS cache in case the cached head node ip is wrong.
        # Do not use Clear-DnsClientCache because it is not supported in Windows Server 2008 R2
        Start-Process -FilePath ipconfig -ArgumentList "/flushdns" -Wait -NoNewWindow | Out-Null
        if(Test-Connection -ComputerName $ClusterName -Quiet)
        {
            TraceInfo "Head node $ClusterName is now reachable."
            break
        }
        else
        {
            if($retry -lt 20)
            {
                Start-Sleep -Seconds 20
                $retry++
            }
            else
            {
                throw "Head node $ClusterName is unreachable"
            }
        }
    }

    # Because ScheduledTasks PowerShell module not available in Windows Server 2008 R2,
    # We use ComObject Schedule.Service to schedule task
    try
    {
        $schdService = new-object -ComObject "Schedule.Service"
        $schdService.Connect("localhost") | Out-Null
        $rootFolder = $schdService.GetFolder("\")
        $taskDefinition = $schdService.NewTask(0)
        $testPathAction = $taskDefinition.Actions.Create(0)
        $testPathAction.Path = "PowerShell.exe"
        $testPathPshCmd = '$retry=0; while($true){if(Test-Path \\{ClusterName}\REMINST\setup.exe){Copy-Item \\{ClusterName}\REMINST\Patches\KB*.exe C:\HPCPatches -ErrorAction SilentlyContinue; return} elseif($retry -lt 30){$retry++; start-sleep -seconds 20} else{throw ''not available''}}'
        $testPathPshCmd = $testPathPshCmd.Replace("{ClusterName}", $ClusterName)
        $testPathAction.Arguments = "-Command `"$testPathPshCmd`""
        $Action = $taskDefinition.Actions.Create(0)
        $Action.Path = "\\$clustername\REMINST\setup.exe"
        $Action.Arguments = "-unattend -{0}:{1}" -f $nodetype.ToLower(), $clustername
        $hpcSetupTask = $Rootfolder.RegisterTaskDefinition("hpcsetup", $taskDefinition, 2, "system", $null, 5)
        TraceInfo  "HPC $nodetype installation task scheduled"
    }
    catch
    {
        throw "Failed to schedule HPC $nodetype installation task" 
    }
    

    try
    {
        $hpcSetupTask.Run($null) | Out-Null
        TraceInfo  "HPC $nodetype installation task started"
        TraceInfo "Waiting for HPC $nodetype installation ..."
        Start-Sleep -Seconds 1
        $retry = 0
        while($true)
        {
            $taskState = $hpcSetupTask.State
            # 2:Queued, 3:Ready, 4:Running
            if($taskState -eq 3)
            {
                #If the task never run, the lastRunTime is December 30, 1899 12:00:00 AM
                if($hpcSetupTask.LastRunTime -lt "1900-01-01")
                {
                    $hpcSetupTask.Run($null) | Out-Null
                }
                else
                {
                    if($hpcSetupTask.LastTaskResult -eq 0)
                    {
                        TraceInfo  "HPC $nodetype installation completed"
                        break
                    }
                    else
                    {
                        # The setup task failed last time, re-run it
                        if($retry -lt 3)
                        {
                            $hpcSetupTask.Run($null) | Out-Null
                            $retry++
                        }
                        else
                        {
                            throw ("HPC $nodetype installation Failed: " + $hpcSetupTask.LastTaskResult)
                        }
                    }
                }
            }
            elseif($taskState -eq 4)
            {
                # if the setup hangs, kill the process to make the task fail, and wait for retry
                $p = Get-Process -Name "HpcSetupChainer" -ErrorAction SilentlyContinue
                if($null -ne $p)
                {
                    $elapsedMins = ((Get-Date) - $p.StartTime).TotalMinutes
                    if($elapsedMins -gt 20)
                    {
                        TraceInfo "HPC $nodetype installation hung, kill the HPC setup process."
                        $p.Kill()  | Out-Null
                    }
                }
            }
            elseif($taskState -ne 2)
            {
                throw "The HPC $nodetype installation task entered into unexpected state: $taskState"
            }

            Start-Sleep -Seconds 2
        }
    }
    catch
    {
        TraceInfo "HPC $nodetype installation Failed"
        throw
    }
    finally
    {
        $Rootfolder.DeleteTask("hpcsetup",0)  | Out-Null
    }

    # Apply the patches if any
    $patchfiles = @(Get-ChildItem "C:\HPCPatches" -Filter "KB*.exe" | select -ExpandProperty FullName)
    if($patchfiles.Count -gt 0)
    {
        $patchTable = @{}
        foreach($pfile in $patchfiles)
        {
            $versionStr = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($pfile).ProductVersion
            $version = New-Object System.Version $versionStr
            $patchTable[$version] = $pfile
        }

        $versions = @($patchTable.Keys | Sort-Object)
        foreach($ver in $versions)
        {
            $pfile = $patchTable[$ver]
            TraceInfo "Applying QFE hotfix $pfile"
            $p = Start-Process -FilePath $pfile -ArgumentList "/unattend" -PassThru -Wait
            if(($p.ExitCode -ne 0) -and ($p.ExitCode -ne 3010))
            {
                throw "Failed to apply QFE hotfix $pfile : $($p.ExitCode)"
            }

            Start-Sleep -Seconds 10
        }
    }
}

Set-StrictMode -Version 3
Import-Module ScheduledTasks

$datetimestr = (Get-Date).ToString("yyyyMMddHHmmssfff")        
$script:LogFile = "$env:windir\Temp\HpcPrepareCNLog-$datetimestr.txt"

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
            $task = Get-ScheduledTask -TaskName "HpcPrepareComputeNode" -ErrorAction SilentlyContinue
            if($null -eq $task)
            {
                $CNPreparePsFile = "$PSScriptRoot\PrepareCN.ps1"
                $taskArgs = "-DomainFQDN $DomainFQDN -ClusterName $ClusterName -AdminUserName $AdminUserName -AdminPassword $AdminPassword"
                if($FromCustomImage.IsPresent)
                {
                    $taskArgs += ' -FromCustomImage'
                }

                if($false -eq [String]::IsNullOrWhiteSpace($PostConfigScript))
                {
                    $taskArgs += " -PostConfigScript '$PostConfigScript'"
                }

                $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Unrestricted -Command `"& '$CNPreparePsFile' $taskArgs`""
                $trigger = New-ScheduledTaskTrigger -AtStartup
                TraceInfo "Register task HpcPrepareComputeNode"
                Register-ScheduledTask -TaskName "HpcPrepareComputeNode" -Action $action -User 'NT AUTHORITY\SYSTEM' -Trigger $trigger -RunLevel Highest | Out-Null    
            }
            else
            {
                TraceInfo "Task HpcPrepareComputeNode is already existed"
            }

            TraceInfo "Restart after 30 seconds"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c shutdown /r /t 30"             
            break
        }
        catch
        {
            TraceInfo "Join domain failed, will try after 5 seconds, $_"
            Start-Sleep -Seconds 5
        }
    }
}
else
{   
    $datetimestr = (Get-Date).ToString("yyyyMMddHHmmssfff")        
    $script:LogFile = "$env:windir\Temp\HpcPrepareCNLog-$datetimestr.txt"
    if($FromCustomImage.IsPresent)
    {
        TraceInfo "Start to set cluster name to $ClusterName"
        Set-HpcClusterName.ps1 -ClusterName $ClusterName
        TraceInfo "Finish to set cluster name"
    }
    else
    {
        TraceInfo "Start to install compute node"
        InstallComputeNode $ClusterName "ComputeNode"
        TraceInfo "Finish to install compute node"
    }

    if($false -eq [String]::IsNullOrWhiteSpace($PostConfigScript))
    {
        $webclient = New-Object System.Net.WebClient
        $ss = $PostConfigScript -split ' '
        $fileWithPath = $ss[0]
        $args = ""
        if($ss.Count -gt 1)
        {
            $args = $ss[1..$($ss.Count-1)] -join ' '
        }

        $fileName = $($fileWithPath -split '/')[-1]
        $file = "$env:windir\Temp\$fileName"
        TraceInfo "download post config script from $fileWithPath"
        $webclient.DownloadFile($fileWithPath,$file)
        $command = "$file $args"
        TraceInfo "execute post config script $command"
        Invoke-Expression -Command $command
        TraceInfo "finish to post config script"
    }
    else
    {
        TraceInfo "PostConfigScript is empty, ignore it!"
    }

    Unregister-ScheduledTask -TaskName "HpcPrepareComputeNode" -Confirm:$false
}