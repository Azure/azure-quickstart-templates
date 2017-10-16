$script:DSCModuleName      = 'xNetworking'
$script:DSCResourceName    = 'MSFT_xHostsFile'

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {

        Describe 'MSFT_xHostsFile' {

            Mock Add-Content {}
            Mock Set-Content {}

            Context "A host entry doesn't exist, and should" {
                $testParams = @{
                    HostName = "www.contoso.com"
                    IPAddress = "192.168.0.156"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        ""
                    )
                }

                It "should return absent from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "should return false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "should create the entry in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Add-Content
                }
            }

            Context "A host entry exists but has the wrong IP address" {
                $testParams = @{
                    HostName = "www.contoso.com"
                    IPAddress = "192.168.0.156"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        "127.0.0.1         $($testParams.HostName)",
                        ""
                    )
                }

                It "should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "should return false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "should update the entry in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Set-Content
                }
            }

            Context "A host entry exists with the correct IP address" {
                $testParams = @{
                    HostName = "www.contoso.com"
                    IPAddress = "192.168.0.156"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        "$($testParams.IPAddress)         $($testParams.HostName)",
                        ""
                    )
                }

                It "should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "should return true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "A host entry exists but it shouldn't" {
                $testParams = @{
                    HostName = "www.contoso.com"
                    Ensure = "Absent"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        "127.0.0.1         $($testParams.HostName)",
                        ""
                    )
                }

                It "should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "should return false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "should remove the entry in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Set-Content
                }
            }

            Context "A host entry doesn't it exist and shouldn't" {
                $testParams = @{
                    HostName = "www.contoso.com"
                    Ensure = "Absent"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        ""
                    )
                }

                It "should return absent from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Absent"
                }

                It "should return true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "A host entry exists and is correct, but it listed with multiple entries on one line" {
                $testParams = @{
                    HostName = "www.contoso.com"
                    IPAddress = "192.168.0.156"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        "$($testParams.IPAddress)         demo.contoso.com   $($testParams.HostName) more.examples.com",
                        ""
                    )
                }

                It "should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "should return true from the test method" {
                    Test-TargetResource @testParams | Should Be $true
                }
            }

            Context "A host entry exists and is not correct, but it listed with multiple entries on one line" {
                $testParams = @{
                    HostName = "www.contoso.com"
                    IPAddress = "192.168.0.156"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        "127.0.0.1         demo.contoso.com   $($testParams.HostName) more.examples.com",
                        ""
                    )
                }

                It "should return present from the get method" {
                    (Get-TargetResource @testParams).Ensure | Should Be "Present"
                }

                It "should return false from the test method" {
                    Test-TargetResource @testParams | Should Be $false
                }

                It "should update the entry in the set method" {
                    Set-TargetResource @testParams
                    Assert-MockCalled Set-Content
                }
            }

            Context "Invalid parameters will throw meaningful errors" {
                $testParams = @{
                    HostName = "www.contoso.com"
                }

                Mock Get-Content {
                    return @(
                        "# A mocked example of a host file - this line is a comment",
                        "",
                        "127.0.0.1       localhost",
                        "127.0.0.1  www.anotherexample.com",
                        ""
                    )
                }

                It "should throw an error when IP Address isn't provide and ensure is present" {
                    { Set-TargetResource @testParams } | Should throw $LocalizedData.UnableToEnsureWithoutIP
                }
            }
        }
    } #end InModuleScope $DSCResourceName
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
