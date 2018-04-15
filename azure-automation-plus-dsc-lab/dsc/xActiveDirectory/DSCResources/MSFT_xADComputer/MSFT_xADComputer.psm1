$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $culture = $PSUICulture
}
$importLocalizedDataParams = @{
    BindingVariable = 'LocalizedData'
    Filename = 'MSFT_xADComputer.psd1'
    BaseDirectory = $moduleRoot
    UICulture = $culture
}
Import-LocalizedData @importLocalizedDataParams
#endregion

## Create a property map that maps the DSC resource parameters to the
## Active Directory computer attributes.
$adPropertyMap = @(
    @{ Parameter = 'ComputerName'; ADProperty = 'cn'; }
    @{ Parameter = 'Location'; }
    @{ Parameter = 'DnsHostName'; }
    @{ Parameter = 'ServicePrincipalNames'; }
    @{ Parameter = 'UserPrincipalName'; }
    @{ Parameter = 'DisplayName'; }
    @{ Parameter = 'Path'; ADProperty = 'distinguishedName'; }
    @{ Parameter = 'Description'; }
    @{ Parameter = 'Enabled'; }
    @{ Parameter = 'Manager'; ADProperty = 'managedBy'; }
)


function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        # Common Name
        [Parameter(Mandatory)]
        [System.String] $ComputerName,

        [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present',

        [ValidateNotNull()]
        [System.String] $UserPrincipalName,

        [ValidateNotNull()]
        [System.String] $DisplayName,

        [ValidateNotNull()]
        [System.String] $Path,

        [ValidateNotNull()]
        [System.String] $Location,

        [ValidateNotNull()]
        [System.String] $DnsHostName,

        [ValidateNotNull()]
        [System.String[]] $ServicePrincipalNames,

        [ValidateNotNull()]
        [System.String] $Description,

        ## Computer's manager specified as a Distinguished Name (DN)
        [ValidateNotNull()]
        [System.String] $Manager,

        [ValidateNotNull()]
        [System.String] $RequestFile,

        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        [ValidateNotNull()]
        [System.String] $DomainController,

        ## Ideally this should just be called 'Credential' but is here for consistency with xADUser
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $DomainAdministratorCredential
    )

    Assert-Module -ModuleName 'ActiveDirectory';
    Import-Module -Name 'ActiveDirectory' -Verbose:$false;

    try
    {
        $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;

        $adProperties = @();
        ## Create an array of the AD property names to retrieve from the property map
        foreach ($property in $adPropertyMap)
        {

            if ($property.ADProperty)
            {
                $adProperties += $property.ADProperty;
            }
            else
            {
                $adProperties += $property.Parameter;
            }
        }

        Write-Verbose -Message ($LocalizedData.RetrievingADComputer -f $ComputerName);
        $adComputer = Get-ADComputer @adCommonParameters -Properties $adProperties;
        Write-Verbose -Message ($LocalizedData.ADComputerIsPresent -f $ComputerName);
        $Ensure = 'Present';
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        Write-Verbose -Message ($LocalizedData.ADComputerNotPresent -f $ComputerName);
        $Ensure = 'Absent';
    }
    catch
    {
        Write-Error -Message ($LocalizedData.RetrievingADComputerError -f $ComputerName);
        throw $_;
    }

    $targetResource = @{
        ComputerName      = $ComputerName;
        DistinguishedName = $adComputer.DistinguishedName; ## Read-only property
        SID               = $adComputer.SID; ## Read-only property
        Ensure            = $Ensure;
        DomainController  = $DomainController;
        RequestFile    = $RequestFile;
    }

    ## Retrieve each property from the ADPropertyMap and add to the hashtable
    foreach ($property in $adPropertyMap)
    {
        $propertyName = $property.Parameter;
        if ($propertyName -eq 'Path') {
            ## The path returned is not the parent container
            if (-not [System.String]::IsNullOrEmpty($adComputer.DistinguishedName))
            {
                $targetResource['Path'] = Get-ADObjectParentDN -DN $adComputer.DistinguishedName;
            }
        }
        elseif ($property.ADProperty)
        {
            ## The AD property name is different to the function parameter to use this
            $targetResource[$propertyName] = $adComputer.($property.ADProperty);
        }
        else
        {
            ## The AD property name matches the function parameter
            if ($adComputer.$propertyName -is [Microsoft.ActiveDirectory.Management.ADPropertyValueCollection])
            {
                $targetResource[$propertyName] = $adComputer.$propertyName -as [System.String[]];
            }
            else
            {
                $targetResource[$propertyName] = $adComputer.$propertyName;
            }
        }
    }
    return $targetResource;

} #end function Get-TargetResource


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        # Common Name
        [Parameter(Mandatory)]
        [System.String] $ComputerName,

        [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present',

        [ValidateNotNull()]
        [System.String] $UserPrincipalName,

        [ValidateNotNull()]
        [System.String] $DisplayName,

        [ValidateNotNull()]
        [System.String] $Path,

        [ValidateNotNull()]
        [System.String] $Location,

        [ValidateNotNull()]
        [System.String] $DnsHostName,

        [ValidateNotNull()]
        [System.String[]] $ServicePrincipalNames,

        [ValidateNotNull()]
        [System.String] $Description,

        ## Computer's manager specified as a Distinguished Name (DN)
        [ValidateNotNull()]
        [System.String] $Manager,

        [ValidateNotNull()]
        [System.String] $RequestFile,

        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        [ValidateNotNull()]
        [System.String] $DomainController,

        ## Ideally this should just be called 'Credential' but is here for backwards compatibility
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $DomainAdministratorCredential
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $isCompliant = $true;

    if ($Ensure -eq 'Absent')
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            Write-Verbose -Message ($LocalizedData.ADComputerNotDesiredPropertyState -f `
                                    'Ensure', $PSBoundParameters.Ensure, $targetResource.Ensure);
            $isCompliant = $false;
        }
    }
    else
    {
        ## Add ensure and enabled as they may not be explicitly passed and we want to enumerate them
        $PSBoundParameters['Ensure'] = $Ensure;
        $PSBoundParameters['Enabled'] = $Enabled;

        foreach ($parameter in $PSBoundParameters.Keys)
        {
            if ($targetResource.ContainsKey($parameter))
            {
                ## This check is required to be able to explicitly remove values with an empty string, if required
                if (([System.String]::IsNullOrEmpty($PSBoundParameters.$parameter)) -and
                    ([System.String]::IsNullOrEmpty($targetResource.$parameter)))
                {
                    # Both values are null/empty and therefore we are compliant
                }
                elseif ($parameter -eq 'ServicePrincipalNames')
                {
                    $testMembersParams = @{
                        ExistingMembers = $targetResource.ServicePrincipalNames -as [System.String[]];
                        Members = $ServicePrincipalNames;
                    }
                    if (-not (Test-Members @testMembersParams))
                    {
                        $existingSPNs = $testMembersParams['ExistingMembers'] -join ',';
                        $desiredSPNs = $ServicePrincipalNames -join ',';
                        Write-Verbose -Message ($LocalizedData.ADComputerNotDesiredPropertyState -f `
                                                'ServicePrincipalNames', $desiredSPNs, $existingSPNs);
                        $isCompliant = $false;
                    }
                }
                elseif ($PSBoundParameters.$parameter -ne $targetResource.$parameter)
                {
                    Write-Verbose -Message ($LocalizedData.ADComputerNotDesiredPropertyState -f `
                                            $parameter, $PSBoundParameters.$parameter, $targetResource.$parameter);
                    $isCompliant = $false;
                }
            }
        } #end foreach PSBoundParameter
    }

    if ($isCompliant)
    {
        Write-Verbose -Message ($LocalizedData.ADComputerInDesiredState -f $ComputerName)
        return $true
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ADComputerNotInDesiredState -f $ComputerName)
        return $false
    }

} #end function Test-TargetResource


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        # Common Name
        [Parameter(Mandatory)]
        [System.String] $ComputerName,

        [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present',

        [ValidateNotNull()]
        [System.String] $UserPrincipalName,

        [ValidateNotNull()]
        [System.String] $DisplayName,

        [ValidateNotNull()]
        [System.String] $Path,

        [ValidateNotNull()]
        [System.String] $Location,

        [ValidateNotNull()]
        [System.String] $DnsHostName,

        [ValidateNotNull()]
        [System.String[]] $ServicePrincipalNames,

        [ValidateNotNull()]
        [System.String] $Description,

        ## Computer's manager specified as a Distinguished Name (DN)
        [ValidateNotNull()]
        [System.String] $Manager,

        [ValidateNotNull()]
        [System.String] $RequestFile,

        [ValidateNotNull()]
        [System.Boolean] $Enabled = $true,

        [ValidateNotNull()]
        [System.String] $DomainController,

        ## Ideally this should just be called 'Credential' but is here for backwards compatibility
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $DomainAdministratorCredential
    )

    $targetResource = Get-TargetResource @PSBoundParameters;

    ## Add ensure and enabled as they may not be explicitly passed and we want to enumerate them
    $PSBoundParameters['Ensure'] = $Ensure;
    $PSBoundParameters['Enabled'] = $Enabled;

    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Absent') {
            ## Computer does not exist and needs creating
            if ($RequestFile)
            {
                ## Use DJOIN to create the computer account as well as the ODJ Request file.
                Write-Verbose -Message ($LocalizedData.ODJRequestStartMessage -f `
                        $DomainName,$ComputerName,$RequestFile)

                # This should only be performed on a Domain Member, so detect the Domain Name.
                $DomainName = Get-DomainName
                $DJoinParameters = @(
                    '/PROVISION'
                    '/DOMAIN',$DomainName
                    '/MACHINE',$ComputerName )
                if ($PSBoundParameters.ContainsKey('Path'))
                {
                    $DJoinParameters += @( '/MACHINEOU',$Path )
                } # if

                if ($PSBoundParameters.ContainsKey('DomainController'))
                {
                    $DJoinParameters += @( '/DCNAME',$DomainController )
                } # if

                $DJoinParameters += @( '/SAVEFILE',$RequestFile )
                $Result = & djoin.exe @DjoinParameters

                if ($LASTEXITCODE -ne 0)
                {
                    $errorId = 'ODJRequestError'
                    $errorMessage = $($LocalizedData.ODJRequestError `
                        -f $LASTEXITCODE,$Result)
                    ThrowInvalidOperationError -ErrorId $errorId -ErrorMessage $errorMessage
                } # if

                Write-Verbose -Message ($LocalizedData.ODJRequestCompleteMessage -f `
                        $DomainName,$ComputerName,$RequestFile)
            }
            else
            {
                ## Create the computer account using New-ADComputer
                $newADComputerParams = Get-ADCommonParameters @PSBoundParameters -UseNameParameter;
                if ($PSBoundParameters.ContainsKey('Path'))
                {
                    Write-Verbose -Message ($LocalizedData.UpdatingADComputerProperty -f 'Path', $Path);
                    $newADComputerParams['Path'] = $Path;
                }
                Write-Verbose -Message ($LocalizedData.AddingADComputer -f $ComputerName);
                New-ADComputer @newADComputerParams;
            } # if
            ## Now retrieve the newly created computer
            $targetResource = Get-TargetResource @PSBoundParameters;
        }

        $setADComputerParams = Get-ADCommonParameters @PSBoundParameters;
        $replaceComputerProperties = @{};
        $removeComputerProperties = @{};
        foreach ($parameter in $PSBoundParameters.Keys)
        {
            ## Only check/action properties specified/declared parameters that match one of the function's
            ## parameters. This will ignore common parameters such as -Verbose etc.
            if ($targetResource.ContainsKey($parameter))
            {
                if ($parameter -eq 'Path' -and ($PSBoundParameters.Path -ne $targetResource.Path))
                {
                    ## Cannot move computers by updating the DistinguishedName property
                    $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;
                    ## Using the SamAccountName for identity with Move-ADObject does not work, use the DN instead
                    $adCommonParameters['Identity'] = $targetResource.DistinguishedName;
                    Write-Verbose -Message ($LocalizedData.MovingADComputer -f `
                                            $targetResource.Path, $PSBoundParameters.Path);
                    Move-ADObject @adCommonParameters -TargetPath $PSBoundParameters.Path;
                }
                elseif ($parameter -eq 'ServicePrincipalNames')
                {
                    Write-Verbose -Message ($LocalizedData.UpdatingADComputerProperty -f `
                                            'ServicePrincipalNames', ($ServicePrincipalNames -join ','));
                    $replaceComputerProperties['ServicePrincipalName'] = $ServicePrincipalNames;
                }
                elseif ($parameter -eq 'Enabled' -and ($PSBoundParameters.$parameter -ne $targetResource.$parameter))
                {
                    ## We cannot enable/disable an account with -Add or -Replace parameters, but inform that
                    ## we will change this as it is out of compliance (it always gets set anyway)
                    Write-Verbose -Message ($LocalizedData.UpdatingADComputerProperty -f `
                                            $parameter, $PSBoundParameters.$parameter);
                }
                elseif ($PSBoundParameters.$parameter -ne $targetResource.$parameter)
                {
                    ## Find the associated AD property
                    $adProperty = $adPropertyMap | Where-Object { $_.Parameter -eq $parameter };

                    if ([System.String]::IsNullOrEmpty($adProperty))
                    {
                        ## We can't do anything with an empty AD property!
                    }
                    elseif ([System.String]::IsNullOrEmpty($PSBoundParameters.$parameter))
                    {
                        ## We are removing properties
                        ## Only remove if the existing value in not null or empty
                        if (-not ([System.String]::IsNullOrEmpty($targetResource.$parameter)))
                        {
                            Write-Verbose -Message ($LocalizedData.RemovingADComputerProperty -f `
                                                    $parameter, $PSBoundParameters.$parameter);
                            if ($adProperty.UseCmdletParameter -eq $true)
                            {
                                ## We need to pass the parameter explicitly to Set-ADComputer, not via -Remove
                                $setADComputerParams[$adProperty.Parameter] = $PSBoundParameters.$parameter;
                            }
                            elseif ([System.String]::IsNullOrEmpty($adProperty.ADProperty))
                            {
                                $removeComputerProperties[$adProperty.Parameter] = $targetResource.$parameter;
                            }
                            else
                            {
                                $removeComputerProperties[$adProperty.ADProperty] = $targetResource.$parameter;
                            }
                        }
                    } #end if remove existing value
                    else
                    {
                        ## We are replacing the existing value
                        Write-Verbose -Message ($LocalizedData.UpdatingADComputerProperty -f `
                                                $parameter, $PSBoundParameters.$parameter);
                        if ($adProperty.UseCmdletParameter -eq $true)
                        {
                            ## We need to pass the parameter explicitly to Set-ADComputer, not via -Replace
                            $setADComputerParams[$adProperty.Parameter] = $PSBoundParameters.$parameter;
                        }
                        elseif ([System.String]::IsNullOrEmpty($adProperty.ADProperty))
                        {
                            $replaceComputerProperties[$adProperty.Parameter] = $PSBoundParameters.$parameter;
                        }
                        else
                        {
                            $replaceComputerProperties[$adProperty.ADProperty] = $PSBoundParameters.$parameter;
                        }
                    } #end if replace existing value
                }

            } #end if TargetResource parameter
        } #end foreach PSBoundParameter

        ## Only pass -Remove and/or -Replace if we have something to set/change
        if ($replaceComputerProperties.Count -gt 0)
        {
            $setADComputerParams['Replace'] = $replaceComputerProperties;
        }
        if ($removeComputerProperties.Count -gt 0)
        {
            $setADComputerParams['Remove'] = $removeComputerProperties;
        }

        Write-Verbose -Message ($LocalizedData.UpdatingADComputer -f $ComputerName);
        [ref] $null = Set-ADComputer @setADComputerParams -Enabled $Enabled;
    }
    elseif (($Ensure -eq 'Absent') -and ($targetResource.Ensure -eq 'Present'))
    {
        ## User exists and needs removing
        Write-Verbose ($LocalizedData.RemovingADComputer -f $ComputerName);
        $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;
        [ref] $null = Remove-ADComputer @adCommonParameters -Confirm:$false;
    }

} #end function Set-TargetResource

## Import the common AD functions
$adCommonFunctions = Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.ps1';
. $adCommonFunctions;

Export-ModuleMember -Function *-TargetResource
