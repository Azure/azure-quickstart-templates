configuration Sample_xNetworkTeamInterface_RemoveInterface
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
          TeamingMode = 'SwitchIndependent'
          LoadBalancingAlgorithm = 'HyperVPort'
          TeamMembers = 'NIC1','NIC2'
          Ensure = 'Present'
        }
        
        xNetworkTeamInterface NewInterface {
            Name = 'NewInterface'
            TeamName = 'HostTeam'
            Ensure = 'Absent'
            DependsOn = '[xNetworkTeam]HostTeam'
        }
    }
 }

Sample_xNetworkTeamInterface_RemoveInterface
Start-DscConfiguration -Path Sample_xNetworkTeamInterface_RemoveInterface -Wait -Verbose -Force
