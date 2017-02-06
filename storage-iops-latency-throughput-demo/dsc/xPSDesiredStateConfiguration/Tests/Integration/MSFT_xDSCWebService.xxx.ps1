######################################################################################
# Integration Tests for DSC Resource xDSCWebService
# 
# There tests will make changes to your system, we are tyring to roll them back,
# but you never know. Best to run this on a throwaway VM.
# Run as an elevated administrator 
######################################################################################

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# create a unique name that we use for our temp files and folders
[string]$tempName = "xDSCWebServiceTests_" + (Get-Date).ToString("yyyyMMdd_HHmmss")

Describe "xDSCWebService" {

    function Verify-DSCPullServer ($protocol,$hostname,$port) {
        ([xml](invoke-webrequest "$($protocol)://$($hostname):$($port)/psdscpullserver.svc" | % Content)).service.workspace.collection.href
    }

    function Remove-WebRoot([string]$filePath)
    {
       if (Test-Path $filePath)
       {
           Get-ChildItem $filePath -Recurse | Remove-Item -Recurse
           Remove-Item $filePath
       }
    }

    try
    {


        # before doing our changes, create a backup of the current config        
        Backup-WebConfiguration -Name $tempName


        It 'Installing Service' -test {
        {

            # define the configuration
            configuration InstallingService
            {
                WindowsFeature DSCServiceFeature
                {
                    Ensure = “Present”
                    Name   = “DSC-Service”
                }
            }

            # execute the configuration into a temp location
            InstallingService -OutputPath $env:temp\$($tempName)_InstallingService
            # run the configuration, it should not throw any errors
            Start-DscConfiguration -Path $env:temp\$($tempName)_InstallingService -Wait -Verbose -ErrorAction Stop -Force}  | should not throw

            (Get-WindowsFeature -name DSC-Service | Where Installed).count | should be 1
        }

        It 'Creating Sites' -test {
        {
            # define the configuration
            configuration CreatingSites
            {
                Import-DSCResource -ModuleName xPSDesiredStateConfiguration
                
                xDscWebService PSDSCPullServer
                {
                    EndpointName            = “TestPSDSCPullServer”
                    Port                    = 21001
                    CertificateThumbPrint   = “AllowUnencryptedTraffic”
                }
            }

            # execute the configuration into a temp location
            CreatingSites -OutputPath $env:temp\$($tempName)_CreatingSites
            # run the configuration, it should not throw any errors
            Start-DscConfiguration -Path $env:temp\$($tempName)_CreatingSites -Wait -Verbose -ErrorAction Stop -Force}  | should not throw

            # we now expect two sites starting with our prefix
            (Get-ChildItem iis:\sites | Where-Object Name -match "^TestPSDSC").count | should be 1

            # we expect some files in the web root, using the defaults
            (Test-Path "$env:SystemDrive\inetpub\TestPSDSCPullServer\web.config") | should be $true

            $FireWallRuleDisplayName = "Desired State Configuration - Pull Server Port:{0}"
            $ruleName = ($($FireWallRuleDisplayName) -f "21001")
            (Get-NetFirewallRule | Where-Object DisplayName -eq "$ruleName" | Measure-Object).count | should be 1

            # we also expect an XML document with certain strings at a certain URI
            (Verify-DSCPullServer "http" "localhost" "21001") | should match "Action|Module"

        }

        It 'Removing Sites' -test {
        {

            # define the configuration
            configuration RemovingSites
            {
                Import-DSCResource -ModuleName xPSDesiredStateConfiguration

                xDscWebService PSDSCPullServer
                {
                    Ensure                  = “Absent”
                    EndpointName            = “TestPSDSCPullServer”
                    CertificateThumbPrint   = “NotUsed”
                }
            }

            # execute the configuration into a temp location
            RemovingSites -OutputPath $env:temp\$($tempName)_RemovingSites
            # run the configuration, it should not throw any errors
            Start-DscConfiguration -Path $env:temp\$($tempName)_RemovingSites -Wait -Verbose -ErrorAction Stop -Force}  | should not throw

            # we now expect two sites starting with our prefix
            (Get-ChildItem iis:\sites | Where-Object Name -match "^TestPSDSC").count | should be 0

            (Test-Path "$env:SystemDrive\inetpub\TestPSDSCPullServer\web.config") | should be $false

            $FireWallRuleDisplayName = "Desired State Configuration - Pull Server Port:{0}"
            $ruleName = ($($FireWallRuleDisplayName) -f "8081")
            (Get-NetFirewallRule | Where-Object DisplayName -eq "$ruleName" | Measure-Object).count | should be 0

        }

        It 'CreatingSitesWithFTP' -test {
        {
            # create a new FTP site on IIS
            If (!(Test-Path IIS:\Sites\DummyFTPSite))
            {
                New-WebFtpSite -Name "DummyFTPSite" -Port "21000"
                # stop the site, we don't want it, it is just here to check whether setup works
                (get-Website -Name "DummyFTPSite").ftpserver.stop()
            }

            # define the configuration
            configuration CreatingSitesWithFTP
            {
                Import-DSCResource -ModuleName xPSDesiredStateConfiguration

                xDscWebService PSDSCPullServer2
                {
                    EndpointName            = “TestPSDSCPullServer2”
                    Port                    = 21003
                    CertificateThumbPrint   = “AllowUnencryptedTraffic”
                }
            }

            # execute the configuration into a temp location
            CreatingSitesWithFTP -OutputPath $env:temp\$($tempName)_CreatingSitesWithFTP
            # run the configuration, it should not throw any errors
            Start-DscConfiguration -Path $env:temp\$($tempName)_CreatingSitesWithFTP -Wait -Verbose -ErrorAction Stop -Force}  | should not throw

        }

    }
    finally
    {
        # roll back our changes
        Restore-WebConfiguration -Name $tempName
        Remove-WebConfigurationBackup -Name $tempName

        # remove possible web files
        Remove-WebRoot -filePath "$env:SystemDrive\inetpub\TestPSDSCPullServer"
        Remove-WebRoot -filePath "$env:SystemDrive\inetpub\TestPSDSCPullServer2"

        # remove the generated MoF files
        Get-ChildItem $env:temp -Filter $tempName* | Remove-item -Recurse

        # remove all firewall rules starting with port 21*
        Get-NetFirewallRule | Where-Object DisplayName -match "^Desired State Configuration - Pull Server Port:21" | Remove-NetFirewallRule

    } 
}
