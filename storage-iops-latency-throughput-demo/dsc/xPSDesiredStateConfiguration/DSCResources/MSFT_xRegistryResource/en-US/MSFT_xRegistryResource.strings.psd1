# Localized resources for MSFT_xRegistryResource

ConvertFrom-StringData @'
    DefaultValueDisplayName = (Default)

    GetTargetResourceStartMessage = Get-TargetResource is starting for Registry resource with Key {0}
    GetTargetResourceEndMessage = Get-TargetResource has finished for Registry resource with Key {0}
    RegistryKeyDoesNotExist = The registry key at path {0} does not exist.
    RegistryKeyExists = The registry key at path {0} exists.
    RegistryKeyValueDoesNotExist = The registry key at path {0} does not have a value named {1}.
    RegistryKeyValueExists = The registry key at path {0} has a value named {1}.

    SetTargetResourceStartMessage = Set-TargetResource is starting for Registry resource with Key {0}
    SetTargetResourceEndMessage = Set-TargetResource has finished for Registry resource with Key {0}
    CreatingRegistryKey = Creating registry key at path {0}...
    SettingRegistryKeyValue = Setting the value {0} under the registry key at path {1}...
    OverwritingRegistryKeyValue = Overwriting the value {0} under the registry key at path {1}...
    RemovingRegistryKey = Removing registry key at path {0}...
    RegistryKeyValueAlreadySet = The value {0} under the registry key at path {1} has already been set to the specified value.
    RemovingRegistryKeyValue = Removeing the value {0} from the registry key at path {1}...

    TestTargetResourceStartMessage = Test-TargetResource is starting for Registry resource with Key {0}
    TestTargetResourceEndMessage = Test-TargetResource has finished for Registry resource with Key {0}
    RegistryKeyValueTypeDoesNotMatch = The type of the value {0} under the registry key at path {1} does not match the expected type. Expected {2} but was {3}.
    RegistryKeyValueDoesNotMatch = The value {0} under the registry key at path {1} does not match the expected value. Expected {2} but was {3}.

    CannotRemoveExistingRegistryKeyWithSubKeysWithoutForce = The registry key at path {0} has subkeys. To remove this registry key please specifiy the Force parameter as $true.
    CannotOverwriteExistingRegistryKeyValueWithoutForce = The registry key at path {0} already has a value with the name {1}. To overwrite this registry key value please specifiy the Force parameter as $true.
    CannotRemoveExistingRegistryKeyValueWithoutForce = The registry key at path {0} already has a value with the name {1}. To remove this registry key value please specifiy the Force parameter as $true.
    RegistryDriveInvalid = The registry drive specified in the registry key path {0} is missing or invalid.
    ArrayNotAllowedForExpectedType = The specified value data has been declared as a string array, but the registry key type {0} cannot be converted from an array. Please declare the value data as only one string or use the registry type MultiString.
    DWordDataNotInHexFormat = The specified registry key value data {0} is not in the correct hex format to parse as an Int32 (dword).
    QWordDataNotInHexFormat = The specified registry key value data {0} is not in the correct hex format to parse as an Int64 (qword). 
    BinaryDataNotInHexFormat = The specified registry key value data {0} is not in the correct hex format to parse as a Byte array (Binary).
    InvalidRegistryDrive = The registry drive {0} is invalid. Please update the Key parameter to include a valid registry drive.
    InvalidRegistryDriveAbbreviation = The registry drive abbreviation {0} is invalid. Please update the Key parameter to include a valid registry drive.
    RegistryDriveCouldNotBeMounted = The registry drive with the abbreviation {0} could not be mounted.
'@
