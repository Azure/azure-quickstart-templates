#region Initialize

function Initialize
{
    # Enum for Ensure
    try
    {
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@
    }
    catch
    {
    }
}

Initialize

#endregion

#region Message Definition

$debugMessage = DATA {
    ConvertFrom-StringData -StringData "
        CheckingPreserveInheritance = Checking acl is inherited. Access : '{0}', AccessControlType : '{1}', IsInherited : '{2}'.
        SettingAcl = Setting ACL to Path '{0}', IsProtected '{1}', PreserveInheritance '{2}'.
    "
}

$verboseMessage = DATA {
    ConvertFrom-StringData -StringData "
        DetectIsProtected = Path detected as Protected, means not inherited from parent.
        DetectIsNotProtected = Path detected as not Protected, means inherited from parent.
        DetectPreserveInheritance = Path detected as PreserveInheritance.
        GetTargetResourceDetectExeption = GetTargetResource detect exception as '{0}'
        ObtainACL = Path '{0}' found. Obtaining ACL.
        PathNotFound = Path '{0}' not found. Skip other checking.
    "
}

$exceptionMessage = DATA {
    ConvertFrom-StringData -StringData "
        PathNotFoundException = Could not found desired path '{0}' exeption!
        NoAccessRuleLeftException = Invalid Operation detected. there are no access left. You must set any not inherit acess before not preserve Inheritance.
    "
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Path,

        [parameter(Mandatory = $true)]
        [System.Boolean]$IsProtected,

        [parameter(Mandatory = $false)]
        [System.Boolean]$PreserveInheritance = $true,

        [parameter(Mandatory = $false)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    # Set Default value
    $isPathExist = $true;
    $returnValue = @{
        Path = $Path;
        IsProtected = $false;
        PreserveInheritance = $true;
    };

    # Path existance Check
    if (!(Test-Path -Path $Path))
    {
        Write-Verbose ($verboseMessage.PathNotFound -f $Path);
        $isPathExist = $false;
    }
    else
    {
        try
        {
            # Obtain current ACL
            Write-Verbose ($verboseMessage.ObtainACL -f $Path);
            $acl = Get-Acl -Path $Path -ErrorAction Stop;            

            # IsProtected Check
            if ($acl.AreAccessRulesProtected)
            {
                Write-Verbose ($verboseMessage.DetectIsProtected);
                $returnValue.IsProtected = $true;

                # Could not detect PreserveInheritanceCheck because this information will lost when Protected.
                $returnValue.PreserveInheritance = $PreserveInheritance;
            }
            else
            {
                Write-Verbose ($verboseMessage.DetectIsNotProtected);
                $returnValue.IsProtected = $false;

                # PreserveInheritanceCheck
                foreach ($access in $acl.Access)
                {
                    Write-Debug ($debugMessage.CheckingPreserveInheritance -f $access.IdentityReference, $access.AccessControlType, $access.IsInherited);
                    $isInherited = $access.IsInherited;
                    if ($isInherited)
                    {
                        Write-Verbose ($verboseMessage.DetectPreserveInheritance);
                        $returnValue.PreserveInheritance = $true;
                        break; # break is fine when any access was detected inherited.
                    }
                }
            }
        }
        catch
        {
            Write-Verbose ($verboseMessage.GetTargetResourceDetectExeption -f $_);

        }
    }

    # Ensure Check (Not path detected => Ensure = "Absent")
    if ($isPathExist -and ($IsProtected -eq $returnValue.IsProtected) -and ($PreserveInheritance -eq $returnValue.PreserveInheritance))
    {
        $returnValue.Ensure = [EnsureType]::Present.ToString();
    }
    else
    {
        $returnValue.Ensure = [EnsureType]::Absent.ToString();
    }

    return $returnValue;
}


function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Path,

        [parameter(Mandatory = $true)]
        [System.Boolean]$IsProtected,

        [parameter(Mandatory = $false)]
        [System.Boolean]$PreserveInheritance = $true,

        [parameter(Mandatory = $false)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    # Path existance Check
    if (!(Test-Path -Path $Path))
    {
        throw New-Object System.IO.FileNotFoundException ($exceptionMessage.PathNotFoundException -f $Path)
    }

    # Get current
    $acl = Get-Acl -Path $Path;

    # Modify ACL
    Write-Debug -Message ($debugMessage -f $Path, $IsProtected, $PreserveInheritance);
    $acl.SetAccessRuleProtection($IsProtected, $PreserveInheritance);
    if (($acl.Access | sort).Count -eq 0)
    {
        throw New-Object System.InvalidOperationException ($exceptionMessage.NoAccessRuleLeftException);
    }

    # Write Back to Path
    $acl | Set-Acl -Path $Path
}


function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Path,

        [parameter(Mandatory = $true)]
        [System.Boolean]$IsProtected,

        [parameter(Mandatory = $false)]
        [System.Boolean]$PreserveInheritance = $true,

        [parameter(Mandatory = $false)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    [bool]$result = (Get-TargetResource -Path $Path -IsProtected $IsProtected -PreserveInheritance $PreserveInheritance).Ensure -eq ([EnsureType]::Present.ToString());
    return $result;
}

#endregion

Export-ModuleMember -Function *-TargetResource

