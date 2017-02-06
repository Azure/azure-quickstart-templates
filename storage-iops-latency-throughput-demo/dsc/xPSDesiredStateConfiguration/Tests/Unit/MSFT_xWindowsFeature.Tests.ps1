# Needed to create a fake credential
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonTestHelper.psm1') `
                               -Force

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DSCResourceModuleName 'xPSDesiredStateConfiguration' `
    -DSCResourceName 'MSFT_xWindowsFeature' `
    -TestType Unit

try {
    InModuleScope 'MSFT_xWindowsFeature' {

        $testUserName = 'TestUserName12345'
        $testUserPassword = 'StrongOne7.'
        $testSecurePassword = ConvertTo-SecureString -String $testUserPassword -AsPlainText -Force
        $testCredential = New-Object -TypeName PSCredential -ArgumentList ($testUserName, $testSecurePassword)

        $testWindowsFeatureName1 = 'Test1'
        $testWindowsFeatureName2 = 'Test2'
        $testSubFeatureName1 = 'SubTest1'
        $testSubFeatureName2 = 'SubTest2'
        $testSubFeatureName3 = 'SubTest3'


        $mockWindowsFeatures = @{
            Test1 = @{ 
                Name                      = 'Test1'
                DisplayName               = 'Test Feature 1'
                Description               = 'Test Feature with 3 subfeatures'
                Installed                 = $false 
                InstallState              = 'Available' 
                FeatureType               = 'Role Service'
                Path                      = 'Test1'
                Depth                     = 1
                DependsOn                 = @()
                Parent                    = ''
                ServerComponentDescriptor = 'ServerComponent_Test_Cert_Authority'
                Subfeatures               = @('SubTest1','SubTest2','SubTest3')
                SystemService             = @()
                Notification              = @()
                BestPracticesModelId      = $null
                EventQuery                = $null
                PostConfigurationNeeded   = $false
                AdditionalInfo            = @('MajorVersion', 'MinorVersion', 'NumericId', 'InstallName')
            }

            SubTest1 = @{ 
                Name                      = 'SubTest1'
                DisplayName               = 'Sub Test Feature 1'
                Description               = 'Sub Test Feature with parent as test1'
                Installed                 = $true
                InstallState              = 'Available'
                FeatureType               = 'Role Service'
                Path                      = 'Test1\SubTest1'
                Depth                     = 2
                DependsOn                 = @()
                Parent                    = 'Test1'
                ServerComponentDescriptor = $null
                Subfeatures               = @()
                SystemService             = @()
                Notification              = @()
                BestPracticesModelId      = $null
                EventQuery                = $null
                PostConfigurationNeeded   = $false
                AdditionalInfo            = @('MajorVersion', 'MinorVersion', 'NumericId', 'InstallName')
            }

            SubTest2 = @{ 
                Name                      = 'SubTest2'
                DisplayName               = 'Sub Test Feature 2'
                Description               = 'Sub Test Feature with parent as test1'
                Installed                 = $true
                InstallState              = 'Available'
                FeatureType               = 'Role Service'
                Path                      = 'Test1\SubTest2'
                Depth                     = 2
                DependsOn                 = @()
                Parent                    = 'Test1'
                ServerComponentDescriptor = $null
                Subfeatures               = @()
                SystemService             = @()
                Notification              = @()
                BestPracticesModelId      = $null
                EventQuery                = $null
                PostConfigurationNeeded   = $false
                AdditionalInfo            = @('MajorVersion', 'MinorVersion', 'NumericId', 'InstallName')
            }

            SubTest3 = @{
                Name                      = 'SubTest3'
                DisplayName               = 'Sub Test Feature 3'
                Description               = 'Sub Test Feature with parent as test1'
                Installed                 = $true
                InstallState              = 'Available'
                FeatureType               = 'Role Service'
                Path                      = 'Test\SubTest3'
                Depth                     = 2
                DependsOn                 = @()
                Parent                    = 'Test1'
                ServerComponentDescriptor = $null
                Subfeatures               = @()
                SystemService             = @()
                Notification              = @()
                BestPracticesModelId      = $null
                EventQuery                = $null
                PostConfigurationNeeded   = $false
                AdditionalInfo            = @('MajorVersion', 'MinorVersion', 'NumericId', 'InstallName')
            }

            Test2 = @{ 
                Name                      = 'Test2'
                DisplayName               = 'Test Feature 2'
                Description               = 'Test Feature with 0 subfeatures'
                Installed                 = $true 
                InstallState              = 'Available' 
                FeatureType               = 'Role Service'
                Path                      = 'Test2'
                Depth                     = 1
                DependsOn                 = @()
                Parent                    = ''
                ServerComponentDescriptor = 'ServerComponent_Test_Cert_Authority'
                Subfeatures               = @()
                SystemService             = @()
                Notification              = @()
                BestPracticesModelId      = $null
                EventQuery                = $null
                PostConfigurationNeeded   = $false
                AdditionalInfo            = @('MajorVersion', 'MinorVersion', 'NumericId', 'InstallName')
            }
        }


        Describe 'xWindowsFeature/Get-TargetResource' {
            Mock -CommandName Import-ServerManager -MockWith {}

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testWindowsFeatureName2 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testWindowsFeatureName2]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testWindowsFeatureName1 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testWindowsFeatureName1]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testSubFeatureName1 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testSubFeatureName1]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testSubFeatureName2 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testSubFeatureName2]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testSubFeatureName3 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testSubFeatureName3]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }
            

            Context 'Windows Feature exists with no sub features' {
              
                It 'Should return the correct hashtable when not on a 2008 Server' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                    $getTargetResourceResult = Get-TargetResource -Name $testWindowsFeatureName2
                    $getTargetResourceResult.Name | Should Be $testWindowsFeatureName2
                    $getTargetResourceResult.DisplayName | Should Be $mockWindowsFeatures[$testWindowsFeatureName2].DisplayName
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                    $getTargetResourceResult.IncludeAllSubFeature | Should Be $false
                }

                It 'Should return the correct hashtable when on a 2008 Server' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $true }

                    $getTargetResourceResult = Get-TargetResource -Name $testWindowsFeatureName2
                    $getTargetResourceResult.Name | Should Be $testWindowsFeatureName2
                    $getTargetResourceResult.DisplayName | Should Be $mockWindowsFeatures[$testWindowsFeatureName2].DisplayName
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                    $getTargetResourceResult.IncludeAllSubFeature | Should Be $false
                }

                It 'Should return the correct hashtable when on a 2008 Server and Credential is passed' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $true }
                    Mock -CommandName Invoke-Command -MockWith { 
                        $windowsFeature = $mockWindowsFeatures[$testWindowsFeatureName2]
                        $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                        $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                        return $windowsFeatureObject
                    }

                    $getTargetResourceResult = Get-TargetResource -Name $testWindowsFeatureName2 -Credential $testCredential
                    $getTargetResourceResult.Name | Should Be $testWindowsFeatureName2
                    $getTargetResourceResult.DisplayName | Should Be $mockWindowsFeatures[$testWindowsFeatureName2].DisplayName
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                    $getTargetResourceResult.IncludeAllSubFeature | Should Be $false

                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It

                }
            }
            Context 'Windows Feature exists with sub features' {

                It 'Should return the correct hashtable when all subfeatures are installed' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                    $getTargetResourceResult = Get-TargetResource -Name $testWindowsFeatureName1
                    $getTargetResourceResult.Name | Should Be $testWindowsFeatureName1
                    $getTargetResourceResult.DisplayName | Should Be $mockWindowsFeatures[$testWindowsFeatureName1].DisplayName
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                    $getTargetResourceResult.IncludeAllSubFeature | Should Be $true

                    Assert-MockCalled -CommandName Test-IsWinServer2008R2SP1 -Times 1 -Exactly -Scope It
                }

                It 'Should return the correct hashtable when not all subfeatures are installed' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }
                    $mockWindowsFeatures[$testSubFeatureName3].Installed = $false

                    $getTargetResourceResult = Get-TargetResource -Name $testWindowsFeatureName1
                    $getTargetResourceResult.Name | Should Be $testWindowsFeatureName1
                    $getTargetResourceResult.DisplayName | Should Be $mockWindowsFeatures[$testWindowsFeatureName1].DisplayName
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                    $getTargetResourceResult.IncludeAllSubFeature | Should Be $false

                    Assert-MockCalled -CommandName Test-IsWinServer2008R2SP1 -Times 1 -Exactly -Scope It

                    $mockWindowsFeatures[$testSubFeatureName3].Installed = $true
                }
            }

            Context 'Windows Feature does not exist' {

                It 'Should throw invalid operation exception' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }
                    $invalidName = 'InvalidFeature'
                    { Get-TargetResource -Name $invalidName } | Should Throw ($script:localizedData.FeatureNotFoundError -f $invalidName)
                }
            }
        }
        
        Describe 'xWindowsFeature/Set-TargetResource' {
            Mock -CommandName Import-ServerManager -MockWith {}

            Context 'Install/Uninstall successful' {
                Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                Mock -CommandName Add-WindowsFeature -MockWith {
                    $windowsFeature = @{
                        Success = $true
                        RestartNeeded = 'No'
                        FeatureResult = @($testWindowsFeatureName2)
                        ExitCode = 'Success'
                    }
                    $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                    $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                    return $windowsFeatureObject
                }

                Mock -CommandName Remove-WindowsFeature -MockWith {
                    $windowsFeature = @{
                        Success = $true
                        RestartNeeded = 'No'
                        FeatureResult = @($testWindowsFeatureName2)
                        ExitCode = 'Success'
                    }
                    $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                    $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                    return $windowsFeatureObject
                }

                It 'Should call Add-WindowsFeature when Ensure set to Present' {
                    { Set-TargetResource -Name $testWindowsFeatureName2 -Ensure 'Present' } | Should Not Throw
                    Assert-MockCalled -CommandName Add-WindowsFeature -Times 1 -Exactly -Scope It
                }

                It 'Should call Remove-WindowsFeature when Ensure set to Absent' {
                    { Set-TargetResource -Name $testWindowsFeatureName2 -Ensure 'Absent' } | Should Not Throw
                    Assert-MockCalled -CommandName Remove-WindowsFeature -Times 1 -Exactly -Scope It
                }

            }

            Context 'Install/Uninstall unsuccessful' {
                Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                Mock -CommandName Add-WindowsFeature -MockWith {
                    $windowsFeature = @{
                        Success = $false
                        RestartNeeded = 'No'
                        FeatureResult = @($testWindowsFeatureName2)
                        ExitCode = 'Nothing succeeded'
                    }
                    $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                    $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                    return $windowsFeatureObject
                }

                Mock -CommandName Remove-WindowsFeature -MockWith {
                    $windowsFeature = @{
                        Success = $false
                        RestartNeeded = 'No'
                        FeatureResult = @($testWindowsFeatureName2)
                        ExitCode = 'Nothing succeeded'
                    }
                    $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                    $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                    return $windowsFeatureObject
                }

                It 'Should throw invalid operation exception when Ensure set to Present' {
                    { Set-TargetResource -Name $testWindowsFeatureName2 -Ensure 'Present' } | 
                        Should Throw ($script:localizedData.FeatureInstallationFailureError -f $testWindowsFeatureName2)
                    Assert-MockCalled -CommandName Add-WindowsFeature -Times 1 -Exactly -Scope It
                }

                It 'Should throw invalid operation exception when Ensure set to Absent' {
                    { Set-TargetResource -Name $testWindowsFeatureName2 -Ensure 'Absent' } | 
                        Should Throw ($script:localizedData.FeatureUninstallationFailureError -f $testWindowsFeatureName2)
                    Assert-MockCalled -CommandName Remove-WindowsFeature -Times 1 -Exactly -Scope It
                }

            }

            Context 'Uninstall/Install with R2/SP1' {
                Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $true }

                Mock -CommandName Invoke-Command -MockWith {
                    $windowsFeature = @{
                        Success = $true
                        RestartNeeded = 'No'
                        FeatureResult = @($testWindowsFeatureName2)
                        ExitCode = 'Success'
                    }
                    $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                    $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                    return $windowsFeatureObject
                }

                Mock -CommandName 'Add-WindowsFeature' -MockWith { }
                Mock -CommandName 'Remove-WindowsFeature' -MockWith { }

                It 'Should install the feature when Ensure set to Present and Credential passed in' {

                    { 
                        Set-TargetResource -Name $testWindowsFeatureName2 `
                                           -Ensure 'Present' `
                                           -Credential $testCredential
                    } | Should Not Throw
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-WindowsFeature -Times 0 -Scope It
                }

                It 'Should uninstall the feature when Ensure set to Absent and Credential passed in' {

                    { 
                        Set-TargetResource -Name $testWindowsFeatureName2 `
                                           -Ensure 'Absent' `
                                           -Credential $testCredential
                    } | Should Not Throw
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-WindowsFeature -Times 0 -Scope It
                }
            }
        }

        Describe 'xWindowsFeature/Test-TargetResource' {
            Mock -CommandName Import-ServerManager -MockWith {}

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testWindowsFeatureName1 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testWindowsFeatureName1]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testSubFeatureName1 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testSubFeatureName1]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testSubFeatureName2 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testSubFeatureName2]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Mock -CommandName Get-WindowsFeature -ParameterFilter { $Name -eq $testSubFeatureName3 } -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testSubFeatureName3]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            # Used as Get-WindowsFeature when on R2/SP1 2008
            Mock -CommandName Invoke-Command -MockWith {
                $windowsFeature = $mockWindowsFeatures[$testWindowsFeatureName1]
                $windowsFeatureObject = New-Object -TypeName PSObject -Property $windowsFeature
                $windowsFeatureObject.PSTypeNames[0] = 'Microsoft.Windows.ServerManager.Commands.Feature'
            
                return $windowsFeatureObject
            }

            Context 'Feature is in the desired state' {

                It 'Should return true when Ensure set to Absent and Feature not installed' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Absent' `
                                                  -IncludeAllSubFeature $false
                    $testTargetResourceResult | Should Be $true
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 1 -Exactly -Scope It
                }

                It 'Should return true when Ensure set to Present and Feature installed not checking subFeatures' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $true
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Present' `
                                                  -IncludeAllSubFeature $false
                    $testTargetResourceResult | Should Be $true
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 1 -Exactly -Scope It
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $false
                }

                It 'Should return true when Ensure set to Present and Feature and subFeatures installed' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $true
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Present' `
                                                  -IncludeAllSubFeature $true
                    $testTargetResourceResult | Should Be $true
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 4 -Exactly -Scope It
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $false
                }

                It 'Should return true when Ensure set to Absent and Feature not installed and on R2/SP1 2008' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $true }

                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Absent' `
                                                  -IncludeAllSubFeature $false `
                                                  -Credential $testCredential
                    $testTargetResourceResult | Should Be $true
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                }
            }

            Context 'Feature is not in the desired state' {
                Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $false }

                It 'Should return false when Ensure set to Present and Feature not installed' {
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Present' `
                                                  -IncludeAllSubFeature $false
                    $testTargetResourceResult | Should Be $false
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 1 -Exactly -Scope It
                }

                It 'Should return false when Ensure set to Absent and Feature installed not checking subFeatures' {
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $true
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Absent' `
                                                  -IncludeAllSubFeature $false
                    $testTargetResourceResult | Should Be $false
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 1 -Exactly -Scope It
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $false
                }

                It 'Should return false when Ensure set to Present, Feature not installed and subFeatures installed' {
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Present' `
                                                  -IncludeAllSubFeature $true
                    $testTargetResourceResult | Should Be $false
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 1 -Exactly -Scope It
                }

                It 'Should return false when Ensure set to Absent and Feature not installed but subFeatures installed' {
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Absent' `
                                                  -IncludeAllSubFeature $true
                    $testTargetResourceResult | Should Be $false
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 2 -Exactly -Scope It
                }

                It 'Should return false when Ensure set to Absent and Feature installed and subFeatures installed' {
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $true
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Absent' `
                                                  -IncludeAllSubFeature $true
                    $testTargetResourceResult | Should Be $false
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 1 -Exactly -Scope It
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $false
                }

                It 'Should return false when Ensure set to Present and Feature installed but not all subFeatures installed' {
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $true
                    $mockWindowsFeatures[$testSubFeatureName2].Installed = $false
                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Present' `
                                                  -IncludeAllSubFeature $true
                    $testTargetResourceResult | Should Be $false
                    Assert-MockCalled -CommandName Get-WindowsFeature -Times 3 -Exactly -Scope It
                    $mockWindowsFeatures[$testWindowsFeatureName1].Installed = $false
                    $mockWindowsFeatures[$testSubFeatureName2].Installed = $true
                }

                It 'Should return false when Ensure set to Present and Feature not installed and on R2/SP1 2008' {
                    Mock -CommandName Test-IsWinServer2008R2SP1 -MockWith { return $true }

                    $testTargetResourceResult = Test-TargetResource -Name $testWindowsFeatureName1 `
                                                  -Ensure 'Present' `
                                                  -IncludeAllSubFeature $false `
                                                  -Credential $testCredential
                    $testTargetResourceResult | Should Be $false
                    Assert-MockCalled -CommandName Invoke-Command -Times 1 -Exactly -Scope It
                }
            }
        }

        Describe 'xWindowsFeature/Assert-SingleFeatureExists' {
            $multipleFeature = @{
                Name = 'MultiFeatureName'
                Count = 2
            }

            It 'Should throw invalid operation when feature equals null' {
                $nonexistentName = 'NonexistentFeatureName'
                { Assert-SingleFeatureExists -Feature $null -Name $nonexistentName } | 
                    Should Throw ($script:localizedData.FeatureNotFoundError -f $nonexistentName)
            }

            It 'Should throw invalid operation when there are multiple features with the given name' {
                { Assert-SingleFeatureExists -Feature $multipleFeature -Name $multipleFeature.Name } | 
                    Should Throw ($script:localizedData.MultipleFeatureInstancesError -f $multipleFeature.Name)
            }
        }

        Describe 'xWindowsFeature/Import-ServerManager' {
            $mockOperatingSystem = @{
                Name = 'mockOS'
                Version = '6.1.'
                OperatingSystemSKU = 10
            }
            Mock -CommandName Get-WmiObject -MockWith { return $mockOperatingSystem }

            It 'Should Not Throw' {
                Mock -CommandName Import-Module -MockWith {}
                { Import-ServerManager } | Should Not Throw
            }
            
            It 'Should Not Throw when exception is Identity Reference Runtime Exception' {
                $mockIdentityReferenceRuntimeException = New-Object -TypeName System.Management.Automation.RuntimeException -ArgumentList 'Some or all identity references could not be translated'
                Mock -CommandName Import-Module -MockWith { Throw $mockIdentityReferenceRuntimeException }

                { Import-ServerManager } | Should Not Throw
            }
            
            It 'Should throw invalid operation exception when exception is not Identity Reference Runtime Exception' {
                $mockOtherRuntimeException = New-Object -TypeName System.Management.Automation.RuntimeException -ArgumentList 'Other error'
                Mock -CommandName Import-Module -MockWith { Throw $mockOtherRuntimeException }

                { Import-ServerManager } | Should Throw ($script:localizedData.SkuNotSupported)
            }

            It 'Should throw invalid operation exception' {
                Mock -CommandName Import-Module -MockWith { Throw }

                { Import-ServerManager } | Should Throw ($script:localizedData.SkuNotSupported)
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
