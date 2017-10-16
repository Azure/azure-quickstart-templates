# Generated from SQL Server 2014 (build 12.0.4213.0)

# Suppressing this rule because these functions are from an external module 
# and are only being used as stubs
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]
param()

function Add-SqlAvailabilityDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Database},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Add-SqlAvailabilityGroupListenerStaticIp {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${StaticIp},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Add-SqlFirewallRule {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${AutomaticallyAcceptUntrustedCertificates},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${ManagementPublicPort},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Backup-SqlDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath')]
        [Parameter(ParameterSetName='ByBackupContainer')]
        [Parameter(ParameterSetName='ByDBObject')]
        [Parameter(ParameterSetName='ByName')]
        [Parameter(ParameterSetName='ByObject')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${BackupContainer},

        [object]
        ${MirrorDevices},

        [object]
        ${BackupAction},

        [string]
        ${BackupSetName},

        [string]
        ${BackupSetDescription},

        [object]
        ${CompressionOption},

        [switch]
        ${CopyOnly},

        [datetime]
        ${ExpirationDate},

        [switch]
        ${FormatMedia},

        [switch]
        ${Incremental},

        [switch]
        ${Initialize},

        [object]
        ${LogTruncationType},

        [string]
        ${MediaDescription},

        [ValidateRange(0, 2147483647)]
        [int]
        ${RetainDays},

        [switch]
        ${SkipTapeHeader},

        [string]
        ${UndoFileName},

        [object]
        ${EncryptionOption},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Database},

        [Parameter(ParameterSetName='ByDBObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${DatabaseObject},

        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(ParameterSetName='ByName')]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [Parameter(ParameterSetName='ByName')]
        [int]
        ${ConnectionTimeout},

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${BackupFile},

        [ValidateNotNullOrEmpty()]
        [psobject]
        ${SqlCredential},

        [ValidateNotNullOrEmpty()]
        [object]
        ${BackupDevice},

        [switch]
        ${PassThru},

        [switch]
        ${Checksum},

        [switch]
        ${ContinueAfterError},

        [switch]
        ${NoRewind},

        [switch]
        ${Restart},

        [switch]
        ${UnloadTapeAfter},

        [switch]
        ${NoRecovery},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${DatabaseFile},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${DatabaseFileGroup},

        [int]
        ${BlockSize},

        [int]
        ${BufferCount},

        [int]
        ${MaxTransferSize},

        [string]
        ${MediaName},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Convert-UrnToPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Urn}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Decode-SqlName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SqlName}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Disable-SqlAlwaysOn {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ServerInstance},

        [switch]
        ${NoServiceRestart},

        [switch]
        ${Force},

        [pscredential]
        ${Credential}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Enable-SqlAlwaysOn {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ServerInstance},

        [switch]
        ${NoServiceRestart},

        [switch]
        ${Force},

        [pscredential]
        ${Credential}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Encode-SqlName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SqlName}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlCredential {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByName', Mandatory=$true, Position=2, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(ParameterSetName='ByName')]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [Parameter(ParameterSetName='ByName')]
        [System.Nullable[int]]
        ${ConnectionTimeout},

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlInstance {
    [CmdletBinding(ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${MachineName},

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${AutomaticallyAcceptUntrustedCertificates},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${ManagementPublicPort},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlSmartAdmin {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByName')]
        [Parameter(Position=1)]
        [Parameter(ParameterSetName='ByPath')]
        [Parameter(ParameterSetName='ByObject')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='ByName')]
        [psobject]
        ${ServerInstance},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Invoke-PolicyEvaluation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        ${Policy},

        [object]
        ${AdHocPolicyEvaluationMode},

        [Parameter(ParameterSetName='ConnectionProcessing', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        ${TargetServerName},

        [Parameter(ParameterSetName='ConnectionProcessing')]
        [string]
        ${TargetExpression},

        [Parameter(ParameterSetName='ObjectProcessing', Mandatory=$true)]
        [psobject[]]
        ${TargetObjects},

        [switch]
        ${OutputXml}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Invoke-Sqlcmd {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [psobject]
        ${ServerInstance},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Database},

        [switch]
        ${EncryptConnection},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Username},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Password},

        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Query},

        [int]
        ${QueryTimeout},

        [int]
        ${ConnectionTimeout},

        [ValidateRange(-1, 255)]
        [int]
        ${ErrorLevel},

        [ValidateRange(-1, 25)]
        [int]
        ${SeverityLevel},

        [ValidateRange(1, 2147483647)]
        [int]
        ${MaxCharLength},

        [ValidateRange(1, 2147483647)]
        [int]
        ${MaxBinaryLength},

        [switch]
        ${AbortOnError},

        [switch]
        ${DedicatedAdministratorConnection},

        [switch]
        ${DisableVariables},

        [switch]
        ${DisableCommands},

        [ValidateNotNullOrEmpty()]
        [string]
        ${HostName},

        [string]
        ${NewPassword},

        [string[]]
        ${Variable},

        [ValidateNotNullOrEmpty()]
        [string]
        ${InputFile},

        [bool]
        ${OutputSqlErrors},

        [switch]
        ${IncludeSqlUserErrors},

        [switch]
        ${SuppressProviderContextWarning},

        [switch]
        ${IgnoreProviderContext}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Join-SqlAvailabilityGroup {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlAvailabilityGroup {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${AvailabilityReplica},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Database},

        [object]
        ${AutomatedBackupPreference},

        [object]
        ${FailureConditionLevel},

        [int]
        ${HealthCheckTimeout},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlAvailabilityGroupListener {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        ${DhcpSubnet},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${StaticIp},

        [ValidateRange(1, 65535)]
        [ValidateNotNullOrEmpty()]
        [int]
        ${Port},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlAvailabilityReplica {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true)]
        [object]
        ${AvailabilityMode},

        [Parameter(Mandatory=$true)]
        [object]
        ${FailoverMode},

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${EndpointUrl},

        [int]
        ${SessionTimeout},

        [object]
        ${ConnectionModeInPrimaryRole},

        [object]
        ${ConnectionModeInSecondaryRole},

        [ValidateRange(0, 100)]
        [int]
        ${BackupPriority},

        [string[]]
        ${ReadOnlyRoutingList},

        [string]
        ${ReadonlyRoutingConnectionUrl},

        [Parameter(ParameterSetName='AsTemplate')]
        [switch]
        ${AsTemplate},

        [Parameter(ParameterSetName='AsTemplate')]
        [ValidateNotNullOrEmpty()]
        [object]
        ${Version},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlBackupEncryptionOption {
    [CmdletBinding()]
    param(
        [switch]
        ${NoEncryption},

        [ValidateNotNullOrEmpty()]
        [object]
        ${Algorithm},

        [ValidateNotNullOrEmpty()]
        [object]
        ${EncryptorType},

        [ValidateNotNullOrEmpty()]
        [string]
        ${EncryptorName}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlCredential {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Identity},

        [ValidateNotNullOrEmpty()]
        [securestring]
        ${Secret},

        [string]
        ${ProviderName},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlHADREndpoint {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [ValidateNotNullOrEmpty()]
        [int]
        ${Port},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Owner},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Certificate},

        [ValidateNotNullOrEmpty()]
        [ipaddress]
        ${IpAddress},

        [ValidateNotNullOrEmpty()]
        [object]
        ${AuthenticationOrder},

        [ValidateNotNullOrEmpty()]
        [object]
        ${Encryption},

        [ValidateNotNullOrEmpty()]
        [object]
        ${EncryptionAlgorithm},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Remove-SqlAvailabilityDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Remove-SqlAvailabilityGroup {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Remove-SqlAvailabilityReplica {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Remove-SqlCredential {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Remove-SqlFirewallRule {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${AutomaticallyAcceptUntrustedCertificates},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${ManagementPublicPort},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Restore-SqlDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [switch]
        ${ClearSuspectPageTable},

        [switch]
        ${KeepReplication},

        [switch]
        ${Partial},

        [switch]
        ${ReplaceDatabase},

        [switch]
        ${RestrictedUser},

        [long[]]
        ${Offset},

        [object]
        ${RelocateFile},

        [int]
        ${FileNumber},

        [object]
        ${RestoreAction},

        [string]
        ${StandbyFile},

        [string]
        ${StopAtMarkAfterDate},

        [string]
        ${StopAtMarkName},

        [string]
        ${StopBeforeMarkAfterDate},

        [string]
        ${StopBeforeMarkName},

        [string]
        ${ToPointInTime},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Database},

        [Parameter(ParameterSetName='ByDBObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${DatabaseObject},

        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(ParameterSetName='ByName')]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [Parameter(ParameterSetName='ByName')]
        [int]
        ${ConnectionTimeout},

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${BackupFile},

        [ValidateNotNullOrEmpty()]
        [psobject]
        ${SqlCredential},

        [ValidateNotNullOrEmpty()]
        [object]
        ${BackupDevice},

        [switch]
        ${PassThru},

        [switch]
        ${Checksum},

        [switch]
        ${ContinueAfterError},

        [switch]
        ${NoRewind},

        [switch]
        ${Restart},

        [switch]
        ${UnloadTapeAfter},

        [switch]
        ${NoRecovery},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${DatabaseFile},

        [ValidateNotNullOrEmpty()]
        [string[]]
        ${DatabaseFileGroup},

        [int]
        ${BlockSize},

        [int]
        ${BufferCount},

        [int]
        ${MaxTransferSize},

        [string]
        ${MediaName},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Resume-SqlAvailabilityDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlAuthenticationMode {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${Mode},

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${SqlCredential},

        [switch]
        ${ForceServiceRestart},

        [switch]
        ${NoServiceRestart},

        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${AutomaticallyAcceptUntrustedCertificates},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${ManagementPublicPort},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlAvailabilityGroup {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [object]
        ${AutomatedBackupPreference},

        [object]
        ${FailureConditionLevel},

        [int]
        ${HealthCheckTimeout},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlAvailabilityGroupListener {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, 65535)]
        [int]
        ${Port},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlAvailabilityReplica {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [object]
        ${AvailabilityMode},

        [object]
        ${FailoverMode},

        [ValidateNotNullOrEmpty()]
        [string]
        ${EndpointUrl},

        [int]
        ${SessionTimeout},

        [object]
        ${ConnectionModeInPrimaryRole},

        [object]
        ${ConnectionModeInSecondaryRole},

        [ValidateRange(0, 100)]
        [int]
        ${BackupPriority},

        [string[]]
        ${ReadOnlyRoutingList},

        [string]
        ${ReadonlyRoutingConnectionUrl},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlCredential {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Identity},

        [Parameter(Position=3)]
        [ValidateNotNullOrEmpty()]
        [securestring]
        ${Secret},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlHADREndpoint {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        ${Owner},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Certificate},

        [ValidateNotNullOrEmpty()]
        [ipaddress]
        ${IpAddress},

        [ValidateNotNullOrEmpty()]
        [object]
        ${AuthenticationOrder},

        [ValidateNotNullOrEmpty()]
        [object]
        ${Encryption},

        [ValidateNotNullOrEmpty()]
        [object]
        ${EncryptionAlgorithm},

        [ValidateNotNullOrEmpty()]
        [int]
        ${Port},

        [ValidateNotNullOrEmpty()]
        [object]
        ${State},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlNetworkConfiguration {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${Protocol},

        [Parameter(Position=2)]
        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${Port},

        [switch]
        ${Disable},

        [switch]
        ${ForceServiceRestart},

        [switch]
        ${NoServiceRestart},

        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${AutomaticallyAcceptUntrustedCertificates},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${ManagementPublicPort},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Set-SqlSmartAdmin {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [ValidateNotNullOrEmpty()]
        [psobject]
        ${SqlCredential},

        [bool]
        ${MasterSwitch},

        [bool]
        ${BackupEnabled},

        [int]
        ${BackupRetentionPeriodInDays},

        [ValidateNotNullOrEmpty()]
        [object]
        ${EncryptionOption},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Start-SqlInstance {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${AutomaticallyAcceptUntrustedCertificates},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${ManagementPublicPort},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Stop-SqlInstance {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByName', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${AutomaticallyAcceptUntrustedCertificates},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${ManagementPublicPort},

        [ValidateRange(0, 2147483647)]
        [ValidateNotNullOrEmpty()]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Suspend-SqlAvailabilityDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Switch-SqlAvailabilityGroup {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [switch]
        ${AllowDataLoss},

        [switch]
        ${Force},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [switch]
        ${Script}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Test-SqlAvailabilityGroup {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [switch]
        ${ShowPolicyDetails},

        [switch]
        ${AllowUserPolicies},

        [switch]
        ${NoRefresh},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Test-SqlAvailabilityReplica {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [switch]
        ${ShowPolicyDetails},

        [switch]
        ${AllowUserPolicies},

        [switch]
        ${NoRefresh},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Test-SqlDatabaseReplicaState {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [switch]
        ${ShowPolicyDetails},

        [switch]
        ${AllowUserPolicies},

        [switch]
        ${NoRefresh},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Test-SqlSmartAdmin {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [switch]
        ${ShowPolicyDetails},

        [switch]
        ${AllowUserPolicies},

        [switch]
        ${NoRefresh},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}
