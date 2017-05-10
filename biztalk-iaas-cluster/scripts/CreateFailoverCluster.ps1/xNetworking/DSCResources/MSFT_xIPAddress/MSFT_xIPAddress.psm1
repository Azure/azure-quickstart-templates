<#######################################################################################
 #  MSDSCPack_IPAddress : DSC Resource that will set/test/get the current IP 
 #  Address, by accepting values among those given in MSDSCPack_IPAddress.schema.mof
 #######################################################################################>
 


######################################################################################
# The Get-TargetResource cmdlet.
# This function will get the present list of IP Address DSC Resource schema variables on the system
######################################################################################
function Get-TargetResource
{
	param
	(		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Int]$SubnetMask = 16,

		[ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,
        
        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4"
	)
	
    
    $returnValue = @{
        IPAddress = [System.String]::Join(", ",(Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily $AddressFamily).IPAddress)
        SubnetMask = $SubnetMask
        DefaultGateway = $DefaultGateway
        AddressFamily = $AddressFamily
        InterfaceAlias=$InterfaceAlias
	}

	$returnValue
}

######################################################################################
# The Set-TargetResource cmdlet.
# This function will set a new IP Address in the current node
######################################################################################
function Set-TargetResource
{
	param
	(	
        #IP Address that has to be set	
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Int]$SubnetMask,

		[ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4"
	)

    
    ValidateProperties @PSBoundParameters -Apply
}

######################################################################################
# The Test-TargetResource cmdlet.
# This will test if the given IP Address is among the current node's IP Address collection
######################################################################################
function Test-TargetResource
{
	param
	(		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [Int]$SubnetMask,

		[ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4"
	)

    ValidateProperties @PSBoundParameters
}


#######################################################################################
#  Helper function that validates the IP Address properties. If the switch parameter
# "Apply" is set, then it will set the properties after a test
#######################################################################################
function ValidateProperties
{
    param
    (
        [Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[String]$IPAddress,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
        [String]$InterfaceAlias,

        [ValidateNotNullOrEmpty()]
        [String]$DefaultGateway,

        [Int]$SubnetMask = 16,

	[ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4",

        [Switch]$Apply
    )
    $ip=$IPAddress
    if(!([System.Net.Ipaddress]::TryParse($ip, [ref]0)))
    {
       throw "IP Address *$IPAddress* is not in the correct format. Please correct the ipaddress in the configuration and try again"
    }
    try
    {        
        Write-Verbose -Message "Checking the IPAddress ..."
        #Get the current IP Address based on the parameters given.
        $currentIP = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily $AddressFamily -ErrorAction Stop

        #Test if the IP Address passed is equal to the current ip address
        if(!$currentIP.IPAddress.Contains($IPAddress))
        {
            Write-Verbose -Message "IPAddress not correct. Expected $IPAddress, actual $($currentIP.IPAddress)"
            $Parameters = @{}

            #Apply is true in the case of set - target resource - in which case, it will set the new IP Address
            if($Apply)
            {
                Write-Verbose -Message "Setting IPAddress ..."
                $Parameters["IPAddress"] = $IPAddress
                $Parameters["PrefixLength"] = $SubnetMask
                $Parameters["InterfaceAlias"] = $currentIP[0].InterfaceAlias

                if($DefaultGateway){ $Parameters["DefaultGateWay"] = $DefaultGateway }
                $null = New-NetIPAddress @Parameters -ErrorAction Stop

                # Make the connection profile private
                Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue
                Write-Verbose -Message "IPAddress is set to $IPAddress."
            }
            else {return $false}
        }
        else
        {
            Write-Verbose -Message "IPAddress is correct."
            return $true
        }
    }
    catch
    {
       Write-Verbose -Message $_
       throw "Can not set or find valid IPAddress using InterfaceAlias $InterfaceAlias and AddressFamily $AddressFamily"
    }
}



#  FUNCTIONS TO BE EXPORTED 
Export-ModuleMember -function Get-TargetResource, Set-TargetResource, Test-TargetResource