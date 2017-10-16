configuration Sample_xNetworkTeam_RemoveTeam
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xNetworkTeam HostTeam
        {
          Name = 'HostTeam'
          Ensure = 'Absent'
        }
    }
 }

Sample_xNetworkTeam_RemoveTeam
Start-DscConfiguration -Path Sample_xNetworkTeam_RemoveTeam -Wait -Verbose -Force
