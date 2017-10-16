configuration Sample_xNetworkTeam_UpdateTeamMembers
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
          TeamMembers = 'NIC1','NIC2','NIC3'
          Ensure = 'Present'
        }
    }
 }

Sample_xNetworkTeam_UpdateTeamMembers
Start-DscConfiguration -Path Sample_xNetworkTeam_UpdateTeamMembers -Wait -Verbose -Force
