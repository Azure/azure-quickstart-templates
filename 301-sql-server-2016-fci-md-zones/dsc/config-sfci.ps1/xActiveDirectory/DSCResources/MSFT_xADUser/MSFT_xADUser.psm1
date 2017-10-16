#
# xADUser: DSC resource to create a new Active Directory user.
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [string]$DomainName,

        [Parameter(Mandatory)]
        [string]$UserName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,
        
        [PSCredential]$Password,

        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"
    )

    try
    {
        Write-Verbose -Message "Checking if the user '$($UserName)' in domain '$($DomainName)' is present ..."
        $user = Get-AdUser -Identity $UserName -Credential $DomainAdministratorCredential
        Write-Verbose -Message "Found '$($UserName)' in domain '$($DomainName)'."
        $Ensure = "Present"
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message "User '$($UserName)' in domain '$($DomainName)' is NOT present."
        $Ensure = "Absent"
    }
    catch
    {
        Write-Error -Message "Error looking up user '$($UserName)' in domain '$($DomainName)'."
        throw $_
    }

    @{
        DomainName = $DomainName
        UserName = $UserName
        Ensure = $Ensure
    }
}

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [string]$DomainName,

        [Parameter(Mandatory)]
        [string]$UserName,
        
        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,

        [PSCredential]$Password,

        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"
    )
    try
    {
        ValidateProperties @PSBoundParameters -Apply
    }
    catch
    {
        Write-Error -Message "Error configuring user '$($UserName)' in domain '$($DomainName)'."
        throw $_
    }
}

function Test-TargetResource
{
	[OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [string]$DomainName,

        [Parameter(Mandatory)]
        [string]$UserName,
        
        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,

        [PSCredential]$Password,

        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"
    )

    try
    {
        $parameters = $PSBoundParameters.Remove("Debug");
        ValidateProperties @PSBoundParameters
    }
    catch
    {
        Write-Error -Message "Error testing user '$($UserName)' in domain '$($DomainName)'."
        throw $_
    }
}

function ValidateProperties
{
    param
    (
        [Parameter(Mandatory)]
        [string]$DomainName,

        [Parameter(Mandatory)]
        [string]$UserName,

        [Parameter(Mandatory)]
        [PSCredential]$DomainAdministratorCredential,

        [PSCredential]$Password,

        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present",

        [Switch]$Apply
    )

    $result = $true
    try
    {
        Write-Verbose -Message "Checking if the user '$($UserName)' in domain '$($DomainName)' is present ..."
        $user = Get-AdUser -Identity $UserName -Credential $DomainAdministratorCredential
        Write-Verbose -Message "Found '$($UserName)' in domain '$($DomainName)'."
        
        if ($Ensure -eq "Absent")
        {
            if ($Apply)
            {
                Remove-ADUser -Identity $UserName -Credential $DomainAdministratorCredential -Confirm:$false
                return
            }
            else
            {
                return $false
            }
        }
        
        if ($Apply)
        {
            # We need to enable the account for password validation.
            if (!($user.Enabled))
            {
                Set-AdUser -Identity $UserName -Enabled $true -Credential $DomainAdministratorCredential
                Write-Verbose -Message "Enabled user account '$($UserName)' in domain '$($DomainName)'."
            }
        }
        
        if ($Password)
        {
            Write-Verbose -Message "Checking if the password specified for user '$($UserName)' is valid ..."
            Add-Type -AssemblyName "System.DirectoryServices.AccountManagement"
            
            Write-Verbose -Message "Creating connection to the domain '$($DomainName)' ..."
            $prnContext = new-object System.DirectoryServices.AccountManagement.PrincipalContext(
                            "Domain", $DomainName, $DomainAdministratorCredential.UserName, `
                            $DomainAdministratorCredential.GetNetworkCredential().Password)

            $result = $prnContext.ValidateCredentials($UserName, $Password.GetNetworkCredential().Password)
            if($result)
            {
                Write-Verbose -Message "The password for user '$($UserName)' is valid."
                return $true
            }
            else
            {
                Write-Verbose -Message "The password for user '$($UserName)' is NOT valid."
                if ($Apply)
                {
                    Set-AdAccountPassword -Reset -Identity $UserName -NewPassword $Password.Password -Credential $DomainAdministratorCredential
                    Write-Verbose -Message "Successfully reset password for user '$($UserName)'."
                }
                else
                {
                    return $false
                }
            }
        }
        else
        {
            Write-Verbose -Message "Found user '$($UserName)' in domain '$($DomainName)'."
            return $true
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message "User '$($UserName)' in domain '$($DomainName)' is NOT present."
        if ($Apply)
        {
            if ($Ensure -ne "Absent")
            {
                $params = @{
                    Name = $UserName
                    Credential = $DomainAdministratorCredential
                    Enabled = $true
                    UserPrincipalName = "$UserName@$DomainName"
                    PasswordNeverExpires = $true
                }
                if ($Password)
                {
                    $params.Add( "AccountPassword", $Password.Password )
                }
                New-AdUser @params
                Write-Verbose -Message "Successfully created user account '$($UserName)' in domain '$($DomainName)'."
            }
        }
        else
        {
            return ($Ensure -eq "Absent")
        }
    }
}


Export-ModuleMember -Function *-TargetResource
