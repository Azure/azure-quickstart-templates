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
    -DscResourceName 'xGroupSet' `
    -TestType 'Integration'

try
{
    Describe 'xGroupSet Integration Tests' {
        BeforeAll {
            # Import xGroup Test Helper for TestGroupExists, New-Group, Remove-Group, New-User, Remove-User
            $groupTestHelperFilePath = Join-Path -Path $script:testsFolderFilePath -ChildPath 'MSFT_xGroupResource.TestHelper.psm1'
            Import-Module -Name $groupTestHelperFilePath

            $script:confgurationFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'xGroupSet.config.ps1'

            # Fake users for testing
            $testUsername1 = 'TestUser1'
            $testUsername2 = 'TestUser2'
            $testUsername3 = 'TestUser3'

            $testUsernames = @( $testUsername1, $testUsername2, $testUsername3 )

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

        It 'Should create a set of two empty groups' {
            $configurationName = 'CreateEmptyGroups'

            $testGroupName1 = 'TestEmptyGroup1'
            $testGroupName2 = 'TestEmptyGroup2'

            $groupSetParameters = @{
                GroupName = @( $testGroupName1, $testGroupName2 )
                Ensure = 'Present'
            }

            Test-GroupExists -GroupName $testGroupName1 | Should Be $false
            Test-GroupExists -GroupName $testGroupName2 | Should Be $false

            try
            {
                { 
                    . $script:confgurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @groupSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName1 -Members @() | Should Be $true
                Test-GroupExists -GroupName $testGroupName2 -Members @() | Should Be $true
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName1)
                {
                    Remove-Group -GroupName $testGroupName1
                }

                if (Test-GroupExists -GroupName $testGroupName2)
                {
                    Remove-Group -GroupName $testGroupName2
                }
            }
        }

        It 'Should create a set of one group with one member' {
            $configurationName = 'CreateOneGroup'

            $testGroupName1 = 'TestGroup1'
            $groupMembers = @( $testUsername1 )

            $groupSetParameters = @{
                GroupName = @( $testGroupName1 )
                Ensure = 'Present'
                MembersToInclude = $groupMembers
            }

            Test-GroupExists -GroupName $testGroupName1 | Should Be $false

            try
            {
                { 
                    . $script:confgurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @groupSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName1 -MembersToInclude $groupMembers | Should Be $true
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName1)
                {
                    Remove-Group -GroupName $testGroupName1
                }
            }
        }

        It 'Should create one group with one member and add the same member to the Administrators group' {
            $configurationName = 'CreateOneGroupAndModifyAdministrators'

            $testGroupName = 'TestGroupWithMember'
            $administratorsGroupName = 'Administrators'

            $groupMembers = @( $testUsername1 )

            $groupSetParameters = @{
                GroupName = @( $testGroupName, $administratorsGroupName )
                Ensure = 'Present'
                MembersToInclude = $groupMembers
            }

            Test-GroupExists -GroupName $testGroupName | Should Be $false
            Test-GroupExists -GroupName $administratorsGroupName | Should Be $true

            try
            {
                { 
                    . $script:confgurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @groupSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                Test-GroupExists -GroupName $testGroupName -MembersToInclude $groupMembers | Should Be $true
                Test-GroupExists -GroupName $administratorsGroupName -MembersToInclude $groupMembers | Should Be $true
            }
            finally
            {
                if (Test-GroupExists -GroupName $testGroupName)
                {
                    Remove-Group -GroupName $testGroupName
                }
            }
        }

        It 'Should remove two members from a set of three groups' {
            $configurationName = 'RemoveTwoMembersFromThreeGroups'
            
            $testGroupNames = @('TestGroupWithMembersToExclude1', 'TestGroupWithMembersToExclude2', 'TestGroupWithMembersToExclude3')

            $groupMembersToExclude = @( $testUsername2, $testUsername3 )

            $groupSetParameters = @{
                GroupName = $testGroupNames
                Ensure = 'Present'
                MembersToExclude = $groupMembersToExclude
            }

            foreach ($testGroupName in $testGroupNames)
            {
                Test-GroupExists -GroupName $testGroupName | Should Be $false

                New-Group -GroupName $testGroupName -Members $testUsernames

                Test-GroupExists -GroupName $testGroupName | Should Be $true
            }

            try
            {
                { 
                    . $script:confgurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @groupSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                foreach ($testGroupName in $testGroupNames)
                {
                    Test-GroupExists -GroupName $testGroupName -MembersToExclude $groupMembersToExclude | Should Be $true
                }
            }
            finally
            {
                foreach ($testGroupName in $testGroupNames)
                {
                    if (Test-GroupExists -GroupName $testGroupName)
                    {
                        Remove-Group -GroupName $testGroupName
                    }
                }
            }
        }

        It 'Should remove a set of groups' {
                $configurationName = 'RemoveThreeGroups'
            
            $testGroupNames = @('TestGroupRemove1', 'TestGroupRemove2', 'TestGroupRemove3')

            $groupSetParameters = @{
                GroupName = $testGroupNames
                Ensure = 'Absent'
            }


            foreach ($testGroupName in $testGroupNames)
            {
                Test-GroupExists -GroupName $testGroupName | Should Be $false

                New-Group -GroupName $testGroupName

                Test-GroupExists -GroupName $testGroupName | Should Be $true
            }

            try
            {
                { 
                    . $script:confgurationFilePath -ConfigurationName $configurationName
                    & $configurationName -OutputPath $TestDrive @groupSetParameters
                    Start-DscConfiguration -Path $TestDrive -ErrorAction 'Stop' -Wait -Force
                } | Should Not Throw

                foreach ($testGroupName in $testGroupNames)
                {
                    Test-GroupExists -GroupName $testGroupName | Should Be $false
                }
            }
            finally
            {
                foreach ($testGroupName in $testGroupNames)
                {
                    if (Test-GroupExists -GroupName $testGroupName)
                    {
                        Remove-Group -GroupName $testGroupName
                    }
                }
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
