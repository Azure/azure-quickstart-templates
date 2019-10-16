Configuration InstallWindowsFeatures {

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node "localhost" {

        WindowsFeature Hyper-V {
            Name = "Hyper-V"
            Ensure = "Present"
        }
        WindowsFeature DHCP {
            Name = "DHCP"
            Ensure = "Present"
        }
        WindowsFeature RemoteAccess {
            Name = "RemoteAccess"
            Ensure = "Present"
        }
        WindowsFeature Routing {
            Name = "Routing"
            Ensure = "Present"
        }
        
    }
}