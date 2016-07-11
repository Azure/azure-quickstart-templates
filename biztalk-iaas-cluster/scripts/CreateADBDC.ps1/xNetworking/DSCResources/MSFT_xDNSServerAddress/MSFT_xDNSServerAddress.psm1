<#######################################################################################
 #  xDNSServerAddress : DSC Resource that will set/test/get the current DNS Server
 #  Address, by accepting values among those given in xDNSServerAddress.schema.mof
 #######################################################################################>
 


######################################################################################
# The Get-TargetResource cmdlet.
# This function will get the present list of DNS ServerAddress DSC Resource schema variables on the system
######################################################################################
function Get-TargetResource
{
	param
	(		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String[]]$Address,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4"
	)
	
    
    $returnValue = @{
        Address = (Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily $AddressFamily).ServerAddresses
        AddressFamily = $AddressFamily
        InterfaceAlias = $InterfaceAlias
	}

	$returnValue
}

######################################################################################
# The Set-TargetResource cmdlet.
# This function will set a new Server Address in the current node
######################################################################################
function Set-TargetResource
{
	param
	(	
        #IP Address that has to be set	
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String[]]$Address,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4"
	)

    ValidateProperties @PSBoundParameters -Apply
}

######################################################################################
# The Test-TargetResource cmdlet.
# This will test if the given Server Address is among the current node's Server Address collection
######################################################################################
function Test-TargetResource
{
	param
	(		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String[]]$Address,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4"
	)

    ValidateProperties @PSBoundParameters
}


#######################################################################################
#  Helper function that validates the Server Address properties. If the switch parameter
# "Apply" is set, then it will set the properties after a test
#######################################################################################
function ValidateProperties
{
    param
    (
        [Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String[]]$Address,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily,

        [Switch]$Apply
    )
    $sa =$Address
    $sa | %{
             if(!([System.Net.Ipaddress]::TryParse($_, [ref]0)))
             {
                 throw "Server Address *$_* is not in the correct format. Please correct the Address in the configuration and try again"
             }
             if (([System.Net.IPAddress]$_).AddressFamily.ToString() -eq [System.Net.Sockets.AddressFamily]::InterNetwork.ToString())
             {
                if ($AddressFamily -ne "IPv4")
                {
                    throw "Server address $Address is in IPv4 format, which does not match server address family $AddressFamily. Please correct either of them in the configuration and try again"
                }
             }
             else
             {
                if ($AddressFamily -ne "IPv6")
                {
                    throw "Server address $Address is in IPv6 format, which does not match server address family $AddressFamily. Please correct either of them in the configuration and try again"
                }
             }
         }
    try
    {        
        Write-Verbose -Message "Checking the DNS Server Address ..."
        #Get the current IP Address based on the parameters given.
        $currentAddress = (Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily $AddressFamily -ErrorAction Stop).ServerAddresses

        #Check if the Server addresses are the same as the desired addresses.
        if(@(Compare-Object -ReferenceObject $currentAddress -DifferenceObject $Address -SyncWindow 0).Length -gt 0)
        {
            Write-Verbose -Message "DNS Servers are not correct. Expected $Address, actual $currentAddress"
            if($Apply)
            {
                # Set the DNS settings as well
                Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $Address
                Write-Verbose -Message "DNS Servers have been set correctly."
            }
            else 
            {
                return $false
            }
        }
        else 
        { 
            #Test will return true in this case
            Write-Verbose -Message "DNS Servers are set correctly."
            return $true
        }
    }
    catch
    {
       Write-Verbose -Message $_
       throw "Can not set or find valid DNS Server addresses using InterfaceAlias $InterfaceAlias and AddressFamily $AddressFamily"
    }
}



#  FUNCTIONS TO BE EXPORTED 
Export-ModuleMember -function Get-TargetResource, Set-TargetResource, Test-TargetResource