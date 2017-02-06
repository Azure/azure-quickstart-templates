<#
 *
 * Once you setup your pull server with registration, run the following set of tests on the pull server machine
 * to verify if the pullserver is setup properly and ready to go.
 #>

<#
 * Prerequisites:
 * You need Pester module to run this test.
 * With PowerShell 5, use Install-Module Pester to install the module if it is not on pull server node.
 * With older PowerShell, install PackageManagement extensions first.
 #>

<#
 * Run the test via Invoke-Pester ./PullServerSetupTests.ps1
 * This test assumes default values are used during deployment for the location of web.config and pull server URL.
 * If default values are not used during deployment , please update these values in the 'BeforeAll' block accordingly.
 #>


Describe PullServerInstallationTests {
    BeforeAll{
 
        # UPDATE THE PULLSERVER URL, If it is different from the default value.
        $DscHostFQDN = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName
        $DscPullServerURL = "https://$($DscHostFQDN):8080/PSDSCPullserver.svc"

        # UPDATE THE LOCATION OF WEB.CONFIG, if it is differnet from the default path.
        $DscWebConfigChildPath = '\inetpub\wwwroot\psdscpullserver\web.config'
        $DscWebConfigPath = Join-Path -Path $env:SystemDrive -ChildPath $DscWebConfigChildPath

        # Skip all tests if web.config is not found
        if (-not (Test-Path $DscWebConfigPath)){
            Write-Error 'No pullserver web.config found.' -ErrorAction Stop
        }

        # Get web.config content as XML
        $DscWebConfigXML = [xml](Get-Content $DscWebConfigPath)

        # Registration Keys info.
        $DscRegKeyName = 'RegistrationKeys.txt'
        $DscRegKeyXMLNode = "//appSettings/add[@key = 'RegistrationKeyPath']"
        $DscRegKeyParentPath = ($DscWebConfigXML.SelectNodes($DscRegKeyXMLNode)).value
        $DscRegKeyPath = Join-Path -Path $DscRegKeyParentPath -ChildPath $DscRegKeyName
        $DscRegKey = Get-Content $DscRegKeyPath

        # Configuration repository info.
        $DscConfigPathXMLNode = "//appSettings/add[@key = 'ConfigurationPath']"
        $DscConfigPath  = ($DscWebConfigXML.SelectNodes($DscConfigPathXMLNode)).value

        # Module repository info.
        $DscModulePathXMLNode = "//appSettings/add[@key = 'ModulePath']"
        $DscModulePath = ($DscWebConfigXML.SelectNodes($DscModulePathXMLNode)).value

        # Testing Files/Variables
        $DscTestMetaConfigName = 'PullServerSetupTestMetaConfig'
        $DscTestMetaConfigPath = Join-Path -Path $PSScriptRoot -ChildPath $DscTestMetaConfigName
        $DscTestConfigName = 'PullServerSetUpTest'
        $DscTestMofPath = Join-Path -Path $DscConfigPath -ChildPath "$DscTestConfigName.mof"
    }
    Context "Verify general pull server functionality" {
        It "$DscRegKeyPath exists" {
            $DscRegKeyPath | Should Exist
        }
        It "Module repository $DscModulePath exists" {
            $DscModulePath | Should Exist 
        }
        It "Configuration repository $DscConfigPath exists" {
            $DscConfigPath | Should Exist 
        }
        It "Verify server $DscPullServerURL is up and running" {
            $DscPullServerResponse = Invoke-WebRequest -Uri $DscPullServerURL -UseBasicParsing
            $DscPullServerResponse.StatusCode | Should Be 200
        }
    }
    Context "Verify pull end to end works" {
        It 'Tests local configuration manager' {
            [DscLocalConfigurationManager()]
            Configuration $DscTestMetaConfigName
            {
                Settings
                {
                    RefreshMode = "PULL"             
                }
                ConfigurationRepositoryWeb ConfigurationManager
                {
                    ServerURL =  $DscPullServerURL
                    RegistrationKey = $DscRegKey
                    ConfigurationNames = @($DscTestConfigName)
                }
            }

            PullServerSetupTestMetaConfig -OutputPath $DscTestMetaConfigPath
            Set-DscLocalConfigurationManager -Path $DscTestMetaConfigPath -Verbose:$VerbosePreference -Force

            $DscLocalConfigNames = (Get-DscLocalConfigurationManager).ConfigurationDownloadManagers.ConfigurationNames
            $DscLocalConfigNames -contains $DscTestConfigName | Should Be True
        }
        It "Creates mof and checksum files in $DscConfigPath" {
            # Sample test configuration 
            Configuration NoOpConfig {
                Import-DscResource -ModuleName PSDesiredStateConfiguration
                Node ($DscTestConfigName)
                {
                    Script script
                    {
                        GetScript = "@{}"
                        SetScript = "{}"            
                        TestScript =  {
                            if ($false) { return $true } else {return $false}
                        }
                    }
                }
            }

            # Create a mof file copy it to 
            NoOpConfig -OutputPath $DscConfigPath -Verbose:$VerbosePreference
            $DscTestMofPath | Should Exist

            # Create checksum 
            New-DscChecksum $DscConfigPath -Verbose:$VerbosePreference -Force
            "$DscTestMofPath.checksum" | Should Exist
        }
        It 'Updates DscConfiguration Successfully' {
            Update-DscConfiguration -Wait -Verbose:$VerbosePreference 
            (Get-DscConfiguration).ConfigurationName | Should Be "NoOpConfig"
        }
    }
}
