#
# xSqlLogin: DSC resource to configure SQL Logins.
#

function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [ValidateNotNullOrEmpty()]
        [PSCredential]$Password,

        [ValidateNotNullOrEmpty()]
        [String]$LoginType,

        [ValidateNotNullOrEmpty()]
        [String[]]$ServerRoles,

        [ValidateNotNullOrEmpty()]
        [Bool]$Enabled,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    $sc = New-Object Microsoft.SqlServer.Management.Common.ServerConnection
    if ($Credential)
    {
        $sc.ConnectAsUser = $true
        if ($Credential.GetNetworkCredential().Domain -and $Credential.GetNetworkCredential().Domain -ne $env:COMPUTERNAME)
        {
            $sc.ConnectAsUserName = "$($Credential.GetNetworkCredential().UserName)@$($Credential.GetNetworkCredential().Domain)"
        }
        else
        {
            $sc.ConnectAsUserName = $Credential.GetNetworkCredential().UserName
        }
        $sc.ConnectAsUserPassword = $Credential.GetNetworkCredential().Password
    }
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    $s = New-Object Microsoft.SqlServer.Management.Smo.Server $sc

    @{
        Name = $Name
        Password = $Password
        LoginType = $s.Logins | where { $_.Name -eq $Name } | select -ExpandProperty LoginType
        ServerRoles = $s.Roles | where {$_.Name -eq $role}
        Enabled = !($s.Logins | where { $_.Name -eq $Name } | select -ExpandProperty IsDisabled)
        Credential = $Credential
    }
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [ValidateNotNullOrEmpty()]
        [PSCredential]$Password,

        [ValidateNotNullOrEmpty()]
        [String]$LoginType,

        [ValidateNotNullOrEmpty()]
        [String[]]$ServerRoles,

        [ValidateNotNullOrEmpty()]
        [Bool]$Enabled = $null,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )

    #Get local sql server management object
    $server = Get-LocalSqlServer -Credential $Credential

    #Test if the login exists
    $login = Test-Login -LoginName $Name -Server $server

    if ($login)
    {
        #Update the Password for existing login
        Update-LoginPassword -Login $login -Password $Password.GetNetworkCredential().SecurePassword
    }
    else 
    {
        if ($LoginType.ToUpper() -eq "WINDOWSUSER")
        {
            #Create Windows login
            Create-Windows-Login -Server $server -LoginName $Name -LoginType $LoginType
        }
        elseif ($LoginType.ToUpper() -eq "SQLLOGIN")
        {
            #Create SQLAUTH login
            Create-SQLAuth-Login -Server $server -LoginName $Name -Password $Password.GetNetworkCredential().SecurePassword -LoginType $LoginType
        }
        else 
        {
            Throw "Error occured: Login Type '$($LoginType)' not support"
        }
        
        #Add roles to login
        Add-LoginRoles -Server $Server -LoginName $Name -ServerRoles $ServerRoles
    }

    #Test login again to the login object
    $login = Test-Login -LoginName $Name -Server $server
    if ($login)
    {
        Enable-Login -Login $login -Enabled $Enabled
    }
    else 
    {
        Write-Error "No Login $($LoginName) found for Enable-Login, exiting...."
        return $false        
    }
    

}

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [ValidateNotNullOrEmpty()]
        [PSCredential]$Password,

        [ValidateNotNullOrEmpty()]
        [String]$LoginType,

        [ValidateNotNullOrEmpty()]
        [String[]]$ServerRoles,

        [ValidateNotNullOrEmpty()]
        [Bool]$Enabled,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )

    # Set-TargetResource is idempotent.
    $false
}


#Return a SMO object to a SQL Server instance using the provided credentials
function Get-LocalSqlServer
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    

    $LoginCreataionRetry = 0

    While ($true) {
        
        try {
            #Setting Up Server Connection Object
            $sc = New-Object Microsoft.SqlServer.Management.Common.ServerConnection
            
            if ($Credential)
            {
                $sc.ConnectAsUser = $true

                #Can not find a proper documentation for setting ConnectTimeout to be forever so we use 300 seconds here which is the max time of the guest agent to determine timeout
                $sc.ConnectTimeout = 300
                
                if ($Credential.GetNetworkCredential().Domain -and ($Credential.GetNetworkCredential().Domain -ne $env:COMPUTERNAME))
                {
                    $domainCredential = "$($Credential.GetNetworkCredential().UserName)@$($Credential.GetNetworkCredential().Domain)"

                    Write-Verbose "Connecting Server with Domain Credential $($domainCredentia) "     

                    $sc.ConnectAsUserName = "$($Credential.GetNetworkCredential().UserName)@$($Credential.GetNetworkCredential().Domain)"
                }
                else
                {
                    Write-Verbose "Connecting Server with local Admin Credential $($Credential.GetNetworkCredential().UserName)"
                    
                    $sc.ConnectAsUserName = $Credential.GetNetworkCredential().UserName
                }
                
                $sc.ConnectAsUserPassword = $Credential.GetNetworkCredential().Password
            }
            else 
            {
               Throw "Server Connection Credential object is null, exiting ..."     
            }
            
            [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

            $s = New-Object Microsoft.SqlServer.Management.Smo.Server $sc 
            
            if ($s.Information.Version) {
            
                $s.Refresh()
            
                Write-Verbose "SQL Management Object Created Successfully, Version : '$($s.Information.Version)' "   
            
            }
            else
            {
                throw "SQL Management Object Creation Failed"
            }
            
            return $s

        }
        catch [System.Exception] 
        {
            $LoginCreationRetry = $LoginCreationRetry + 1
            
            if ($_.Exception.InnerException) {                   
             $ErrorMSG = "Error occured: '$($_.Exception.Message)',InnerException: '$($_.Exception.InnerException.Message)',  failed after '$($LoginCreationRetry)' times"
            } 
            else 
            {               
             $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($LoginCreationRetry)' times"
            }
            
            if ($LoginCreationRetry -eq 30) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($LoginCreationRetry)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 60

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($LoginCreationRetry)' times"
        }
    }
}

function Test-Login
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.SqlServer.Management.Smo.Server]$Server
    )

    Write-Verbose "Testing if Login $($LoginName) exists in SQL Server $($Server.Name)"

    $login = $Server.Logins | where { $_.Name -eq $LoginName }

    return $login
}

function Enable-Login
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.SqlServer.Management.Smo.Login]$Login,

        [ValidateNotNullOrEmpty()]
        [Bool]$Enabled
    )

    $LoginCreationRetry = 0

    While ($true) {
        
        try {
            #Enable this login if enable flag is set
            if ($Enabled)
            {
                Write-Verbose "Enabling login '$($Login.Name)'"
                
                $Login.Enable()

                Write-Verbose "Login '$($Login.Name)' enabled"

                return $true
            }
            elseif ($Enabled -eq $false)
            {
                Write-Verbose "Disabling login '$($Login.Name)'"
               
                $Login.Disable()

                Write-Verbose "Login '$($Login.Name)' disabled"

                return $true
            }

        }
        catch [System.Exception] 
        {
            $LoginCreationRetry = $LoginCreationRetry + 1
            
            $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($LoginCreationRetry)' times"
            
            if ($LoginCreationRetry -eq 30) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($LoginCreationRetry)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 60

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($LoginCreationRetry)' times"
        }
    }

}

function Update-LoginPassword
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.SqlServer.Management.Smo.Login]$Login,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]$Password
    )

    $LoginCreationRetry = 0

    While ($true) {
        
        try {
            #Update Password of an existing Login
            Write-Verbose "Updating the password for login '$($Name)'"

            $Login.ChangePassword($Password)

            Write-Verbose "Password for login '$($Name)' has updated."

            return $true
        }
        catch [System.Exception] 
        {
            $LoginCreationRetry = $LoginCreationRetry + 1
            
            $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($LoginCreationRetry)' times"
            
            if ($LoginCreationRetry -eq 30) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($LoginCreationRetry)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 60

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($LoginCreationRetry)' times"
        }
    }
}


function Add-LoginRoles
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.SqlServer.Management.Smo.Server]$Server,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginName,

        [ValidateNotNullOrEmpty()]
        [String[]]$ServerRoles
    )

    $LoginCreationRetry = 0

    While ($true) {
        
        try {
            #Add ServerRoles to this newly created Login
            foreach ($role in $ServerRoles)
            {
                $svrole = $Server.Roles | where {$_.Name -eq $role}
                
                $members = $svrole.EnumMemberNames()

                if ($members.Contains($LoginName))
                {
                   continue 
                }

                if ($svrole)
                {
                    Write-Verbose "Adding login '$($LoginName)' to server role '$($role)'"
                    
                    $svrole.AddMember($LoginName)

                    Write-Verbose "Login '$($LoginName)' added to server role '$($role)'"


                }
                else
                {
                    Write-Verbose "Server role '$($role)' does not exist, skipping ..."
                }
            }

            return $true
        }
        catch [System.Exception] 
        {
            $LoginCreationRetry = $LoginCreationRetry + 1
            
            $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($LoginCreationRetry)' times"
            
            if ($LoginCreationRetry -eq 30) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($LoginCreationRetry)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 60

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($LoginCreationRetry)' times"
        }
    }
}

function Create-Windows-Login
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.SqlServer.Management.Smo.Server]$Server,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginType
    )

    $LoginCreationRetry = 0

    While ($true) {
        
        try {
            
            $NewLogin = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login($Server, $LoginName)
        
            $NewLogin.LoginType = $LoginType
                
            $NewLogin.PasswordExpirationEnabled = $false

            Write-Verbose "Creating Login $($LoginName) as Windows Login"
            #Create a Windows Login without Password 
            $NewLogin.Create()

            Write-Verbose "Login '$($LoginName)' created successfully......"

            return $true
        }
        catch [System.Exception] 
        {
            $LoginCreationRetry = $LoginCreationRetry + 1
            
            $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($LoginCreationRetry)' times"
            
            if ($LoginCreationRetry -eq 30) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($LoginCreationRetry)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 60

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($LoginCreationRetry)' times"
        }
    }
}



function Create-SQLAuth-Login
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.SqlServer.Management.Smo.Server]$Server,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginName,

        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]$Password,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginType
    )

    $LoginCreationRetry = 0

    While ($true) {
        
        try {
            
            $NewLogin = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login($Server, $LoginName)
        
            $NewLogin.LoginType = $LoginType
                
            $NewLogin.PasswordExpirationEnabled = $false
        
            Write-Verbose "Creating Login $($LoginName) as SQL Login"

            if ($Password)
            {
                #Create a SQLLogin with Password 
                $NewLogin.Create($Password)

                Write-Verbose "Login '$($LoginName)' created successfully......"

                return $true
            
            }else 
            {
                Throw "Login '$($LoginName)' can not be created with type '$($LoginType)', the password is null ......"
            }

        }
        catch [System.Exception] 
        {
            $LoginCreationRetry = $LoginCreationRetry + 1

            $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($LoginCreationRetry)' times"
            
            if ($LoginCreationRetry -eq 30) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($LoginCreationRetry)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 60

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($LoginCreationRetry)' times"
        }
    }
}



Export-ModuleMember -Function *-TargetResource