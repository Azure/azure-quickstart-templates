configuration Sample_xNetworkTeamInterface_UpdateInterface
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
            VlanID = 105
            Ensure = 'Present'
            DependsOn = '[xNetworkTeam]HostTeam'
        }
    }
 }

Sample_xNetworkTeamInterface_UpdateInterface
Start-DscConfiguration -Path Sample_xNetworkTeamInterface_UpdateInterface -Wait -Verbose -Force
