
$script:DSCModuleName = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xWebConfigKeyValue'

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'Tests\MockWebAdministrationWindowsFeature.psm1')

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    InModuleScope $script:DSCResourceName {
        $script:DSCModuleName = 'xWebAdministration'
        $script:DSCResourceName = 'MSFT_xWebConfigKeyValue'

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'Value is absent' {
                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName -MockWith {
                    return $null
                }

                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                }

                $result = Get-TargetResource @parameters

                It 'Should return the correct values' {
                    $result.Ensure      | Should Be 'Absent'
                    $result.Key         | Should Be 'Key'
                    $result.Value       | Should Be $null
                }

                It 'Should have called Get-ItemValue the correct amount of times' {
                    Assert-MockCalled -CommandName Get-ItemValue -Times 2 -Exactly
                }
            }

            Context 'Value is present but not an attribute' {
                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $IsAttribute -eq $false } `
                    -MockWith { return 'Value' }

                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                }

                $result = Get-TargetResource @parameters

                It 'Should return the correct values' {
                    $result.Ensure      | Should Be 'Present'
                    $result.Key         | Should Be 'Key'
                    $result.Value       | Should Be 'Value'
                }

                It 'Should have called Get-ItemValue the correct amount of times' {
                    Assert-MockCalled -CommandName Get-ItemValue -Times 1 -Exactly
                }
            }

            Context 'Value is present but is an attribute' {
                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName -MockWith {
                    return $null
                }

                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $isAttribute -eq $true } `
                    -MockWith { return 'Value' }

                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                }

                $result = Get-TargetResource @parameters

                It 'Should return the correct values' {
                    $result.Ensure      | Should Be 'Present'
                    $result.Key         | Should Be 'Key'
                    $result.Value       | Should Be 'Value'
                }

                It 'Should have called Get-ItemValue the correct amount of times' {
                    Assert-MockCalled -CommandName Get-ItemValue -Times 2 -Exactly
                }
            }
        }
        #endregion Function Get-TargetResource

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Ensure is present and is Attribute is False but value is null' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Value         = 'Value'
                    Ensure        = 'Present'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $isAttribute -eq $false } `
                    -MockWith { return $null }

                $result = Test-TargetResource @parameters

                It 'Should return false' {
                    $result | Should Be $false
                }
            }

            Context 'Ensure is present and is Attribute is False but value is an empty string' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Value         = 'Value'
                    Ensure        = 'Present'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $isAttribute -eq $false } `
                    -MockWith { return [System.String]::Empty }

                $result = Test-TargetResource @parameters

                It 'Should return false' {
                    $result | Should Be $false
                }
            }

            Context 'Ensure is present and is Attribute is False but value is wrong' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Value         = 'Value'
                    Ensure        = 'Present'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $isAttribute -eq $false } `
                    -MockWith { return 'WrongValue' }

                $result = Test-TargetResource @parameters

                It 'Should return false' {
                    $result | Should Be $false
                }
            }

            Context 'Ensure is present and is Attribute is False and the value is the same' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Value         = 'Value'
                    Ensure        = 'Present'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $isAttribute -eq $false } `
                    -MockWith { return 'Value' }

                $result = Test-TargetResource @parameters

                It 'Should return true' {
                    $result | Should Be $true
                }
            }

            Context 'Ensure is absent and the value is not null' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Value         = 'Value'
                    Ensure        = 'Absent'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $isAttribute -eq $false } `
                    -MockWith { return 'Value' }

                $result = Test-TargetResource @parameters

                It 'Should return false' {
                    $result | Should Be $false
                }
            }

            Context 'Ensure is absent and the value is null' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Value         = 'Value'
                    Ensure        = 'Absent'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -ModuleName $script:DSCResourceName `
                    -ParameterFilter { $isAttribute -eq $false } `
                    -MockWith { return $null }

                $result = Test-TargetResource @parameters

                It 'Should return true' {
                    $result | Should Be $true
                }
            }
        }
        #endregion Function Test-TargetResource


        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'Ensure is Present and IsAttribute is False and value is not present' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Ensure        = 'Present'
                    Value         = 'Value'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -MockWith { return $null }
                Mock -CommandName Add-Item

                Set-TargetResource @parameters

                It 'Should call the right Mocks' {
                    Assert-MockCalled Get-ItemValue
                    Assert-MockCalled Add-Item
                }
            }

            Context 'Ensure is Present and IsAttribute is True and value is not present' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Ensure        = 'Present'
                    Value         = 'Value'
                    IsAttribute   = $true
                }

                Mock -CommandName Get-ItemValue -MockWith { return [System.String]::Empty }
                Mock -CommandName Add-Item

                Set-TargetResource @parameters

                It 'Should call the right Mocks' {
                    Assert-MockCalled -CommandName Get-ItemValue
                    Assert-MockCalled -CommandName Add-Item
                }
            }

            Context 'Ensure is Present and IsAttribute is True and value is present' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Ensure        = 'Present'
                    Value         = 'Value'
                    IsAttribute   = $true
                }

                Mock -CommandName Get-ItemValue -MockWith { return 'Value' }
                Mock -CommandName Edit-Item -MockWith { return $propertyName }

                $results = Set-TargetResource @parameters

                It 'Should call the right Mocks' {
                    Assert-MockCalled -CommandName Get-ItemValue
                    Assert-MockCalled -CommandName Edit-Item
                }

                It 'Should use the right property value' {
                    $results | Should Be $parameters['Key']
                }
            }

            Context 'Ensure is Present and IsAttribute is False and value is present' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Ensure        = 'Present'
                    Value         = 'Value'
                    IsAttribute   = $false
                }

                Mock -CommandName Get-ItemValue -MockWith { return 'Value' }
                Mock -CommandName Edit-Item -MockWith { return $propertyName }

                $results = Set-TargetResource @parameters

                It 'Should call the right Mocks' {
                    Assert-MockCalled -CommandName Get-ItemValue
                    Assert-MockCalled -CommandName Edit-Item
                }

                It 'Should use the right property value' {
                    $results | Should Be 'value'
                }
            }

            Context 'Ensure is Absent' {
                $parameters = @{
                    WebsitePath   = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                    Key           = 'Key'
                    Ensure        = 'Absent'
                    Value         = 'Value'
                    IsAttribute   = $false
                }

                Mock -CommandName Remove-Item

                Set-TargetResource @parameters

                It 'Should call the right Mocks' {
                    Assert-MockCalled -CommandName Remove-Item
                }
            }
        }
        #endregion Function Set-TargetResource

        #endregion Exported Function Unit Tests

        #region Non-Exported Function Unit Tests
        Describe "$($script:DSCResourceName)\Add-Item" {
            Context 'IsAttribute is false' {
                Mock -CommandName Add-WebConfigurationProperty -MockWith {}

                $parameters = @{
                    Key           = 'Key'
                    Value         = 'Value'
                    IsAttribute   = $false;
                    WebsitePath   = 'C:\somePath\web.config'
                    ConfigSection = 'AppSettings'
                }

                $result = Add-Item @parameters

                It 'Should call Add-WebConfigurationProperty' {
                    Assert-MockCalled -CommandName Add-WebConfigurationProperty
                }
            }

            Context 'IsAttribute is true' {
                Mock -CommandName Set-WebConfigurationProperty -MockWith {}

                $parameters = @{
                    Key           = 'Key'
                    Value         = 'Value'
                    IsAttribute   = $true;
                    WebsitePath   = 'C:\somePath\web.config'
                    ConfigSection = 'AppSettings'
                }

                $result = Add-Item @parameters

                It 'Should call Set-WebConfigurationProperty' {
                    Assert-MockCalled -CommandName Set-WebConfigurationProperty
                }
            }
        }

        Describe "$($script:DSCResourceName)\Edit-Item" {
            Context 'IsAttribute is false' {
                Mock -CommandName Set-WebConfigurationProperty -MockWith { return $filter }

                $parameters = @{
                    PropertyName = 'PropertyName'
                    OldValue     = 'OldValue'
                    NewValue     = 'NewValue'
                    IsAttribute  = $false
                    WebsitePath  = 'C:\test\web.config'
                    ConfigSection = 'AppSettings'
                }

                $result = Edit-Item @parameters

                It 'Should have called the right command' {
                    $result | Should Be "AppSettings/add[@key='OldValue']"
                }

                It 'Should have called Set-WebConfigurationProperty' {
                    Assert-MockCalled -CommandName Set-WebConfigurationProperty
                }
            }

            Context 'IsAttribute is true' {
                Mock -CommandName Set-WebConfigurationProperty -MockWith { return $filter }

                $parameters = @{
                    propertyName = 'PropertyName'
                    OldValue     = 'OldValue'
                    NewValue     = 'NewValue'
                    IsAttribute  = $true
                    WebsitePath  = 'C:\test\web.config'
                    ConfigSection = 'AppSettings'
                }

                $result = Edit-Item @parameters

                It 'Should have called the right command' {
                    $result | Should Be 'AppSettings'
                }

                It 'Should have called Set-WebConfigurationProperty' {
                    Assert-MockCalled -CommandName Set-WebConfigurationProperty
                }
            }
        }

        Describe "$($script:DSCResourceName)\Remove-Item" {
            Context 'IsAttribute is false' {
                Mock  -CommandName Clear-WebConfiguration -MockWith { return $filter }

                $parameters = @{
                    Key = 'Key'
                    IsAttribute = $false
                    WebsitePath = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                }

                $results = Remove-Item @parameters

                It 'Should call the correct functions' {
                    Assert-MockCalled -CommandName Clear-WebConfiguration
                }

                It 'Should use the right filter' {
                    $results | Should Be "AppSettings/add[@key='Key']"
                }

            }

            Context 'IsAttribute is true' {
                Mock -CommandName Clear-WebConfiguration -MockWith { return $filter }
                Mock -CommandName Add-Item

                $parameters = @{
                    Key = 'Key'
                    IsAttribute = $true
                    WebsitePath = 'C:\SomePath\web.config'
                    ConfigSection = 'AppSettings'
                }

                $results = Remove-Item @parameters

                It 'Should call the correct functions' {
                    Assert-MockCalled -CommandName Clear-WebConfiguration -Exactly -Times 2
                    Assert-MockCalled -CommandName Add-Item
                }

                It 'Should use the right filter' {
                    $results[0] | Should Be "AppSettings/@Key"
                    $results[1] | Should Be "AppSettings/add[@key='dummyKey']"
                }
            }
        }
        #endregion Non-Exported Function Unit Tests
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
