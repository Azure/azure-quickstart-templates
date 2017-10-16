$TestTeam = [PSObject]@{
    Name                    = 'TestTeam'
    Members                 =  (Get-NetAdapter -Physical).Name
    loadBalancingAlgorithm  = 'Dynamic'
    teamingMode             = 'SwitchIndependent'
    Ensure                  = 'Present'
}

configuration MSFT_xNetworkTeam_Config
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
          Name = $TestTeam.Name
          TeamingMode = $TestTeam.teamingMode
          LoadBalancingAlgorithm = $TestTeam.loadBalancingAlgorithm
          TeamMembers = $TestTeam.Members
          Ensure = $TestTeam.Ensure
        }
    }
}
