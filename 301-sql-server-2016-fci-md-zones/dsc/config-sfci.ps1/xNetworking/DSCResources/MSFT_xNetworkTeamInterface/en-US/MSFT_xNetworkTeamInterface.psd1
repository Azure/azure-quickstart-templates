ConvertFrom-StringData @"
    getTeamNicInfo=Getting network team interface information for {0}.
    foundTeamNic=Found a network team interface with name {0}.
    teamNicNotFound=Network team interface with name {0} not found.
    teamNicVlanMismatch=Vlan ID is different from the requested ID of {0}.
    modifyTeamNic=Modifying the network team interface named {0}.
    createTeamNic=Creating a network team interface with the name {0}.
    removeTeamNic=Removing a network team interface with the name {0}.
    teamNicExistsNoAction=Network team interface with name {0} exists. No action needed.
    teamNicExistsWithDifferentConfig=Network team interface with name {0} exists but with different configuration. This will be modified.
    teamNicDoesNotExistShouldCreate=Network team interface with name {0} does not exist. It will be created.
    teamNicExistsShouldRemove=Network team interface with name {0} exists. It will be removed.
    teamNicDoesNotExistNoAction=Network team interface with name {0} does not exist. No action needed.
    waitingForTeamNic=Waiting for network team interface status to change to up.
    createdNetTeamNic=Network Team Interface was created successfully.
    failedToCreateTeamNic=Failed to create the network team interface with specific configuration.
"@
