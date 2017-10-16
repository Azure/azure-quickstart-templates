# Generated from SQLServer module, module version 20.0 (SQL Server Management Studio 13.0.15600.2 - August 2016)

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

function Add-SqlAzureAuthenticationContext {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [switch]
        ${Interactive},

        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ClientID},

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Secret},

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Tenant}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Add-SqlColumnEncryptionKeyValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ColumnMasterKeyName},

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${EncryptedValue},

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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Backup-SqlDatabase {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByBackupContainer')]
        [Parameter(ParameterSetName='ByDBObject')]
        [Parameter(ParameterSetName='ByPath')]
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

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByName', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
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

function Complete-SqlColumnMasterKeyRotation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SourceColumnMasterKeyName},

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

function ConvertFrom-EncodedSqlName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SqlName}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function ConvertTo-EncodedSqlName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SqlName}
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

function Get-SqlAgent {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
        [Parameter(ParameterSetName='ByObject', Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${InputObject},

        [Parameter(ParameterSetName='ByPath', Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [Parameter(ParameterSetName='ByName', Position=1, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${ServerInstance},

        [Parameter(ParameterSetName='ByName')]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [Parameter(ParameterSetName='ByName')]
        [int]
        ${ConnectionTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlAgentJob {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
        [Parameter(ParameterSetName='ByName', Position=2, ValueFromPipeline=$true)]
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
        ${Path}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlAgentJobHistory {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
        [datetime]
        ${StartRunDate},

        [datetime]
        ${EndRunDate},

        [guid]
        ${JobID},

        [string]
        ${JobName},

        [int]
        ${MinimumRetries},

        [int]
        ${MinimumRunDurationInSeconds},

        [switch]
        ${OldestFirst},

        [object]
        ${OutcomesType},

        [int]
        ${SqlMessageID},

        [int]
        ${SqlSeverity},

        [object]
        ${Since},

        [Parameter(ParameterSetName='ByName', Position=1, ValueFromPipeline=$true)]
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

function Get-SqlAgentJobSchedule {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
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
        ${Path}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlAgentJobStep {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
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
        ${Path}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlAgentSchedule {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
        [Parameter(ParameterSetName='ByName', Position=2, ValueFromPipeline=$true)]
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
        ${Path}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlColumnEncryptionKey {
    [CmdletBinding()]
    param(
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

function Get-SqlColumnMasterKey {
    [CmdletBinding()]
    param(
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

function Get-SqlErrorLog {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
        [timespan]
        ${Timespan},

        [datetime]
        ${Before},

        [datetime]
        ${After},

        [object]
        ${Since},

        [switch]
        ${Ascending},

        [Parameter(ParameterSetName='ByName', Position=1, ValueFromPipeline=$true)]
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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
        [System.Nullable[int]]
        ${RetryTimeout}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Get-SqlSmartAdmin {
    [CmdletBinding(DefaultParameterSetName='ByPath', ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='ByPath')]
        [Parameter(ParameterSetName='ByName')]
        [Parameter(Position=1)]
        [Parameter(ParameterSetName='ByObject')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [string]
        ${DatabaseName},

        [Parameter(ParameterSetName='ByName')]
        [Parameter(ValueFromPipeline=$true)]
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
    [CmdletBinding(DefaultParameterSetName='ByConnectionParameters')]
    param(
        [Parameter(ParameterSetName='ByConnectionParameters', ValueFromPipeline=$true)]
        [psobject]
        ${ServerInstance},

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Database},

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [switch]
        ${EncryptConnection},

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Username},

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Password},

        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Query},

        [int]
        ${QueryTimeout},

        [Parameter(ParameterSetName='ByConnectionParameters')]
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

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [switch]
        ${DedicatedAdministratorConnection},

        [switch]
        ${DisableVariables},

        [switch]
        ${DisableCommands},

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${HostName},

        [Parameter(ParameterSetName='ByConnectionParameters')]
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

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [switch]
        ${SuppressProviderContextWarning},

        [Parameter(ParameterSetName='ByConnectionParameters')]
        [switch]
        ${IgnoreProviderContext},

        [Alias('As')]
        [object]
        ${OutputAs},

        [Parameter(ParameterSetName='ByConnectionString', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ConnectionString}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function Invoke-SqlColumnMasterKeyRotation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SourceColumnMasterKeyName},

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${TargetColumnMasterKeyName},

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

        [switch]
        ${BasicAvailabilityGroup},

        [switch]
        ${DatabaseHealthTrigger},

        [switch]
        ${DtcSupportEnabled},

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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, 65535)]
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

function New-SqlAzureKeyVaultColumnMasterKeySettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${KeyUrl}
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

function New-SqlCertificateStoreColumnMasterKeySettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CertificateStoreLocation},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Thumbprint}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlCngColumnMasterKeySettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CngProviderName},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${KeyName}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlColumnEncryptionKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ColumnMasterKeyName},

        [ValidateNotNullOrEmpty()]
        [string]
        ${EncryptedValue},

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

function New-SqlColumnEncryptionKeyEncryptedValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${TargetColumnMasterKeySettings},

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${ColumnMasterKeySettings},

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${EncryptedValue}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlColumnEncryptionSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ColumnName},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${EncryptionType},

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${EncryptionKey}
   )

    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}

function New-SqlColumnMasterKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${ColumnMasterKeySettings},

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

function New-SqlCspColumnMasterKeySettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CspProviderName},

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${KeyName}
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

function Remove-SqlColumnEncryptionKey {
    [CmdletBinding()]
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

function Remove-SqlColumnEncryptionKeyValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ColumnMasterKeyName},

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

function Remove-SqlColumnMasterKey {
    [CmdletBinding()]
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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
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

        [Parameter(ParameterSetName='ByObject', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByName', Mandatory=$true, Position=1)]
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=1)]
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

function Save-SqlMigrationReport {
    [CmdletBinding()]
    param(
        [string]
        ${Server},

        [string]
        ${Database},

        [string]
        ${Schema},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Username},

        [ValidateNotNullOrEmpty()]
        [string]
        ${Password},

        [string]
        ${Object},

        [object]
        ${InputObject},

        [object]
        ${MigrationType},

        [ValidateNotNullOrEmpty()]
        [string]
        ${FolderPath}
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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
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

        [bool]
        ${DatabaseHealthTrigger},

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

function Set-SqlColumnEncryption {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [object]
        ${ColumnEncryptionSettings},

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

function Set-SqlErrorLog {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
        [Parameter(ParameterSetName='ByName', Position=1, ValueFromPipeline=$true)]
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

        [ValidateRange(6, 99)]
        [uint16]
        ${MaxLogCount},

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
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
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

        [string]
        ${DatabaseName},

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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
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

        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, 2147483647)]
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
