function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Account,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("ReadAndExecute", "Modify", "FullControl")]
        [System.Security.AccessControl.FileSystemRights]$Rights = "ReadAndExecute",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [ValidateNotNullOrEmpty()]
        [String]$Ensure = "Present",
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Allow", "Deny")]
        [System.Security.AccessControl.AccessControlType]$Access = "Allow",

        [Parameter(Mandatory = $false)]
        [Bool]$Inherit = $false,

        [Parameter(Mandatory = $false)]
        [Bool]$Recurse = $false,

        [Parameter(Mandatory = $false)]
        [System.Boolean]$Strict = $false
    )

    $desiredRule = GetDesiredRule -Path $Path -Account $Account -Rights $Rights -Access $Access -Inherit $Inherit -Recurse $Recurse
    $currentACL = (Get-Item $Path).GetAccessControl("Access")
    $currentRules = $currentACL.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
    $match = IsDesiredRuleAndCurrentRuleSame -DesiredRule $desiredRule -CurrentRules $currentRules -Strict $Strict

    if ($Ensure -eq "Present")
    {
        $CurrentACL.AddAccessRule($DesiredRule)
        $CurrentACL | Set-Acl -Path $Path 
    }
    elseif ($Ensure -eq "Absent")
    {
        $CurrentACL.RemoveAccessRule($DesiredRule) > $null
        $CurrentACL | Set-Acl -Path $Path 
    }
}


function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Account,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("ReadAndExecute", "Modify", "FullControl")]
        [System.Security.AccessControl.FileSystemRights]$Rights = "ReadAndExecute",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [ValidateNotNullOrEmpty()]
        [String]$Ensure = "Present",
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Allow", "Deny")]
        [System.Security.AccessControl.AccessControlType]$Access = "Allow",

        [Parameter(Mandatory = $false)]
        [Bool]$Inherit = $false,

        [Parameter(Mandatory = $false)]
        [Bool]$Recurse = $false,

        [Parameter(Mandatory = $false)]
        [System.Boolean]$Strict = $false
    )

    $desiredRule = GetDesiredRule -Path $Path -Account $Account -Rights $Rights -Access $Access -Inherit $Inherit -Recurse $Recurse
    $currentACL = (Get-Item $Path).GetAccessControl("Access")
    $currentRules = $currentACL.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
    $match = IsDesiredRuleAndCurrentRuleSame -DesiredRule $desiredRule -CurrentRules $currentRules -Strict $Strict
    
    $presence = if ($true -eq $match)
    {
        "Present"
    }
    else
    {
        "Absent"
    }

    return @{
        Ensure    = $presence
        Path      = $Path
        Account   = $Account
        Rights    = $Rights
        Access    = $Access
        Inherit   = $Inherit
        Recurse   = $Recurse
        Strict    = $Strict
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Account,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("ReadAndExecute", "Modify", "FullControl")]
        [System.Security.AccessControl.FileSystemRights]$Rights = "ReadAndExecute",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [ValidateNotNullOrEmpty()]
        [String]$Ensure = "Present",
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Allow", "Deny")]
        [System.Security.AccessControl.AccessControlType]$Access = "Allow",

        [Parameter(Mandatory = $false)]
        [Bool]$Inherit = $false,

        [Parameter(Mandatory = $false)]
        [Bool]$Recurse = $false,

        [Parameter(Mandatory = $false)]
        [System.Boolean]$Strict = $false
    )

    $desiredRule = GetDesiredRule -Path $Path -Account $Account -Rights $Rights -Access $Access -Inherit $Inherit -Recurse $Recurse
    $currentACL = (Get-Item $Path).GetAccessControl("Access")
    $currentRules = $currentACL.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
    $match = IsDesiredRuleAndCurrentRuleSame -DesiredRule $desiredRule -CurrentRules $currentRules -Strict $Strict
    
    $presence = if ($true -eq $match)
    {
        "Present"
    }
    else
    {
        "Absent"
    }
    return $presence -eq $Ensure
}

function GetDesiredRule
{
    [OutputType([System.Security.AccessControl.FileSystemAccessRule])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Account,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("ReadAndExecute", "Modify", "FullControl")]
        [System.Security.AccessControl.FileSystemRights]$Rights = "ReadAndExecute",

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Allow", "Deny")]
        [System.Security.AccessControl.AccessControlType]$Access = "Allow",

        [Parameter(Mandatory = $false)]
        [Bool]$Inherit = $false,

        [Parameter(Mandatory = $false)]
        [Bool]$Recurse = $false
    )

    $InheritFlag = if ($Inherit)
    {
        "{0}, {1}" -f [System.Security.AccessControl.InheritanceFlags]::ContainerInherit, [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    }
    elseif ($Recurse)
    {
        "{0}, {1}" -f [System.Security.AccessControl.InheritanceFlags]::ContainerInherit, [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    }
    else
    {
        [System.Security.AccessControl.InheritanceFlags]::None
    }

    $desiredRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Account, $Rights, $InheritFlag, "None", $Access)
    return $desiredRule
}

function IsDesiredRuleAndCurrentRuleSame
{
    [OutputType([Bool])]
    [CmdletBinding()]
    param
    (
        [System.Security.AccessControl.FileSystemAccessRule]$DesiredRule,
        [System.Security.AccessControl.AuthorizationRuleCollection]$CurrentRules,
        [bool]$Strict
    )

    $match = if ($Strict)
    {
        Write-Verbose "Using strict name checking. It does not split AccountName with \''."
        $currentRules `
        | where {$_.IdentityReference.Value -eq $DesiredRule.IdentityReference.Value} `
        | where FileSystemRights -eq $DesiredRule.FileSystemRights `
        | where AccessControlType -eq $DesiredRule.AccessControlType `
        | where Inherit -eq $_.InheritanceFlags `
        | measure
    }
    else
    {
        Write-Verbose "Using non-strict name checking. It split AccountName with \''."
        $currentRules `
        | where {$_.IdentityReference.Value.Split("\")[1] -eq $DesiredRule.IdentityReference.Value} `
        | where FileSystemRights -eq $DesiredRule.FileSystemRights `
        | where AccessControlType -eq $DesiredRule.AccessControlType `
        | where Inherit -eq $_.InheritanceFlags `
        | measure
    }

    if ($match.Count -eq 0)
    {
        Write-Verbose "Current ACL result."
        Write-Verbose ($CurrentRules | Format-List | Out-String)

        Write-Verbose "Desired ACL result."
        Write-Verbose ($DesiredRule | Format-List | Out-String)

        Write-Verbose "Result does not match as desired. Showing Desired v.s. Current Status."
        [PSCustomObject]@{
            DesiredRuleIdentity = $DesiredRule.IdentityReference.Value
            CurrentRuleIdentity = $currentRules.IdentityReference.Value
            StrictCurrentRuleIdentity = $currentRules.IdentityReference.Value.Split("\")[1]
            StrictResult = ($currentRules | where {$_.IdentityReference.Value -eq $DesiredRule.IdentityReference.Value} | measure).Count -ne 0
            NoneStrictResult = ($currentRules | where {$_.IdentityReference.Value.Split("\")[1] -eq $DesiredRule.IdentityReference.Value} | measure).Count -ne 0
        } | Format-List | Out-String -Stream | Write-Verbose

        [PSCustomObject]@{
            DesiredFileSystemRights = $DesiredRule.FileSystemRights
            CurrentFileSystemRights = $currentRules.FileSystemRights
            StrictResult = ($currentRules | where {$_.IdentityReference.Value -eq $DesiredRule.IdentityReference.Value} | where FileSystemRights -eq $DesiredRule.FileSystemRights | measure).Count -ne 0
            NoneStrictResult = ($currentRules | where {$_.IdentityReference.Value.Split("\")[1] -eq $DesiredRule.IdentityReference.Value} | where FileSystemRights -eq $DesiredRule.FileSystemRights | measure).Count -ne 0
        } | Format-List | Out-String -Stream | Write-Verbose

        [PSCustomObject]@{
            DesiredAccessControlType = $DesiredRule.AccessControlType
            CurrentAccessControlType = $currentRules.AccessControlType
            StrictResult = ($currentRules | where {$_.IdentityReference.Value -eq $DesiredRule.IdentityReference.Value} | where FileSystemRights -eq $DesiredRule.FileSystemRights | where AccessControlType -eq $DesiredRule.AccessControlType | measure).Count -ne 0
            NoneStrictResult = ($currentRules | where {$_.IdentityReference.Value.Split("\")[1] -eq $DesiredRule.IdentityReference.Value} | where FileSystemRights -eq $DesiredRule.FileSystemRights | where AccessControlType -eq $DesiredRule.AccessControlType | measure).Count -ne 0
        } | Format-List | Out-String -Stream | Write-Verbose

        [PSCustomObject]@{
            DesiredInherit = $DesiredRule.Inherit
            CurrentInherit = $currentRules.Inherit
            StrictResult = ($currentRules | where {$_.IdentityReference.Value -eq $DesiredRule.IdentityReference.Value} | where FileSystemRights -eq $DesiredRule.FileSystemRights | where AccessControlType -eq $DesiredRule.AccessControlType | where Inherit -eq $DesiredRule.Inherit | measure).Count -ne 0
            NoneStrictResult = ($currentRules | where {$_.IdentityReference.Value.Split("\")[1] -eq $DesiredRule.IdentityReference.Value} | where FileSystemRights -eq $DesiredRule.FileSystemRights | where AccessControlType -eq $DesiredRule.AccessControlType | where Inherit -eq $DesiredRule.Inherit | measure).Count -ne 0
        } | Format-List | Out-String -Stream | Write-Verbose
    }

    return $match.Count -ge 1
}

Export-ModuleMember -Function *-TargetResource