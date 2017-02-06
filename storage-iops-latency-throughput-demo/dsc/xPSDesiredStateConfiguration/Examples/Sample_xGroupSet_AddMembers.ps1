<#
    .SYNOPSIS
        If the groups named GroupName1 and Administrators do not exist, creates the groups named
        GroupName1 and Administrators and adds the users with the usernames Username1 and Username2
        to both groups.
        
        If the groups named GroupName1 and Administrators already exist, adds the users with the
        usernames Username1 and Username2 to both groups.
#>
Configuration Sample_xGroupSet_AddMembers
{
    [CmdletBinding()]
    param ()

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    xGroupSet GroupSet
    {
        GroupName = @( 'Administrators', 'GroupName1' )
        Ensure = 'Present'
        MembersToInclude = @( 'Username1', 'Username2' )
    }
}
