[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
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
    -TestType 'Unit'

try
{
    InModuleScope 'MSFT_xGroupResource' {
        Describe 'xGroup Unit Tests' {
            BeforeAll {
                $script:disposableObjects = @()

                $script:testGroupName = 'TestGroup'
                $script:testGroupDescription = 'A group for testing'

                $script:localDomain = $env:computerName

                $script:onNanoServer = Test-IsNanoServer

                $script:testMemberName1 = 'User1'
                $script:testMemberName2 = 'User2'
                $script:testMemberName3 = 'User3'

                $testUserName = 'TestUserName'
                $testPassword = 'TestPassword'
                $secureTestPassword = ConvertTo-SecureString -String $testPassword -AsPlainText -Force

                $script:testCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @( $testUsername, $secureTestPassword )

                $script:testErrorMessage = 'Test error message'

                if ($script:onNanoServer)
                {
                    $script:testLocalGroup = New-Object -TypeName 'Microsoft.PowerShell.Commands.LocalGroup' -ArgumentList @( $script:testGroupName )
                }
                else
                {
                    $script:testPrincipalContext = New-Object -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext' -ArgumentList @( [System.DirectoryServices.AccountManagement.ContextType]::Machine )

                    $script:testGroup = New-Object -TypeName 'System.DirectoryServices.AccountManagement.GroupPrincipal' -ArgumentList @( $script:testPrincipalContext )
                    $script:disposableObjects += $testGroup

                    $script:testUserPrincipal1 = New-Object -TypeName 'System.DirectoryServices.AccountManagement.UserPrincipal' -ArgumentList @( $testPrincipalContext )
                    $script:testuserPrincipal1.Name = $script:testMemberName1
                    $script:testuserPrincipal1.SamAccountName = 'SamAccountName1'
                    $script:disposableObjects += $script:testuserPrincipal1

                    $script:testUserPrincipal2 = New-Object -TypeName 'System.DirectoryServices.AccountManagement.UserPrincipal' -ArgumentList @( $testPrincipalContext )
                    $script:testuserPrincipal2.Name = $script:testMemberName2
                    $script:testuserPrincipal2.SamAccountName = 'SamAccountName2'
                    $script:disposableObjects += $script:testuserPrincipal2

                    $script:testUserPrincipal3 = New-Object -TypeName 'System.DirectoryServices.AccountManagement.UserPrincipal' -ArgumentList @( $testPrincipalContext )
                    $script:testuserPrincipal3.Name = $script:testMemberName3
                    $script:testuserPrincipal3.SamAccountName = 'SamAccountName3'
                    $script:disposableObjects += $script:testuserPrincipal3
                }
            }

            BeforeEach {
                # Reset the test group
                if (-not ($script:onNanoServer))
                {
                    $script:testGroup.Name = $script:testGroupName
                    $script:testGroup.Description = ''

                    if ($script:testGroup.Members.Count -gt 0)
                    {
                        $script:testGroup.Members.Clear()
                    }
                }
                else
                {
                    # Reset the local group
                    $script:testLocalGroup.Name = $script:testGroupName
                    $script:testLocalGroup.Description = ''
                }
            }

            AfterAll {
                foreach ($disposableObject in $script:disposableObjects)
                {
                    $disposableObject.Dispose()
                }
            }

            <#
                Get-Group, Add-GroupMember, Remove-GroupMember, Clear-GroupMembers, Save-Group,
                Remove-Group, Find-Principal, and Remove-DisposableObject cannot be unit tested
                because they are wrapper functions for .NET class function calls.
            #>

            Context 'Get-TargetResource' {
                Mock -CommandName 'Assert-GroupNameValid' -MockWith { }
                Mock -CommandName 'Test-IsNanoServer' -MockWith { return $false }
                Mock -CommandName 'Get-TargetResourceOnFullSKU' -MockWith { return @{ TestResult = 'OnFullSKU' } }
                Mock -CommandName 'Get-TargetResourceOnNanoServer' -MockWith { return @{ TestResult = 'OnNanoServer' } }

                It 'Should call Assert-GroupNameValid with the given group name' {
                    $null = Get-TargetResource -GroupName $script:testGroupName
                    Assert-MockCalled -CommandName 'Assert-GroupNameValid' -ParameterFilter { $GroupName -eq $script:testGroupName }
                }

                It 'Should return output Get-TargetResourceOnFullSKU with all parameters when not on Nano Server' {
                    $getTargetResourceResult = Get-TargetResource -GroupName $script:testGroupName -Credential $script:testCredential
                    
                    Assert-MockCalled -CommandName 'Test-IsNanoServer'
                    Assert-MockCalled -CommandName 'Get-TargetResourceOnFullSKU' -ParameterFilter { $GroupName -eq $script:testGroupName -and $Credential -eq $script:testCredential }
                    $getTargetResourceResult.TestResult | Should Be 'OnFullSKU'
                }

                It 'Should call Get-TargetResourceOnNanoServer with all parameters when on Nano Server' {
                    Mock -CommandName 'Test-IsNanoServer' -MockWith { return $true }
                    
                    $getTargetResourceResult = Get-TargetResource -GroupName $script:testGroupName -Credential $script:testCredential
                    
                    Assert-MockCalled -CommandName 'Test-IsNanoServer'
                    Assert-MockCalled -CommandName 'Get-TargetResourceOnNanoServer' -ParameterFilter { $GroupName -eq $script:testGroupName -and $Credential -eq $script:testCredential }
                    $getTargetResourceResult.TestResult | Should Be 'OnNanoServer'
                }
            }

            Context 'Set-TargetResource' {
                Mock -CommandName 'Assert-GroupNameValid' -MockWith { }
                Mock -CommandName 'Test-IsNanoServer' -MockWith { return $false }
                Mock -CommandName 'Set-TargetResourceOnFullSKU' -MockWith { }
                Mock -CommandName 'Set-TargetResourceOnNanoServer' -MockWith { }

                It 'Should call Assert-GroupNameValid with the given group name' {
                    $null = Set-TargetResource -GroupName $script:testGroupName
                    Assert-MockCalled -CommandName 'Assert-GroupNameValid' -ParameterFilter { $GroupName -eq $script:testGroupName }
                }

                It 'Should call Set-TargetResourceOnFullSKU with all parameters when not on Nano Server' {
                    Set-TargetResource -GroupName $script:testGroupName -Credential $script:testCredential
                    
                    Assert-MockCalled -CommandName 'Test-IsNanoServer'
                    Assert-MockCalled -CommandName 'Set-TargetResourceOnFullSKU' -ParameterFilter { $GroupName -eq $script:testGroupName -and $Credential -eq $script:testCredential }
                }

                It 'Should call Set-TargetResourceOnNanoServer with all parameters when on Nano Server' {
                    Mock -CommandName 'Test-IsNanoServer' -MockWith { return $true }
                    
                    Set-TargetResource -GroupName $script:testGroupName -Credential $script:testCredential
                    
                    Assert-MockCalled -CommandName 'Test-IsNanoServer'
                    Assert-MockCalled -CommandName 'Set-TargetResourceOnNanoServer' -ParameterFilter { $GroupName -eq $script:testGroupName -and $Credential -eq $script:testCredential }
                }
            }

            Context 'Test-TargetResource' {
                Mock -CommandName 'Assert-GroupNameValid' -MockWith { }
                Mock -CommandName 'Test-IsNanoServer' -MockWith { return $false }
                Mock -CommandName 'Test-TargetResourceOnFullSKU' -MockWith { }
                Mock -CommandName 'Test-TargetResourceOnNanoServer' -MockWith { }

                It 'Should call Assert-GroupNameValid with the given group name' {
                    $testTargetResourceResult = Test-TargetResource -GroupName $script:testGroupName
                    Assert-MockCalled -CommandName 'Assert-GroupNameValid' -ParameterFilter { $GroupName -eq $script:testGroupName }
                }

                It 'Should call Test-TargetResourceOnFullSKU with all parameters when not on Nano Server' {
                    $testTargetResourceResult = Test-TargetResource -GroupName $script:testGroupName -Credential $script:testCredential
                    
                    Assert-MockCalled -CommandName 'Test-IsNanoServer'
                    Assert-MockCalled -CommandName 'Test-TargetResourceOnFullSKU' -ParameterFilter { $GroupName -eq $script:testGroupName -and $Credential -eq $script:testCredential }
                }

                It 'Should call Test-TargetResourceOnNanoServer with all parameters when on Nano Server' {
                    Mock -CommandName 'Test-IsNanoServer' -MockWith { return $true }
                    
                    $testTargetResourceResult = Test-TargetResource -GroupName $script:testGroupName -Credential $script:testCredential
                    
                    Assert-MockCalled -CommandName 'Test-IsNanoServer'
                    Assert-MockCalled -CommandName 'Test-TargetResourceOnNanoServer' -ParameterFilter { $GroupName -eq $script:testGroupName -and $Credential -eq $script:testCredential }
                }
            }

            Context 'Assert-GroupNameValid' {
                $invalidCharacters = @( '\', '/', '"', '[', ']', ':', '|', '<', '>', '+', '=', ';', ',', '?', '*', '@' )
                
                foreach ($invalidCharacter in $invalidCharacters)
                {
                    It "Should throw error if name contains invalid character '$invalidCharacter'" {
                        $invalidGroupName = ('Invalid' + $invalidCharacter + 'Group')
                        { Assert-GroupNameValid -GroupName $invalidGroupName } | Should Throw ($script:localizedData.InvalidGroupName -f $invalidGroupName, '')
                    }
                }

                It 'Should throw if name contains only whitespace' {
                    $invalidGroupName = '    '
                    { Assert-GroupNameValid -GroupName $invalidGroupName } | Should Throw ($script:localizedData.InvalidGroupName -f $invalidGroupName, '')
                }

                It 'Should throw if name contains only dots' {
                    $invalidGroupName = '....'
                    { Assert-GroupNameValid -GroupName $invalidGroupName } | Should Throw ($script:localizedData.InvalidGroupName -f $invalidGroupName, '')
                }

                It 'Should throw if name contains only whitespace and dots' {
                    $invalidGroupName = '..    ..'
                    { Assert-GroupNameValid -GroupName $invalidGroupName } | Should Throw ($script:localizedData.InvalidGroupName -f $invalidGroupName, '')
                }

                It 'Should not throw if name contains whitespace and dots' {
                    $invalidGroupName = '..  MyGroup  ..'
                    { Assert-GroupNameValid -GroupName $invalidGroupName } | Should Not Throw
                }
            }

            Context 'Test-IsLocalMachine' {
                Mock -CommandName 'Get-CimInstance' -MockWith { }
                
                $localMachineScopes = @( '.', $env:computerName, 'localhost', '127.0.0.1' )

                foreach ($localMachineScope in $localMachineScopes)
                {
                    It "Should return true for local machine scope $localMachineScope" {
                        Test-IsLocalMachine -Scope $localMachineScope | Should Be $true
                    }
                }

                $customLocalIPAddress = '123.4.5.6'

                It 'Should return false if custom local IP address provided and Get-CimInstance returns null' {
                    Test-IsLocalMachine -Scope $customLocalIPAddress | Should Be $false
                }

                It 'Should return true if custom local IP address provided and Get-CimInstance contains matching IP address' {
                    Mock -CommandName 'Get-CimInstance' -MockWith { return @{ IPAddress = @($customLocalIPAddress, '789.1.2.3')} }
                    
                    Test-IsLocalMachine -Scope $customLocalIPAddress | Should Be $true
                }

                It 'Should return false if custom local IP address provided and Get-CimInstance do not contain matching IP addresses' {
                    Mock -CommandName 'Get-CimInstance' -MockWith { return @{ IPAddress = @('789.1.2.3')} }

                    Test-IsLocalMachine -Scope $customLocalIPAddress | Should Be $false
                }
            }

            Context 'Split-MemberName' {
                Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $true }

                It 'Should split a member name in the domain\username format with the machine domain' {
                    $testMemberName = 'domain\username'
                    $splitMemberNameResult = Split-MemberName -MemberName $testMemberName

                    Assert-MockCalled -CommandName 'Test-IsLocalMachine'

                    $splitMemberNameResult | Should Be @( $script:localDomain, 'username' )
                }

                Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $false }

                It 'Should split a member name in the domain\username format with a custom domain' {
                    $testMemberName = 'domain\username'
                    $splitMemberNameResult = Split-MemberName -MemberName $testMemberName

                    Assert-MockCalled -CommandName 'Test-IsLocalMachine'

                    $splitMemberNameResult | Should Be @( 'domain', 'username' )
                }

                It 'Should split a member name in the username@domain format' {
                    $testMemberName = 'username@domain'
                    $splitMemberNameResult = Split-MemberName -MemberName $testMemberName

                    $splitMemberNameResult | Should Be @( 'domain', 'username' )
                }

                It 'Should split a member name in the CN=username,DC=domain format with local domain' {
                    $testMemberName = 'CN=username,DC=domain'
                    $splitMemberNameResult = Split-MemberName -MemberName $testMemberName

                    $splitMemberNameResult | Should Be @( $script:localDomain, $testMemberName )
                }

                It 'Should split a member name in the CN=username,DC=domain format with outisde domain' {
                    $testMemberName = 'CN=username,DC=domain,DC=com'
                    $splitMemberNameResult = Split-MemberName -MemberName $testMemberName

                    $splitMemberNameResult | Should Be @( 'domain', $testMemberName )
                }

                It 'Should split a member name in the local username format' {
                    $testMemberName = 'username'
                    $splitMemberNameResult = Split-MemberName -MemberName $testMemberName

                    $splitMemberNameResult | Should Be @( $script:localDomain, 'username' )
                }
            }

            if ($script:onNanoServer)
            {
                Context 'Get-TargetResourceOnNanoServer' {
                    $testMembers = @('User1', 'User2')

                    Mock -CommandName 'Get-MembersOnNanoServer' -MockWith { return @() }
                
                    It 'Should return Ensure as Absent when Get-LocalGroup throws a GroupNotFound exception' {
                        Mock -CommandName 'Get-LocalGroup' -MockWith { Write-Error -Message 'Test error message' -CategoryReason 'GroupNotFoundException' }
                    
                        $getTargetResourceResult = Get-TargetResourceOnNanoServer -GroupName $script:testGroupName
                    
                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }

                        $getTargetResourceResult -is [Hashtable] | Should Be $true
                        $getTargetResourceResult.Keys.Count | Should Be 2
                        $getTargetResourceResult.GroupName | Should Be $script:testGroupName
                        $getTargetResourceResult.Ensure | Should Be 'Absent'
                    }

                    It 'Should throw an error when Get-LocalGroup throws an exception other than GroupNotFound' {
                        Mock -CommandName 'Get-LocalGroup' -MockWith { Write-Error -Message $script:testErrorMessage -CategoryReason 'OtherException' }
                    
                        { $getTargetResourceResult = Get-TargetResourceOnNanoServer -GroupName $script:testGroupName } | Should Throw $script:testErrorMessage
                    
                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }

                    It 'Should return correct hashtable values when Get-LocalGroup returns a valid, existing group without members' {
                        $script:testLocalGroup.Description = $script:testGroupDescription
                    
                        Mock -CommandName 'Get-LocalGroup' -MockWith { return $script:testLocalGroup }
                    
                        $getTargetResourceResult = Get-TargetResourceOnNanoServer -GroupName $script:testGroupName

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group -eq $script:testLocalGroup }

                        $getTargetResourceResult -is [Hashtable] | Should Be $true
                        $getTargetResourceResult.Keys.Count | Should Be 4
                        $getTargetResourceResult.GroupName | Should Be $script:testGroupName
                        $getTargetResourceResult.Ensure | Should Be 'Present'
                        $getTargetResourceResult.Description | Should Be $script:testGroupDescription
                        $getTargetResourceResult.Members | Should Be $null
                    }

                    It 'Should return correct hashtable values when Get-LocalGroup returns a valid, existing group with members' {
                        $script:testLocalGroup.Description = $script:testGroupDescription
                    
                        Mock -CommandName 'Get-LocalGroup' -MockWith { return $script:testLocalGroup }
                        Mock -CommandName 'Get-MembersOnNanoServer' -MockWith { return $testMembers }
                    
                        $getTargetResourceResult = Get-TargetResourceOnNanoServer -GroupName $script:testGroupName
                    
                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group -eq $script:testLocalGroup }

                        $getTargetResourceResult -is [Hashtable] | Should Be $true
                        $getTargetResourceResult.Keys.Count | Should Be 4
                        $getTargetResourceResult.GroupName | Should Be $script:testGroupName
                        $getTargetResourceResult.Ensure | Should Be 'Present'
                        $getTargetResourceResult.Description | Should Be $script:testGroupDescription
                        $getTargetResourceResult.Members | Should Be $testMembers
                    }
                }

                Context 'Set-TargetResourceOnNanoServer' {
                    Mock -CommandName 'Get-LocalGroup' -MockWith { Write-Error -Message 'Test error message' -CategoryReason 'GroupNotFoundException' }
                    Mock -CommandName 'New-LocalGroup' -MockWith { return $script:testLocalGroup }
                    Mock -CommandName 'Set-LocalGroup' -MockWith { }
                    Mock -CommandName 'Remove-LocalGroup' -MockWith { }
                    Mock -CommandName 'Get-MembersOnNanoServer' -MockWith { }
                    Mock -CommandName 'Add-LocalGroupMember' -MockWith { }
                    Mock -CommandName 'Remove-LocalGroupMember' -MockWith { }
                    
                    It 'Should not attempt to remove an absent group when Ensure is Absent' {
                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Absent'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-LocalGroup' -Times 0 -Scope 'It'
                    }

                    It 'Should create an empty group' {
                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }

                    It 'Should create an empty group with a description' {
                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Description $script:testGroupDescription -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Set-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName -and $Description -eq $script:testGroupDescription }
                    }

                    It 'Should create a group with one local member using Members' {
                        $testMembers = @( $script:testMemberName1 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                    }

                    It 'Should create a group with two local members using Members' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    It 'Should create a group with one local member using MembersToInclude' {
                        $testMembers = @( $script:testMemberName1 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                    }

                    It 'Should create a group with two local members using MembersToInclude' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    Mock -CommandName 'Get-LocalGroup' -MockWith { Write-Error -Message $script:testErrorMessage -CategoryReason 'OtherException' }

                    It 'Should throw from group retrieval if exception is not a GroupNotFoundException' {
                        { Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Present' } | Should Throw $script:testErrorMessage
                    }

                    Mock -CommandName 'Get-LocalGroup' -MockWith { return $script:testLocalGroup }

                    It 'Should add a member to an existing group with no members using Members' {
                        $testMembers = @( $script:testMemberName1 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                    }

                    It 'Should add two members to an existing group with one of the members using Members' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    It 'Should not modify group with no members if Members is empty' {
                        $testMembers = @( )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }

                    It 'Should add a member to an existing group with no members using MembersToInclude' {
                        $testMembers = @( $script:testMemberName1 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                    }

                    It 'Should add two members to an existing group with one of the members using MembersToInclude' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    Mock -CommandName 'Get-MembersOnNanoServer' -MockWith { return @( $script:testMemberName1, $script:testMemberName2 ) }

                    It 'Should remove a member from an existing group using Members' {
                        $testMembers = @( $script:testMemberName1 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    It 'Should clear group members from an existing group using Members' {
                        $testMembers = @( )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName1 }
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    It 'Should remove a member from an existing group using MembersToExclude' {
                        $testMembers = @( $script:testMemberName2 )
                 
                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    It 'Should add a user and remove a user using Members' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName3 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName3 }
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    It 'Should add a user and remove a user using MembersToInclude and MembersToExclude at the same time' {
                        $testMembersToInclude = @( $script:testMemberName3 )
                        $testMembersToExclude = @( $script:testMemberName2 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMemberstoInclude -MembersToExclude $testMemberstoExclude -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName3 }
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Member.Name -eq $script:testMemberName2 }
                    }

                    It 'Should throw if Members and MembersToInclude are both specified' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )
                        $testMembersToInclude = @( $script:testMemberName3 )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToInclude'

                        { Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -MembersToInclude $testMembersToInclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if Members and MembersToExclude are both specified' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )
                        $testMembersToExclude = @( $script:testMemberName3 )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToExclude'

                        { Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if MembersToInclude and MembersToExclude contain the same member' {
                        $testMembersToInclude = @( $script:testMemberName1 )
                        $testMembersToExclude = @( $script:testMemberName1 )

                        $errorMessage = $script:localizedData.IncludeAndExcludeConflict -f $script:testMemberName1, 'MembersToInclude', 'MembersToExclude'

                        { Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembersToInclude -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should not modify group if member specified by MembersToInclude is already in group' {
                        $testMembers = @( $script:testMemberName1 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if member specified by MembersToExclude is not in group' {
                        $testMembers = @( $script:testMemberName3 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if members specified by Members match group members' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if MembersToInclude is empty' {
                        $testMembers = @( )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if MembersToExclude is empty' {
                        $testMembers = @( )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if both MembersToInclude and MembersToExclude are empty' {
                        $testMembers = @( )

                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }

                    It 'Should remove an existing group when Ensure is Absent' {
                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Absent'

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName } -Scope 'It'
                    }

                    It 'Should not modify group if no changes were made' {
                        Set-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Set-LocalGroup' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-LocalGroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-LocalGroupMember' -Times 0 -Scope 'It'
                    }
                }

                Context 'Test-TargetResourceOnNanoServer' {
                    Mock -CommandName 'Get-LocalGroup' -MockWith { Write-Error -Message 'Test error message' -CategoryReason 'GroupNotFoundException' }
                    Mock -CommandName 'Get-MembersOnNanoServer' -MockWith { }
                    
                    It 'Should return true for an absent group when Ensure is Absent' {
                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Absent' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }
                
                    It 'Should return false for an absent group when Ensure is Present' {
                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }

                    Mock -CommandName 'Get-LocalGroup' -MockWith { Write-Error -Message $script:testErrorMessage -CategoryReason 'OtherException' }

                    It 'Should throw from group retrieval if exception is not a GroupNotFoundException' {
                        { Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Present' } | Should Throw $script:testErrorMessage
                    }

                    Mock -CommandName 'Get-LocalGroup' -MockWith { return $script:testLocalGroup }

                    It 'Should return true for an existing group when Ensure is Present' {
                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }

                    It 'Should return false for an existing group when Ensure is Absent' {
                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Ensure 'Absent' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }

                    It 'Should return true for an existing group with a matching description' {
                        $script:testLocalGroup.Description = $script:testGroupDescription
                    
                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Description $script:testGroupDescription -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }

                    It 'Should return false for an existing  group with a mismatching description' {
                        $script:testLocalGroup.Description = $script:testGroupDescription
                    
                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Description 'Wrong description' -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                    }

                    It 'Should return true with matching empty members when using Members' {
                        $testMembers = @( )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    It 'Should return false with mismatching number of members when using Members' {
                        $testMembers = @( $script:testMemberName1 )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    It 'Should return false with missing member when using MembersToInclude' {
                        $testMembers = @( $script:testMemberName1 )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    It 'Should return true with missing member when using MembersToExclude' {
                        $testMembers = @( $script:testMemberName1 )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    Mock -CommandName 'Get-MembersOnNanoServer' -MockWith { @( $script:testMemberName1, $script:testMemberName2 ) }

                    It 'Should return false when group contains member specified by MemberstoExclude' {
                        $testMembers = @( $script:testMemberName1 )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    It 'Should return true when group contains member specified by MembersToInclude' {
                        $testMembers = @( $script:testMemberName1 )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    It 'Should return true when group members match Members' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    It 'Should return false when group members do not match Members' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName3 )

                        Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-LocalGroup' -ParameterFilter { $Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnNanoServer' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    It 'Should throw if Members and MembersToInclude are both specified' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )
                        $testMembersToInclude = @( $script:testMemberName3 )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToInclude'

                        { Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -MembersToInclude $testMembersToInclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if Members and MembersToExclude are both specified' {
                        $testMembers = @( $script:testMemberName1, $script:testMemberName2 )
                        $testMembersToExclude = @( $script:testMemberName3 )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToExclude'

                        { Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -Members $testMembers -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if MembersToInclude and MembersToExclude contain the same member' {
                        $testMembersToInclude = @( $script:testMemberName1 )
                        $testMembersToExclude = @( $script:testMemberName1 )

                        $errorMessage = $script:localizedData.IncludeAndExcludeConflict -f $script:testMemberName1, 'MembersToInclude', 'MembersToExclude'

                        { Test-TargetResourceOnNanoServer -GroupName $script:testGroupName -MembersToInclude $testMembersToInclude -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }
                }

                Context 'Get-MembersOnNanoServer' {
                    Mock -CommandName 'Get-LocalGroupMember' -MockWith { }

                    It 'Should return nothing if group does not have members' {
                        Get-MembersOnNanoServer -Group $script:testLocalGroup | Should Be $null

                        Assert-MockCalled -CommandName 'Get-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    $testDomainUser1 = @{
                        Name = 'TestDomainUser1'
                        PrincipalSource = 'NotLocal'
                    }

                    $testDomainUser2 = @{
                        Name = 'TestDomainUser2'
                        PrincipalSource = 'Local'
                    }

                    Mock -CommandName 'Get-LocalGroupMember' -MockWith { return @( $testDomainUser1, $testDomainUser2 ) }

                    It 'Should return all local members and ignore non-local members' {
                        Get-MembersOnNanoServer -Group $script:testLocalGroup | Should Be @( $testDomainUser2.Name )

                        Assert-MockCalled -CommandName 'Get-LocalGroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }
                }
            }
            else
            {
                Context 'Get-TargetResourceOnFullSKU' {
                    $testMembers = @($script:testuserPrincipal1.Name, $script:testuserPrincipal2.Name)

                    Mock -CommandName 'Get-Group' -MockWith { }
                    Mock -CommandName 'Get-MembersOnFullSKU' -MockWith { return @() }
                    Mock -CommandName 'Remove-DisposableObject' -MockWith { }
                
                    It 'Should return Ensure as Absent when Get-Group returns null' {
                        $getTargetResourceResult = Get-TargetResourceOnFullSKU -GroupName $script:testGroupName
                    
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'

                        $getTargetResourceResult -is [Hashtable] | Should Be $true
                        $getTargetResourceResult.Keys.Count | Should Be 2
                        $getTargetResourceResult.GroupName | Should Be $script:testGroupName
                        $getTargetResourceResult.Ensure | Should Be 'Absent'
                    }

                    It 'Should return correct hashtable values when Get-Group returns a valid, existing group without members' {
                        $script:testGroup.Description = $script:testGroupDescription
                    
                        Mock -CommandName 'Get-Group' -MockWith { return $script:testGroup }
                    
                        $getTargetResourceResult = Get-TargetResourceOnFullSKU -GroupName $script:testGroupName

                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnFullSKU' -ParameterFilter { $Group -eq $script:testGroup }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'

                        $getTargetResourceResult -is [Hashtable] | Should Be $true
                        $getTargetResourceResult.Keys.Count | Should Be 4
                        $getTargetResourceResult.GroupName | Should Be $script:testGroupName
                        $getTargetResourceResult.Ensure | Should Be 'Present'
                        $getTargetResourceResult.Description | Should Be $script:testGroupDescription
                        $getTargetResourceResult.Members | Should Be $null
                    }

                    It 'Should return correct hashtable values when Get-Group returns a valid, existing group with members' {
                        $testGroup.Description = $script:testGroupDescription
                    
                        Mock -CommandName 'Get-Group' -MockWith { return $script:testGroup }
                        Mock -CommandName 'Get-MembersOnFullSKU' -MockWith { return $testMembers }
                    
                        $getTargetResourceResult = Get-TargetResourceOnFullSKU -GroupName $script:testGroupName
                    
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersOnFullSKU' -ParameterFilter { $Group -eq $script:testGroup }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'

                        $getTargetResourceResult -is [Hashtable] | Should Be $true
                        $getTargetResourceResult.Keys.Count | Should Be 4
                        $getTargetResourceResult.GroupName | Should Be $script:testGroupName
                        $getTargetResourceResult.Ensure | Should Be 'Present'
                        $getTargetResourceResult.Description | Should Be $script:testGroupDescription
                        $getTargetResourceResult.Members | Should Be $testMembers
                    }
                }

                Context 'Set-TargetResourceOnFullSKU' {
                    Mock -CommandName 'Get-Group' -MockWith { }
                    Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { }
                    Mock -CommandName 'ConvertTo-UniquePrincipalsList' -MockWith { 
                        $memberPrincipals = @()

                        if ($MemberNames -contains $script:testUserPrincipal1.Name)
                        {
                            $memberPrincipals += @( $script:testUserPrincipal1` )
                        }
                    
                        if ($MemberNames -contains $script:testUserPrincipal2.Name)
                        {
                            $memberPrincipals += @( $script:testUserPrincipal2 )
                        }
                    
                        if ($MemberNames -contains $script:testUserPrincipal3.Name)
                        {
                            $memberPrincipals += @( $script:testUserPrincipal3 )
                        }

                        return $memberPrincipals
                    } 
               
                    Mock -CommandName 'Clear-GroupMembers' -MockWith { }
                    Mock -CommandName 'Add-GroupMember' -MockWith { }
                    Mock -CommandName 'Remove-GroupMember' -MockWith { }
                    Mock -CommandName 'Remove-Group' -MockWith { }
                    Mock -CommandName 'Save-Group' -MockWith { }
                
                    Mock -CommandName 'Remove-DisposableObject' -MockWith { }
                    Mock -CommandName 'Get-PrincipalContext' -MockWith { return $script:testPrincipalContext }
                    
                    It 'Should not attempt to remove an absent group when Ensure is Absent' {
                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Absent'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -Scope 'It'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName } -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName } -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-DisposableObject' -Scope 'It'
                    }
                
                    It 'Should create an empty group' {
                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should create an empty group with a description' {
                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Description $script:testGroupDescription -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $Group.Description -eq $script:testGroupDescription }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should create a group with one local member using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name )
                 
                        Mock -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' } -MockWith { return $testGroup }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { $MemberNames -eq $testMembers }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal1 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should create a group with two local members using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' } -MockWith { return $testGroup } 

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null  }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal1 }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should create a group with one local member using MembersToInclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )
                 
                        Mock -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' } -MockWith { return $testGroup }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { $MemberNames -eq $testMembers }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal1 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should create a group with two local members using MembersToInclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' } -MockWith { return $testGroup }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.GroupPrincipal' }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames)  -eq $null  }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal1 }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                     Mock -CommandName 'Get-Group' -MockWith { return $script:testGroup }

                    It 'Should add a member to an existing group with no members using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @() }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal1 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should add two members to an existing group with one of the members using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should add a member to an existing group with no members using MembersToInclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @() }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal1 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should add two members to an existing group with one of the members using MembersToInclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should remove a member from an existing group using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should clear group members from an existing group using Members' {
                        $testMembers = @( )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should remove a member from an existing group using MembersToExclude' {
                        $testMembers = @( $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should add a user and remove a user using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal3.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembers -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal3 }
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should add a user and remove a user using MembersToInclude and MembersToExclude at the same time' {
                        $testMembersToInclude = @( $script:testUserPrincipal3.Name )
                        $testMembersToExclude = @( $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }
                    
                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembersToInclude -MembersToExclude $testMembersToExclude -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembersToInclude -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { (Compare-Object -ReferenceObject $testMembersToExclude -DifferenceObject $MemberNames) -eq $null }
                        Assert-MockCalled -CommandName 'Add-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal3 }
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -ParameterFilter { $Group.Name -eq $script:testGroupName -and $MemberAsPrincipal -eq $script:testUserPrincipal2 }
                        Assert-MockCalled -CommandName 'Save-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should throw if Members and MembersToInclude are both specified' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                        $testMembersToInclude = @( $script:testUserPrincipal3.Name )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToInclude'

                        { Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -MembersToInclude $testMembersToInclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if Members and MembersToExclude are both specified' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                        $testMembersToExclude = @( $script:testUserPrincipal3.Name )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToExclude'

                        { Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if MembersToInclude and MembersToExclude contain the same member' {
                        $testMembersToInclude = @( $script:testUserPrincipal1.Name )
                        $testMembersToExclude = @( $script:testUserPrincipal1.Name )

                        $errorMessage = $script:localizedData.IncludeAndExcludeConflict -f $script:testUserPrincipal1.Name, 'MembersToInclude', 'MembersToExclude'

                        { Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembersToInclude -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should not modify group if member specified by MembersToInclude is already in group' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) } 

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if member specified by MembersToExclude is not in group' {
                        $testMembers = @( $script:testUserPrincipal3.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if members specified by Members match group members' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if MembersToInclude is empty' {
                        $testMembers = @( )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if MembersToExclude is empty' {
                        $testMembers = @( )

                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group if both MembersToInclude and MembersToExclude are empty' {
                        $testMembers = @( )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( ) }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -MembersToExclude $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -Times 0 -Scope 'It'
                    }

                    It 'Should not modify group with no members if Members is empty' {
                        $testMembers = @( )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Clear-GroupMembers' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Add-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-GroupMember' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -Times 0 -Scope 'It'
                    }

                    It 'Should remove an existing group when Ensure is Absent' {
                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Absent'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -Scope 'It'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName } -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-Group' -ParameterFilter { $Group.Name -eq $script:testGroupName } -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-DisposableObject' -Scope 'It'
                    }

                    It 'Should not save group if no changes were made' {
                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -Scope 'It'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName } -Scope 'It'
                        Assert-MockCalled -CommandName 'Save-Group' -Times 0 -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-DisposableObject' -Scope 'It'
                    }

                    It 'Should pass Credential to all appropriate functions when using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @() }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Credential $script:testCredential -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential  }
                    }

                    It 'Should pass Credential to all appropriate functions when using MembersToInclude and MembersToExclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )
                 
                        Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @() }

                        Set-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Credential $script:testCredential -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential  }
                    }


                }

                Context 'Test-TargetResourceOnFullSKU' {
                    Mock -CommandName 'Get-Group' -MockWith { }
                    Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { }
                    Mock -CommandName 'ConvertTo-UniquePrincipalsList' -MockWith { 
                        $memberPrincipals = @()

                        if ($MemberNames -contains $script:testUserPrincipal1.Name)
                        {
                            $memberPrincipals += @( $script:testUserPrincipal1` )
                        }
                    
                        if ($MemberNames -contains $script:testUserPrincipal2.Name)
                        {
                            $memberPrincipals += @( $script:testUserPrincipal2 )
                        }
                    
                        if ($MemberNames -contains $script:testUserPrincipal3.Name)
                        {
                            $memberPrincipals += @( $script:testUserPrincipal3 )
                        }

                        return $memberPrincipals
                    }
                
                    Mock -CommandName 'Remove-DisposableObject' -MockWith { }
                    Mock -CommandName 'Get-PrincipalContext' -MockWith { return $script:testPrincipalContext }
                    
                    It 'Should return true for an absent group when Ensure is Absent' {
                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Absent' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -Scope 'It'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName } -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }
                
                    It 'Should return false for an absent group when Ensure is Present' {
                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    Mock -CommandName 'Get-Group' -MockWith { return $script:testGroup }

                    It 'Should return true for an existing group when Ensure is Present' {
                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return false for an existing group when Ensure is Absent' {
                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Ensure 'Absent' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -Scope 'It'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName } -Scope 'It'
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return true for an existing group with a matching description' {
                        $script:testGroup.Description = $script:testGroupDescription
                    
                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Description $script:testGroupDescription -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return false for an existing  group with a mismatching description' {
                        $script:testGroup.Description = $script:testGroupDescription
                    
                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Description 'Wrong description' -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return true with matching empty members when using Members' {
                        $testMembers = @( )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return false with mismatching number of members when using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return false with missing member when using MembersToInclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return true with missing member when using MembersToExclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                    It 'Should return false when group contains member specified by MemberstoExclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToExclude $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return true when group contains member specified by MembersToInclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return true when group members match Members' {
                        $testMembers = @( $script:testUserPrincipal1, $script:testUserPrincipal2 )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $true

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should return false when group members do not match Members' {
                        $testMembers = @( $script:testUserPrincipal1, $script:testUserPrincipal3 )

                        Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Ensure 'Present' | Should Be $false

                        Assert-MockCalled -CommandName 'Get-PrincipalContext'
                        Assert-MockCalled -CommandName 'Get-Group' -ParameterFilter { $GroupName -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'Remove-DisposableObject'
                    }

                    It 'Should pass Credential to all appropriate functions when using Members' {
                        $testMembers = @( $script:testUserPrincipal1.Name )

                        $null = Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Credential $script:testCredential -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential  }
                    }

                    It 'Should pass Credential to all appropriate functions when using MembersToInclude and MembersToExclude' {
                        $testMembers = @( $script:testUserPrincipal1.Name )

                        $null = Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -Credential $script:testCredential -Ensure 'Present'

                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential }
                        Assert-MockCalled -CommandName 'ConvertTo-UniquePrincipalsList' -ParameterFilter { $Credential -eq $script:testCredential  }
                    }

                    It 'Should throw if Members and MembersToInclude are both specified' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                        $testMembersToInclude = @( $script:testUserPrincipal3.Name )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToInclude'

                        { Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -MembersToInclude $testMembersToInclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if Members and MembersToExclude are both specified' {
                        $testMembers = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                        $testMembersToExclude = @( $script:testUserPrincipal3.Name )

                        $errorMessage = $script:localizedData.MembersAndIncludeExcludeConflict -f 'Members', 'MembersToExclude'

                        { Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -Members $testMembers -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }

                    It 'Should throw if MembersToInclude and MembersToExclude contain the same member' {
                        $testMembersToInclude = @( $script:testUserPrincipal1.Name )
                        $testMembersToExclude = @( $script:testUserPrincipal1.Name )

                        $errorMessage = $script:localizedData.IncludeAndExcludeConflict -f $script:testUserPrincipal1.Name, 'MembersToInclude', 'MembersToExclude'

                        { Test-TargetResourceOnFullSKU -GroupName $script:testGroupName -MembersToInclude $testMembersToInclude -MembersToExclude $testMembersToExclude -Ensure 'Present' } | Should Throw $errorMessage
                    }
                }
                
                Context 'Get-MembersOnFullSKU' {
                    $principalContextCache = @{}
                    $disposables = New-Object -TypeName 'System.Collections.ArrayList'

                    Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { }

                    It 'Should return nothing if group does not have members' {
                        Get-MembersOnFullSKU -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables | Should Be $null

                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $script:testUserPrincipal1, $script:testUserPrincipal2 ) }

                    It 'Should return principal names for members without domains' {
                        Get-MembersOnFullSKU -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables | Should Be @( $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )

                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    $testDomainUser1 = @{
                        Name = 'TestDomainUser1'
                        SamAccountName = 'TestSamAccountName1'
                        ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
                        Context = @{
                            Name = 'TestDomain1'
                        }
                        StructuralObjectClass = 'Domain'
                    }

                    $domainName2 = 'TestDomain2'

                    $testDomainUser2 = @{
                        Name = 'TestDomainUser2'
                        SamAccountName = 'TestSamAccountName2'
                        ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
                        Context = @{
                            Name = "$domainName2.WithDot"
                        }
                        StructuralObjectClass = 'Computer'
                    }

                    Mock -CommandName 'Get-MembersAsPrincipalsList' -MockWith { return @( $testDomainUser1, $testDomainUser2 ) }

                    It 'Should return principal names for members with domains' {
                        $expectedName1 = "$($testDomainUser1.Context.Name)\$($testDomainUser1.SamAccountName)"
                        $expectedName2 = "$($domainName2)\$($testDomainUser2.Name)"

                        $expectedGetMembersResult = @( $expectedName1, $expectedName2 )

                        $getMembersResult = Get-MembersOnFullSKU -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables
                    
                        (Compare-Object -ReferenceObject $expectedGetMembersResult -DifferenceObject $getMembersResult) | Should Be $null

                        Assert-MockCalled -CommandName 'Get-MembersAsPrincipalsList' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }
                }

                Context 'Get-MembersAsPrincipalsList' {
                    $principalContextCache = @{}
                    $disposables = New-Object -TypeName 'System.Collections.ArrayList'
                
                    Mock -CommandName 'Get-GroupMembersFromDirectoryEntry' -MockWith { }
                
                    Mock -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.DirectoryEntry' } -MockWith {
                        return $ArgumentList[0]
                    }
                
                    Mock -CommandName 'Get-PrincipalContext' -MockWith { return $script:testPrincipalContext }
                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $true }
                
                    Mock -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.Security.Principal.SecurityIdentifier' } -MockWith {
                        return 'S-1-0-0'
                    }

                    Mock -CommandName 'Resolve-SidToPrincipal' -MockWith { return 'FakeSidValue' }

                    It 'Should return empty list when there are no group members' {
                        Get-MembersAsPrincipalsList -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables | Should Be $null
                        Assert-MockCalled -CommandName 'Get-GroupMembersFromDirectoryEntry' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                    }

                    $memberDirectoryEntry1 = @{
                        Path = 'WinNT://domainname/accountname'
                        Properties = @{
                            ObjectSid = @{
                                Value = 'SidValue1'
                            }
                        }
                    }

                    $memberDirectoryEntry2 = @{
                        Path = 'WinNT://domainname/machinename/accountname'
                        Properties = @{
                            ObjectSid = @{
                                Value = 'SidValue2'
                            }
                        }
                    }

                    $memberDirectoryEntry3 = @{
                        Path ='accountname'
                    }

                    Mock 'Get-GroupMembersFromDirectoryEntry' { return @( $memberDirectoryEntry3 ) }

                    It 'Should ignore stale members' {
                        $getMembersResult = Get-MembersAsPrincipalsList -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables -WarningAction 'SilentlyContinue'
                        $getMembersResult | Should Be $null

                        Assert-MockCalled -CommandName 'Get-GroupMembersFromDirectoryEntry' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.DirectoryEntry' }
                    }

                    Mock 'Get-GroupMembersFromDirectoryEntry' { return @( $memberDirectoryEntry1, $memberDirectoryEntry2 ) }

                    It 'Should return current members' {
                        $getMembersResult = Get-MembersAsPrincipalsList -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables
                        $getMembersResult.Count | Should Be 2

                        Assert-MockCalled -CommandName 'Get-GroupMembersFromDirectoryEntry' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.DirectoryEntry' } -Times 2 -Scope 'It'
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Scope -eq 'domainname' }
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Scope -eq 'machinename' }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq 'domainname' }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq 'machinename' }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.Security.Principal.SecurityIdentifier' -and $ArgumentList[0] -eq 'SidValue1' }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.Security.Principal.SecurityIdentifier' -and $ArgumentList[0] -eq 'SidValue2' }
                        Assert-MockCalled -CommandName 'Resolve-SidToPrincipal' -ParameterFilter { $Sid -eq 'S-1-0-0' -and $Scope -eq 'domainname' }
                        Assert-MockCalled -CommandName 'Resolve-SidToPrincipal' -ParameterFilter { $Sid -eq 'S-1-0-0' -and $Scope -eq 'machinename' }
                    }

                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $false }

                    It 'Should return current members with custom domain when prinicpal can be found' {
                        $getMembersResult = Get-MembersAsPrincipalsList -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables
                        $getMembersResult.Count | Should Be 2

                        Assert-MockCalled -CommandName 'Get-GroupMembersFromDirectoryEntry' -ParameterFilter { $Group.Name -eq $script:testGroupName }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.DirectoryEntry' } -Times 2 -Scope 'It'
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Scope -eq 'domainname' }
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Scope -eq 'machinename' }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq 'domainname' }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq 'machinename' }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.Security.Principal.SecurityIdentifier' -and $ArgumentList[0] -eq 'SidValue1' }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.Security.Principal.SecurityIdentifier' -and $ArgumentList[0] -eq 'SidValue2' }
                        Assert-MockCalled -CommandName 'Resolve-SidToPrincipal' -ParameterFilter { $Sid -eq 'S-1-0-0' -and $Scope -eq 'domainname' }
                        Assert-MockCalled -CommandName 'Resolve-SidToPrincipal' -ParameterFilter { $Sid -eq 'S-1-0-0' -and $Scope -eq 'machinename' }
                    }

                    It 'Should pass Credential to appropriate functions' {
                        $getMembersResult = Get-MembersAsPrincipalsList -Group $script:testGroup -Credential $script:testCredential -PrincipalContextCache $principalContextCache -Disposables $disposables
                   
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Credential -eq $script:testCredential }
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Credential -eq $script:testCredential}
                    }

                    Mock -CommandName 'Get-PrincipalContext' -MockWith { }

                    It 'Should throw when prinicpal context for custom domain cannot be found' {
                        $errorMessage = ($script:localizedData.DomainCredentialsRequired -f 'accountname')

                        { Get-MembersAsPrincipalsList -Group $script:testGroup -PrincipalContextCache $principalContextCache -Disposables $disposables } | Should Throw $errorMessage
                    }
                }

                Context 'ConvertTo-UniquePrincipalsList' {
                    $principalContextCache = @{}
                    $disposables = New-Object -TypeName 'System.Collections.ArrayList'
                
                    $testDomainUser1 = @{
                        Name = 'TestDomainUser1'
                        SamAccountName = 'TestSamAccountName1'
                        ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
                        Context = @{
                            Name = 'TestDomain1'
                        }
                        StructuralObjectClass = 'Domain'
                        DistinguishedName = 'TestDomainUser1'
                    }

                    Mock -CommandName 'ConvertTo-Principal' -MockWith {
                        switch ($MemberName)
                        {
                            $script:testUserPrincipal1.Name { return $script:testUserPrincipal1 }
                            $script:testUserPrincipal2.Name { return $script:testUserPrincipal2 }
                            $script:testUserPrincipal3.Name { return $script:testUserPrincipal3 }
                            $testDomainUser1.Name { return $testDomainUser1 }
                        }
                    } 
                
                    It 'Should not return duplicate local prinicpals' {
                        $memberNames = @( $script:testUserPrincipal1.Name, $script:testUserPrincipal1.Name, $script:testUserPrincipal2.Name )
                    
                        $uniquePrincipalsList = ConvertTo-UniquePrincipalsList -MemberNames $memberNames -PrincipalContextCache $principalContextCache -Disposables $disposables
                        $uniquePrincipalsList | Should Be @( $script:testUserPrincipal1, $script:testUserPrincipal2 )

                        foreach ($passedInMemberName in $memberNames)
                        {
                            Assert-MockCalled -CommandName 'ConvertTo-Principal' -ParameterFilter { $MemberName -eq $passedInMemberName }
                        }
                    }

                    It 'Should not return duplicate domain prinicpals' {
                        $memberNames = @( $testDomainUser1.Name, $testDomainUser1.Name )

                        $uniquePrincipalsList = ConvertTo-UniquePrincipalsList -MemberNames $memberNames -PrincipalContextCache $principalContextCache -Disposables $disposables
                        $uniquePrincipalsList | Should Be @( $testDomainUser1 )

                        foreach ($passedInMemberName in $memberNames)
                        {
                            Assert-MockCalled -CommandName 'ConvertTo-Principal' -ParameterFilter { $MemberName -eq $passedInMemberName }
                        }
                    }

                    It 'Should pass Credential to appropriate functions' {
                        ConvertTo-UniquePrincipalsList -MemberNames @( $script:testUserPrincipal1 ) -Credential $script:testCredential -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'ConvertTo-Principal' -ParameterFilter { $Credential -eq $script:testCredential }
                    }
                }

                Context 'ConvertTo-Principal' {
                    $principalContextCache = @{}
                    $disposables = New-Object -TypeName 'System.Collections.ArrayList'
                
                    Mock -CommandName 'Split-MemberName' -MockWith { return $script:localDomain, $MemberName }
                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $true }
                    Mock -CommandName 'Get-PrincipalContext' -MockWith { return $script:testPrincipalContext }
                    Mock -CommandName 'Find-Principal' -MockWith {
                        switch ($IdentityValue)
                        {
                            $script:testUserPrincipal1.Name { return $script:testUserPrincipal1 }
                            $script:testUserPrincipal2.Name { return $script:testUserPrincipal2 }
                            $script:testUserPrincipal3.Name { return $script:testUserPrincipal3 }
                        }
                    }

                    It 'Should return principal with local member name' {
                        $convertToPrincipalResult = ConvertTo-Principal `
                            -MemberName $script:testUserPrincipal1.Name `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables

                        $convertToPrincipalResult | Should Be $script:testUserPrincipal1

                        Assert-MockCalled -CommandName 'Split-MemberName' -ParameterFilter { $MemberName -eq $script:testUserPrincipal1.Name }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $script:localDomain }
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Scope -eq $script:localDomain }
                        Assert-MockCalled -CommandName 'Find-Principal' -ParameterFilter { $IdentityValue -eq $script:testUserPrincipal1.Name }
                    }

                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $false }

                    It 'Should attempt to resolve non-local member with domain trust' {
                        $convertToPrincipalResult = ConvertTo-Principal `
                            -MemberName $script:testUserPrincipal1.Name `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables

                        $convertToPrincipalResult | Should Be $script:testUserPrincipal1

                        Assert-MockCalled -CommandName 'Split-MemberName' -ParameterFilter { $MemberName -eq $script:testUserPrincipal1.Name }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $script:localDomain }
                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Scope -eq $script:localDomain }
                        Assert-MockCalled -CommandName 'Find-Principal' -ParameterFilter { $IdentityValue -eq $script:testUserPrincipal1.Name }
                    }

                    It 'Should pass Credential to appropriate functions' {
                        $null = ConvertTo-Principal -MemberName $script:testUserPrincipal1.Name -Credential $script:testCredential -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'Get-PrincipalContext' -ParameterFilter { $Credential -eq $script:testCredential }
                    }

                    Mock -CommandName 'Find-Principal' -MockWith { }

                    It 'Should throw if principal cannot be found' {
                        $errorMessage = ($script:localizedData.CouldNotFindPrincipal -f $script:testUserPrincipal1.Name)
                    
                        { $convertToPrincipalResult = ConvertTo-Principal `
                            -MemberName $script:testUserPrincipal1.Name `
                            -PrincipalContextCache $principalContextCache `
                            -Disposables $disposables } | Should Throw $errorMessage
                    }
                }

                Context 'Resolve-SidToPrincipal' {
                    Mock -CommandName 'Find-Principal' -MockWith { }
                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $true }

                    $testSidValue = 'S-1-0-0'
                    $testSid = New-Object -TypeName 'System.Security.Principal.SecurityIdentifier' -ArgumentList @( $testSidValue )

                    $sidIdentityType = [System.DirectoryServices.AccountManagement.IdentityType]::Sid

                    It 'Should throw when principal not found and scope is local' {
                        { Resolve-SidToPrincipal -Sid $testSid -PrincipalContext $script:testPrincipalContext -Scope $script:localDomain } | Should Throw ($script:localizedData.CouldNotFindPrincipal -f $testSidValue)

                        Assert-MockCalled -CommandName 'Find-Principal' -ParameterFilter { $PrincipalContext -eq $script:testPrincipalContext -and $IdentityType -eq $sidIdentityType -and $IdentityValue -eq $testSidValue }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $script:localDomain }
                    }

                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $false }

                    It 'Should throw when principal not found and scope is custom' {
                        $customDomain = 'CustomDomain'

                        { Resolve-SidToPrincipal -Sid $testSid -PrincipalContext $script:testPrincipalContext -Scope $customDomain } | Should Throw ($script:localizedData.CouldNotFindPrincipal -f $testSidValue)

                        Assert-MockCalled -CommandName 'Find-Principal' -ParameterFilter { $PrincipalContext -eq $script:testPrincipalContext -and $IdentityType -eq $sidIdentityType -and $IdentityValue -eq $testSidValue }
                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $customDomain }
                    }

                    $fakePrincipal = 'FakePrincipal'
                    Mock -CommandName 'Find-Principal' -MockWith { return $fakePrincipal }

                    It 'Should return found principal' {
                        Resolve-SidToPrincipal -Sid $testSid -PrincipalContext $script:testPrincipalContext -Scope $script:localDomain | Should Be $fakePrincipal
                        Assert-MockCalled -CommandName 'Find-Principal' -ParameterFilter { $PrincipalContext -eq $script:testPrincipalContext -and $IdentityType -eq $sidIdentityType -and $IdentityValue -eq $testSidValue }
                    }
                }

                Context 'Get-PrincipalContext' {
                    $fakePrincipalContext = 'FakePrincipalContext'
                
                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $true }
                    Mock -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' } -MockWith { $fakePrincipalContext }

                    $localMachineContext = [System.DirectoryServices.AccountManagement.ContextType]::Machine
                    $customDomainContext = [System.DirectoryServices.AccountManagement.ContextType]::Domain

                    It 'Should create a new local principal context' {
                        $principalContextCache = @{}
                        $disposables = New-Object -TypeName 'System.Collections.ArrayList'

                        $localScope = 'localhost'

                        Get-PrincipalContext -Scope $localScope -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $localScope }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' -and $ArgumentList.Contains($localMachineContext) }

                        $principalContextCache.ContainsKey($localScope) | Should Be $false
                        $principalContextCache.$script:localDomain | Should Be $fakePrincipalContext
                        $disposables.Contains($fakePrincipalContext) | Should Be $true
                    }

                    It 'Should return the local principal context from the cache' {
                        $principalContextCache = @{ $script:localDomain = $script:testPrincipalContext }
                        $disposables = New-Object -TypeName 'System.Collections.ArrayList'
                    
                        Get-PrincipalContext -Scope $script:localDomain -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $script:localDomain }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' } -Times 0 -Scope 'It'
                
                        $principalContextCache.$script:localDomain | Should Not Be $fakePrincipalContext
                        $disposables.Contains($fakePrincipalContext) | Should Be $false
                    }

                    Mock -CommandName 'Test-IsLocalMachine' -MockWith { return $false }

                    It 'Should create a new custom principal context without a Credential' {
                        $principalContextCache = @{}
                        $disposables = New-Object -TypeName 'System.Collections.ArrayList'

                        $customDomain = 'CustomDomain'
                    
                        Get-PrincipalContext -Scope $customDomain -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $customDomain }

                        $principalContextArgumentList = @($customDomainContext, $customDomain)

                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' -and
                            (Compare-Object -ReferenceObject $principalContextArgumentList -DifferenceObject $ArgumentList) -eq $null }

                        $principalContextCache.$customDomain | Should Be $fakePrincipalContext
                        $disposables.Contains($fakePrincipalContext) | Should Be $true
                    }

                    It 'Should create a new custom principal context with a Credential without a domain' {
                        $principalContextCache = @{}
                        $disposables = New-Object -TypeName 'System.Collections.ArrayList'

                        $customDomain = 'CustomDomain'
                    
                        Get-PrincipalContext -Scope $customDomain -Credential $script:testCredential -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $customDomain }

                        $principalContextArgumentList = @( $customDomainContext, $customDomain, $script:testCredential.GetNetworkCredential().UserName, $script:testCredential.GetNetworkCredential().Password )

                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' -and
                            (Compare-Object -ReferenceObject $principalContextArgumentList -DifferenceObject $ArgumentList) -eq $null }

                        $principalContextCache.$customDomain | Should Be $fakePrincipalContext
                        $disposables.Contains($fakePrincipalContext) | Should Be $true
                    }

                    It 'Should create a new custom principal context with a Credential with a domain' {
                        $principalContextCache = @{}
                        $disposables = New-Object -TypeName 'System.Collections.ArrayList'

                        $customDomain = 'CustomDomain'
                    
                        $userNameWithDomain = 'CustomDomain\username'
                        $testPassword = 'TestPassword'
                        $secureTestPassword = ConvertTo-SecureString -String $testPassword -AsPlainText -Force

                        $credentialWithDomain = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @( $userNameWithDomain, $secureTestPassword )

                        Get-PrincipalContext -Scope $customDomain -Credential $credentialWithDomain -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $customDomain }

                        $principalContextArgumentList = @( $customDomainContext, $customDomain, $userNameWithDomain, $credentialWithDomain.GetNetworkCredential().Password  )

                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' -and
                            (Compare-Object -ReferenceObject $principalContextArgumentList -DifferenceObject $ArgumentList) -eq $null }

                        $principalContextCache.$customDomain | Should Be $fakePrincipalContext
                        $disposables.Contains($fakePrincipalContext) | Should Be $true
                    }

                    It 'Should return a custom principal context from the cache' {
                        $customDomain = 'CustomDomain'
                    
                        $principalContextCache = @{ $customDomain = $script:testPrincipalContext }
                        $disposables = New-Object -TypeName 'System.Collections.ArrayList'
                    
                        Get-PrincipalContext -Scope $customDomain -PrincipalContextCache $principalContextCache -Disposables $disposables

                        Assert-MockCalled -CommandName 'Test-IsLocalMachine' -ParameterFilter { $Scope -eq $customDomain }
                        Assert-MockCalled -CommandName 'New-Object' -ParameterFilter { $TypeName -eq 'System.DirectoryServices.AccountManagement.PrincipalContext' } -Times 0 -Scope 'It'
                
                        $principalContextCache.$customDomain | Should Not Be $fakePrincipalContext
                        $disposables.Contains($fakePrincipalContext) | Should Be $false
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
