#################################################################################################################################
#  Name        : Configure-WinRM.ps1                                                                                            #
#                                                                                                                               #
#  Description : Configures the WinRM on a local machine                                                                        #
#                                                                                                                               #
#  Arguments   : HostName, specifies the FQDN of machine or domain                                                           #
#################################################################################################################################

param
(
    [string] $hostname
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

function Delete-WinRMListener
{
    try
    {
        $config = Winrm enumerate winrm/config/listener
        foreach($conf in $config)
        {
            if($conf.Contains("HTTPS"))
            {
                Write-Verbose "HTTPS is already configured. Deleting the exisiting configuration."
    
                winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
                break
            }
        }
    }catch
    {
        Write-Verbose -Verbose "Exception while deleting the listener: " + $_.Exception.Message
    }
}

function Configure-WinRMHttpsListener
{
    param([string] $hostname,
          [string] $port)

    # Delete the WinRM Https listener if it is already configured
    Delete-WinRMListener

    # Create a test certificate
    $thumbprint = (Get-ChildItem cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=" + $hostname } | Select-Object -Last 1).Thumbprint
    if(-not $thumbprint)
    {
        .\makecert -r -pe -n CN=$hostname -b 01/01/2012 -e 01/01/2022 -eku 1.3.6.1.5.5.7.3.1 -ss my -sr localmachine -sky exchange -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12
        $thumbprint=(Get-ChildItem cert:\Localmachine\my | Where-Object { $_.Subject -eq "CN=" + $hostname } | Select-Object -Last 1).Thumbprint

        if(-not $thumbprint)
        {
            throw "Failed to create the test certificate."
        }
    }    

    cmd.exe /c .\winrmconf.cmd $hostname $thumbprint
}

function Add-FirewallException
{
    param([string] $port)

    # Delete an exisitng rule
    netsh advfirewall firewall delete rule name="Windows Remote Management (HTTPS-In)" dir=in protocol=TCP localport=$port

    # Add a new firewall rule
    netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=$port
}


#################################################################################################################################
#                                              Configure WinRM                                                                  #
#################################################################################################################################

$winrmHttpsPort=5986

# The default MaxEnvelopeSizekb on Windows Server is 500 Kb which is very less. It needs to be at 8192 Kb. The small envelop size if not changed
# results in WS-Management service responding with error that the request size exceeded the configured MaxEnvelopeSize quota.
winrm set winrm/config '@{MaxEnvelopeSizekb = "8192"}'

# Configure https listener
Configure-WinRMHttpsListener $hostname $port

# Add firewall exception
Add-FirewallException -port $winrmHttpsPort

#################################################################################################################################
#################################################################################################################################
