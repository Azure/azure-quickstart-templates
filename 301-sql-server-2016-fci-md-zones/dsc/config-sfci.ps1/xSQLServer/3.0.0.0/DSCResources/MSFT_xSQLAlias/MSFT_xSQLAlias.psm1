#
# xSQLAlias: DSC resource to configure Client Aliases part of xSQLServer
#

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName
    )

    $returnValue = @{
        Name = [System.String] $Name
        Protocol = [System.String] ''
        ServerName = [System.String] ''
        TcpPort = [System.UInt16] 0
        PipeName = [System.String] ''
        Ensure = [System.String] 'Absent'
    }

    $protocolTcp = 'DBMSSOCN'
    $protocolNamedPipes = 'DBNMPNTW'

    Write-Verbose "Get the client alias $Name"

    <#
        Get-ItemProperty will either return $null if no value is set, or if value is set, it will always
        return a value in the format 'DBNMPNTW,\\ServerName\PIPE\sql\query' or 'DBMSSOCN,ServerName.company.local,1433'
    #>
    $itemValue = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo' -Name $Name -ErrorAction SilentlyContinue
    if ((Get-WmiOSArchitecture) -eq '64-bit')
    {
        Write-Verbose "64-bit Operating System. Also get the client alias $Name from Wow6432Node"
        
        $isWow6432Node = $true
        $itemValueWow6432Node = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\MSSQLServer\Client\ConnectTo' -Name $Name -ErrorAction SilentlyContinue
    }
    
    if ((-not $isWow6432Node -and $null -ne $itemValue ) -or
            ( ($null -ne $itemValue -and $null -ne $itemValueWow6432Node) -and
            ($isWow6432Node -and $itemValueWow6432Node."$Name" -eq $itemValue."$Name") ))
    {
        $itemConfig = $itemValue."$Name" | ConvertFrom-Csv -Header 'Protocol','ServerName','TcpPort'
        if ($itemConfig)
        {
            if ($itemConfig.Protocol -eq $protocolTcp)
            {
                $returnValue.Ensure = 'Present'
                $returnValue.Protocol = 'TCP'
                $returnValue.ServerName = $itemConfig.ServerName
                $returnValue.TcpPort = $itemConfig.TcpPort
            }
            elseif ($itemConfig.Protocol -eq $protocolNamedPipes)
            {
                $returnValue.Ensure = 'Present'
                $returnValue.Protocol = 'NP'
                $returnValue.PipeName = $itemConfig.ServerName
            }
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [ValidateSet("TCP","NP")]
        [System.String]
        $Protocol = 'TCP',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName,

        [System.UInt16]
        $TcpPort = 1433,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present'
    )

    if ($Protocol -eq 'NP')
    {
        $itemValue = "DBNMPNTW,\\$ServerName\PIPE\sql\query"
    }

    if ($Protocol -eq 'TCP')
    {
        $itemValue = "DBMSSOCN,$ServerName,$TcpPort"
    }

    $registryPath = 'HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo'
    $registryPathWow6432Node = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\MSSQLServer\Client\ConnectTo' 

    if ($Ensure -eq 'Present')
    {
        if ($PSCmdlet.ShouldProcess($Name, 'Setting the client alias'))
        {
            if (!(Test-Path -Path $registryPath))
            {
                New-Item -Path $registryPath | Out-Null
            }

            Set-ItemProperty -Path $registryPath -Name $Name -Value $itemValue | Out-Null
        }

        # If this is a 64-bit OS then also update Wow6432Node
        if ((Get-WmiOSArchitecture) -eq '64-bit')
        {
            if ($PSCmdlet.ShouldProcess($Name, 'Setting the client alias (32-bit)'))
            {
                if (!(Test-Path -Path $registryPathWow6432Node))
                {
                    New-Item -Path $registryPathWow6432Node | Out-Null
                }

                Set-ItemProperty -Path $registryPathWow6432Node -Name $Name -Value $itemValue | Out-Null
            }
        }
    }

    if ($Ensure -eq 'Absent')
    {
        if ($PSCmdlet.ShouldProcess($Name, 'Remove the client alias'))
        {
            if (Test-Path -Path $registryPath)
            {
                Remove-ItemProperty -Path $registryPath -Name $Name
            }
        }
            
        # If this is a 64-bit OS then also remove from Wow6432Node
        if ((Get-WmiOSArchitecture) -eq '64-bit' -and (Test-Path -Path $registryPathWow6432Node))
        {
            if ($PSCmdlet.ShouldProcess($Name, 'Remove the client alias (32-bit)'))
            {
                Remove-ItemProperty -Path $registryPathWow6432Node -Name $Name
            }
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [ValidateSet("TCP","NP")]
        [System.String]
        $Protocol = 'TCP',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerName,

        [System.UInt16]
        $TcpPort = 1433,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present'
    )

    $result = $false

    $currentValues = Get-TargetResource -Name $Name -ServerName $ServerName
    if ($Ensure -eq $currentValues.Ensure)
    {
        if( $Ensure -eq 'Absent' )
        {
            $result = $true
        }
        else {
            Write-Verbose "Ensure is in the desired state. Verifying values."

            if ($Protocol -eq $currentValues.Protocol)
            {
                switch ($Protocol)
                {
                    'NP'
                    {
                        if ($currentValues.PipeName -eq "\\$ServerName\PIPE\sql\query")
                        {
                            $result = $true
                        }
                    }

                    'TCP'
                    {
                        if ($currentValues.ServerName -eq $ServerName -and
                            $currentValues.TcpPort -eq $TcpPort)
                        {
                            $result = $true
                        }
                    }
                }
            }
        }
    }
    
    if ($result) 
    {
        Write-Verbose -Message 'In the desired state'
    }
    else
    {
        Write-Verbose -Message 'Not in the desired state'
    }

    return $result
}

function Get-WmiOSArchitecture
{
    return (Get-WmiObject -Class win32_OperatingSystem).OSArchitecture
}

Export-ModuleMember -Function *-TargetResource
