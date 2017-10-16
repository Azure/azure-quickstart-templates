#
# xComputer: DSC resource to rename a computer and add it to a domain or
# workgroup.
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [string] $DomainName,

        [PSCredential] $Credential,

        [PSCredential] $UnjoinCredential,

        [string] $WorkGroupName
    )

    $convertToCimCredential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$Credential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
    $convertToCimUnjoinCredential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$UnjoinCredential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly

    $returnValue = @{
        Name = $env:COMPUTERNAME
        DomainName = GetComputerDomain
        Credential = [ciminstance]$convertToCimCredential
        UnjoinCredential = [ciminstance]$convertToCimUnjoinCredential
        WorkGroupName= (gwmi WIN32_ComputerSystem).WorkGroup
    }

    $returnValue
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,
    
        [string] $DomainName,
        
        [PSCredential] $Credential,

        [PSCredential] $UnjoinCredential,

        [string] $WorkGroupName
    )

    ValidateDomainOrWorkGroup -DomainName $DomainName -WorkGroupName $WorkGroupName

    if ($Credential)
    {
        if ($DomainName)
        {
            if ($DomainName -eq (GetComputerDomain))
            {
                # Rename the computer, but stay joined to the domain.
                Rename-Computer -NewName $Name -DomainCredential $Credential -Force
                Write-Verbose -Message "Renamed computer to '$($Name)'."
            }
            else
            {
                if ($Name -ne $env:COMPUTERNAME)
                {
                    # Rename the comptuer, and join it to the domain.
                    if ($UnjoinCredential)
                    {
                        Add-Computer -DomainName $DomainName -Credential $Credential -NewName $Name -UnjoinDomainCredential $UnjoinCredential -Force
                    }
                    else
                    {
                        Add-Computer -DomainName $DomainName -Credential $Credential -NewName $Name -Force
                    }
                    Write-Verbose -Message "Renamed computer to '$($Name)' and added to the domain '$($DomainName)."
                }
                else
                {
                    # Same computer name, and join it to the domain.
                    if ($UnjoinCredential)
                    {
                        Add-Computer -DomainName $DomainName -Credential $Credential -UnjoinDomainCredential $UnjoinCredential -Force
                    }
                    else
                    {
                        Add-Computer -DomainName $DomainName -Credential $Credential -Force
                    }
                    Write-Verbose -Message "Added computer to domain '$($DomainName)."
                }
            }
        }
        elseif ($WorkGroupName)
        {
            if($WorkGroupName -eq (gwmi win32_computersystem).WorkGroup)
            {
                # Rename the comptuer, but stay in the same workgroup.
                Rename-Computer -NewName $Name
                Write-Verbose -Message "Renamed computer to '$($Name)'."
            }
            else
            {
                if ($Name -ne $env:COMPUTERNAME)
                {
                    # Rename the computer, and join it to the workgroup.
                    Add-Computer -NewName $Name -Credential $Credential -WorkgroupName $WorkGroupName -Force
                    Write-Verbose -Message "Renamed computer to '$($Name)' and addded to workgroup '$($WorkGroupName)'."
                }
                else
                {
                    # Same computer name, and join it to the workgroup.
                    Add-Computer -WorkGroupName $WorkGroupName -Credential $Credential -Force
                    Write-Verbose -Message "Added computer to workgroup '$($WorkGroupName)'."
                }
            }
        }
        elseif($Name -ne $env:COMPUTERNAME)
        {
            if (GetComputerDomain)
            {
                Rename-Computer -NewName $Name -DomainCredential $Credential -Force
                Write-Verbose -Message "Renamed computer to '$($Name)'."
            }
            else
            {
                Rename-Computer -NewName $Name -Force
                Write-Verbose -Message "Renamed computer to '$($Name)'."
            }
        }
    }
    else
    {
        if ($DomainName)
        {
            throw "Missing domain join credentials."
        }
        if ($WorkGroupName)
        {
            
            if ($WorkGroupName -eq (Get-WmiObject win32_computersystem).Workgroup)
            {
                # Same workgroup, new computer name
                Rename-Computer -NewName $Name -force
                Write-Verbose -Message "Renamed computer to '$($Name)'."
            }
            else
            {
                if ($name -ne $env:COMPUTERNAME)
                {
                    # New workgroup, new computer name
                    Add-Computer -WorkgroupName $WorkGroupName -NewName $Name
                    Write-Verbose -Message "Renamed computer to '$($Name)' and added to workgroup '$($WorkGroupName)'."
                }
                else
                {
                    # New workgroup, same computer name
                    Add-Computer -WorkgroupName $WorkGroupName
                    Write-Verbose -Message "Added computer to workgroup '$($WorkGroupName)'."
                }
            }
        }
        else
        {
            if ($Name -ne $env:COMPUTERNAME)
            {
                Rename-Computer -NewName $Name
                Write-Verbose -Message "Renamed computer to '$($Name)'."
            }
        }
    }

    $global:DSCMachineStatus = 1
}

function Test-TargetResource
{
	[OutputType([System.Boolean])]
	[CmdletBinding()]
	param
	(
        [parameter(Mandatory)]
        [string] $Name,
        
        [PSCredential]$Credential,

        [PSCredential]$UnjoinCredential,
        
        [string] $DomainName,

	    [string] $WorkGroupName
	)
    
    Write-Verbose -Message "Checking if computer name is $Name"
    if ($Name -ne $env:COMPUTERNAME) {return $false}

    ValidateDomainOrWorkGroup -DomainName $DomainName -WorkGroupName $WorkGroupName

    if($DomainName)
    {
        if(!($Credential))
        {
            throw "Need to specify credentials with domain"
        }
        
        try
        {
            Write-Verbose "Checking if the machine is a member of $DomainName."
            return ($DomainName.ToLower() -eq (GetComputerDomain).ToLower())
        }
        catch
        {
           Write-Verbose 'The machine is not a domain member.'
           return $false
        }
    }
    elseif($WorkGroupName)
    {
        Write-Verbose -Message "Checking if workgroup name is $WorkGroupName"
        return ($WorkGroupName -eq (gwmi WIN32_ComputerSystem).WorkGroup)
    }
}

function ValidateDomainOrWorkGroup($DomainName, $WorkGroupName)
{
    if ($DomainName -and $WorkGroupName)
    {
        throw "Only DomainName or WorkGroupName can be specified at once."
    }
}

function GetComputerDomain
{
  try
    {
        return ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name
    }
    catch [System.Management.Automation.MethodInvocationException]
    {
        Write-Debug 'This machine is not a domain member.'
    }
}

Export-ModuleMember -Function *-TargetResource
