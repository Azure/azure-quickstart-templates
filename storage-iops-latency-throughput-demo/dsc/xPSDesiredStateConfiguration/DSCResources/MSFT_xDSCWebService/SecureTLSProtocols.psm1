# This module file contains a utility to test and set TLS protocol according best practices
#
# Copyright (c) Microsoft Corporation, 2016
#

# ============ Best Practice Security Settings Block =========
$insecureProtocols            = @("SSL 2.0", "SSL 3.0", "TLS 1.0", "PCT 1.0", "Multi-Protocol Unified Hello")
$secureProtocols              = @("TLS 1.1", "TLS 1.2")

# ===========================================================

function Test-SChannelProtocol
{
    foreach ($protocol in $insecureProtocols)
    {
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server"
        if ((Test-Path $registryPath) -and ($null -ne (Get-ItemProperty -Path $registryPath)) -and ((Get-ItemProperty -Path $registryPath).Enabled -ne 0))
        {
            return $false
        }
    }
    foreach ($protocol in $secureProtocols)
    {
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server"
        if ((-not (Test-Path $registryPath)) -or ($null -eq (Get-ItemProperty -Path $registryPath)) -or ((Get-ItemProperty -Path $registryPath).Enabled -eq 0))
        {
            return $false
        }
    }
    return $true
}

function Set-SChannelProtocol
{
    foreach ($protocol in $insecureProtocols)
    {
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server"
        New-Item -Path $registryPath -Force | Out-Null
        New-ItemProperty -Path $registryPath -Name Enabled -Value 0 -PropertyType 'DWord' -Force | Out-Null
    }
    foreach ($protocol in $secureProtocols)
    {
        $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server"
        New-Item -Path $registryPath -Force | Out-Null
        New-ItemProperty -Path $registryPath -Name Enabled -Value '0xffffffff' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -Path $registryPath -Name DisabledByDefault -Value 0 -PropertyType 'DWord' -Force | Out-Null
    }
}
