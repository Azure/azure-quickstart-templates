#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData `
                         -Filename MSFT_xHostsFile.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData `
                         -Filename MSFT_xHostsFile.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion


function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $HostName,
        
        [Parameter(Mandatory = $false)]
        [System.String]
        $IPAddress,
        
        [Parameter(Mandatory = $false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present"
    )

    Write-Verbose -Message ($LocalizedData.StartingGet -f $HostName)

    $hosts = Get-Content -Path "$env:windir\System32\drivers\etc\hosts"
    $allHosts = $hosts `
           | Where-Object { [System.String]::IsNullOrEmpty($_) -eq $false -and $_.StartsWith('#') -eq $false } `
           | ForEach-Object { 
                $data = $_ -split '\s+'
                if ($data.Length -gt 2) 
                {
                    # Account for host entries that have multiple entries on a single line
                    $result = @()
                    for ($i = 1; $i -lt $data.Length; $i++) 
                    {
                        $result += @{
                            Host = $data[$i]
                            IP = $data[0]
                        }    
                    }
                    return $result
                }
                else 
                {
                    return @{
                        Host = $data[1]
                        IP = $data[0]
                    }    
                }
        } | Select-Object @{ Name="Host"; Expression={$_.Host}}, @{Name="IP"; Expression={$_.IP}}
        
    $hostEntry = $allHosts | Where-Object { $_.Host -eq $HostName }
    
    if ($null -eq $hostEntry) 
    {
        return @{
            HostName = $HostName
            IPAddress = $null
            Ensure = "Absent"
        }
    }
    else 
    {
        return @{
            HostName = $hostEntry.Host
            IPAddress = $hostEntry.IP
            Ensure = "Present"
        }
    }
}

function Set-TargetResource
{
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $HostName,
        
        [Parameter(Mandatory = $false)]
        [System.String]
        $IPAddress,
        
        [Parameter(Mandatory = $false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present"
    )
    
    $currentValues = Get-TargetResource @PSBoundParameters
    
    Write-Verbose -Message ($LocalizedData.StartingSet -f $HostName)

    if ($Ensure -eq "Present" -and $PSBoundParameters.ContainsKey("IPAddress") -eq $false) 
    {
        $errorId = 'IPAddressNotPresentError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.UnableToEnsureWithoutIP) -f $Address,$AddressFamily
        $exception = New-Object -TypeName System.InvalidOperationException `
                                -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                                  -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    
    if ($currentValues.Ensure -eq "Absent" -and $Ensure -eq "Present")
    {
        Write-Verbose -Message ($LocalizedData.CreateNewEntry -f $HostName)
        Add-Content -Path "$env:windir\System32\drivers\etc\hosts" -Value "`r`n$IPAddress`t$HostName"
    }
    else 
    {
        $hosts = Get-Content -Path "$env:windir\System32\drivers\etc\hosts"
        $replace = $hosts | Where-Object { 
            [System.String]::IsNullOrEmpty($_) -eq $false -and $_.StartsWith('#') -eq $false 
        } | Where-Object { $_ -like "*$HostName" }

        $multiLineEntry = $false
        $data = $replace -split '\s+'
        if ($data.Length -gt 2) 
        {
            $multiLineEntry = $true
        }

        if ($currentValues.Ensure -eq "Present" -and $Ensure -eq "Present")
        {
            Write-Verbose -Message ($LocalizedData.UpdateExistingEntry -f $HostName)
            if ($multiLineEntry -eq $true) 
            {
                $newReplaceLine = $replace -replace $HostName, ""
                $hosts = $hosts -replace $replace, $newReplaceLine
                $hosts += "$IPAddress`t$HostName"
            }
            else 
            {
                $hosts = $hosts -replace $replace, "$IPAddress`t$HostName"    
            }
        }
        if ($Ensure -eq "Absent")
        {
            Write-Verbose -Message ($LocalizedData.RemoveEntry -f $HostName)
            if ($multiLineEntry -eq $true) 
            {
                $newReplaceLine = $replace -replace $HostName, ""
                $hosts = $hosts -replace $replace, $newReplaceLine
            }
            else 
            {
                $hosts = $hosts -replace $replace, ""
            }
        }
        $hosts | Set-Content -Path "$env:windir\System32\drivers\etc\hosts"
    }
}

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $HostName,
        
        [Parameter(Mandatory = $false)]
        [System.String]
        $IPAddress,
        
        [Parameter(Mandatory = $false)]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present"
    )
    
    $currentValues = Get-TargetResource @PSBoundParameters
    Write-Verbose -Message ($LocalizedData.StartingTest -f $HostName)
    
    if ($Ensure -ne $currentValues.Ensure) 
    {
        return $false
    }
   
    if ($Ensure -eq "Present" -and $IPAddress -ne $currentValues.IPAddress) 
    {
        return $false
    }
    return $true
}

