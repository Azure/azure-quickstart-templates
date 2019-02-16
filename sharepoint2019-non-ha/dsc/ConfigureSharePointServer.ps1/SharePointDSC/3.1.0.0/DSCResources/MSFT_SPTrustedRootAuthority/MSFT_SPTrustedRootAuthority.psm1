function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose "Getting Trusted Root Authority with name '$Name'"
    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $rootCert = Get-SPTrustedRootAuthority -Identity $params.Name -ErrorAction SilentlyContinue

        $ensure = "Absent"

        if($null -eq $rootCert)
        {
            return @{
                Name = $params.Name
                CertificateThumbprint = [string]::Empty
                Ensure = $ensure
            }
        }
        else
        {
            $ensure = "Present"

            return @{
                Name = $params.Name
                CertificateThumbprint = $rootCert.Certificate.Thumbprint
                Ensure = $ensure
            }
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting SPTrustedRootAuthority '$Name'"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    if ($Ensure -eq "Present" -and $CurrentValues.Ensure -eq "Present")
    {
        Write-Verbose -Message "Updating SPTrustedRootAuthority '$Name'"
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $PSBoundParameters `
                                      -ScriptBlock {
            $params = $args[0]
            $cert = Get-Item -Path "CERT:\LocalMachine\My\$($params.CertificateThumbprint)" `
                             -ErrorAction SilentlyContinue

            if ($null -eq $cert)
            {
                throw "Certificate not found in the local Certificate Store"
            }

            if ($cert.HasPrivateKey)
            {
                $pubKeyBytes = $cert.Export("cert")
                $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                $cert2.Import($pubKeyBytes)
                $cert = $cert2
            }

            Set-SPTrustedRootAuthority -Identity $params.Name -Certificate $cert
        }
    }
    if ($Ensure -eq "Present" -and $CurrentValues.Ensure -eq "Absent")
    {
        Write-Verbose -Message "Adding SPTrustedRootAuthority '$Name'"
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $PSBoundParameters `
                                      -ScriptBlock {
            $params = $args[0]

            $cert = Get-Item -Path "CERT:\LocalMachine\My\$($params.CertificateThumbprint)" `
                             -ErrorAction SilentlyContinue

            if($null -eq $cert)
            {
                throw "Certificate not found in the local Certificate Store"
            }

            if($cert.HasPrivateKey)
            {
                $pubKeyBytes = $cert.Export("cert")
                $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                $cert2.Import($pubKeyBytes)
                $cert = $cert2
            }

            New-SPTrustedRootAuthority -Name $params.Name -Certificate $cert
        }
    }
    if ($Ensure -eq "Absent")
    {
        Write-Verbose -Message "Removing SPTrustedRootAuthority '$Name'"
        $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                      -Arguments $PSBoundParameters `
                                      -ScriptBlock {
            $params = $args[0]
            Remove-SPTrustedRootAuthority -Identity $params.Name `
                                          -ErrorAction SilentlyContinue
        }
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing SPTrustedRootAuthority '$Name'"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    if($Ensure -eq "Present")
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Name","CertificateThumbprint","Ensure")
    }
    else
    {
         return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Name","Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource
