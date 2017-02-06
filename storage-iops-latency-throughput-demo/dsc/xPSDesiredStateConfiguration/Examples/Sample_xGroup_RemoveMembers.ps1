<#
    .SYNOPSIS
        If the group named GroupName1 does not exist, creates a group named GroupName1.
        
        If the group named GroupName1 already exists removes the users that have the usernames
        Username1 or Username2 from the group.
#>
Configuration Sample_xGroup_RemoveMembers
{
    [CmdletBinding()]
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xGroup Group1
    {
        GroupName = 'GroupName1'
        Ensure = 'Present'
        MembersToExclude = @( 'Username1', 'Username2' )
    }
}
