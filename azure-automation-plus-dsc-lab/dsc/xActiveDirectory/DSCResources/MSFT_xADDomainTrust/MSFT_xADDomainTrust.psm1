# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
MissingRoleMessage        = Please ensure that the {0} role is installed 

CheckingTrustMessage      = Checking if Trust between {0} and {1} exists ...
TestTrustMessage          = Trust is {0} between source and target domains and it should be {1} 
RemovingTrustMessage      = Removing trust between {0} and {1} domains ...
DeleteTrustMessage        = Trust between specified domains is now absent                          
AddingTrustMessage        = Adding domain trust between {0} and {1}  ...
SetTrustMessage           = Trust between specified domains is now present

CheckPropertyMessage      = Checking for {0} between domains ...
DesiredPropertyMessage    = {0} between domains is set correctly
NotDesiredPropertyMessage = {0} between domains is not correct. Expected {1}, actual {2}
SetPropertyMessage        = {0} between domains is set
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [String]$SourceDomainName,

        [parameter(Mandatory)]
        [String]$TargetDomainName,

        [parameter(Mandatory)]
        [PSCredential]$TargetDomainAdministratorCredential,

        [parameter(Mandatory)]
        [ValidateSet("External","Forest")]
        [String]$TrustType,

        [parameter(Mandatory)]
        [ValidateSet("Bidirectional","Inbound","Outbound")]
        [String]$TrustDirection,

        [ValidateSet("Present","Absent")]
        [String]$Ensure = 'Present'
    )

#region Input Validation

    # Load the .NET assembly
    try
    {
        Add-type -AssemblyName System.DirectoryServices
    }
    # If not found, means ADDS role is not installed
    catch
    {
        $missingRoleMessage = $($LocalizedData.MissingRoleMessage) -f 'AD-Domain-Services' 
        New-TerminatingError -errorId ActiveDirectoryRoleMissing -errorMessage $missingRoleMessage -errorCategory NotInstalled
    }

#endregion

    try
    {
        switch ($TrustType)
        {
            'External' {$DomainOrForest = 'Domain'}
            'Forest' {$DomainOrForest = 'Forest'}
        }
        # Create the target object
        $trgDirectoryContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext($DomainOrForest,$TargetDomainName, $TargetDomainAdministratorCredential.UserName, $TargetDomainAdministratorCredential.GetNetworkCredential().Password)
        $trgDomain = ([type]"System.DirectoryServices.ActiveDirectory.$DomainOrForest")::"Get$DomainOrForest"($trgDirectoryContext)
        # Create the source object
        $srcDirectoryContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext($DomainOrForest,$SourceDomainName)
        $srcDomain = ([type]"System.DirectoryServices.ActiveDirectory.$DomainOrForest")::"Get$DomainOrForest"($srcDirectoryContext)

        # Find trust betwen source & destination.
        $trust = $srcDomain.GetTrustRelationship($trgDomain)

        $Ensure = 'Present'
    }
    catch
    {
        $Ensure = 'Absent'
    }

    # return a credential object without password
    $CIMCredential = New-CimInstance -ClassName MSFT_Credential -ClientOnly `
                                     -Namespace root/microsoft/windows/desiredstateconfiguration `
                                     -Property @{
                                                  UserName = [string]$TargetDomainAdministratorCredential.UserName
                                                  Password = [string]$null
                                                }

    @{
        SourceDomainName = $SourceDomainName
        TargetDomainName = $TargetDomainName
        Ensure           = $Ensure
        TrustType        = $trust.TrustType
        TrustDirection   = $trust.TrustDirection
        TargetDomainAdministratorCredential = $CIMCredential
    }

}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [String]$SourceDomainName,

        [parameter(Mandatory)]
        [String]$TargetDomainName,

        [parameter(Mandatory)]
        [PSCredential]$TargetDomainAdministratorCredential,

        [parameter(Mandatory)]
        [ValidateSet("External","Forest")]
        [String]$TrustType,

        [parameter(Mandatory)]
        [ValidateSet("Bidirectional","Inbound","Outbound")]
        [String]$TrustDirection,

        [ValidateSet("Present","Absent")]
        [String]$Ensure = 'Present'
    )

    if($PSBoundParameters.ContainsKey('Debug')){$null = $PSBoundParameters.Remove('Debug')}
    Validate-ResourceProperties @PSBoundParameters -Apply
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory)]
        [String]$SourceDomainName,

        [parameter(Mandatory)]
        [String]$TargetDomainName,

        [parameter(Mandatory)]
        [PSCredential]$TargetDomainAdministratorCredential,

        [parameter(Mandatory)]
        [ValidateSet("External","Forest")]
        [String]$TrustType,

        [parameter(Mandatory)]
        [ValidateSet("Bidirectional","Inbound","Outbound")]
        [String]$TrustDirection,

        [ValidateSet("Present","Absent")]
        [String]$Ensure = 'Present'
    )

#region Input Validation

    # Load the .NET assembly
    try
    {
        Add-type -AssemblyName System.DirectoryServices
    }
    # If not found, means ADDS role is not installed
    catch
    {
        $missingRoleMessage = $($LocalizedData.MissingRoleMessage) -f 'AD-Domain-Services' 
        New-TerminatingError -errorId ActiveDirectoryRoleMissing -errorMessage $missingRoleMessage -errorCategory NotInstalled
    }

#endregion

    if($PSBoundParameters.ContainsKey('Debug')){$null = $PSBoundParameters.Remove('Debug')}
    Validate-ResourceProperties @PSBoundParameters
}

#region Helper Functions
function Validate-ResourceProperties
{
    [Cmdletbinding()]
    param
    (
        [parameter(Mandatory)]
        [String]$SourceDomainName,

        [parameter(Mandatory)]
        [String]$TargetDomainName,

        [parameter(Mandatory)]
        [PSCredential]$TargetDomainAdministratorCredential,

        [parameter(Mandatory)]
        [ValidateSet("External","Forest")]
        [String]$TrustType,

        [parameter(Mandatory)]
        [ValidateSet("Bidirectional","Inbound","Outbound")]
        [String]$TrustDirection,

        [ValidateSet("Present","Absent")]
        [String]$Ensure = 'Present',

        [Switch]$Apply
    )

    try
    {
        $checkingTrustMessage = $($LocalizedData.CheckingTrustMessage) -f $SourceDomainName,$TargetDomainName
        Write-Verbose -Message $checkingTrustMessage

        switch ($TrustType)
        {
            'External' {$DomainOrForest = 'Domain'}
            'Forest' {$DomainOrForest = 'Forest'}
        }
        # Create the target object
        $trgDirectoryContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext($DomainOrForest,$TargetDomainName, $TargetDomainAdministratorCredential.UserName, $TargetDomainAdministratorCredential.GetNetworkCredential().Password)
        $trgDomain = ([type]"System.DirectoryServices.ActiveDirectory.$DomainOrForest")::"Get$DomainOrForest"($trgDirectoryContext)
        # Create the source object
        $srcDirectoryContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext($DomainOrForest,$SourceDomainName)
        $srcDomain = ([type]"System.DirectoryServices.ActiveDirectory.$DomainOrForest")::"Get$DomainOrForest"($srcDirectoryContext)

        # Find trust
        try
        {
            # Find trust betwen source & destination.
            $trust = $srcDomain.GetTrustRelationship($TargetDomainName)
        
            $TestTrustMessage = $($LocalizedData.TestTrustMessage) -f 'present',$Ensure
            Write-Verbose -Message $TestTrustMessage

            if($Ensure -eq 'Present')
            {
                #region Test for trust direction

                $CheckPropertyMessage = $($LocalizedData.CheckPropertyMessage) -f 'trust direction'
                Write-Verbose -Message $CheckPropertyMessage
             
                # Set the trust direction if not correct
                if($trust.TrustDirection -ne $TrustDirection)
                {
                    $notDesiredPropertyMessage = $($LocalizedData.NotDesiredPropertyMessage) -f 'Trust direction',$TrustDirection,$trust.TrustDirection
                    Write-Verbose -Message $notDesiredPropertyMessage

                    if($Apply)
                    {
                        $srcDomain.UpdateTrustRelationship($trgDomain,$TrustDirection)

                        $setPropertyMessage = $($LocalizedData.SetPropertyMessage) -f 'Trust direction'
                        Write-Verbose -Message $setPropertyMessage
                    }
                    else
                    {
                        return $false
                    }
                } # end trust direction is not correct
            
                # Trust direction is correct
                else
                {
                    $desiredPropertyMessage = $($LocalizedData.DesiredPropertyMessage) -f 'Trust direction'
                    Write-Verbose -Message $desiredPropertyMessage
                }
                #endregion trust direction
             
                #region Test for trust type

                $CheckPropertyMessage = $($LocalizedData.CheckPropertyMessage) -f 'trust type'
                Write-Verbose -Message $CheckPropertyMessage
             
                # Set the trust type if not correct
                if($trust.TrustType-ne $TrustType)
                {
                    $notDesiredPropertyMessage = $($LocalizedData.NotDesiredPropertyMessage) -f 'Trust type',$TrustType,$trust.TrustType
                    Write-Verbose -Message $notDesiredPropertyMessage

                    if($Apply)
                    {
                        # Only way to fix the trust direction is to delete it and create again
                        # TODO: Add a property to ask user permission to delete an existing trust
                        $srcDomain.DeleteTrustRelationship($trgDomain)
                        $srcDomain.CreateTrustRelationship($trgDomain,$TrustDirection)

                        $setPropertyMessage = $($LocalizedData.SetPropertyMessage) -f 'Trust type'
                        Write-Verbose -Message $setPropertyMessage
                    }
                    else
                    {
                        return $false
                    }
                } # end trust type is not correct
            
                # Trust type is correct
                else
                {
                    $desiredPropertyMessage = $($LocalizedData.DesiredPropertyMessage) -f 'Trust type'
                    Write-Verbose -Message $desiredPropertyMessage
                }

                #endregion Test for trust type

                # If both trust type and trust direction are correct, return true
                if(-not $Apply)
                {
                    return $true
                }                
            } # end Ensure -eq present
 
            # If the trust should be absent, remove the trust
            else
            {                                                    
                if($Apply)
                {
                    $removingTrustMessage = $($LocalizedData.RemovingTrustMessage) -f $SourceDomainName,$TargetDomainName
                    Write-Verbose -Message $removingTrustMessage

                    $srcDomain.DeleteTrustRelationship($trgDomain)

                    $deleteTrustMessage = $LocalizedData.DeleteTrustMessage
                    Write-Verbose -Message $deleteTrustMessage
                }
                else
                {
                    return $false
                }
            } # end Ensure -eq absent
        } # end find trust

        # Trust does not exist between source and destination
        catch [System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFoundException]
        {
            $TestTrustMessage = $($LocalizedData.TestTrustMessage) -f 'absent',$Ensure
            Write-Verbose -Message $TestTrustMessage

            if($Ensure -eq 'Present')
            {
                if($Apply)
                {
                    $addingTrustMessage = $($LocalizedData.AddingTrustMessage) -f $SourceDomainName,$TargetDomainName
                    Write-Verbose -Message $addingTrustMessage
            
                    $srcDomain.CreateTrustRelationship($trgDomain,$TrustDirection)

                    $setTrustMessage = $LocalizedData.SetTrustMessage
                    Write-Verbose -Message $setTrustMessage
                }
                else
                {
                    return $false
                }
            } # end Ensure -eq Present
            else
            {
                if(-not $Apply)
                {
                    return $true
                }
            }
        } # end no trust
    }# end getting directory object
    catch [System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFoundException]
    {
        throw
    }
}

# Internal function to throw terminating error with specified errroCategory, errorId and errorMessage
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String]$errorId,
        
        [Parameter(Mandatory)]
        [String]$errorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]$errorCategory
    )
    
    $exception = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}

#endregion

Export-ModuleMember -Function *-TargetResource
