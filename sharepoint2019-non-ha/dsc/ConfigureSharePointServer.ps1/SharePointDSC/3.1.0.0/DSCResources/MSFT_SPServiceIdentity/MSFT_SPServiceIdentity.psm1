function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ManagedAccount
    )

    Write-Verbose -Message "Getting identity for service instance '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]

        if ($params.Name -eq "SharePoint Server Search")
        {
            $processIdentity = (Get-SPEnterpriseSearchService).get_ProcessIdentity()
        }
        else
        {
            $serviceInstance = Get-SPServiceInstance -Server $env:computername | Where-Object {
                                    $_.TypeName -eq $params.Name
                               }

            if ($null -eq $serviceInstance.service.processidentity)
            {
                Write-Verbose "WARNING: Service $($params.name) does not support setting the process identity"
            }

            $processIdentity = $serviceInstance.Service.ProcessIdentity
        }

        switch ($processIdentity.CurrentIdentityType)
        {
            "LocalSystem" { $ManagedAccount = "LocalSystem" }
            "NetworkService" { $ManagedAccount = "NetworkService" }
            "LocalService" { $ManagedAccount = "LocalService" }
            Default { $ManagedAccount = $processIdentity.Username }
        }

        return @{
            Name = $params.Name
            ManagedAccount = $ManagedAccount
        }
    }

    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ManagedAccount
    )

    Write-Verbose -Message "Setting service instance '$Name' to '$ManagedAccount'"

    Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]

        if ($params.Name -eq "SharePoint Server Search")
        {
            $processIdentity = (Get-SPEnterpriseSearchService).get_ProcessIdentity()
        }
        else
        {
            $serviceInstance = Get-SPServiceInstance -Server $env:COMPUTERNAME | Where-Object {
                                    $_.TypeName -eq $params.Name
                               }
            if ($null -eq $serviceInstance)
            {
                throw [System.Exception] "Unable to locate service $($params.Name)"
            }

            if ($null -eq $serviceInstance.service.processidentity)
            {
                throw [System.Exception] "Service $($params.name) does not support setting the process identity"
            }

            $processIdentity = $serviceInstance.Service.ProcessIdentity
        }

        if ($params.ManagedAccount -eq "LocalSystem" -or `
            $params.ManagedAccount -eq "LocalService" -or `
            $params.ManagedAccount -eq "NetworkService")
        {
            $processIdentity.CurrentIdentityType = $params.ManagedAccount
        }
        else
        {
            $managedAccount = Get-SPManagedAccount -Identity $params.ManagedAccount `
                                                   -ErrorAction SilentlyContinue
            if ($null -eq $managedAccount)
            {
                throw [System.Exception] "Unable to locate Managed Account $($params.ManagedAccount)"
            }

            $processIdentity.CurrentIdentityType = [Microsoft.SharePoint.Administration.IdentityType]::SpecificUser
            $processIdentity.ManagedAccount = $managedAccount
        }

        $processIdentity.Update()
        $processIdentity.Deploy()
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ManagedAccount
    )

    Write-Verbose -Message "Testing service instance '$Name' Process Identity"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return ($CurrentValues.ManagedAccount -eq $ManagedAccount)
}
