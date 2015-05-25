param
(
    [Parameter(Mandatory=$true, ParameterSetName='Prepare')]
    [String] $DomainFQDN, 
        
    [Parameter(Mandatory=$true, ParameterSetName='Prepare')]
    [String] $AdminUserName,

    [Parameter(Mandatory=$true, ParameterSetName='Prepare')]
    [String] $AdminPassword,

    [Parameter(Mandatory=$false, ParameterSetName='Prepare')]
    [String] $SubscriptionId,

    [Parameter(Mandatory=$false, ParameterSetName='Prepare')]
    [String] $VNet,

    [Parameter(Mandatory=$false, ParameterSetName='Prepare')]
    [String] $Subnet,

    [Parameter(Mandatory=$false, ParameterSetName='Prepare')]
    [String] $Location,

    [Parameter(Mandatory=$false, ParameterSetName='Prepare')]
    [String] $PostConfigScript="",

    [Parameter(Mandatory=$true, ParameterSetName='Prepare')]
    [switch] $NodePrepare,

    [Parameter(Mandatory=$true, ParameterSetName='NodeState')]
    [switch] $NodeStateCheck
)

. "$PSScriptRoot\HpcPrepareUtil.ps1"

function PromoteDC
{
    param
    (
        [Parameter(Mandatory=$true)]
        [String] $DomainFQDN, 
        
        [Parameter(Mandatory=$true)]
        [String] $AdminUserName,

        [Parameter(Mandatory=$true)]
        [String] $AdminPassword
    )

    $localAdminCred = New-Object -TypeName System.Management.Automation.PSCredential `
            -ArgumentList @($AdminUserName, (ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))
    try
    {
        TraceInfo "$env:COMPUTERNAME is not domain controller, start to install domain $DomainFQDN"
        TraceInfo 'Disable NLA first'
        $NLA = Get-WmiObject -Class Win32_TSGeneralSetting -ComputerName $env:COMPUTERNAME -Namespace root\CIMV2\TerminalServices -Authentication PacketPrivacy
        $NLA.SetUserAuthenticationRequired(0)

        # 0 for Standalone Workstation, 1 for Member Workstation, 2 for Standalone Server, 3 for Member Server, 4 for Backup Domain Controller, 5 for Primary Domain Controller
        $domainRole = (Get-WmiObject Win32_ComputerSystem).DomainRole
        if($domainRole -eq 5)
        {
            TraceInfo "$env:COMPUTERNAME was already a domain controller"
            return
        }
        
        TraceInfo 'Installing windows features AD-Domain-Services and GPMC'
        Install-WindowsFeature -Name AD-Domain-Services,GPMC -IncludeManagementTools *>$null

        Import-Module ADDSDeployment

        $netbios = $DomainFQDN.Split('.')[0];

        TraceInfo "Installing AD Forest $DomainFQDN"
        Install-ADDSForest `
            -DatabasePath 'C:\Windows\NTDS' `
            -DomainMode 'Win2012' `
            -DomainName $DomainFQDN `
            -DomainNetBIOSName $netbios `
            -SafeModeAdministratorPassword $localAdminCred.Password `
            -ForestMode 'Win2012' `
            -InstallDNS:$true `
            -LogPath 'C:\Windows\NTDS' `
            -NoRebootOnCompletion `
            -SYSVOLPath 'C:\Windows\SYSVOL' `
            -Force `
            -WarningAction Continue
        
        if(-not $?)
        {
            if($Error[0].Exception -eq $null)
            {
                throw ("Failed to promoting VM $env:COMPUTERNAME to Domain Controller: " + $Error[0])
            }
            else
            {
                throw $Error[0].Exception
            }
        }

        $forwarders = (Get-DnsServerForwarder).IPAddress
        if($null -ne $forwarders)
        {
           TraceInfo "Removing DNS forwarders from the domain controller: $forwarders"
           Remove-DnsServerForwarder -IPAddress $forwarders -Force
        }        
    }
    catch
    {
        $exType = $_.Exception.GetType().ToString()
        TraceInfo "Unexpected $exType catched, throw again"
        throw
    }
}

function PrepareHeadNode
{
    param
    (
    [Parameter(Mandatory=$true)]
    [String] $DomainFQDN, 
        
    [Parameter(Mandatory=$true)]
    [String] $AdminUserName,

    [Parameter(Mandatory=$true)]
    [String] $AdminPassword,

    [Parameter(Mandatory=$false)]
    [String] $PostConfigScript=""
    )

    Import-Module ScheduledTasks

    $domainNetBios = $DomainFQDN.Split('.')[0].ToUpper()
    $domainUserCred = New-Object -TypeName System.Management.Automation.PSCredential `
            -ArgumentList @("$domainNetBios\$AdminUserName", (ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))

    # 0 for Standalone Workstation, 1 for Member Workstation, 2 for Standalone Server, 3 for Member Server, 4 for Backup Domain Controller, 5 for Primary Domain Controller
    $domainRole = (Get-WmiObject Win32_ComputerSystem).DomainRole
    TraceInfo "Domain role $domainRole"
    if($domainRole -ne 5)
    {
        # join the domain
        PromoteDC -DomainFQDN $DomainFQDN -AdminUserName $AdminUserName -AdminPassword $AdminPassword
        $task = Get-ScheduledTask -TaskName 'HpcPrepareHeadNode' -ErrorAction SilentlyContinue
        if($null -eq $task)
        {
            $HNPreparePsFile = "$PSScriptRoot\PrepareHN.ps1"
            $taskArgs = "-DomainFQDN $DomainFQDN -AdminUserName $AdminUserName -AdminPassword $AdminPassword -NodePrepare"
            if($false -eq [String]::IsNullOrWhiteSpace($PostConfigScript))
            {
                $taskArgs += " -PostConfigScript '$PostConfigScript'"
            }

            $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Unrestricted -Command `"& '$HNPreparePsFile' $taskArgs`""
            $trigger = New-ScheduledTaskTrigger -AtStartup
            TraceInfo 'Register task HpcPrepareHeadNode'
            Register-ScheduledTask -TaskName 'HpcPrepareHeadNode' -Action $action -User 'NT AUTHORITY\SYSTEM' -Trigger $trigger -RunLevel Highest *>$script:PrepareNodeLogFile    
        }
        else
        {
            TraceInfo 'Task HpcPrepareHeadNode is already existed'
        }

        # restart HN
        TraceInfo 'Restarting Domain controller node to apply changes......'
        Start-Process -FilePath 'cmd.exe' -ArgumentList '/c shutdown /r /t 30'
    }
    else
    {
        $job = Start-Job -ScriptBlock{
            param($scriptPath, $domainUserCred, $PostConfigScript)

            . "$scriptPath\HpcPrepareUtil.ps1"
            TraceInfo 'register HPC Head Node Preparation Task'
            # prepare headnode
            $dbArgs = '-DBServerInstance .\COMPUTECLUSTER'
            $HNPreparePsFile = "$scriptPath\HPCHNPrepare.ps1"
            $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Unrestricted -Command `"& '$HNPreparePsFile' $dbArgs`""
            Register-ScheduledTask -TaskName 'HPCPrepare' -Action $action -User $domainUserCred.UserName -Password $domainUserCred.GetNetworkCredential().Password -RunLevel Highest *>$script:PrepareNodeLogFile
            if(-not $?)
            {
                throw 'Failed to schedule HPC Head Node Preparation Task'
            }

            TraceInfo 'HPC Head Node Preparation Task scheduled'
            Start-ScheduledTask -TaskName 'HPCPrepare'
            TraceInfo 'Running HPC Head Node Preparation Task'
            Start-Sleep -Milliseconds 500
            $taskSucceeded = $false
            do
            {
                $taskState = (Get-ScheduledTask -TaskName 'HPCPrepare').State
                if($taskState -eq 'Ready')
                {
                    $taskInfo = Get-ScheduledTaskInfo -TaskName 'HPCPrepare'
                    if($taskInfo.LastRunTime -eq $null)
                    {
                        Start-ScheduledTask -TaskName 'HPCPrepare'
                    }
                    else
                    {
                        if($taskInfo.LastTaskResult -eq 0)
                        {
                            $taskSucceeded = $true
                            break
                        }
                        else
                        {
                            TraceInfo ('The scheduled task for HPC Head Node Preparation failed:' + $taskInfo.LastTaskResult)
                            break
                        }
                    }
                }
                elseif($taskState -ne 'Queued' -and $taskState -ne 'Running')
                {
                    TraceInfo "The scheduled task for HPC Head Node Preparation entered into unexpected state: $taskState"
                    break
                }

                Start-Sleep -Seconds 2        
            } while ($true)

            if($taskSucceeded)
            {
                TraceInfo 'Checking the Head Node Services status ...'
                #$HNServiceList = @("HpcSdm", "HpcManagement", "HpcReporting", "HpcMonitoringClient", "HpcNodeManager", "msmpi", "HpcBroker", `
                #            "HpcDiagnostics", "HpcScheduler", "HpcMonitoringServer", "HpcSession", "HpcSoaDiagMon")
                $HNServiceList = @('HpcSdm', 'HpcManagement', 'HpcNodeManager', 'msmpi', 'HpcBroker', 'HpcScheduler', 'HpcSession')
                foreach($svcname in $HNServiceList)
                {
                    $service = Get-Service -Name $svcname -ErrorAction SilentlyContinue
                    if($service -eq $null)
                    {
                        TraceInfo "Service $svcname not found"
                        $taskSucceeded = $false
                    }
                    elseif($service.Status -eq 'Running')
                    {
                        TraceInfo "Service $svcname is running"
                    }
                    else
                    {
                        TraceInfo "Service $svcname is in $($service.Status) status"
                        $taskSucceeded = $false
                    }
                }
            }

            Unregister-ScheduledTask -TaskName 'HPCPrepare' -Confirm:$false    

            if($taskSucceeded)
            {
                TraceInfo 'Succeeded to prepare HPC Head Node'
                # HPC to do list
                Add-PSSnapin Microsoft.HPC
                # setting network topology to 5 (enterprise)
                TraceInfo 'Setting HPC cluster network topologogy...'
                while($true)
                {
                    $nics = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | `
                            Where-Object {($_.NetworkInterfaceType -eq 'Ethernet') -and ($_.GetIPProperties().UnicastAddresses.PrefixOrigin -contains 'Dhcp')}
    
                    $nics = @($nics)
                    if (@($nics).Count -ne 1)
                    {
                        throw 'Cannot find a suitable network adapter for enterprise topology'
                    }

                    Set-HpcNetwork -Topology 'Enterprise' -Enterprise $nics.Description -EnterpriseFirewall $true -ErrorAction SilentlyContinue 
                    $topo = Get-HpcNetworkTopology -ErrorAction SilentlyContinue
                    if ([String]::IsNullOrWhiteSpace($topo))
                    {
                        TraceInfo 'Setting network topologogy failed, will retry after 5 seconds'
                        Start-Sleep -Seconds 5
                    }
                    else
                    {
                        TraceInfo "Network topology is set to $topo"
                        break;
                    }
                }

                # Set installation credentials
                Set-HpcClusterProperty -InstallCredential $domainUserCred
                $hpccred = Get-HpcClusterProperty -InstallCredential
                TraceInfo ('Installation Credentials set to ' + $hpccred.Value)

	            # set node naming series
                $nodenaming = 'AzureVMCN-%0000%'
                ExecuteCommandWithRetry -Command "Set-HpcClusterProperty -NodeNamingSeries $nodenaming"
                TraceInfo "Node naming series set to $nodenaming"
        
                # Create a default compute node template
                New-HpcNodeTemplate -Name 'Default ComputeNode Template' -Description 'This is the default compute node template' -ErrorAction SilentlyContinue
                TraceInfo "'Default ComputeNode Template' created"

                # register scheduler task to bring node online
                $task = Get-ScheduledTask -TaskName 'HpcNodeOnlineCheck' -ErrorAction SilentlyContinue
                if($null -eq $task)
                {
                    TraceInfo 'Start to register HpcNodeOnlineCheck Task'
                    $HpcNodeOnlineCheckFile = "$scriptPath\PrepareHN.ps1"
                    $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Unrestricted -Command `"& '$HpcNodeOnlineCheckFile' -NodeStateCheck`""
                    $now = get-date
                    $trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 1) -At $now -RepetitionDuration (New-TimeSpan -Days 3650) -Once
                    Register-ScheduledTask -TaskName 'HpcNodeOnlineCheck' -Action $action -Trigger $trigger -User $domainUserCred.UserName -Password $domainUserCred.GetNetworkCredential().Password -RunLevel Highest | Out-Null
                    TraceInfo 'Finish to register task HpcNodeOnlineCheck'
                    if(-not $?)
                    {
                        TraceInfo 'Failed to schedule HpcNodeOnlineCheck Task'
                    }
                }
                else
                {
                    TraceInfo 'Task HpcNodeOnlineCheck is already existed'
                }
        
                TraceInfo 'Generating a self-signed certificate for the HPC web service ...'
                $hpcBinPath = [System.IO.Path]::Combine($env:CCP_HOME, 'Bin')
                $thumbprint = . $hpcBinPath\New-HpcCert.ps1 -MachineName $dnsHostName -SelfSigned
                TraceInfo "A self-signed certificate $thumbprint was created and installed"

                TraceInfo 'Enabling HPC Pack web portal ...'
                . $hpcBinPath\Set-HPCWebComponents.ps1 -Service Portal -enable -Certificate $thumbprint | Out-Null
                TraceInfo 'HPC Pack web portal enabled.'

                TraceInfo 'Starting HPC web service ...'
                Set-Service -Name 'HpcWebService' -StartupType Automatic | Out-Null
                Start-Service -Name 'HpcWebService' | Out-Null
                TraceInfo 'HPC web service started.'

                TraceInfo 'Enabling HPC Pack REST API ...'
                . $hpcBinPath\Set-HPCWebComponents.ps1 -Service REST -enable -Certificate $thumbprint | Out-Null
                TraceInfo 'HPC Pack REST API enabled.'

                TraceInfo 'Restarting HPCScheduler service ...'
                Restart-Service -Name 'HpcScheduler' -Force | Out-Null
                TraceInfo 'HPCScheduler service restarted.'

                $cert = Get-ChildItem -Path Cert:\LocalMachine\My\$thumbprint
                $cerFile = "$env:TEMP\hpcwebcomponent_{0}.cer" -f (Get-Random)
                Export-Certificate -Cert $cert -FilePath $cerFile | Out-Null
                $cerContent = [IO.File]::ReadAllBytes($cerFile)
                TraceInfo "The certificate file with public key was exported: $thumbprint"
                Remove-Item $cerFile -Force -ErrorAction SilentlyContinue
                
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
            }
            else
            {
                TraceInfo 'Failed to prepare HPC Head Node'
                if(Test-Path -Path "$env:windir\Temp\HPCHeadNodePrepare.log" -PathType Leaf)
                {
                    TraceInfo 'The Head Node Preparation Logs as below:'
                    Get-Content -Path "$env:windir\Temp\HPCHeadNodePrepare.log" | Write-Verbose -Verbose
                }

                throw 'Failed to prepare HPC Head Node'
            }
        } -ArgumentList $PSScriptRoot,$domainUserCred,$PostConfigScript

        Wait-Job $job
        TraceInfo 'job completed'
        Receive-Job $job -Verbose
        TraceInfo 'receive completed'
        Unregister-ScheduledTask -TaskName 'HpcPrepareHeadNode' -Confirm:$false
    }
}

function NodeStateCheck
{
    Add-PSSnapin Microsoft.HPC

    $datetimestr = (Get-Date).ToString('yyyyMMdd')
    $script:PrepareNodeLogFile = "$env:windir\Temp\HpcNodeCheckLog-$datetimestr.txt"

    $unapprovedNodes = @()
    $unapprovedNodes += Get-HpcNode -State Unknown -ErrorAction SilentlyContinue
    if($unapprovedNodes.Count -gt 0)
    {
        TraceInfo 'Start to assign template to unknown nodes'
        PrintNodes $unapprovedNodes
        Assign-HpcNodeTemplate -Name "Default ComputeNode Template" -Node $unapprovedNodes -Confirm:$false        
    }

    $offlineNodes = @()
    $offlineNodes += Get-HpcNode -State Offline -ErrorAction SilentlyContinue
    if($offlineNodes.Count -gt 0)
    {
        TraceInfo 'Start to bring nodes online'
        $result = @()
        $result += Set-HpcNodeState -State online -Node $offlineNodes
        PrintNodes $result
    }
}

Set-StrictMode -Version 3
if ($PsCmdlet.ParameterSetName -eq 'Prepare')
{
    if([string]::IsNullOrEmpty($SubscriptionId) -eq $false)
    {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\HPC -Name IaaSInfo -Force | Out-Null
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HPC\IaaSInfo -Name SubscriptionId -Value $SubscriptionId
        $deployId = "00000000" + [System.Guid]::NewGuid().ToString().Substring(8)
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HPC\IaaSInfo -Name DeploymentId -Value $deployId
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HPC\IaaSInfo -Name VNet -Value $VNet
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HPC\IaaSInfo -Name Subnet -Value $Subnet
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HPC\IaaSInfo -Name AffinityGroup -Value ""
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\HPC\IaaSInfo -Name Location -Value $Location
        TraceInfo "The information needed for in-box management scripts succcessfully configured."
    }

    PrepareHeadNode -DomainFQDN $DomainFQDN -AdminUserName $AdminUserName -AdminPassword $AdminPassword -PostConfigScript $PostConfigScript
}
else
{
    NodeStateCheck
}