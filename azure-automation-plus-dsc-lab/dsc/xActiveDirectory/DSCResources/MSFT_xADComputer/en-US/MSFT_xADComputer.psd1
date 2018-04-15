# culture="en-US"
ConvertFrom-StringData @'
    RoleNotFoundError                 = Please ensure that the PowerShell module for role '{0}' is installed.
    RetrievingADComputerError         = Error looking up Active Directory computer '{0}'.

    RetrievingADComputer              = Retrieving Active Directory computer '{0}' ...
    CreatingADDomainConnection        = Creating connection to Active Directory domain ...
    ADComputerIsPresent               = Active Directory computer '{0}' is present.
    ADComputerNotPresent              = Active Directory computer '{0}' was NOT present.
    ADComputerNotDesiredPropertyState = Computer '{0}' property is NOT in the desired state. Expected '{1}', actual '{2}'.
    ADComputerInDesiredState          = Active Directory computer '{0}' is in the desired state.
    ADComputerNotInDesiredState       = Active Directory computer '{0}' is NOT in the desired state.

    AddingADComputer                  = Adding Active Directory computer '{0}'.
    RemovingADComputer                = Removing Active Directory computer '{0}'.
    UpdatingADComputer                = Updating Active Directory computer '{0}'.
    UpdatingADComputerProperty        = Updating computer property '{0}' with/to '{1}'.
    RemovingADComputerProperty        = Removing computer property '{0}' with '{1}'.
    MovingADComputer                  = Moving computer from '{0}' to '{1}'.
    RenamingADComputer                = Renaming computer from '{0}' to '{1}'.

    ODJRequestStartMessage=Attempting to create the ODJ request file '{2}' for computer '{1}' in Domain '{0}'.
    ODJRequestCompleteMessage=The ODJ request file '{2}' for computer '{1}' in Domain '{0}' has been provisioned successfully.
    ODJRequestError=Error {0} occured provisioning the computer using ODJ- {1}.
'@
