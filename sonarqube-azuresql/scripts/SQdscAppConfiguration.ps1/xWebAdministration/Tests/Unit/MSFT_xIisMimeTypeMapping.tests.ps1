
$script:DSCModuleName = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xIisMimeTypeMapping'

#region HEADER

$moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
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
    #region Pester Tests
    
    InModuleScope $DSCResourceName {
    
        $mockMapping =
        @{
            fileExtension = 'mockFileExtension'
            mimeType = 'mockMimeType'
        }

        #region testing Get-TargetResource
        Describe 'MSFT_xIisMimeTypeMapping\Get-TargetResource' {
            Mock -CommandName Assert-Module -MockWith {}
            
            Context 'MimeType is Absent' {
                Mock -CommandName Get-Mapping -MockWith { return $null }
                
                It 'Should return the correct hashtable' {
                    $result = Get-TargetResource -Extension 'mockExtension' -MimeType 'mockType' -Ensure 'Absent'
                    $result.Ensure    | Should be 'Absent'
                    $result.Extension | Should be $null
                    $result.MimeType  | Should be $null
                }
            }
            
            Context 'MimeType is Present' {
                Mock -CommandName Get-Mapping -MockWith { return $mockMapping }
                
                It 'Should return the correct hashtable' {
                    $result = Get-TargetResource -Extension 'mockExtension' -MimeType 'mockType' -Ensure 'Absent'
                    $result.Ensure    | Should be 'Present'
                    $result.Extension | Should be $mockMapping.fileExtension
                    $result.MimeType  | Should be $mockMapping.mimeType
                }
            }
        }
        #endregion

        #region testing Set-TargetResource
        Describe 'MSFT_xIisMimeTypeMapping\Set-TargetResource' {
            Mock -CommandName Assert-Module -MockWith {}
            
            Context 'Add MimeType' {
                 Mock -CommandName Get-Mapping -MockWith { return $null }
                 Mock -CommandName Add-WebConfigurationProperty -MockWith {}
                 
                 Set-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Present'
                 It 'should call all the mocks' {
                    Assert-MockCalled -CommandName Get-Mapping -Exactly 1
                    Assert-MockCalled -CommandName Add-WebConfigurationProperty -Exactly 1
                 }
            }
            
            Context 'Remove MimeType' {
                 Mock -CommandName Get-Mapping -MockWith { return 'mock' }
                 Mock -CommandName Remove-WebConfigurationProperty -MockWith {}
                 
                 Set-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Absent'
                 It 'should call all the mocks' {
                    Assert-MockCalled -CommandName Get-Mapping -Exactly 1
                    Assert-MockCalled -CommandName Remove-WebConfigurationProperty -Exactly 1
                 }
            }
            
            Context 'MimeType that does not exist trying to be removed' {
                 Mock -CommandName Get-Mapping -MockWith { return $null }
                 
                 Set-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Absent'
                 It 'should call all the mocks' {
                    Assert-MockCalled -CommandName Get-Mapping -Exactly 1
                 }
            }
            
            Context 'MimeType that already exists trying to be added' {
                 Mock -CommandName Get-Mapping -MockWith { return 'mock' }
                 
                 Set-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Present'
                 It 'should call all the mocks' {
                    Assert-MockCalled -CommandName Get-Mapping -Exactly 1
                 }
            }     
        }
        #endregion
        
        #region testing Test-TargetResource
        Describe 'MSFT_xIisMimeTypeMapping\Test-TargetResource' {
            Mock -CommandName Assert-Module -MockWith {}
            
            Context 'Mapping could not be found with Ensure = to Present' {
                 Mock -CommandName Get-Mapping -MockWith { return $null }
                 
                 $result = Test-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Present'
                 It 'should return false' {
                    $result | Should be $false
                 }
            }
            Context 'Mapping found but Ensure = to Absent' {
                 Mock -CommandName Get-Mapping -MockWith { return $mockMapping }
                 
                 $result = Test-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Absent'
                 It 'should return false' {
                    $result | Should be $false
                 }
            }
            Context 'Mapping found and type exists' {
                 Mock -CommandName Get-Mapping -MockWith { return $mockMapping }
                 
                 $result = Test-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Present'
                 It 'should return true' {
                    $result | Should be $true
                 }
            }
            Context 'Mapping not found and type is absent' {
                 Mock -CommandName Get-Mapping -MockWith { return $null }
                 
                 $result = Test-TargetResource -Extension 'mockExtension' -MimeType 'mockMimeType' -Ensure 'Absent'
                 It 'should return true' {
                    $result | Should be $true
                 }
            }
        }
        #endregion
        
        #region Get-Mapping
        Describe 'MSFT_xIisMimeTypeMapping\Get-Mapping' {
            
            Context 'Get-mapping with Extension and Type' {
                Mock -CommandName Get-WebConfigurationProperty -MockWith { return $mockMapping }
                
                $result = Get-Mapping -Extension 'mockExtension' -Type 'mockType'
                It 'should return $mockMapping' {
                    $result | Should be $mockMapping
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

}
