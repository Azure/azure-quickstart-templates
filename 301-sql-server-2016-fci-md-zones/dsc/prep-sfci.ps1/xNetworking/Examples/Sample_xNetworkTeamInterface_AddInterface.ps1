configuration Sample_xNetworkTeamInterface_AddInterface
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
            VlanID = 100
            Ensure = 'Present'
            DependsOn = '[xNetworkTeam]HostTeam'
        }
    }
 }

Sample_xNetworkTeamInterface_AddInterface
Start-DscConfiguration -Path Sample_xNetworkTeamInterface_AddInterface -Wait -Verbose -Force
