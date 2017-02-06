Import-Module -Name (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'CommonTestHelper.psm1')

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xWindowsPackageCab' `
    -TestType 'Unit'

try
{
    InModuleScope 'MSFT_xWindowsPackageCab' {
        Describe 'xWindowsPackageCab Unit Tests' {
            BeforeAll {
                Import-Module -Name 'Dism'

                $script:testPackageName = 'TestPackage'
                $script:testSourcePath = Join-Path -Path $TestDrive -ChildPath 'FakeCabFile.cab'
                $script:testLogPath = Join-Path -Path $TestDrive -ChildPath 'WindowsPackageCabTestLog.log'

                New-Item -Path $script:testSourcePath -ItemType 'File'
            }

            Context 'Get-TargetResource' {
                Mock -CommandName 'Dism\Get-WindowsPackage' -MockWith { }

                $getTargetResourceCommonParams = @{
                    SourcePath = $script:testSourcePath
                    Ensure = 'Present'
                }

                It 'Should return Ensure as Absent when package is not installed' {
                    $getTargetResourceResult = Get-TargetResource -Name $script:testPackageName @getTargetResourceCommonParams
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                    
                    Assert-MockCalled -CommandName 'Dism\Get-WindowsPackage'
                }

                It 'Should return Ensure as Absent when package is on machine but not installed' {
                    Mock -CommandName 'Dism\Get-WindowsPackage' -MockWith { return @{ PackageState = 'NotPresent' } }

                    $getTargetResourceResult = Get-TargetResource -Name $script:testPackageName @getTargetResourceCommonParams
                    $getTargetResourceResult.Ensure | Should Be 'Absent'
                    
                    Assert-MockCalled -CommandName 'Dism\Get-WindowsPackage'
                }
        
                It 'Should return Ensure as Present when package is installed' {
                    Mock -CommandName 'Dism\Get-WindowsPackage' -MockWith { return @{ PackageState = 'Installed' } }

                    $getTargetResourceResult = Get-TargetResource -Name $script:testPackageName @getTargetResourceCommonParams
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                    
                    Assert-MockCalled -CommandName 'Dism\Get-WindowsPackage'
                }

                It 'Should return Ensure as Present when package install is pending' {
                    Mock -CommandName 'Dism\Get-WindowsPackage' -MockWith { return @{ PackageState = 'InstallPending' } }

                    $getTargetResourceResult = Get-TargetResource -Name $script:testPackageName @getTargetResourceCommonParams
                    $getTargetResourceResult.Ensure | Should Be 'Present'
                    
                    Assert-MockCalled -CommandName 'Dism\Get-WindowsPackage'
                }

                It 'Should pass specified log path to Get-WindowsPackage' {
                    $null = Get-TargetResource -Name $script:testPackageName -LogPath $script:testLogPath @getTargetResourceCommonParams
                    Assert-MockCalled -CommandName 'Dism\Get-WindowsPackage' -ParameterFilter { $LogPath -eq $script:testLogPath }
                }
            }

            Context 'Set-TargetResource' {
                Mock -CommandName 'Dism\Add-WindowsPackage' -MockWith { }
                Mock -CommandName 'Dism\Remove-WindowsPackage' -MockWith { }

                It 'Should throw when SourcePath is invalid' {
                    $invalidSourcePath = (Join-Path -Path $TestDrive -ChildPath 'DoesNotExist')
                    { Set-TargetResource -Name 'Name' -SourcePath $invalidSourcePath -Ensure 'Absent' } |
                        Should Throw ($script:localizedData.SourcePathDoesNotExist -f $invalidSourcePath)
                }

                It 'Should call Add-WindowsPackage when Ensure is Present' {
                    Set-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Present'
                    Assert-MockCalled -CommandName 'Dism\Add-WindowsPackage'
                }

                It 'Should call Remove-WindowsPackage when Ensure is Absent' {
                    Set-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Absent'
                    Assert-MockCalled -CommandName 'Dism\Remove-WindowsPackage'
                }

                It 'Should pass specified log path to Add-WindowsPackage' {
                    Set-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Present' -LogPath $script:testLogPath
                    Assert-MockCalled -CommandName 'Dism\Add-WindowsPackage' -ParameterFilter { $LogPath -eq $script:testLogPath }
                }

                It 'Should pass specified log path to Remove-WindowsPackage' {
                    Set-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Absent' -LogPath $script:testLogPath
                    Assert-MockCalled -CommandName 'Dism\Remove-WindowsPackage' -ParameterFilter { $LogPath -eq $script:testLogPath }
                }
            }

            Context 'Test-TargetResource' {
                Mock -CommandName 'Get-TargetResource' -MockWith { return @{ Ensure = 'Absent' } }

                It 'Should return true when Get-TargetResource returns Ensure Absent and Ensure is set to Absent' {
                    Test-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Absent' | Should Be $true
                    Assert-MockCalled -CommandName 'Get-TargetResource'
                }

                It 'Should return false when Get-TargetResource returns Ensure Absent and Ensure is set to Present' {
                    Test-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Present' | Should Be $false
                    Assert-MockCalled -CommandName 'Get-TargetResource'
                }

                Mock -CommandName 'Get-TargetResource' -MockWith { return @{ Ensure = 'Present' } }

                It 'Should return true when Get-TargetResource returns Ensure Present and Ensure is set to Present' {
                    Test-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Present' | Should Be $true
                    Assert-MockCalled -CommandName 'Get-TargetResource'
                } 

                It 'Should return false when Get-TargetResource returns Ensure Present and Ensure is set to Absent' {
                    Test-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Absent' | Should Be $false 
                    Assert-MockCalled -CommandName 'Get-TargetResource'
                }

                It 'Should pass specified log path to Get-TargetResource' {
                    $null = Test-TargetResource -Name $script:testPackageName -SourcePath $script:testSourcePath -Ensure 'Absent' -LogPath $script:testLogPath
                    Assert-MockCalled -CommandName 'Get-TargetResource' -ParameterFilter { $LogPath -eq $script:testLogPath }
                }
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
