# Localized resources for xUser

ConvertFrom-StringData @'
    UserWithName = User: {0}
    RemoveOperation = Remove
    AddOperation = Add
    SetOperation = Set
    ConfigurationStarted = Configuration of user {0} started.
    ConfigurationCompleted = Configuration of user {0} completed successfully.
    UserCreated = User {0} created successfully.
    UserUpdated = User {0} properties updated successfully.
    UserRemoved = User {0} removed successfully.
    NoConfigurationRequired = User {0} exists on this node with the desired properties. No action required.
    NoConfigurationRequiredUserDoesNotExist = User {0} does not exist on this node. No action required.
    InvalidUserName = The name {0} cannot be used. Names may not consist entirely of periods and/or spaces, or contain these characters: {1}
    UserExists = A user with the name {0} exists.
    UserDoesNotExist = A user with the name {0} does not exist.
    PropertyMismatch = The value of the {0} property is expected to be {1} but it is {2}.
    PasswordPropertyMismatch = The value of the {0} property does not match.
    AllUserPropertisMatch = All {0} {1} properties match.
    ConnectionError = There could be a possible connection error while trying to use the System.DirectoryServices API's.
    MultipleMatches = There could be a possible multiple matches exception while trying to use the System.DirectoryServices API's.
'@
