$DSCResourceName = 'UserRightsAssignment'
$DSCModuleName   = 'cSecurityOptions'

$Splat = @{
    Path = $PSScriptRoot
    ChildPath = "..\..\DSCResources\$DSCResourceName\$DSCResourceName.psm1"
    Resolve = $true
    ErrorAction = 'Stop'
}

$DSCResourceModuleFile = Get-Item -Path (Join-Path @Splat)

$moduleRoot = "${env:ProgramFiles}\WindowsPowerShell\Modules\$DSCModuleName"

if(-not (Test-Path -Path $moduleRoot))
{
    $null = New-Item -Path $moduleRoot -ItemType Directory
}
else
{
    # Copy the existing folder out to the temp directory to hold until the end of the run
    # Delete the folder to remove the old files.
    $tempLocation = Join-Path -Path $env:Temp -ChildPath $DSCModuleName
    Copy-Item -Path $moduleRoot -Destination $tempLocation -Recurse -Force
    Remove-Item -Path $moduleRoot -Recurse -Force
    $null = New-Item -Path $moduleRoot -ItemType Directory
}

Copy-Item -Path $PSScriptRoot\..\..\* -Destination $moduleRoot -Recurse -Force -Exclude '.git'

if (Get-Module -Name $DSCResourceName)
{
    Remove-Module -Name $DSCResourceName
}

Import-Module -Name $DSCResourceModuleFile.FullName -Force

InModuleScope UserRightsAssignment {

    #######################################################################################

    Describe 'Get-TargetResource' {

        Context 'ServerCore' {
            #region Mocks
            Mock TestServerCore {
                $true
            }
            #endregion
            
            $NonServerCoreConformantAssignments = @(
                'SeChangeNotifyPrivilege',
                'SeIncreaseWorkingSetPrivilege'
            )
            
            foreach ($nonServerCoreConformantAssignment in $nonServerCoreConformantAssignments) {
                It "$nonServerCoreConformantAssignment Privilege should return return Absent" {
                    (get-targetresource -Privilege $nonServerCoreConformantAssignment).Ensure | should be 'Absent'
                }
            }
        }

        Context '0 Users' {
            Mock 'GetAccountsWithUserRight' {
                @{
                    'Account' = ''
                }
            }

            It 'should return ensure Absent' {
                (get-targetresource -Privilege 'SeIncreaseQuotaPrivilege').Ensure | should be 'Absent'
            }
        }

        Context '1 Users' {
            Mock 'GetAccountsWithUserRight' {
                @{
                    'Account' = 'a'
                }
            }

            It 'should return ensure Present' {
                (get-targetresource -Privilege 'SeIncreaseQuotaPrivilege').Ensure | should be 'Present'
            }

            It 'should return proper account' {
                (get-targetresource -Privilege 'SeIncreaseQuotaPrivilege').Identity | should be 'a'
            }
        }

        Context 'Many Users' {
            Mock 'GetAccountsWithUserRight' {
                @{
                    'Account' = 'b', 'c', 'd'
                }
            }

            It 'should return ensure Present' {
                (get-targetresource -Privilege 'SeIncreaseQuotaPrivilege').Ensure | should be 'Present'
            }

            It 'should return proper account' {
                (get-targetresource -Privilege 'SeIncreaseQuotaPrivilege').Identity | should be 'b', 'c', 'd'
            }

        }
}
    Describe 'Test-TargetResource' {

        Mock GetUserRightsAssignment {
             @{
                'Privilege' = $Privilege
                'Identity' = ''
                'Ensure' = 'Absent'
            }
        } -ParameterFilter { $Privilege -eq 'SeNetworkLogonRight' }
        Mock GetUserRightsAssignment {
             @{
                'Privilege' = $Privilege
                'Identity' = 'a'
                'Ensure' = 'Present'
            }
        } -ParameterFilter { $Privilege -eq 'SeTcbPrivilege' }

        Mock FilterIdentity {
            $Identity
        }
        Context 'ServerCore' {
            #region Mocks
            Mock TestServerCore {
                $true
            }
            #endregion
            
            $NonServerCoreConformantAssignments = @(
                'SeChangeNotifyPrivilege',
                'SeIncreaseWorkingSetPrivilege'
            )
            
            foreach ($nonServerCoreConformantAssignment in $nonServerCoreConformantAssignments) {
                $Parameters = @{
                    'Privilege' = $NonServerCoreConformantAssignment
                    'Identity' = 'a'
                    'Ensure' = 'Present'
                }
                It "$nonServerCoreConformantAssignment test for Ensure should be false" {
                    test-targetresource @Parameters | should be $false
                }
            }

            It 'Should return true if Privilege Exists' {
                $Parameters = @{
                    'Privilege' = 'SeTcbPrivilege'
                    'Identity' = 'a'
                    'Ensure' = 'Present'
                }
                test-targetresource @Parameters | should be $True
            }

            It 'Should return false if Privilege Does not Exists' {
                $Parameters = @{
                    'Privilege' = 'SeNetworkLogonRight'
                    'Identity' = 'a'
                    'Ensure' = 'Present'
                }
                test-targetresource @Parameters | should be $False
            }

            It 'Should return false if input identity does not match current identity list (more account than specified)' {
                $Parameters = @{
                    'Privilege' = 'SeTcbPrivilege'
                    'Identity' = 'a','b'
                    'Ensure' = 'Present'
                }
                test-targetresource @Parameters | should be $False
            }

            
            It 'Should return false if input identity does not match current identity list (no accounts specified)' {
                $Parameters = @{
                    'Privilege' = 'SeTcbPrivilege'
                    'Identity' = ''
                    'Ensure' = 'Present'
                }
                test-targetresource @Parameters | should be $False
            }
        }
    }
}