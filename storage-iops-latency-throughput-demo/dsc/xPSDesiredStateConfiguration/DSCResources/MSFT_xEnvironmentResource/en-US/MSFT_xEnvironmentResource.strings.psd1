# Localized resources for MSFT_xEnvironmentResource

ConvertFrom-StringData @'
    ArgumentTooLong = Argument is too long.
    CannotSetValueToEmpty = Cannot create environment variable with an empty value. Set Ensure = Absent to remove environment variable '{0}'.
    EnvVarCreated = Environment variable '{0}' created with value '{1}'.
    EnvVarSetError = Failed to set environment variable '{0}' to value '{1}'.
    EnvVarPathSetError = Failed to add path '{0}' to environment variable '{1}' holding value '{2}'.
    EnvVarRemoveError = Failed to remove environment variable '{0}' holding value '{1}'.
    EnvVarPathRemoveError = Failed to remove path '{0}' from variable '{1}' holding value '{2}'.
    EnvVarUnchanged = Environment variable '{0}' with value '{1}' was not updated.
    EnvVarUpdated = Environment variable '{0}' updated from value '{1}' to value '{2}'.
    EnvVarPathUnchanged = Path environment variable '{0}' with value '{1}' was not updated.
    EnvVarPathUpdated = Environment variable '{0}' updated from value '{1}' to value '{2}'.
    EnvVarNotFound = Environment variable '{0}' does not exist.
    EnvVarFound = Environment variable '{0}' with value '{1}' was successfully found.
    EnvVarFoundWithMisMatchingValue = Environment variable '{0}' with value '{1}' mismatched the specified value '{2}'.
    EnvVarRemoved = Environment variable '{0}' removed.
    GetItemPropertyFailure = Failed to get the item property for variable '{0}' with path '{1}'.
    RemoveNonExistentVarError = Environment variable '{0}' cannot be removed because it does not exist.
'@
