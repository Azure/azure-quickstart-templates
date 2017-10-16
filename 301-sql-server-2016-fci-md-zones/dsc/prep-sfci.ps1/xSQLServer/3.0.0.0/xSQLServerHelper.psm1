# Set Global Module Verbose
$VerbosePreference = 'Continue' 

# Load Localization Data 
Import-LocalizedData LocalizedData -filename xSQLServer.strings.psd1 -ErrorAction SilentlyContinue 
Import-LocalizedData USLocalizedData -filename xSQLServer.strings.psd1 -UICulture en-US -ErrorAction SilentlyContinue

function Connect-SQL
{
[CmdletBinding()]
    param
    (   [ValidateNotNull()] 
        [System.String]
        $SQLServer = $env:COMPUTERNAME,
        
        [ValidateNotNull()] 
        [System.String]
        $SQLInstanceName = "MSSQLSERVER",

        [ValidateNotNull()] 
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )
    
    $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
    
    if($SQLInstanceName -eq "MSSQLSERVER")
    {
        $ConnectSQL = $SQLServer
    }
    else
    {
        $ConnectSQL = "$SQLServer\$SQLInstanceName"
    }
    if ($SetupCredential)
    {
        $SQL = New-Object Microsoft.SqlServer.Management.Smo.Server
        $SQL.ConnectionContext.ConnectAsUser = $true
        $SQL.ConnectionContext.ConnectAsUserPassword = $SetupCredential.GetNetworkCredential().Password
        $SQL.ConnectionContext.ConnectAsUserName = $SetupCredential.GetNetworkCredential().UserName 
        $SQL.ConnectionContext.ServerInstance = $ConnectSQL
        $SQL.ConnectionContext.connect()
    }
    else
    {
        $SQL = New-Object Microsoft.SqlServer.Management.Smo.Server $ConnectSQL
    }
    if($SQL)
    {
        New-VerboseMessage -Message "Connected to SQL $ConnectSQL"
        $SQL
    }
    else
    {
        Throw -Message "Failed connecting to SQL $ConnectSQL"
        Exit
    }
}

function New-TerminatingError 
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ErrorType,

        [Parameter(Mandatory = $false)]
        [String[]]
        $FormatArgs,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory = [System.Management.Automation.ErrorCategory]::OperationStopped,

        [Parameter(Mandatory = $false)]
        [Object]
        $TargetObject = $null,

        [Parameter(Mandatory = $false)]
        [System.Exception]
        $InnerException = $null
    )

    $errorMessage = $LocalizedData.$ErrorType
    
    if(!$errorMessage)
    {
        $errorMessage = ($LocalizedData.NoKeyFound -f $ErrorType)

        if(!$errorMessage)
        {
            $errorMessage = ("No Localization key found for key: {0}" -f $ErrorType)
        }
    }

    $errorMessage = ($errorMessage -f $FormatArgs)
    
    if( $InnerException )
    {
        $errorMessage += " InnerException: $($InnerException.Message)"
    }
    
    $callStack = Get-PSCallStack 

    # Get Name of calling script
    if($callStack[1] -and $callStack[1].ScriptName)
    {
        $scriptPath = $callStack[1].ScriptName

        $callingScriptName = $scriptPath.Split('\')[-1].Split('.')[0]
    
        $errorId = "$callingScriptName.$ErrorType"
    }
    else
    {
        $errorId = $ErrorType
    }

    Write-Verbose -Message "$($USLocalizedData.$ErrorType -f $FormatArgs) | ErrorType: $errorId"

    $exception = New-Object System.Exception $errorMessage, $InnerException    
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $ErrorCategory, $TargetObject

    return $errorRecord
}

function New-VerboseMessage
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true)]
        $Message
    )
    Write-Verbose -Message ((Get-Date -format yyyy-MM-dd_HH-mm-ss) + ": $Message");

}

<#
.SYNOPSIS

This method is used to compare current and desired values for any DSC resource

.PARAMETER CurrentValues

This is hashtable of the current values that are applied to the resource

.PARAMETER DesiredValues 

This is a PSBoundParametersDictionary of the desired values for the resource

.PARAMETER ValuesToCheck

This is a list of which properties in the desired values list should be checked.
If this is empty then all values in DesiredValues are checked.

#>
function Test-SQLDscParameterState 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]  
        [HashTable]
        $CurrentValues,
        
        [Parameter(Mandatory = $true)]  
        [Object]
        $DesiredValues,

        [Parameter(Mandatory = $false)] 
        [Array]
        $ValuesToCheck
    )

    $returnValue = $true

    if (($DesiredValues.GetType().Name -ne "HashTable") `
        -and ($DesiredValues.GetType().Name -ne "CimInstance") `
        -and ($DesiredValues.GetType().Name -ne "PSBoundParametersDictionary")) 
    {
        throw ("Property 'DesiredValues' in Test-SQLDscParameterState must be either a " + `
               "Hashtable or CimInstance. Type detected was $($DesiredValues.GetType().Name)")
    }

    if (($DesiredValues.GetType().Name -eq "CimInstance") -and ($null -eq $ValuesToCheck)) 
    {
        throw ("If 'DesiredValues' is a CimInstance then property 'ValuesToCheck' must contain " + `
               "a value")
    }

    if (($null -eq $ValuesToCheck) -or ($ValuesToCheck.Count -lt 1)) 
    {
        $KeyList = $DesiredValues.Keys
    } 
    else 
    {
        $KeyList = $ValuesToCheck
    }

    $KeyList | ForEach-Object -Process {
        if (($_ -ne "Verbose")) 
        {
            if (($CurrentValues.ContainsKey($_) -eq $false) `
            -or ($CurrentValues.$_ -ne $DesiredValues.$_) `
            -or (($DesiredValues.ContainsKey($_) -eq $true) -and ($DesiredValues.$_.GetType().IsArray))) 
            {
                if ($DesiredValues.GetType().Name -eq "HashTable" -or `
                    $DesiredValues.GetType().Name -eq "PSBoundParametersDictionary") 
                {
                    
                    $CheckDesiredValue = $DesiredValues.ContainsKey($_)
                } 
                else 
                {
                    $CheckDesiredValue = Test-SPDSCObjectHasProperty $DesiredValues $_
                }

                if ($CheckDesiredValue) 
                {
                    $desiredType = $DesiredValues.$_.GetType()
                    $fieldName = $_
                    if ($desiredType.IsArray -eq $true) 
                    {
                        if (($CurrentValues.ContainsKey($fieldName) -eq $false) `
                        -or ($null -eq $CurrentValues.$fieldName)) 
                        {
                            Write-Verbose -Message ("Expected to find an array value for " + `
                                                    "property $fieldName in the current " + `
                                                    "values, but it was either not present or " + `
                                                    "was null. This has caused the test method " + `
                                                    "to return false.")
                            $returnValue = $false
                        } 
                        else 
                        {
                            $arrayCompare = Compare-Object -ReferenceObject $CurrentValues.$fieldName `
                                                           -DifferenceObject $DesiredValues.$fieldName
                            if ($null -ne $arrayCompare) 
                            {
                                Write-Verbose -Message ("Found an array for property $fieldName " + `
                                                        "in the current values, but this array " + `
                                                        "does not match the desired state. " + `
                                                        "Details of the changes are below.")
                                $arrayCompare | ForEach-Object -Process {
                                    Write-Verbose -Message "$($_.InputObject) - $($_.SideIndicator)"
                                }
                                $returnValue = $false
                            }
                        }
                    } 
                    else 
                    {
                        switch ($desiredType.Name) 
                        {
                            "String" {
                                if (-not [String]::IsNullOrEmpty($CurrentValues.$fieldName) -or `
                                    -not [String]::IsNullOrEmpty($DesiredValues.$fieldName))
                                {
                                    Write-Verbose -Message ("String value for property $fieldName does not match. " + `
                                                            "Current state is '$($CurrentValues.$fieldName)' " + `
                                                            "and Desired state is '$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int32" {
                                if (-not ($DesiredValues.$fieldName -eq 0) -or `
                                    -not ($null -eq $CurrentValues.$fieldName))
                                { 
                                    Write-Verbose -Message ("Int32 value for property " + "$fieldName does not match. " + `
                                                            "Current state is " + "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int16" {
                                if (-not ($DesiredValues.$fieldName -eq 0) -or `
                                    -not ($null -eq $CurrentValues.$fieldName))
                                { 
                                    Write-Verbose -Message ("Int32 value for property " + "$fieldName does not match. " + `
                                                            "Current state is " + "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            default {
                                Write-Verbose -Message ("Unable to compare property $fieldName " + `
                                                        "as the type ($($desiredType.Name)) is " + `
                                                        "not handled by the " + `
                                                        "Test-SQLDscParameterState cmdlet")
                                $returnValue = $false
                            }
                        }
                    }
                }            
            }
        } 
    }
    return $returnValue
}

function Grant-ServerPerms
{
[CmdletBinding()]
    param
    (
        [ValidateNotNull()]         
        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [ValidateNotNull()] 
        [System.String]
        $SQLInstanceName= "MSSQLSERVER",

        [ValidateNotNullOrEmpty()]  
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential,

        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory = $true)]
        [System.String]
        $AuthorizedUser
    )
    
    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -SetupCredential $SetupCredential
    }
    Try{
        $sps = New-Object Microsoft.SqlServer.Management.Smo.ServerPermissionSet([Microsoft.SqlServer.Management.Smo.ServerPermission]::AlterAnyAvailabilityGroup)
        $sps.Add([Microsoft.SqlServer.Management.Smo.ServerPermission]::ViewServerState)
        $SQL.Grant($sps,$AuthorizedUser)
        New-VerboseMessage -Message "Granted Permissions to $AuthorizedUser"
        }
    Catch{
        Write-Error "Failed to grant Permissions to $AuthorizedUser."
        }
}

function Grant-CNOPerms
{
[CmdletBinding()]
    Param
    (
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupNameListener,
        
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory = $true)]
        [System.String]
        $CNO
    )

    #Verify Active Directory Tools are installed, if they are load if not Throw Error
    If (!(Get-Module -ListAvailable | Where-Object {$_.Name -eq "ActiveDirectory"})){
        Throw "Active Directory Module is not installed and is Required."
        Exit
    }
    else{Import-Module ActiveDirectory -ErrorAction Stop -Verbose:$false}
    Try{
        $AG = Get-ADComputer $AvailabilityGroupNameListener
        
        $comp = $AG.DistinguishedName  # input AD computer distinguishedname
        $acl = Get-Acl "AD:\$comp" 
        $u = Get-ADComputer $CNO                        # get the AD user object given full control to computer
        $SID = [System.Security.Principal.SecurityIdentifier] $u.SID
        
        $identity = [System.Security.Principal.IdentityReference] $SID
        $adRights = [System.DirectoryServices.ActiveDirectoryRights] "GenericAll"
        $type = [System.Security.AccessControl.AccessControlType] "Allow"
        $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $identity,$adRights,$type,$inheritanceType
        
        $acl.AddAccessRule($ace) 
        Set-Acl -AclObject $acl "AD:\$comp"
        New-VerboseMessage -Message "Granted privileges on $comp to $CNO"
        }
    Catch{
        Throw "Failed to grant Permissions on $comp."
        Exit
        } 
}

function New-ListenerADObject
{
[CmdletBinding()]
    Param
    (
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupNameListener,
        
        [ValidateNotNull()] 
        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [ValidateNotNull()] 
        [System.String]
        $SQLInstanceName = "MSSQLSERVER",
    
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -SetupCredential $SetupCredential
    }

    $CNO= $SQL.ClusterName
        
    #Verify Active Directory Tools are installed, if they are load if not Throw Error
    If (!(Get-Module -ListAvailable | Where-Object {$_.Name -eq "ActiveDirectory"})){
        Throw "Active Directory Module is not installed and is Required."
        Exit
    }
    else{Import-Module ActiveDirectory -ErrorAction Stop -Verbose:$false}
    try{
        $CNO_OU = Get-ADComputer $CNO
        #Accounts for the comma and CN= at the start of Distinguished Name
        #We want to remove these plus the ClusterName to get the actual OU Path.
        $AdditionalChars = 4
        $Trim = $CNO.Length+$AdditionalChars
        $CNOlgth = $CNO_OU.DistinguishedName.Length - $trim
        $OUPath = $CNO_OU.ToString().Substring($Trim,$CNOlgth)
        }
    catch{
        Throw ": Failed to find Computer in AD"
        exit
    }
    
    
    $m = Get-ADComputer -Filter {Name -eq $AvailabilityGroupNameListener} -Server $env:USERDOMAIN | Select-Object -Property * | Measure-Object
    
    If ($m.Count -eq 0)
    {
        Try{
            #Create Computer Object for the AgListenerName
            New-ADComputer -Name $AvailabilityGroupNameListener -SamAccountName $AvailabilityGroupNameListener -Path $OUPath -Enabled $false -Credential $SetupCredential
            New-VerboseMessage -Message "Created Computer Object $AvailabilityGroupNameListener"
            }
        Catch{
               Throw "Failed to Create $AvailabilityGroupNameListener in $OUPath"
            Exit
            }
            
            $SucccessChk =0
    
        #Check for AD Object Validate at least three successful attempts 
        $i=1
        While ($i -le 5) {
            Try{
                $ListChk = Get-ADComputer -filter {Name -like $AvailabilityGroupNameListener}
                If ($ListChk){$SuccessChk++}
                Start-Sleep -Seconds 10  
                If($SuccesChk -eq 3){break}
               }
            Catch{
                 Throw "Failed Validate $AvailabilityGroupNameListener was created in $OUPath"
                 Exit
            }
            $i++
        }            
    }
    Try{
        Grant-CNOPerms -AvailabilityGroupNameListener $AvailabilityGroupNameListener -CNO $CNO
        }
    Catch{
          Throw "Failed Validate grant permissions on $AvailabilityGroupNameListener in location $OUPAth to $CNO"
          Exit
        }

}

function Import-SQLPSModule {
    [CmdletBinding()]
    param()

    
    <# If SQLPS is not removed between resources (if it was started by another DSC resource) getting
    objects with the SQL PS provider will fail in some instances because of some sort of inconsistency. Uncertain why this happens. #>
    if( (Get-Module SQLPS).Count -ne 0 ) {
        Write-Debug "Unloading SQLPS module."
        Remove-Module -Name SQLPS -Force -Verbose:$False
    }
    
    Write-Debug "SQLPS module changes CWD to SQLSERVER:\ when loading, pushing location to pop it when module is loaded."
    Push-Location

    try {
        New-VerboseMessage -Message "Importing SQLPS module."
        Import-Module -Name SQLPS -DisableNameChecking -Verbose:$False -ErrorAction Stop # SQLPS has unapproved verbs, disable checking to ignore Warnings.
        Write-Debug "SQLPS module imported." 
    }
    catch {
        throw New-TerminatingError -ErrorType FailedToImportSQLPSModule -ErrorCategory InvalidOperation -InnerException $_.Exception
    }
    finally {
        Write-Debug "Popping location back to what it was before importing SQLPS module."
        Pop-Location
    }

}

function Get-SQLPSInstanceName
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    if( $InstanceName -eq "MSSQLSERVER" ) {
        $InstanceName = "DEFAULT"            
    }
    
    return $InstanceName
}

function Get-SQLPSInstance
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeName 
    )

    $InstanceName = Get-SQLPSInstanceName -InstanceName $InstanceName 
    $Path = "SQLSERVER:\SQL\$NodeName\$InstanceName"
    
    New-VerboseMessage -Message "Connecting to $Path as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"

    Import-SQLPSModule
    $instance = Get-Item $Path
    
    return $instance
}

function Get-SQLAlwaysOnEndpoint
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeName 
    )

    $instance = Get-SQLPSInstance -InstanceName $InstanceName -NodeName $NodeName
    $Path = "$($instance.PSPath)\Endpoints"

    Write-Debug "Connecting to $Path as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    
    [String[]] $presentEndpoint = Get-ChildItem $Path
    if( $presentEndpoint.Count -ne 0 -and $presentEndpoint.Contains("[$Name]") ) {
        Write-Debug "Connecting to endpoint $Name as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        $endpoint = Get-Item "$Path\$Name"
    } else {
        $endpoint = $null
    }    

    return $endpoint
}

function New-SqlDatabase
{
    [CmdletBinding()]    
    param
    (   
        [ValidateNotNull()] 
        [System.Object]
        $SQL,
        
        [ValidateNotNull()] 
        [System.String]
        $Name
    )
    
    $newDatabase = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $SQL,$Name
    if ($newDatabase)
    {
        New-VerboseMessage -Message "Adding to SQL the database $Name"
        $newDatabase.Create()
    }
    else
    {
        New-VerboseMessage -Message "Failed to adding the database $Name"
    }    
}

function Remove-SqlDatabase
{
    [CmdletBinding()]    
    param
    (   
        [ValidateNotNull()] 
        [System.Object]
        $SQL,
        
        [ValidateNotNull()] 
        [System.String]
        $Name
    )
    
    $getDatabase = $SQL.Databases[$Name]
    if ($getDatabase)
    {
        New-VerboseMessage -Message "Deleting to SQL the database $Name"
        $getDatabase.Drop()
    }
    else
    {
        New-VerboseMessage -Message "Failed to deleting the database $Name"
    }    
}

function Add-SqlServerRole
{
    [CmdletBinding()]    
    param
    (   
        [ValidateNotNull()] 
        [System.Object]
        $SQL,
        
        [ValidateNotNull()] 
        [System.String]
        $LoginName,

        [ValidateNotNull()] 
        [System.String[]]
        $ServerRole

    )
    
    $sqlRole = $SQL.Roles
    if ($sqlRole)
    {
        try
        {
            foreach ($currentServerRole in $ServerRole)
            {
                New-VerboseMessage -Message "Adding SQL login $LoginName in role $currentServerRole"
                $sqlRole[$currentServerRole].AddMember($LoginName)
            }
        }
        catch
        {
            New-VerboseMessage -Message "Failed adding SQL login $LoginName in role $currentServerRole"
        }
    }
    else
    {
        New-VerboseMessage -Message "Failed to getting SQL server roles"
    }
}

function Remove-SqlServerRole
{
    [CmdletBinding()]    
    param
    (   
        [ValidateNotNull()] 
        [System.Object]
        $SQL,
        
        [ValidateNotNull()] 
        [System.String]
        $LoginName,

        [ValidateNotNull()] 
        [System.String[]]
        $ServerRole

    )
    
    $sqlRole = $SQL.Roles
    if ($sqlRole)
    {
        try
        {
            foreach ($currentServerRole in $ServerRole)
            {
                New-VerboseMessage -Message "Deleting SQL login $LoginName in role $currentServerRole"
                $sqlRole[$currentServerRole].DropMember($LoginName)
            }
        }
        catch
        {
            New-VerboseMessage -Message "Failed deleting SQL login $LoginName in role $currentServerRole"
        }
    }
    else
    {
        New-VerboseMessage -Message "Failed to getting SQL server roles"
    }
}

function Confirm-SqlServerRole
{
    [CmdletBinding()]    
    param
    (   
        [ValidateNotNull()] 
        [System.Object]
        $SQL,
        
        [ValidateNotNull()] 
        [System.String]
        $LoginName,

        [ValidateNotNull()] 
        [System.String[]]
        $ServerRole

    )
    
    $sqlRole = $SQL.Roles
    if ($sqlRole)
    {
        foreach ($currentServerRole in $ServerRole)
        {
            if ($sqlRole[$currentServerRole])
            {
                $membersInRole = $sqlRole[$currentServerRole].EnumMemberNames()             
                if ($membersInRole.Contains($Name))
                {
                    $confirmServerRole = $true
                    New-VerboseMessage -Message "$Name is present in SQL role name $currentServerRole"
                }
                else
                {
                    New-VerboseMessage -Message "$Name is absent in SQL role name $currentServerRole"
                    $confirmServerRole = $false
                }
            }
            else
            {
                New-VerboseMessage -Message "SQL role name $currentServerRole is absent"
                $confirmServerRole = $false
            }
        }
    }
    else
    {
        New-VerboseMessage -Message "Failed getting SQL roles"
        $confirmServerRole = $false
    }

    return $confirmServerRole
}

<#
.SYNOPSIS

This cmdlet is used to return the owner of a SQL database

.PARAMETER SQL

This is an object of the SQL server that contains the result of Connect-SQL

.PARAMETER Database

This is the SQL database that will be checking

#>
function Get-SqlDatabaseOwner
{
    [CmdletBinding()]    
    param
    (   
        [ValidateNotNull()] 
        [System.Object]
        $SQL,

        [ValidateNotNull()] 
        [System.String]
        $Database
    )
    
    Write-Verbose -Message 'Getting SQL Databases'
    $sqlDatabase = $SQL.Databases
    if ($sqlDatabase)
    {
        if ($sqlDatabase[$Database])
        {
            $Name = $sqlDatabase[$Database].Owner
        }
        else
        {
            throw New-TerminatingError -ErrorType FailedToGetOwnerDatabase `
                                       -FormatArgs @($Database) `
                                       -ErrorCategory InvalidOperation
        }
    }
    else
    {
        Write-Verbose -Message 'Failed getting SQL databases'
    }

    $Name
}

<#
.SYNOPSIS

This cmdlet is used to configure the owner of a SQL database

.PARAMETER SQL

This is an object of the SQL server that contains the result of Connect-SQL

.PARAMETER Name 

This is the name of the desired owner for the SQL database

.PARAMETER Database

This is the SQL database that will be setting

#>
function Set-SqlDatabaseOwner
{
    [CmdletBinding()]    
    param
    (   
        [ValidateNotNull()] 
        [System.Object]
        $SQL,
        
        [ValidateNotNull()] 
        [System.String]
        $Name,

        [ValidateNotNull()] 
        [System.String]
        $Database
    )
    
    Write-Verbose -Message 'Getting SQL Databases'
    $sqlDatabase = $SQL.Databases
    $sqlLogins = $SQL.Logins

    if ($sqlDatabase -and $sqlLogins)
    {
        if ($sqlDatabase[$Database])
        {
            if ($sqlLogins[$Name])
            {
                try
                {
                    $sqlDatabase[$Database].SetOwner($Name)
                    New-VerboseMessage -Message "Owner of SQL Database name $Database is now $Name"
                }
                catch
                {
                    throw New-TerminatingError -ErrorType FailedToSetOwnerDatabase -ErrorCategory InvalidOperation -InnerException $_.Exception
                }
            }
            else
            {
                Write-Error -Message "SQL Login name $Name does not exist" -Category InvalidData
            }
        }
        else
        {
            Write-Error -Message "SQL Database name $Database does not exist" -Category InvalidData
        }
    }
    else
    {
        Write-Verbose -Message 'Failed getting SQL databases and logins'
    }
}
