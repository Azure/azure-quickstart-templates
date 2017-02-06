# Localized resources for MSFT_xGroupResource

ConvertFrom-StringData @'
    GroupWithName = Group: {0}
    RemoveOperation = Remove
    AddOperation = Add
    SetOperation = Set
    GroupCreated = Group {0} created successfully.
    GroupUpdated = Group {0} properties updated successfully.
    GroupRemoved = Group {0} removed successfully.
    NoConfigurationRequired = Group {0} exists on this node with the desired properties. No action required.
    NoConfigurationRequiredGroupDoesNotExist = Group {0} does not exist on this node. No action required.
    CouldNotFindPrincipal = Could not find a principal with the provided name {0}.
    MembersAndIncludeExcludeConflict = The {0} and {1} parameters conflict. The {0} parameter should not be used in any combination with the {1} parameter.
    GroupAndMembersEmpty = Members is empty and group {0} has no members. No change to group members is needed.
    MemberIsNotALocalUser = {0} is not a local user. User's principal source is {1}.
    MemberNotValid = The group member {0} does not exist or cannot be resolved.
    IncludeAndExcludeConflict = The principal {0} is included in both {1} and {2} parameter values. The same principal cannot be included in both {1} and {2} parameter values.
    InvalidGroupName = The group name {0} cannot be used. Names may not consist entirely of periods and/or whitespace or contain these characters: {1}
    GroupExists = A group with the name {0} exists.
    GroupDoesNotExist = A group with the name {0} does not exist.
    PropertyMismatch = The value of the {0} property is expected to be {1} but it is {2}.
    MembersNumberMismatch = The number of provided unique group members {1} in {0} is different from the number of actual group members {2}.
    MembersMemberMismatch = At least one member {0} of the provided {1} parameter does not match a user in the existing group {2}.
    MemberToExcludeMatch = At least one member {0} of the provided {1} parameter matches a user in the existing group {2}.
    ResolvingLocalAccount = Resolving {0} as a local account.
    ResolvingDomainAccount = Resolving {0} in the domain {1}.
    ResolvingDomainAccountWithTrust = Resolving {0} with domain trust.
    DomainCredentialsRequired = Credentials are required to resolve the domain account {0}.
    UnableToResolveAccount = Unable to resolve account '{0}'. Failed with message: {1} (error code={2})
    InvokingFunctionForGroup = Invoking the function {0} for the group {1}.
    SetTargetResourceStartMessage = Begin executing Set functionality on the group {0}.
    SetTargetResourceEndMessage = End executing Set functionality on the group {0}.
    MembersToIncludeEmpty = MembersToInclude is empty. No group member additions are needed.
    MembersToExcludeEmpty = MembersToExclude is empty. No group member removals are needed.
'@
