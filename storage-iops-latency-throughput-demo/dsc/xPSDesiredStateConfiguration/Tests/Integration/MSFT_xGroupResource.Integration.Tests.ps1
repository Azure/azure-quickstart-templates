[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xGroupResource' `
    -TestType 'Integration'

try
{
    Describe 'xGroup Integration Tests'  {
        BeforeAll {
            Import-Module -Name (Join-Path -Path $script:testsFolderFilePath -ChildPath 'MSFT_xGroupResource.TestHelper.psm1')

            $script:confgurationNoMembersFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xGroupResource_NoMembers.config.ps1'
            $script:confgurationWithMembersFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xGroupResource_Members.config.ps1'
            $script:confgurationWithMembersToIncludeExcludeFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xGroupResource_MembersToIncludeExclude.config.ps1'
                                                                            
            # Fake users for testing
            $testUsername1 = 'TestUser1'
            $testUsername2 = 'TestUser2'

            $testUsernames = @( $testUsername1, $testUsername2 )

            $testPassword = 'T3stPassw0rd#'
            $secureTestPassword = ConvertTo-SecureString -String $testPassword -AsPlainText -Force

            foreach ($username in $testUsernames)
            {
                $testUserCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @( $username, $secureTestPassword )
                $null = New-User -Credential $testUserCredential
            }
        }

        AfterAll {
            foreach ($username in $testUsernames)
            {
                Remove-User -UserName $username
            }
        }

        It 'Should create an empty group' {
            $configurationName = 'CreateEmptyGroup'
            $testGroupName = 'TestEmptyGroup1'

            $resourceParameters = @{
                Ensure = 'Present'
                GroupName = $testGroupName
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $false

            try
            {
                { 
                    . $script:confgurationWithMembersFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName -Members @() | Should Be $true
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName)
                {
                    Remove-Group -GroupName $testGroupName
                }
            }
        }

        It 'Should not change the state of the present built-in Users group when no Members specified' {
            $configurationName = 'BuiltInGroup'
            $testGroupName = 'Users'

            $resourceParameters = @{
                Ensure = 'Present'
                GroupName = $testGroupName
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $true

            { 
                . $script:confgurationNoMembersFilePath -ConfigurationName $configurationName
                & $configurationName -OutputPath $TestDrive @resourceParameters
                Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
            } | Should Not Throw

            Test-GroupExists -GroupName $testGroupName | Should Be $true
        }

        It 'Should add a member to the built-in Users group with MembersToInclude' {
            $configurationName = 'BuiltInGroup'
            $testGroupName = 'Users'

            $resourceParameters = @{
                Ensure = 'Present'
                GroupName = $testGroupName
                MembersToInclude = $testUsername1
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $true

            { 
                . $script:confgurationWithMembersToIncludeExcludeFilePath -ConfigurationName $configurationName
                & $configurationName -OutputPath $TestDrive @resourceParameters
                Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
            } | Should Not Throw

            Test-GroupExists -GroupName $testGroupName -MembersToInclude $testUsername1 | Should Be $true
        }

        It 'Should create a group with two test users using Members' {
            $configurationName = 'CreateGroupWithTwoMembers'
            $testGroupName = 'TestGroupWithMembers2'

            $groupMembers = $testUsernames

            $resourceParameters = @{
                Ensure = 'Present'
                GroupName = $testGroupName
                Members = $groupMembers
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $false

            try
            {
                { 
                    . $script:confgurationWithMembersFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName -Members $groupMembers | Should Be $true
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName)
                {
                    Remove-Group -GroupName $testGroupName
                }
            }
        }

        It 'Should add a member to a group with MembersToInclude' {
            $configurationName = 'CreateGroupWithTwoMembers'
            $testGroupName = 'TestGroupWithMembersToInclude3'

            $groupMembers = @( $testUsername1 )

            $resourceParameters = @{
                Ensure = 'Present'
                GroupName = $testGroupName
                MembersToInclude = $groupMembers
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $false

            New-Group -GroupName $testGroupName

            Test-GroupExists -GroupName $testGroupName | Should Be $true

            try
            {
                { 
                    . $script:confgurationWithMembersToIncludeExcludeFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName -MembersToInclude $groupMembers | Should Be $true
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName)
                {
                    Remove-Group -GroupName $testGroupName
                }
            }
        }

        It 'Should remove a member from a group with MembersToExclude' {
            $configurationName = 'CreateGroupWithTwoMembers'
            $testGroupName = 'TestGroupWithMembersToInclude3'

            $groupMembersToExclude = @( $testUsername1 )

            $resourceParameters = @{
                Ensure = 'Present'
                GroupName = $testGroupName
                MembersToExclude = $groupMembersToExclude
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $false

            New-Group -GroupName $testGroupName -Members $groupMembersToExclude

            Test-GroupExists -GroupName $testGroupName | Should Be $true

            try
            {
                { 
                    . $script:confgurationWithMembersToIncludeExcludeFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName -MembersToExclude $groupMembersToExclude | Should Be $true
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName)
                {
                    Remove-Group -GroupName $testGroupName
                }
            }
        }

        It 'Should remove a group' {
            $configurationName = 'RemoveGroup'
            $testGroupName = 'TestRemoveGroup1'

            $resourceParameters = @{
                Ensure = 'Absent'
                GroupName = $testGroupName
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $false

            New-Group -GroupName $testGroupName

            Test-GroupExists -GroupName $testGroupName | Should Be $true

            try
            {
                { 
                    . $script:confgurationWithMembersFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @resourceParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName | Should Be $false
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName)
                {
                    Remove-Group -GroupName $testGroupName
                }
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
