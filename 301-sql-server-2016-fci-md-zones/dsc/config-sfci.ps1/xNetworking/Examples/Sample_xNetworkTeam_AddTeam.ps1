configuration Sample_xNetworkTeam_AddTeam
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
    }
 }

Sample_xNetworkTeam_AddTeam
Start-DscConfiguration -Path Sample_xNetworkTeam_AddTeam -Wait -Verbose -Force
