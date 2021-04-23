#
# xSQLServerInstall: DSC resource to install Sql Server Enterprise version.
#


#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
    param
    (   
        [parameter(Mandatory)] 
        [string] $InstanceName = "MSSQLSERVER",
        
        [parameter(Mandatory)] 
        [ValidateNotNullOrEmpty()]
        [string] $SourcePath,

        [PSCredential] $SourcePathCredential,

        [string] $Features="SQLEngine,SSMS",

        [PSCredential] $SqlAdministratorCredential,
        
        [bool] $UpdateEnabled = $false,
        [string] $SvcAccount = $NULL,
        [string] $SysAdminAccounts = $NULL,
        [string] $AgentSvcAccount = $NULL
    )

    $list = Get-Service -Name MSSQL*
    $retInstanceName = $null

    if ($InstanceName -eq "MSSQLSERVER")
    {
        if ($list.Name -contains "MSSQLSERVER")
        {
            $retInstanceName = $InstanceName
        }
    }
    elseif ($list.Name -contains $("MSSQL$" + $InstanceName))
    {
        Write-Verbose -Message "SQL Instance $InstanceName is present"
        $retInstanceName = $InstanceName
    }


    $returnValue = @{
        InstanceName = $retInstanceName
    }

    return $returnValue
}


#
# The Set-TargetResource cmdlet.
#
function Set-TargetResource
{
    param
    (   
        [parameter(Mandatory)] 
        [string] $InstanceName = "MSSQLSERVER",
        
        [parameter(Mandatory)] 
        [ValidateNotNullOrEmpty()]
        [string] $SourcePath,

        [PSCredential] $SourcePathCredential,

        [string] $Features="SQLEngine,SSMS",

        [PSCredential] $SqlAdministratorCredential,
        
        [bool] $UpdateEnabled = $false,
        [string] $SvcAccount = $NULL,
        [string] $SysAdminAccounts = $NULL,
        [string] $AgentSvcAccount = $NULL
    )
    $LogPath = Join-Path $env:SystemDrive -ChildPath "Logs"

    if (!(Test-Path $LogPath))
    {
        New-Item $LogPath -ItemType Directory
    }
    # SQL log from setup cmdline run output
    $logFile = Join-Path $LogPath -ChildPath "sqlInstall-log.txt"
    
    # SQL installer path       
    $cmd = Join-Path $SourcePath -ChildPath "Setup.exe"

    # TCPENABLED- Specifies the state of the TCP protocol for the SQL Server service. 
    # NPENABLED- Specifies the state of the Named Pipes protocol for the SQL Server service
    # tcp/ip and named pipes protocol needs to be enabled for web apps to access db instances. So these are being enabled as a part of default sql server installation
    $cmd += " /Q /ACTION=Install /IACCEPTSQLSERVERLICENSETERMS /IndicateProgress "
    $cmd += " /FEATURES=$Features /INSTANCENAME=$InstanceName "
    
    if ($SqlAdministratorCredential)
    {
        $saPwd = $SqlAdministratorCredential.GetNetworkCredential().Password
        $cmd += " /TCPENABLED=1 /NPENABLED=1 /SECURITYMODE=SQL /SAPWD=$saPwd "
    }
    else
    {
        $cmd += " /TCPENABLED=1 /NPENABLED=1 "
    }
    
    if ($UpdateEnabled)
    {
        $cmd += " /updateEnabled=true "
    }
    else 
    {
        $cmd += " /updateEnabled=false "
    }
    
    if ($SysAdminAccounts)
    {
        $cmd += " /SQLSYSADMINACCOUNTS=$SysAdminAccounts "
    }
    else
    {
        $cmd += " /SQLSYSADMINACCOUNTS='builtin\administrators' "
    }
    
    if ($SvcAccount)
    {
        $cmd += " /SQLSVCACCOUNT=$SvcAccount "
    }
    
    if ($AgentSvcAccount)
    {    
        $cmd += " /AGTSVCACCOUNT=$AgentSvcAccount "
    }
    
    $cmd += " > $logFile 2>&1 "

    NetUse -SharePath $SourcePath -SharePathCredential $SourcePathCredential -Ensure "Present"
    try
    {
        Invoke-Expression $cmd
    }
    finally
    {
        NetUse -SharePath $SourcePath -SharePathCredential $SourcePathCredential -Ensure "Absent"
    }
    # Check the SQL logs for installation status.
    $installStatus = $false
    try
    {        
        # SQL Server log folder
        $LogPath = Join-Path $env:ProgramFiles "Microsoft SQL Server\110\Setup Bootstrap\Log"        
        $sqlLog = Get-Content "$LogPath\summary.txt"
        if($sqlLog -ne $null)
        {
            $message = $sqlLog | fl
            if($message -ne $null)
            {
                # sample report when the install is succesful
                #    Overall summary:
                #    Final result:                  Passed
                #    Exit code (Decimal):           0
                $finalResult = $message[1] | Out-String     
                $exitCode = $message[2] | Out-String    

                if(($finalResult.Contains("Passed") -eq $True) -and ($exitCode.Contains("0") -eq $True))
                {                     
                    $installStatus = $true
                }                
             }
        }
    }
    catch
    {
        Write-Verbose "SQL Installation did not succeed."
    }
    if($installStatus -eq $true)
    {
        # Tell the DSC Engine to restart the machine
        $global:DSCMachineStatus = 1
    }
    else    
    {        
        # Throw an error message indicating failure to install SQL Server install 
        $errorId = "InValidSQLServerInstall";
        $exceptionStr = "SQL Server installation did not succeed. For more details please refer to the logs under $LogPath folder."
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidResult;
        $exception = New-Object System.InvalidOperationException $exceptionStr; 
        $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord);
     }
}
#
# The Test-TargetResource cmdlet.
#
function Test-TargetResource
{
    param
    (   
        [parameter(Mandatory)] 
        [string] $InstanceName = "MSSQLSERVER",
        
        [parameter(Mandatory)] 
        [ValidateNotNullOrEmpty()]
        [string] $SourcePath,

        [PSCredential] $SourcePathCredential,

        [string] $Features="SQLEngine,SSMS",

        [PSCredential] $SqlAdministratorCredential,

        [bool] $UpdateEnabled = $false,
        [string] $SvcAccount = $NULL,
        [string] $SysAdminAccounts = $NULL,
        [string] $AgentSvcAccount = $NULL
    )

    $info = Get-TargetResource -InstanceName $InstanceName -SourcePath $SourcePath -SqlAdministratorCredential $SqlAdministratorCredential
    
    return ($info.InstanceName -eq $InstanceName)
}



function NetUse
{
    param
    (   
        [parameter(Mandatory)] 
        [string] $SharePath,
        
        [PSCredential]$SharePathCredential,
        
        [string] $Ensure = "Present"
    )

    if ($null -eq $SharePathCredential)
    {
        return;
    }

    Write-Verbose -Message "NetUse set share $SharePath ..."

    if ($Ensure -eq "Absent")
    {
        $cmd = "net use $SharePath /DELETE"
    }
    else 
    {
        $cred = $SharePathCredential.GetNetworkCredential()
        $pwd = $cred.Password 
        $user = $cred.Domain + "\" + $cred.UserName
        $cmd = "net use $SharePath $pwd /user:$user"
    }

    Invoke-Expression $cmd
}

Export-ModuleMember -Function *-TargetResource
