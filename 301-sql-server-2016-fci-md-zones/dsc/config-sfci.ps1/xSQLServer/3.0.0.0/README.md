[![Build status](https://ci.appveyor.com/api/projects/status/mxn453y284eab8li/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xsqlserver/branch/master)

# xSQLServer

The **xSQLServer** module contains DSC resources for deployment and configuration of SQL Server in a way that is fully compliant with the requirements of System Center.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

* **xSQLServerSetup** installs a standalone SQL Server instance
* **xSQLServerFirewall** configures firewall settings to allow remote access to a SQL Server instance.
* **xSQLServerRSSecureConnectionLevel** sets the secure connection level for SQL Server Reporting Services.
* **xSQLServerFailoverClusterSetup** installs SQL Server failover cluster instances.
* **xSQLServerRSConfig** configures SQL Server Reporting Services to use a database engine in another instance.
* **xSQLServerLogin** resource to manage SQL logins
* **xSQLServerRole** resource to manage SQL server roles
* **xSQLServerDatabaseRole** resource to manage SQL database roles
* **xSQLServerDatabasePermissions** resource to manage SQL database permissions
* **xSQLServerDatabaseOwner** resource to manage SQL database owners
* **xSQLDatabaseRecoveryModel** resource to manage database recovery model
* **xSQLServerMaxDop** resource to manage MaxDegree of Parallelism for SQL Server
* **xSQLServerMemory** resource to manage Memory for SQL Server
* **xSQLServerPowerPlan** resource to manage windows powerplan on SQL Server
* **xSQLServerNetwork** resource to manage SQL Server Network Protocols
* **xSQLServerDatabase** resource to manage ensure database is present or absent
* **xSQLAOGroupEnsure** resource to ensure availability group is present or absent
* **xSQLAOGroupJoin** resource to join a replica to an existing availability group
* **xSQLServerAlwaysOnService** resource to enable always on on a SQL Server
* **xSQLServerEndpoint** resource to ensure database endpoint is present or absent
* **xWaitForAvailabilityGroup** resource to wait till availability group is created on primary server
* **xSQLServerConfiguration** resource to manage [SQL Server Configuration Options](https://msdn.microsoft.com/en-us/library/ms189631.aspx)
* **xSQLServerPermission** Grant or revoke permission on the SQL Server.
* **xSQLServerEndpointState** Change state of the endpoint.
* **xSQLServerEndpointPermission** Grant or revoke permission on the endpoint.
* **xSQLServerAvailabilityGroupListener** Create or remove an availability group listener.
* **xSQLServerReplication** resource to manage SQL Replication distribution and publishing.
* **xSQLServerScript** resource to extend DSCs Get/Set/Test functionality to T-SQL
* **xSQLAlias** resource to manage SQL Server client Aliases

### xSQLServerSetup

* **SourcePath**: (Required) UNC path to the root of the source files for installation.
* **SourceFolder**: Folder within the source path containing the source files for installation.
* **SetupCredential**: (Required) Credential to be used to perform the installation.
* **SourceCredential**: Credential used to access SourcePath
* **SuppressReboot**: Suppresses reboot
* **ForceReboot**: Forces Reboot
* **Features**: (Key) SQL features to be installed.
* **InstanceName**: (Key) SQL instance to be installed.
* **InstanceID**: SQL instance ID, if different from InstanceName.
* **PID**: Product key for licensed installations.
* **UpdateEnabled**: Enabled updates during installation.
* **UpdateSource**: Source of updates to be applied during installation.
* **SQMReporting**: Enable customer experience reporting.
* **ErrorReporting**: Enable error reporting.
* **InstallSharedDir**: Installation path for shared SQL files.
* **InstallSharedWOWDir**: Installation path for x86 shared SQL files.
* **InstanceDir**: Installation path for SQL instance files.
* **SQLSvcAccount**: Service account for the SQL service.
* **SQLSvcAccountUsername**: Output user name for the SQL service.
* **AgtSvcAccount**: Service account for the SQL Agent service.
* **AgtSvcAccountUsername**: Output user name for the SQL Agent service.
* **SQLCollation**: Collation for SQL.
* **SQLSysAdminAccounts**: Array of accounts to be made SQL administrators.
* **SecurityMode**: SQL security mode.
* **SAPwd**: SA password, if SecurityMode=SQL.
* **InstallSQLDataDir**: Root path for SQL database files.
* **SQLUserDBDir**: Path for SQL database files.
* **SQLUserDBLogDir**: Path for SQL log files.
* **SQLTempDBDir**: Path for SQL TempDB files.
* **SQLTempDBLogDir**: Path for SQL TempDB log files.
* **SQLBackupDir**: Path for SQL backup files.
* **FTSvcAccount**: Service account for the Full Text service.
* **FTSvcAccountUsername**: Output username for the Full Text service.
* **RSSvcAccount**: Service account for Reporting Services service.
* **RSSvcAccountUsername**: Output username for the Reporting Services service.
* **ASSvcAccount**: Service account for Analysis Services service.
* **ASSvcAccountUsername**: Output username for the Analysis Services service.
* **ASCollation**: Collation for Analysis Services.
* **ASSysAdminAccounts**: Array of accounts to be made Analysis Services admins.
* **ASDataDir**: Path for Analysis Services data files.
* **ASLogDir**: Path for Analysis Services log files.
* **ASBackupDir**: Path for Analysis Services backup files.
* **ASTempDir**: Path for Analysis Services temp files.
* **ASConfigDir**: Path for Analysis Services config.
* **ISSvcAccount**: Service account for Integration Services service.
* **ISSvcAccountUsername**: Output user name for the Integration Services service.

### xSQLServerFirewall

* **Ensure**: (Key) Ensures that SQL firewall rules are **Present** or **Absent** on the machine.
* **SourcePath**: (Required) UNC path to the root of the source files for installation.
* **SourceFolder**: Folder within the source path containing the source files for installation.
* **Features**: (Key) SQL features to enable firewall rules for.
* **InstanceName**: (Key) SQL instance to enable firewall rules for.
* **DatabaseEngineFirewall**: Is the firewall rule for the Database Engine enabled?
* **BrowserFirewall**: Is the firewall rule for the Browser enabled?
* **ReportingServicesFirewall**: Is the firewall rule for Reporting Services enabled?
* **AnalysisServicesFirewall**: Is the firewall rule for Analysis Services enabled?
* **IntegrationServicesFirewall**: Is the firewall rule for the Integration Services enabled?

### xSQLServerRSSecureConnectionLevel

* **InstanceName**: (Key) SQL instance to set secure connection level for.
* **SecureConnectionLevel**: (Key) SQL Server Reporting Service secure connection level.
* **Credential**: (Required) Credential with administrative permissions to the SQL instance.

### xSQLServerFailoverClusterSetup

* **Action**: (Key) { Prepare | Complete }
* **SourcePath**: (Required) UNC path to the root of the source files for installation.
* **SourceFolder**: Folder within the source path containing the source files for installation.
* **SetupCredential**: (Required) Credential to be used to perform the installation.
* **SourceCredential**: Credential to be used to access SourcePath
* **SuppressReboot**: Suppresses reboot
* **ForceReboot**: Forces Reboot
* **Features**: (Required) SQL features to be installed.
* **InstanceName**: (Key) SQL instance to be installed.
* **InstanceID**: SQL instance ID, if different from InstanceName.
* **PID**: Product key for licensed installations.
* **UpdateEnabled**: Enabled updates during installation.
* **UpdateSource**: Source of updates to be applied during installation.
* **SQMReporting**: Enable customer experience reporting.
* **ErrorReporting**: Enable error reporting.
* **FailoverClusterGroup**: Name of the resource group to be used for the SQL Server failover cluster.
* **FailoverClusterNetworkName**: (Required) Network name for the SQL Server failover cluster.
* **FailoverClusterIPAddress**: IPv4 address for the SQL Server failover cluster.
* **InstallSharedDir**: Installation path for shared SQL files.
* **InstallSharedWOWDir**: Installation path for x86 shared SQL files.
* **InstanceDir**: Installation path for SQL instance files.
* **SQLSvcAccount**: Service account for the SQL service.
* **SQLSvcAccountUsername**: Output user name for the SQL service.
* **AgtSvcAccount**: Service account for the SQL Agent service.
* **AgtSvcAccountUsername**: Output user name for the SQL Agent service.
* **SQLCollation**: Collation for SQL.
* **SQLSysAdminAccounts**: Array of accounts to be made SQL administrators.
* **SecurityMode**: SQL security mode.
* **SAPwd**: SA password, if SecurityMode=SQL.
* **InstallSQLDataDir**: Root path for SQL database files.
* **SQLUserDBDir**: Path for SQL database files.
* **SQLUserDBLogDir**: Path for SQL log files.
* **SQLTempDBDir**: Path for SQL TempDB files.
* **SQLTempDBLogDir**: Path for SQL TempDB log files.
* **SQLBackupDir**: Path for SQL backup files.
* **ASSvcAccount**: Service account for Analysis Services service.
* **ASSvcAccountUsername**: Output user name for the Analysis Services service.
* **ASCollation**: Collation for Analysis Services.
* **ASSysAdminAccounts**: Array of accounts to be made Analysis Services admins.
* **ASDataDir**: Path for Analysis Services data files.
* **ASLogDir**: Path for Analysis Services log files.
* **ASBackupDir**: Path for Analysis Services backup files.
* **ASTempDir**: Path for Analysis Services temp files.
* **ASConfigDir**: Path for Analysis Services config.
* **ISSvcAccount**: Service account for Integration Services service.
* **ISSvcAccountUsername**: Output user name for the Integration Services service.
* **ISFileSystemFolder**: File system folder for Integration Services.

### xSQLServerRSConfig

* **InstanceName**: (Key) Name of the SQL Server Reporting Services instance to be configured.
* **RSSQLServer**: (Required) Name of the SQL Server to host the Reporting Service database.
* **RSSQLInstanceName**: (Required) Name of the SQL Server instance to host the Reporting Service database.
* **SQLAdminCredential**: (Required) Credential to be used to perform the configuration.
* **IsInitialized**: Output is the Reporting Services instance initialized.

### xSQLServerLogin
* **Ensure**: If the values should be present or absent. Valid values are 'Present' or 'Absent'. 
* **Name**: (Key) The name of the SQL login. If LoginType is 'WindowsUser' or 'WindowsGroup' then provide the name in the format DOMAIN\name.
* **LoginCredential**: If LoginType is 'SqlLogin' then a PSCredential is needed for the password to the login.
* **LoginType**: The SQL login type. Valid values are 'SqlLogin', 'WindowsUser' or 'WindowsGroup'.
* **SQLServer**: (Key) The SQL Server for the login.
* **SQLInstanceName**: (Key) The SQL instance for the login.

### xSQLServerRole
* **Name**: (Key) Name of the SQL Login to create
* **ServerRole**: Type of SQL role to add.(bulkadmin, dbcreator, diskadmin, processadmin , public, securityadmin, serveradmin , setupadmin, sysadmin)
* **SQLServer**: SQL Server where login should be created
* **SQLInstance**: SQL Instance for the login

### xSQLServerDatabaseRole
* **Name**: (Key) Name of the SQL Login or the role on the database
* **SQLServer**: The SQL Server for the database
* **SQLInstanceName**: The SQL Instance for the database
* **Database**: The SQL Database for the role
* **Role**: The SQL role for the database

###xSQLServerDatabasePermissions
* **Database**: (Key) The SQL Database
* **Name**: (Required) The name of permissions for the SQL database
* **Permissions**: (Required) The set of Permissions for the SQL database
* **SQLServer**: The SQL Server for the database
* **SQLInstanceName**: The SQL instance for the database

###xSQLServerDatabaseOwner
* **Database**: (Key) The SQL Database
* **Name**: (Required) The name of the SQL login for the owner
* **SQLServer**: The SQL Server for the database
* **SQLInstance**: The SQL instance for the database

###xSQLDatabaseRecoveryModel
* **DatabaseName**: (key) The SQL database name
* **SQLServerInstance**: (Required) The SQL server and instance
* **RecoveryModel**: (Required) Recovery Model (Full, Simple, BulkLogged)

###xSQLServerMaxDop
* **Ensure**: An enumerated value that describes if Min and Max memory is configured
* **DyamicAlloc**: Flag to indicate if MaxDop is dynamically configured
* **MaxDop**: Numeric value to configure MaxDop to
* **SQLServer**: The SQL Server where to set MaxDop
* **SQLInstance** (Key): The SQL instance where to set MaxDop

###xSQLServerMemory
* **Ensure**: An enumerated value that describes if Min and Max memory is configured
* **DyamicAlloc**: (key) Flag to indicate if Memory is dynamically configured
* **MinMemory**: Minimum memory value to set SQL Server memory to
* **MaxMemory**: Maximum memory value to set SQL Server memory to
* **SQLServer**: The SQL Server for the database
* **SQLInstance**: (key) The SQL instance for the database

###xSQLServerPowerPlan
* **Ensure**: (key) An enumerated value that describes if Min and Max memory is configured

### xSQLServerNetwork
* **InstanceName**: (Key) name of SQL Server instance for which network will be configured.
* **ProtocolName**: (Required) Name of network protocol to be configured. Only tcp is currently supported.
* **IsEnabled**: Enables/Disables network protocol.
* **TCPDynamicPorts**: 0 if Dynamic ports should be used otherwise empty.
* **TCPPort**: Custom TCP port.
* **RestartService**: If true will restart SQL Service instance service after update. Default false.

###xSQLServerDatabase
* **Database**: (key) Database to be created or dropped
* **Ensure**: (Default = 'Present') An enumerated value that describes if Database is to be present or absent.
* **SQLServer**: (key) The SQL Server for the database
* **SQLInstance**: (key) The SQL instance for the database 

###xSQLAOGroupEnsure
* **Ensure**: (Key) Determines whether the availability group should be added or removed.
* **AvailabilityGroupName** (Key) Name for availability group.
* **AvailabilityGroupNameListener** Listener name for availability group.
* **AvailabilityGroupNameIP** List of IP addresses associated with listener.
* **AvailabilityGroupSubMask** Network subnetmask for listener.
* **AvailabilityGroupPort** Port availability group should listen on.
* **ReadableSecondary** Mode secondaries should operate under (None, ReadOnly, ReadIntent).
* **AutoBackupPreference** Where backups should be backed up from (Primary, Secondary).
* **BackupPriority** The percentage weight for backup prority (default 50).
* **EndPointPort** The TCP port for the SQL AG Endpoint (default 5022).
* **SQLServer**: The SQL Server for the database.
* **SQLInstance**: The SQL instance for the database.
* **SetupCredential**: (Required) Credential to be used to Grant Permissions on SQL Server, set this to $null to use Windows Authentication. 

###xSQLServerAOJoin
* **Ensure**: (key) An enumerated value that describes if Replica is to be present or absent from availability group
* **AvailabilityGroupName** (key) Name for availability group
* **SQLServer**: The SQL Server for the database
* **SQLInstance**: The SQL instance for the database
* **SetupCredential**: (Required) Credential to be used to Grant Permissions on SQL Server

###xSQLServerAlwaysOnService
* **Ensure**: (key) An enumerated value that describes if SQL server should have AlwaysOn property present or absent.
* **SQLServer**: The SQL Server for the database
* **SQLInstance**: The SQL instance for the database

###xSQLServerEndpoint
* **EndPointName**: Name for endpoint to be created on SQL Server
* **Ensure**: (key) An enumerated value that describes if endpoint is to be present or absent on SQL Server
* **Port**: Port Endpoint should listen on
* **AuthorizedUser**:  User who should have connect ability to endpoint
* **SQLServer**: The SQL Server for the database
* **SQLInstance**: The SQL instance for the database 

###xWaitforAvailabilityGroup
* **Name**:  (key) Name for availability group
* **RetryIntervalSec**: Interval to check for availability group
* **RetryCount**: Maximum number of retries to check availability group creation

###xSQLServerConfiguration
* **InstanceName**: (Key) name of SQL Server instance for which configuration options will be configured.
* **OptionName**: (Key) SQL Server option name. For all possible values reference [MSDN](https://msdn.microsoft.com/en-us/library/ms189631.aspx) or run sp_configure.
* **OptionValue**: (Required) SQL Server option value to be set.
* **RestartService**: Default false. If true will restart SQL Service instance service after update.

### xSQLServerPermission
* **InstanceName** The SQL Server instance name.
* **NodeName** The host name or FQDN.
* **Ensure** If the permission should be present or absent.
* **Principal** The login to which permission will be set.
* **Permission** The permission to set for the login. Valid values are AlterAnyAvailabilityGroup, ViewServerState or AlterAnyEndPoint.

### xSQLServerEndpointState
* **InstanceName** The SQL Server instance name.
* **NodeName** The host name or FQDN.
* **Name** The name of the endpoint.
* **State** The state of the endpoint. Valid states are Started, Stopped or Disabled.

### xSQLServerEndpointPermission
* **InstanceName** The SQL Server instance name.
* **NodeName** The host name or FQDN.
* **Ensure** If the permission should be present or absent.
* **Name** The name of the endpoint.
* **Principal** The login to which permission will be set.
* **Permission** The permission to set for the login. Valid value for permission are only CONNECT.

### xSQLServerAvailabilityGroupListener
*This resource requires that the CNO has been delegated the right `Create computer object` on the organizational unit (OU) in which the CNO resides.*
* **InstanceName** The SQL Server instance name of the primary replica.
* **NodeName** The host name or FQDN of the primary replica.
* **Ensure** If the availability group listener should be present or absent.
* **Name** The name of the availability group listener, max 15 characters. This name will be used as the Virtual Computer Object (VCO).
* **AvailabilityGroup** The name of the availability group to which the availability group listener is or will be connected.
* **IpAddress** The IP address used for the availability group listener, in the format 192.168.10.45/255.255.252.0. If using DCHP, set to the first IP-address of the DHCP subnet, in the format 192.168.8.1/255.255.252.0. Must be valid in the cluster-allowed IP range.
* **Port** The port used for the availability group listener.
* **DHCP** If DHCP should be used for the availability group listener instead of static IP address.

###xSQLServerReplication
* **InstanceName**: (Key) SQL Server instance name where replication distribution will be configured.
* **Ensure**: (Default = 'Present') 'Present' will configure replication, 'Absent' will disable replication.
* **DistributorMode**: (Required), 'Local' - Instance will be configured as it's own distributor, 'Remote' - Instace will be configure with remote distributor (remote distributor needs to be already configured for distribution).
* **AdminLinkCredentials**: (Required) - AdminLink password to be used when setting up publisher distributor relationship.
* **DistributionDBName**: (Default = 'distribution') distribution database name. If DistributionMode='Local' this will be created, if 'Remote' needs to match distribution database on remote distributor. 
* **RemoteDistributor**: (Required if DistributionMode='Remote') SQL Server network name that will be used as distributor for local instance.
* **WorkingDirectory**: (Required) Publisher working directory.
* **UseTrustedConnection**: (Default = $true) Publisher security mode.
* **UninstallWithForce**: (Default = $true) Force flag for uninstall procedure

###xSQLServerScript
* **ServerInstance**: (Required) The name of an instance of the Database Engine. For default instances, only specify the computer name. For named instances, use the format ComputerName\\InstanceName.
* **SetFilePath**: (Key) Path to SQL file that will perform Set action.
* **GetFilePath**: (Key) Path to SQL file that will perform Get action. SQL Queries returned by this function are returned by the Get-DscConfiguration cmdlet with the GetResult parameter.
* **TestFilePath**: (Key) Path to SQL file that will perform Test action. Any Script that does not throw an error and returns null is evaluated to true. Invoke-SqlCmd treats SQL Print statements as verbose text, this will not cause a Test to return false. 
* **Credential**: Specifies the credentials for making a SQL Server Authentication connection to an instance of the Database Engine.
* **Variable**: Creates a sqlcmd scripting variable for use in the sqlcmd script, and sets a value for the variable.

### xSQLAlias
 * **Ensure**: Determines whether the alias should be added or removed. Default value is 'Present'
 * **Name**: (Key) The name of Alias (e.g. svr01\inst01).
 * **ServerName**: (Key) The SQL Server you are aliasing (the netbios name or FQDN).
 * **Protocol**: Protocol to use when connecting. Valid values are 'TCP' or 'NP' (Named Pipes). Default value is 'TCP'.
 * **TCPPort**: The TCP port SQL is listening on. Only used when protocol is set to 'TCP'. Default value is port 1433.
 * **PipeName**: (Read) Named Pipes path from the Get-TargetResource method.

## Versions

### Unreleased

### 3.0.0.0
* xSQLServerHelper
  - added functions
    - Test-SQLDscParameterState
    - Get-SqlDatabaseOwner
    - Set-SqlDatabaseOwner
* Examples
  - xSQLServerDatabaseOwner
   - 1-SetDatabaseOwner.ps1
 * Added tests for resources
   - MSFT_xSQLServerDatabaseOwner.Tests.Tests.ps1

### 2.0.0.0
* Added resources
  - xSQLServerReplication
  - xSQLServerScript
  - xSQLAlias  
  - xSQLServerRole
* Added tests for resources
  - xSQLServerPermission
  - xSQLServerEndpointState
  - xSQLServerEndpointPermission
  - xSQLServerAvailabilityGroupListener
  - xSQLServerLogin
  - xSQLAOGroupEnsure
  - xSQLAlias
  - xSQLServerRole
* Fixes in xSQLServerAvailabilityGroupListener
  - In one case the Get-method did not report that DHCP was configured. 
  - Now the resource will throw 'Not supported' when IP is changed between Static and DHCP.
  - Fixed an issue where sometimes the listener wasn't removed.
  - Fixed the issue when trying to add a static IP to a listener was ignored.
* Fix in xSQLServerDatabase
  - Fixed so dropping a database no longer throws an error
  - BREAKING CHANGE: Fixed an issue where it was not possible to add the same database to two instances on the same server.
  - BREAKING CHANGE: The name of the parameter Database has changed. It is now called Name.
* Fixes in xSQLAOGroupEnsure
  - Added parameters to New-ListenerADObject to allow usage of a named instance.
  - pass setup credential correctly
* Changes to xSQLServerLogin
   - Fixed an issue when dropping logins.
   - BREAKING CHANGE: Fixed an issue where it was not possible to add the same login to two instances on the same server.
* Changes to xSQLServerMaxDop
   - BREAKING CHANGE: Made SQLInstance parameter a key so that multiple instances on the same server can be configured

### 1.8.0.0

* Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.
* Added Support for SQL Server 2016
* xSQLAOGroupEnsure
   - Fixed spelling mistake in AutoBackupPreference property
   - Added BackupPriority property
* Added resources
  - xSQLServerPermission
  - xSQLServerEndpointState
  - xSQLServerEndpointPermission
  - xSQLServerAvailabilityGroupListener
* xSQLServerHelper
	- added functions 
		- Import-SQLPSModule
		- Get-SQLPSInstanceName
		- Get-SQLPSInstance
		- Get-SQLAlwaysOnEndpoint
	- modified functions
		- New-TerminatingError - *added optional parameter `InnerException` to be able to give the user more information in the returned message*

### 1.7.0.0

* Resources Added
  - xSQLServerConfiguration

### 1.6.0.0

* Resources Added
  - xSQLAOGroupEnsure
  - xSQLAOGroupJoin
  - xWaitForAvailabilityGroup
  - xSQLServerEndPoint
  - xSQLServerAlwaysOnService
* xSQLServerHelper
    - added functions 
        - Connect-SQL
        - New-VerboseMessage
        - Grant-ServerPerms
        - Grant-CNOPerms
        - New-ListenerADObject
* xSQLDatabaseRecoveryModel
    - Updated Verbose statements to use new function New-VerboseMessage
* xSQLServerDatabase
    - Updated Verbose statements to use new function New-VerboseMessage
    - Removed ConnectSQL function and replaced with new Connect-SQL function
* xSQLServerDatabaseOwner
    - Removed ConnectSQL function and replaced with new Connect-SQL function
* xSQLServerDatabasePermissions
    - Removed ConnectSQL function and replaced with new Connect-SQL function
* xSQLServerDatabaseRole
    - Removed ConnectSQL function and replaced with new Connect-SQL function
* xSQLServerLogin
    - Removed ConnectSQL function and replaced with new Connect-SQL function
* xSQLServerMaxDop
    - Updated Verbose statements to use new function New-VerboseMessage
    - Removed ConnectSQL function and replaced with new Connect-SQL function
* xSQLServerMemory
    - Updated Verbose statements to use new function New-VerboseMessage
    - Removed ConnectSQL function and replaced with new Connect-SQL function
* xSQLServerPowerPlan
    - Updated Verbose statements to use new function New-VerboseMessage
* Examples
    - Added xSQLServerConfiguration resource example

### 1.5.0.0

* Added new resource xSQLServerDatabase that allows adding an empty database to a server

### 1.4.0.0

* Resources Added
  - xSQLDatabaseRecoveryModeAdded
  - xSQLServerDatabaseOwner
  - xSQLServerDatabasePermissions
  - xSQLServerDatabaseRole
  - xSQLServerLogin
  - xSQLServerMaxDop
  - xSQLServerMemory
  - xSQLServerPowerPlan
  - xSQLServerDatabase
* xSQLServerSetup:
  - Corrected bug in GetFirstItemPropertyValue to correctly handle registry keys with only one value.
  - Added support for SQL Server 
  - 2008 R2 installation
  - Removed default values for parameters, to avoid compatibility issues and setup errors
  - Added Replication sub feature detection
  - Added setup parameter BrowserSvcStartupType
  - Change SourceFolder to Source to allow for multiversion Support
  - Add Source Credential for accessing source files
  - Add Parameters for SQL Server configuration
  - Add Parameters to SuppressReboot or ForceReboot
* xSQLServerFirewall
  - Removed default values for parameters, to avoid compatibility issues
  - Updated firewall rule name to not use 2012 version, since package supports 2008, 2012 and 2014 versions
  - Additional of SQLHelper Function and error handling
  - Change SourceFolder to Source to allow for multiversion Support
* xSQLServerNetwork
  - Added new resource that configures network settings.
  - Currently supports only tcp network protocol
  - Allows to enable and disable network protocol for specified instance service
  - Allows to set custom or dynamic port values
* xSQLServerRSSecureConnectionLevel
  - Additional of SQLHelper Function and error handling
* xSqlServerRSConfig
* xSQLServerFailoverClusterSetup
  - Additional of SQLHelper Function and error handling
  - Change SourceFolder to Source to allow for multiversion Support
  - Add Parameters to SuppressReboot or ForceReboot 
* Examples
  - Updated example files to use correct DebugMode parameter value ForceModuleImport, this is not boolean in WMF 5.0 RTM
  - Added xSQLServerNetwork example

### 1.3.0.0

* xSqlServerSetup: 
    - Make Features case-insensitive.

### 1.2.1.0

* Increased timeout for setup process to start to 60 seconds.

### 1.2.0.0

* Updated release with the following new resources 
    - xSQLServerFailoverClusterSetup
    - xSQLServerRSConfig

### 1.1.0.0

* Initial release with the following resources 
    - xSQLServerSetup
    - xSQLServerFirewall
    - xSQLServerRSSecureConnectionLevel

## Examples

Examples for use of this resource can be found with the System Center resources, such as **xSCVMM**, **xSCSMA**, and **xSCOM**.

