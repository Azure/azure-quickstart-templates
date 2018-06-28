#region Initialize

function Initialize
{
    # hosts location
    $script:hostsLocation = "$env:SystemRoot\System32\drivers\etc\hosts";
    $script:encoding = "UTF8";

    # Enum for Ensure
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@ -ErrorAction SilentlyContinue; 

    # Enum for Reference
    Add-Type -TypeDefinition @"
        public enum ReferenceType
        {
            DnsServer,
            StaticIp
        }
"@ -ErrorAction SilentlyContinue; 
}

. Initialize;

#endregion

#region Message Definition

Data VerboseMessages {
    ConvertFrom-StringData -StringData @"
        CheckHostsEntry = Check hosts entry is exists.
        CreateHostsEntry = Create hosts entry {0} : {1}.
        HostsEntryFound = Found a hosts entry {0} : {1}.
        HostsEntryNotFound = Did not find a hosts entry {0} : {1}.
        ReferenceDnsServer = Reference is DnsServer. Trying to connect to DnsServer and get first A record. {0}
        ReferenceStaticIp = Reference is StaticIp. IPAddress will directly used. {0}
        RemoveHostsEntry = Remove hosts entry {0} : {1}.
        RemoveHostsEntryBeforeAdd = Remove duplicate hostname entry before adding host entry. This will ignore IPAddress because correct host entry will add right after remove. hostname : {0}
        RemovedEntryIP = Removed Entry for {0} : {1}.{2}.{3}.{4}
"@
}

Data DebugMessages {
    ConvertFrom-StringData -StringData @"
"@
}

Data ErrorMessages {
    ConvertFrom-StringData -StringData @"
        CouldNotResolveIpWithDnsServer = Could not resolve A revord with DnsServer. IpAddress : {0}
"@
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$HostName,
        
        [parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = [EnsureType]::Present,

        [parameter(Mandatory = $true)]
        [string]$IpAddress,

        [parameter(Mandatory = $false)]
        [ValidateSet("DnsServer","StaticIp")]
        [String]$Reference = "DnsServer"
    )  
    
    $Configuration = @{
        HostName = $HostName
        IPAddress = $IpAddress
        Reference = $Reference
    };

    Write-Verbose $VerboseMessages.CheckHostsEntry;

    try
    {
        $ipEntry = ResolveIpAddressReference -IpAddress $IpAddress -HostName $HostName -Reference $Reference;
        if (TestIsHostEntryExists -IpAddress $ipEntry -HostName $HostName)
        {
            Write-Verbose ($VerboseMessages.HostsEntryFound -f $HostName, $ipEntry);
            $Configuration.Ensure = [EnsureType]::Present;
        }
        else
        {
            Write-Verbose ($VerboseMessages.HostsEntryNotFound -f $HostName, $ipEntry);
            $Configuration.Ensure = [EnsureType]::Absent;
        }
    }
    catch
    {
        Write-Error $_;
    }

    return $Configuration;
}

function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$HostName,
        
        [parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = [EnsureType]::Present,

        [parameter(Mandatory = $true)]
        [string]$IpAddress,

        [parameter(Mandatory = $false)]
        [ValidateSet("DnsServer","StaticIp")]
        [String]$Reference = "DnsServer"
    )  

    try
    {
        $ipEntry = ResolveIpAddressReference -IpAddress $IpAddress -HostName $HostName -Reference $Reference
        $hostEntry = "`n{0}`t{1}" -f $ipEntry, $HostName

        # Absent
        if ($Ensure -eq [EnsureType]::Absent.ToString())
        {
            Write-Verbose ($VerboseMessages.RemoveHostsEntry -f $HostName, $ipEntry);
            ((Get-Content $script:hostsLocation) -notmatch "^\s*$") -notmatch "^[^#]*$ipEntry\s+$HostName" | Set-Content -Path $script:hostsLocation -Force -Encoding $script:encoding;
            return;
        }
        else
        {
            # Present
            Write-Verbose ($VerboseMessages.RemoveHostsEntryBeforeAdd -f $HostName);
            ((Get-Content $script:hostsLocation) -notmatch "^\s*$") -notmatch "^[^#]*(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\s+$HostName" | Set-Content -Path $script:hostsLocation -Force -Encoding $script:encoding;

            Write-Verbose ($VerboseMessages.CreateHostsEntry -f $HostName, $ipEntry);
            Add-Content -Path $script:hostsLocation -Value $hostEntry -Force -Encoding $script:encoding;
        }
    }
    catch
    {
        throw $_;
    }
}

function Test-TargetResource
{
    [OutputType([boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$HostName,
        
        [parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = [EnsureType]::Present,

        [parameter(Mandatory = $true)]
        [string]$IpAddress,

        [parameter(Mandatory = $false)]
        [ValidateSet("DnsServer","StaticIp")]
        [String]$Reference = "DnsServer"
    )  

    return (Get-TargetResource -HostName $HostName -IpAddress $IpAddress -Ensure $Ensure -Reference $Reference).Ensure -eq $Ensure;
}

#endregion

#region Helper Function

function TestIsHostEntryExists ([string]$IpAddress, [string] $HostName)
{
    return ((Get-Content -Path $script:hostsLocation -Encoding $script:encoding) -match "^[^#]*$ipAddress\s+$HostName" | measure).Count -ne 0;
}

function ResolveIpAddressReference ([string]$IpAddress, [string]$HostName, [ReferenceType]$Reference)
{
    $ipEntry = if ($Reference -eq [ReferenceType]::StaticIp)
    {
        # Reference is StaticIp
        Write-Verbose ($VerboseMessages.ReferenceStaticIp -f $IpAddress);
        $IpAddress;
    }
    elseif ($Reference -eq [ReferenceType]::DnsServer)
    {
        # Reference is DnsServer
        Write-Verbose ($VerboseMessages.ReferenceDnsServer -f $IpAddress);
        $resolveIp = Resolve-DnsName -Name $HostName -Server $IpAddress -DnsOnly | where Type -eq A | sort IPAddress;
        if ($null -eq $resolveIp)
        {
            throw New-Object System.NullReferenceException ($ErrorMessages.CouldNotResolveIpWithDnsServer -f $IpAddress);
        }
        ($resolveIp | select -First 1).IPAddress;
    }

    return $ipEntry;
}

#endregion

Export-ModuleMember -Function *-TargetResource;
