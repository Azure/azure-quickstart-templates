<#
    .SYNOPSIS
        If the group named GroupName1 does not exist, creates a group named GroupName1 and adds the
        users with the usernames Username1 and Username2 to the group.
        
        If the group named GroupName1 already exists, removes any users that do not have the
        usernames Username1 or Username2 from the group and adds the users that have the usernames
        Username1 and Username2 to the group.
#>
Configuration Sample_xGroup_SetMembers
{
    [CmdletBinding()]
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xGroup Group1
    {
        GroupName = 'GroupName1'
        Ensure = 'Present'
        Members = @( 'Username1', 'Username2' )
    }
}
