Configuration InstallWindowsFeatures {

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node "localhost" {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
            ActionAfterReboot  = 'ContinueConfiguration'
        }

        WindowsFeature Hyper-V {
            Name   = "Hyper-V"
            Ensure = "Present"
        }
        WindowsFeature DHCP {
            Name   = "DHCP"
            Ensure = "Present"
        }
        WindowsFeature RemoteAccess {
            Name   = "RemoteAccess"
            Ensure = "Present"
        }
        WindowsFeature Routing {
            Name   = "Routing"
            Ensure = "Present"
        }
        
    }
}