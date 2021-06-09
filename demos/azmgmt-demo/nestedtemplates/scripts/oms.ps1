Configuration OMS
{
  
    $OMSPackageLocalPath = 'C:\MMA\MMASetup-AMD64.exe'
    $OMSWorkspaceId = Get-AutomationVariable -Name 'OMSWorkspaceId'
    $OMSWorkspaceKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'


    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost {
        Service OMSService
        {
            Name = "HealthService"
            State = "Running"
        } 

        xRemoteFile OMSPackage {
            Uri = "https://go.microsoft.com/fwlink/?LinkID=517476"
            DestinationPath = $OMSPackageLocalPath
        }

        Package OMS {
            Ensure = "Present"
            Path  = $OMSPackageLocalPath
            Name = 'Microsoft Monitoring Agent'
            ProductId = '8A7F2C51-4C7D-4BFD-9014-91D11F24AAE2'
            Arguments = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=' + $OMSWorkspaceId + ' OPINSIGHTS_WORKSPACE_KEY=' + $OMSWorkspaceKey + ' AcceptEndUserLicenseAgreement=1"'
            DependsOn = '[xRemoteFile]OMSPackage'
        }
    }
}  
