function Get-TargetResource
{
    [CmdletBinding()] 
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,   
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure='Present',
        [parameter(Mandatory = $false)]
        [UInt32]
        $Priority,
        [parameter(Mandatory = $false)]
        [PSCredential]
        $Credentials,
        [parameter(Mandatory = $false)]
        [System.String]
        $Source
    )

    Write-Verbose "Start Get-TargetResource"

    #Needs to return a hashtable that returns the current
    #status of the configuration component
    $Configuration = @{
        Name = $Name
        Priority = $Priority
        Source = $Source
    }

    return $Configuration
}

function Set-TargetResource
{
    [CmdletBinding()]    
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,   
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure='Present',
        [parameter(Mandatory = $false)]
        [UInt32]
        $Priority,
        [parameter(Mandatory = $false)]
        [PSCredential]
        $Credentials,
        [parameter(Mandatory = $false)]
        [System.String]
        $Source
    )
    Write-Verbose "Start Set-TargetResource"

	if($Ensure -eq "Present")
	{
		if($Credentials -eq $null)
		{
			if($priority -eq $null)
			{
				choco sources add -n"$name" -s"$source"
			}
			else
			{
				choco sources add -n"$name" -s"$source" --priority=$priority
			}
		}
		else
		{
			$username = $Credentials.UserName
			$password = $Credentials.GetNetworkCredential().Password
			
			if($priority -eq $null)
			{
				choco sources add -n"$name" -s"$source" -u="$username" -p="$password"
			}
			else
			{
				choco sources add -n"$name" -s"$source" -u="$username" -p="$password" --priority=$priority
			}
		}
	}
	else
	{
		choco sources remove -n"$name"
	}
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,   
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure='Present',
        [parameter(Mandatory = $false)]
        [UInt32]
        $Priority,
        [parameter(Mandatory = $false)]
        [PSCredential]
        $Credentials,
        [parameter(Mandatory = $false)]
        [System.String]
        $Source
    )

    Write-Verbose "Start Test-TargetResource"
	
	if($env:ChocolateyInstall -eq "" -or $env:ChocolateyInstall -eq $null)
	{	
		$exe = (get-command choco).Source
		$chocofolder = $exe.Substring(0,$exe.LastIndexOf("\"))

		if( $chocofolder.EndsWith("bin") )
		{
			$chocofolder = $chocofolder.Substring(0,$chocofolder.LastIndexOf("\"))
		}
	}
	else
	{
		$chocofolder = $env:ChocolateyInstall
	}
	$configfolder = "$chocofolder\config"
	$configfile = Get-ChildItem $configfolder | Where-Object {$_.Name -match "chocolatey.config"}

	$xml = [xml](Get-Content $configfile.FullName)
	$sources = $xml.chocolatey.sources.source

	foreach($chocosource in $sources)
	{
		if($chocosource.id -eq $name -and $ensure -eq 'Present')
		{		
			return $true
		}
		elseif($chocosource.id -eq $name -and $ensure -eq 'Absent')
		{
			return $false
		}
	}
	
	if($Ensure -eq 'Present')
	{
		return $false
	}
	else
	{
		return $true
	}
}


Export-ModuleMember -Function *-TargetResource
