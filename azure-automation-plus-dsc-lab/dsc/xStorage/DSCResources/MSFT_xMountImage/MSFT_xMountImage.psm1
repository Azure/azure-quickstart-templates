function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $ImagePath
    )

    #Validate driveletter has a ":"    
    If($DriveLetter -match "^[A-Za-z][:]$")
    {
        Write-Verbose "DriveLetter validation passed."
    }
    Else
    {
        Throw "DriveLetter did not pass validation.  Ensure DriveLetter contains a letter and a colon."
    }

    #Test for Image mounted. If not mounted mount
    $Image = Get-DiskImage -ImagePath $ImagePath | Get-Volume

    If($Image)
    {
        $EnsureResult = 'Present'
        $Name = $Name
    }
    Else
    {
        $EnsureResult = 'Absent'
        $Name = $null
    }

    $returnValue = @{
        Name = [System.String]$Name
        ImagePath = [System.String]$ImagePath
        DriveLetter = [System.String]$Image.DriveLetter
        Ensure = [System.String]$EnsureResult
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $ImagePath,

        [System.String]
        $DriveLetter,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present'
    )

    #Validate driveletter has a ":"
    If($DriveLetter -match "^[A-Za-z][:]$")
    {
        Write-Verbose "DriveLetter validation passed."
    }
    Else
    {
        Throw "DriveLetter did not pass validation. Ensure DriveLetter contains a letter and a colon."
    }
    #Test for Image mounted. If not mounted mount
    $Image = Get-DiskImage -ImagePath $ImagePath | Get-Volume

    If($Ensure -eq 'Present')
    {
        $Image = Get-DiskImage -ImagePath $ImagePath | Get-Volume
        If(!$Image)
        {
            Write-Verbose "Image is not mounted. Mounting image $ImagePath"
            $Image = Mount-DiskImage -ImagePath $ImagePath -PassThru | Get-Volume
        }

        #Verify drive letter        
        $CimVolume = Get-CimInstance -ClassName Win32_Volume | where {$_.DeviceId -eq $Image.ObjectId}
        If($CimVolume.DriveLetter -ne $DriveLetter)
        {
            Write-Verbose "Drive letter does not match expected value. Expected DriveLetter $DriveLetter Actual DriverLetter $($CimVolume.DriveLetter)"
            Write-Verbose "Changing drive letter to $DriveLetter"            
            Set-CimInstance -InputObject $CimVolume -Property @{DriveLetter = $DriveLetter}
        }
    }
    Else
    {
        Write-Verbose "Dismounting $ImagePath"
        Dismount-DiskImage -ImagePath $ImagePath
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $ImagePath,

        [System.String]
        $DriveLetter,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present'
    )

    #Validate driveletter has a ":"    
    If($DriveLetter -match "^[A-Za-z][:]$")
    {
        Write-Verbose "DriveLetter validation passed."
    }
    Else
    {
        Throw "DriveLetter did not pass validation.  Ensure DriveLetter contains a letter and a colon."
    }

    #Test for Image mounted. If not mounted mount
    $Image = Get-DiskImage -ImagePath $ImagePath | Get-Volume

    If($Ensure -eq 'Present')
    {
        $Image = Get-DiskImage -ImagePath $ImagePath | Get-Volume
        If(!$Image)
        {
            Write-Verbose "Image is not mounted. Mounting image $ImagePath"
            return $false
        }

        #Verify drive letter        
        $CimVolume = Get-CimInstance -ClassName Win32_Volume | where {$_.DeviceId -eq $Image.ObjectId}
        If($CimVolume.DriveLetter -ne $DriveLetter)
        {
            Write-Verbose "Drive letter does not match expected value. Expected DriveLetter $DriveLetter Actual DriverLetter $($CimVolume.DriveLetter)"
            
            return $false
        }
        #If the script made it this far the ISO is mounted and has the desired DriveLetter
        return $true
    }

    If($Ensure -eq 'Absent' -and $Image)
    {
        Write-Verbose "Expect ISO to be dismounted. Actual is mounted with drive letter $($Image.DriveLetter)" 
        return $false       
    }
    Else
    {
        return $true
    }
}


Export-ModuleMember -Function *-TargetResource

