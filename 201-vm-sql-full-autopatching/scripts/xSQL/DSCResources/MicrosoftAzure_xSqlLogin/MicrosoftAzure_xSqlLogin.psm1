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

    $login = $s.Logins | where { $_.Name -eq $Name }
    if (!$login)
    {
        Write-Verbose -Message "Creating login '$($Name)'"
        $login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $s, $Name
        $login.LoginType = $LoginType
        $login.PasswordExpirationEnabled = $false
        if ($LoginType -eq [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin)
        {
            $login.Create($Password.GetNetworkCredential().SecurePassword)
        }
        else
        {
            $login.Create()
        }
    }
    elseif ($Password)
    {
        Write-Verbose -Message "Setting the password for login '$($Name)'"
        $login.ChangePassword($Password.GetNetworkCredential().Password)
    }

    foreach ($role in $ServerRoles)
    {
        $svrole = $s.Roles | where {$_.Name -eq $role}
        if ($svrole)
        {
            Write-Verbose -Message "Added login '$($Name)' to server role '$($role)'"
            $svrole.AddMember($Name)
        }
        else
        {
            Write-Warning -Message "Server role '$($role)' does not exist, skipping ..."
        }
    }

    if ($Enabled)
    {
        Write-Verbose -Message "Enabling login '$($Name)'"
        $login.Enable()
    }
    elseif ($Enabled -eq $false)
    {
        Write-Verbose -Message "Disabling login '$($Name)'"
        $login.Disable()
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


Export-ModuleMember -Function *-TargetResource
