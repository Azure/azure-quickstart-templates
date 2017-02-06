<#
    Localized resources for MSFT_xServiceResource
    Strings underneath the blank line are for Grant-LogOnAsServiceRight.
#>

ConvertFrom-StringData @'
    ServiceExists = Service {0} exists.
    ServiceDoesNotExist = Service {0} does not exist.
    BuiltInAccountAndCredentialSpecified = Both BuiltInAccount and Credential cannot be specified. Please remove one for service {0}.
    ServiceAlreadyAbsent = Service {0} is already absent. No change required.
    ServiceDoesNotExistPathMissingError = The service '{0}' does not exist, but Path was not specified. Please specify the path to the executable the service should run to create a new service.
    CreatingService = Creating new service {0}...
    EditingServiceProperties = Editing the properties of service {0}...
    RemovingService = Removing the service {0}...
    RestartingService = Restarting the service {0}...
    ServicePathMatches = The path of service {0} matches the expected path.
    ServicePathDoesNotMatch = The path of service {0} does not match the expected path.
    ServiceDepdenciesMatch = The dependencies of service {0} match the expected dependencies.
    ServiceDepdenciesDoNotMatch = The dependencies of service {0} do not match the expected dependencies.
    ServiceStartupTypeMatches = The start mode of service {0} matches the expected start mode.
    ServiceStartupTypeDoesNotMatch = The start mode of service {0} does not match the expected start mode.
    ServicePropertyDoesNotMatch = The service property {0} of service {1} does not match the expected value. The expected value is {2}. The actual value is {3}.
    ServiceCredentialDoesNotMatch = The start name of service {0} does not match the expected username from the given credential. The expected value is {1}. The actual value is {2}.
    ServiceDeletionSucceeded = The service {0} has been successfully deleted.
    ServiceDeletionFailed = Failed to delete service {0}.
    WaitingForServiceDeletion = Waiting for service {0} to be deleted.
    ErrorSettingLogOnAsServiceRightsForUser = Error granting user {0} the right to log on as a service. Error message: '{1}'
    StartupTypeStateConflict = Service {0} cannot have a startup type of {1} and a state of {2} at the same time.
    InvokeCimMethodFailed = The CIM method {0} failed on service {1} while attempting to update the {2} property(s) with the error code {3}.

    CannotOpenPolicyErrorMessage = Cannot open policy manager.
    UserNameTooLongErrorMessage = User name is too long.
    CannotLookupNamesErrorMessage = Failed to lookup user name.
    CannotOpenAccountErrorMessage = Failed to open policy for user.
    CannotCreateAccountAccessErrorMessage = Failed to create policy for user.
    CannotGetAccountAccessErrorMessage = Failed to get user policy rights.
    CannotSetAccountAccessErrorMessage = Failed to set user policy rights.
'@
