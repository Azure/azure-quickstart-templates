ConvertFrom-StringData @'
###PSLOC 
# Common
NoKeyFound = No Localization key found for ErrorType: '{0}'.
AbsentNotImplemented = Ensure = Absent is not implemented!
TestFailedAfterSet = Test-TargetResource returned false after calling set.
RemoteConnectionFailed = Remote PowerShell connection to Server '{0}' failed.
TODO = ToDo. Work not implemented at this time. 
UnexpectedErrorFromGet = Got unexpected result from Get-TargetResource. No change is made.
FailedToImportSQLPSModule = Failed to import SQLPS module. 

# SQLServer
NoDatabase = Database '{0}' does not exist on SQL server '{1}\{2}'.
SSRSNotFound = SQL Reporting Services instance {0} does not exist!
RoleNotFound = Role '{0}' does not exist on database '{1}' on SQL server '{2}\{3}'."
LoginNotFound = Login '{0}' does not exist on SQL server '{1}\{2}'."
FailedLogin = Creating a login of type 'SqlLogin' requires LoginCredential
FeatureNotSupported = '{0}' is not a valid value for setting 'FEATURES'.  Refer to SQL Help for more information.

# AvailabilityGroupListener
AvailabilityGroupListenerNotFound = Trying to make a change to a listener that does not exist.
AvailabilityGroupListenerErrorVerifyExist = Unexpected result when trying to verify existence of listener {0}.
AvailabilityGroupListenerIPChangeError = IP-address configuration mismatch. Expecting {0} found {1}. Resource does not support changing IP-address. Listener needs to be removed and then created again.
AvailabilityGroupListenerDHCPChangeError = IP-address configuration mismatch. Expecting {0} found {1}. Resource does not support changing between static IP and DHCP. Listener needs to be removed and then created again.

# Endpoint
EndpointNotFound = Endpoint {0} does not exist
EndpointErrorVerifyExist = Unexpected result when trying to verify existence of endpoint {0}.

# Permission
PermissionGetError = Unexpected result when trying to get permissions for {0}.
PrincipalNotFound = Principal {0} does not exist.
PermissionMissingEnsure = Ensure is not set. No change can be made.
'@
