$script:DSCModuleName   = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xWebsite'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

[String] $tempName = "$($script:DSCResourceName)_" + (Get-Date).ToString('yyyyMMdd_HHmmss')

try
{
    # Now that xWebAdministration should be discoverable, load the configuration data
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $configFile

    $null = Backup-WebConfiguration -Name $tempName

    $dscConfig = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName "$($script:DSCResourceName).config.psd1"

    # Create a SelfSigned Cert
    $selfSignedCert = (New-SelfSignedCertificate -DnsName $dscConfig.AllNodes.HTTPSHostname  -CertStoreLocation 'cert:\LocalMachine\My')
    
    #region HelperFunctions

   # Function needed to test AuthenticationInfo
    function Get-AuthenticationInfo
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [String] $Type,

            [Parameter(Mandatory = $true)]
            [String] $Website
        )

        (Get-WebConfigurationProperty `
            -Filter /system.WebServer/security/authentication/${Type}Authentication `
            -Name enabled `
            -Location $Website).Value
    }

    #endregion

    Describe "$($script:DSCResourceName)_Present_Started" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Present_Started -ConfigurationData `$dscConfig -OutputPath `$TestDrive -CertificateThumbprint `$selfSignedCert.Thumbprint"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should Create a Started Website with correct settings' -test {
            
            Invoke-Expression -Command "$($script:DSCResourceName)_Present_Started -ConfigurationData `$dscConfg  -OutputPath `$TestDrive -CertificateThumbprint `$selfSignedCert.Thumbprint"

            # Build results to test
            $result = Get-Website -Name $dscConfig.AllNodes.Website
            
            $defultPages = Get-WebConfiguration `
                -Filter '//defaultDocument/files/*' `
                -PSPath 'IIS:\Sites\Website' |
                ForEach-Object -Process {Write-Output -InputObject $_.value}

            $serviceAutoStartProviders = (Get-WebConfiguration -filter /system.applicationHost/serviceAutoStartProviders).Collection

            # Test Website basic settings are correct
            $result.Name             | Should Be $dscConfig.AllNodes.Website
            $result.PhysicalPath     | Should Be $dscConfig.AllNodes.PhysicalPath
            $result.State            | Should Be 'Started'
            $result.ApplicationPool  | Should Be $dscConfig.AllNodes.ApplicationPool
            $result.EnabledProtocols | Should Be $dscConfig.AllNodes.EnabledProtocols
            
            # Test Website AuthenticationInfo are correct
            Get-AuthenticationInfo -Type 'Anonymous' -Website $dscConfig.AllNodes.Website | Should Be $dscConfig.AllNodes.AuthenticationInfoAnonymous
            Get-AuthenticationInfo -Type 'Basic' -Website $dscConfig.AllNodes.Website     | Should Be $dscConfig.AllNodes.AuthenticationInfoBasic
            Get-AuthenticationInfo -Type 'Digest' -Website $dscConfig.AllNodes.Website    | Should Be $dscConfig.AllNodes.AuthenticationInfoDigest
            Get-AuthenticationInfo -Type 'Windows' -Website $dscConfig.AllNodes.Website   | Should Be $dscConfig.AllNodes.AuthenticationInfoWindows
            
            # Test Website Application settings
            $result.ApplicationDefaults.PreloadEnabled           | Should Be $dscConfig.AllNodes.PreloadEnabled
            $result.ApplicationDefaults.ServiceAutoStartProvider | Should Be $dscConfig.AllNodes.ServiceAutoStartProvider
            $result.ApplicationDefaults.ServiceAutoStartEnabled  | Should Be $dscConfig.AllNodes.ServiceAutoStartEnabled
            
            # Test the serviceAutoStartProviders are present in IIS config
            $serviceAutoStartProviders.Name | Should Be $dscConfig.AllNodes.ServiceAutoStartProvider
            $serviceAutoStartProviders.Type | Should Be $dscConfig.AllNodes.ApplicationType

            # Test bindings are correct
            $result.bindings.Collection.Protocol                | Should Match $dscConfig.AllNodes.HTTPProtocol
            $result.bindings.Collection.BindingInformation[0]   | Should Match $dscConfig.AllNodes.HTTP1Hostname
            $result.bindings.Collection.BindingInformation[1]   | Should Match $dscConfig.AllNodes.HTTP2Hostname
            $result.bindings.Collection.BindingInformation[2]   | Should Match $dscConfig.AllNodes.HTTPSHostname
            $result.bindings.Collection.BindingInformation[0]   | Should Match $dscConfig.AllNodes.HTTPPort
            $result.bindings.Collection.BindingInformation[1]   | Should Match $dscConfig.AllNodes.HTTPPort
            $result.bindings.Collection.BindingInformation[2]   | Should Match $dscConfig.AllNodes.HTTPSPort
            $result.bindings.Collection.certificateHash[2]      | Should Be $selfSignedCert.Thumbprint
            $result.bindings.Collection.certificateStoreName[2] | Should Be $dscConfig.AllNodes.CertificateStoreName
            
            #Test DefaultPage is correct
            $defultPages[0] | Should Match $dscConfig.AllNodes.DefaultPage

            }

    }

    Describe "$($script:DSCResourceName)_Present_Stopped" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Present_Stopped -ConfigurationData `$dscConfig -OutputPath `$TestDrive -CertificateThumbprint `$selfSignedCert.Thumbprint"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion
        
        It 'Should Create a Stopped Website with correct settings' -test {
            
            Invoke-Expression -Command "$($script:DSCResourceName)_Present_Stopped -ConfigurationData `$dscConfg  -OutputPath `$TestDrive -CertificateThumbprint `$selfSignedCert.Thumbprint"

            # Build results to test
            $result = Get-Website -Name $dscConfig.AllNodes.Website
            
            $defultPages = Get-WebConfiguration `
                -Filter '//defaultDocument/files/*' `
                -PSPath 'IIS:\Sites\Website' |
                ForEach-Object -Process {Write-Output -InputObject $_.value}

            $serviceAutoStartProviders = (Get-WebConfiguration -filter /system.applicationHost/serviceAutoStartProviders).Collection

            # Test Website basic settings are correct
            $result.Name             | Should Be $dscConfig.AllNodes.Website
            $result.PhysicalPath     | Should Be $dscConfig.AllNodes.PhysicalPath
            $result.State            | Should Be 'Stopped'
            $result.ApplicationPool  | Should Be $dscConfig.AllNodes.ApplicationPool
            $result.EnabledProtocols | Should Be $dscConfig.AllNodes.EnabledProtocols
            
            # Test Website AuthenticationInfo are correct
            Get-AuthenticationInfo -Type 'Anonymous' -Website $dscConfig.AllNodes.Website | Should Be $dscConfig.AllNodes.AuthenticationInfoAnonymous
            Get-AuthenticationInfo -Type 'Basic' -Website $dscConfig.AllNodes.Website     | Should Be $dscConfig.AllNodes.AuthenticationInfoBasic
            Get-AuthenticationInfo -Type 'Digest' -Website $dscConfig.AllNodes.Website    | Should Be $dscConfig.AllNodes.AuthenticationInfoDigest
            Get-AuthenticationInfo -Type 'Windows' -Website $dscConfig.AllNodes.Website   | Should Be $dscConfig.AllNodes.AuthenticationInfoWindows
            
            # Test Website Application settings
            $result.ApplicationDefaults.PreloadEnabled           | Should Be $dscConfig.AllNodes.PreloadEnabled
            $result.ApplicationDefaults.ServiceAutoStartProvider | Should Be $dscConfig.AllNodes.ServiceAutoStartProvider
            $result.ApplicationDefaults.ServiceAutoStartEnabled  | Should Be $dscConfig.AllNodes.ServiceAutoStartEnabled

            # Test the serviceAutoStartProviders are present in IIS config
            $serviceAutoStartProviders.Name | Should Be $dscConfig.AllNodes.ServiceAutoStartProvider
            $serviceAutoStartProviders.Type | Should Be $dscConfig.AllNodes.ApplicationType

            # Test bindings are correct
            $result.bindings.Collection.Protocol                | Should Match $dscConfig.AllNodes.HTTPProtocol
            $result.bindings.Collection.BindingInformation[0]   | Should Match $dscConfig.AllNodes.HTTP1Hostname
            $result.bindings.Collection.BindingInformation[1]   | Should Match $dscConfig.AllNodes.HTTP2Hostname
            $result.bindings.Collection.BindingInformation[2]   | Should Match $dscConfig.AllNodes.HTTPSHostname
            $result.bindings.Collection.BindingInformation[0]   | Should Match $dscConfig.AllNodes.HTTPPort
            $result.bindings.Collection.BindingInformation[1]   | Should Match $dscConfig.AllNodes.HTTPPort
            $result.bindings.Collection.BindingInformation[2]   | Should Match $dscConfig.AllNodes.HTTPSPort
            $result.bindings.Collection.certificateHash[2]      | Should Be $selfSignedCert.Thumbprint
            $result.bindings.Collection.certificateStoreName[2] | Should Be $dscConfig.AllNodes.CertificateStoreName
            
            #Test DefaultPage is correct
            $defultPages[0] | Should Match $dscConfig.AllNodes.DefaultPage

            }

    }

    Describe "$($script:DSCResourceName)_Absent" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Absent -ConfigurationData `$dscConfig -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion
        
        It 'Should remove the Website' -test {
            
            Invoke-Expression -Command "$($script:DSCResourceName)_Absent -ConfigurationData `$dscConfg  -OutputPath `$TestDrive"

            # Build results to test
            $result = Get-Website -Name $dscConfig.AllNodes.Website
            
            # Test Website is removed
            $result | Should BeNullOrEmpty 
            
            }

    }

    Describe 'MSFT_xWebBindingInformation' {
        # Directly interacting with Cim classes is not supported by PowerShell DSC
        # it is being done here explicitly for the purpose of testing. Please do not
        # do this in actual resource code
   
        $storeNames = (Get-CimClass -Namespace 'root/microsoft/Windows/DesiredStateConfiguration' -ClassName 'MSFT_xWebBindingInformation').CimClassProperties['CertificateStoreName'].Qualifiers['Values'].Value

        foreach ($storeName in $storeNames)
        {
            It "Uses valid credential store: $storeName" {
                (Join-Path -Path Cert:\LocalMachine -ChildPath $storeName) | Should Exist
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-WebConfiguration -Name $tempName
    Remove-WebConfigurationBackup -Name $tempName

    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
