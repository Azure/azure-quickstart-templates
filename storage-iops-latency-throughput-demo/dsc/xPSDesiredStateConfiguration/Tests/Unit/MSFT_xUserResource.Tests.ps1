# To run these tests, the currently logged on user must have rights to create a user
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath 'CommonTestHelper.psm1') `
                               -Force

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DSCResourceModuleName 'xPSDesiredStateConfiguration' `
    -DSCResourceName 'MSFT_xUserResource' `
    -TestType Unit

try {

    Import-Module -Name (Join-Path -Path $PSScriptRoot `
                                   -ChildPath 'MSFT_xUserResource.TestHelper.psm1') `
                                   -Force

    InModuleScope 'MSFT_xUserResource' {
        # Used to skip the Nano server tests for the time being since they are not working on AppVeyor
        
        $script:skipMe = $true
    
        $existingUserName = 'TestUserName12345'
        $existingUserPassword = 'StrongOne7.'
        $existingDescription = 'Some Description'
        $existingSecurePassword = ConvertTo-SecureString $existingUserPassword -AsPlainText -Force
        $existingTestCredential = New-Object PSCredential ($existingUserName, $existingSecurePassword)
        
        New-User -Credential $existingTestCredential -Description $existingDescription
        
        $newUserName1 = 'NewTestUserName12345'
        $newUserPassword1 = 'NewStrongOne123.'
        $newFullName1 = 'Fullname1'
        $newUserDescription1 = 'New Description1'
        $newSecurePassword1 = ConvertTo-SecureString $newUserPassword1 -AsPlainText -Force
        $newCredential1 = New-Object PSCredential ($newUserName1, $newSecurePassword1)
        
        $newUserName2 = 'newUser1234'
        $newPassword2 = 'ThisIsAStrongPassword543!'
        $newFullName2 = 'Fullname2'
        $newUserDescription2 = 'New Description2'
        $newSecurePassword2 = ConvertTo-SecureString $newPassword2 -AsPlainText -Force
        $newCredential2 = New-Object PSCredential ($newUserName2, $newSecurePassword2)
        
        try {

            Describe 'xUserResource/Get-TargetResource' {

                Context 'Tests on FullSKU' {
                    Mock -CommandName Test-IsNanoServer -MockWith { return $false }

                    It 'Should return the user as Present' {
                        $getTargetResourceResult = Get-TargetResource $existingUserName

                        $getTargetResourceResult['UserName']                | Should Be $existingUserName
                        $getTargetResourceResult['Ensure']                  | Should Be 'Present'
                        $getTargetResourceResult['Description']             | Should Be $existingDescription
                        $getTargetResourceResult['PasswordChangeRequired']  | Should Be $null
                    }

                    It 'Should return the user as Absent' {
                        $getTargetResourceResult = Get-TargetResource 'NotAUserName'

                        $getTargetResourceResult['UserName']                | Should Be 'NotAUserName'
                        $getTargetResourceResult['Ensure']                  | Should Be 'Absent'
                    }
                }

                Context 'Tests on Nano Server' {
                    Mock -CommandName Test-IsNanoServer -MockWith { return $true }

                    It 'Should return the user as Present on Nano Server' -Skip:$script:skipMe {
                        $getTargetResourceResult = Get-TargetResource $existingUserName

                        $getTargetResourceResult['UserName']                | Should Be $existingUserName
                        $getTargetResourceResult['Ensure']                  | Should Be 'Present'
                        $getTargetResourceResult['Description']             | Should Be $existingDescription
                        $getTargetResourceResult['PasswordChangeRequired']  | Should Be $null
                    }

                    It 'Should return the user as Absent' -Skip:$script:skipMe {
                        $getTargetResourceResult = Get-TargetResource 'NotAUserName'

                        $getTargetResourceResult['UserName']                | Should Be 'NotAUserName'
                        $getTargetResourceResult['Ensure']                  | Should Be 'Absent'
                    }
                }
            }

            Describe 'xUserResource/Set-TargetResource' {
                Context 'Tests on FullSKU' {
                    Mock -CommandName Test-IsNanoServer -MockWith { return $false }
                    
                    try
                    {
                        New-User -Credential $newCredential1 -Description $newUserDescription1
                    
                        It 'Should remove the user' {
                            Test-User -UserName $newUserName1 | Should Be $true
                            Set-TargetResource -UserName $newUserName1 -Ensure 'Absent'
                            Test-User -UserName $newUserName1 | Should Be $false
                        }
                    
                        It 'Should add the new user' {
                            Set-TargetResource -UserName $newUserName2 -Password $newCredential2 -Ensure 'Present'
                            Test-User -UserName $newUserName2 | Should Be $true
                        }
                        
                        It 'Should update the user' {
                            $disabled = $false
                            $passwordNeverExpires = $true
                            $passwordChangeRequired = $false
                            $passwordChangeNotAllowed = $true
                            
                            Set-TargetResource -UserName $newUserName2 `
                                               -Password $newCredential2 `
                                               -Ensure 'Present' `
                                               -FullName $newFullName1 `
                                               -Description $newUserDescription1 `
                                               -Disabled $disabled `
                                               -PasswordNeverExpires $passwordNeverExpires `
                                               -PasswordChangeRequired $passwordChangeRequired `
                                               -PasswordChangeNotAllowed $passwordChangeNotAllowed
                        
                            Test-User -UserName $newUserName2 | Should Be $true
                            $testTargetResourceResult1 = 
                                    Test-TargetResource -UserName $newUserName2 `
                                                        -Password $newCredential2 `
                                                        -Ensure 'Present' `
                                                        -FullName $newFullName1 `
                                                        -Description $newUserDescription1 `
                                                        -Disabled $disabled `
                                                        -PasswordNeverExpires $passwordNeverExpires `
                                                        -PasswordChangeNotAllowed $passwordChangeNotAllowed
                            $testTargetResourceResult1 | Should Be $true
                        }
                        It 'Should update the user again with different values' {
                            $disabled = $false
                            $passwordNeverExpires = $false
                            $passwordChangeRequired = $true
                            $passwordChangeNotAllowed = $false
                            
                            Set-TargetResource -UserName $newUserName2 `
                                               -Password $newCredential1 `
                                               -Ensure 'Present' `
                                               -FullName $newFullName2 `
                                               -Description $newUserDescription2 `
                                               -Disabled $disabled `
                                               -PasswordNeverExpires $passwordNeverExpires `
                                               -PasswordChangeRequired $passwordChangeRequired `
                                               -PasswordChangeNotAllowed $passwordChangeNotAllowed
                        
                            Test-User -UserName $newUserName2 | Should Be $true
                            $testTargetResourceResult2 = 
                                    Test-TargetResource -UserName $newUserName2 `
                                                        -Password $newCredential1 `
                                                        -Ensure 'Present' `
                                                        -FullName $newFullName2 `
                                                        -Description $newUserDescription2 `
                                                        -Disabled $disabled `
                                                        -PasswordNeverExpires $passwordNeverExpires `
                                                        -PasswordChangeNotAllowed $passwordChangeNotAllowed
                            $testTargetResourceResult2 | Should Be $true
                        }
                    }
                    finally
                    {
                        Remove-User -UserName $newUserName1
                        Remove-User -UserName $newUserName2
                    }
                }

                Context 'Tests on Nano Server' {
                    Mock -CommandName Test-IsNanoServer -MockWith { return $true }
                    Mock -CommandName Test-CredentialsValidOnNanoServer { return $true }
                    
                    try
                    {
                        New-User -Credential $newCredential1 -Description $newUserDescription1
                    
                        It 'Should remove the user' -Skip:$script:skipMe {
                            Test-User -UserName $newUserName1 | Should Be $true
                            Set-TargetResource -UserName $newUserName1 -Ensure 'Absent'
                            Test-User -UserName $newUserName1 | Should Be $false
                        }
                    
                        It 'Should add the new user' -Skip:$script:skipMe {
                            Set-TargetResource -UserName $newUserName2 -Password $newCredential2 -Ensure 'Present'
                            Test-User -UserName $newUserName2 | Should Be $true
                        }
                        
                        It 'Should update the user' -Skip:$script:skipMe {
                            $disabled = $false
                            $passwordNeverExpires = $true
                            $passwordChangeRequired = $false
                            $passwordChangeNotAllowed = $true
                            
                            Set-TargetResource -UserName $newUserName2 `
                                               -Password $newCredential2 `
                                               -Ensure 'Present' `
                                               -FullName $newFullName1 `
                                               -Description $newUserDescription1 `
                                               -Disabled $disabled `
                                               -PasswordNeverExpires $passwordNeverExpires `
                                               -PasswordChangeRequired $passwordChangeRequired `
                                               -PasswordChangeNotAllowed $passwordChangeNotAllowed
                        
                            Test-User -UserName $newUserName2 | Should Be $true
                            $testTargetResourceResult1 = 
                                    Test-TargetResource -UserName $newUserName2 `
                                                        -Password $newCredential2 `
                                                        -Ensure 'Present' `
                                                        -FullName $newFullName1 `
                                                        -Description $newUserDescription1 `
                                                        -Disabled $disabled `
                                                        -PasswordNeverExpires $passwordNeverExpires `
                                                        -PasswordChangeNotAllowed $passwordChangeNotAllowed
                            $testTargetResourceResult1 | Should Be $true
                        }
                        It 'Should update the user again with different values' -Skip:$script:skipMe {
                            $disabled = $false
                            $passwordNeverExpires = $false
                            $passwordChangeRequired = $true
                            $passwordChangeNotAllowed = $false
                            
                            Set-TargetResource -UserName $newUserName2 `
                                               -Password $newCredential1 `
                                               -Ensure 'Present' `
                                               -FullName $newFullName2 `
                                               -Description $newUserDescription2 `
                                               -Disabled $disabled `
                                               -PasswordNeverExpires $passwordNeverExpires `
                                               -PasswordChangeRequired $passwordChangeRequired `
                                               -PasswordChangeNotAllowed $passwordChangeNotAllowed
                        
                            Test-User -UserName $newUserName2 | Should Be $true
                            $testTargetResourceResult2 = 
                                    Test-TargetResource -UserName $newUserName2 `
                                                        -Password $newCredential1 `
                                                        -Ensure 'Present' `
                                                        -FullName $newFullName2 `
                                                        -Description $newUserDescription2 `
                                                        -Disabled $disabled `
                                                        -PasswordNeverExpires $passwordNeverExpires `
                                                        -PasswordChangeNotAllowed $passwordChangeNotAllowed
                            $testTargetResourceResult2 | Should Be $true
                        }
                    }
                    finally
                    {
                        Remove-User -UserName $newUserName1
                        Remove-User -UserName $newUserName2
                    }
                }
            }

            Describe 'xUserResource/Test-TargetResource' {
                Context 'Tests on FullSKU' {
                    Mock -CommandName Test-IsNanoServer -MockWith { return $false }
                    $absentUserName = 'AbsentUserUserName123456789'
                    
                    It 'Should return true when user Present and correct values' {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Description $existingDescription `
                                                                        -Password $existingTestCredential `
                                                                        -Disabled $false `
                                                                        -PasswordNeverExpires $false `
                                                                        -PasswordChangeNotAllowed $false
                        $testTargetResourceResult | Should Be $true
                    }
                    
                    It 'Should return true when user Absent and Ensure = Absent' {
                        $testTargetResourceResult = Test-TargetResource -UserName $absentUserName `
                                                                        -Ensure 'Absent'
                        $testTargetResourceResult | Should Be $true
                    }

                    It 'Should return false when user Absent and Ensure = Present' {
                        $testTargetResourceResult = Test-TargetResource -UserName $absentUserName `
                                                                        -Ensure 'Present'
                        $testTargetResourceResult | Should Be $false
                    }
                    
                    It 'Should return false when user Present and Ensure = Absent' {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Ensure 'Absent'
                        $testTargetResourceResult | Should Be $false
                    }
                    
                    It 'Should return false when Password is wrong' {
                        $badPassword = 'WrongPassword'
                        $secureBadPassword = ConvertTo-SecureString $badPassword -AsPlainText -Force
                        $badTestCredential = New-Object PSCredential ($existingUserName, $secureBadPassword)
                        
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Password $badTestCredential
                        $testTargetResourceResult | Should Be $false
                    }
                    
                    It 'Should return false when user Present and wrong Description' {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Description 'Wrong description'
                        $testTargetResourceResult | Should Be $false
                    }

                    It 'Should return false when FullName is incorrect' {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -FullName 'Wrong FullName'
                        $testTargetResourceResult | Should Be $false 
                    }
                    
                    It 'Should return false when Disabled is incorrect' {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Disabled $true
                        $testTargetResourceResult | Should Be $false 
                    }
                    
                    It 'Should return false when PasswordNeverExpires is incorrect' {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -PasswordNeverExpires $true
                        $testTargetResourceResult | Should Be $false 
                    }
                    
                    It 'Should return false when PasswordChangeNotAllowed is incorrect' {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -PasswordChangeNotAllowed $true
                        $testTargetResourceResult | Should Be $false 
                    }
                }
                
                Context 'Tests on Nano Server' {
                    Mock -CommandName Test-IsNanoServer -MockWith { return $true }
                    
                    $absentUserName = 'AbsentUserUserName123456789'
                    
                    It 'Should return true when user Present and correct values' -Skip:$script:skipMe {
                        Mock -CommandName Test-CredentialsValidOnNanoServer { return $true }
                        
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Description $existingDescription `
                                                                        -Password $existingTestCredential `
                                                                        -Disabled $false `
                                                                        -PasswordNeverExpires $false `
                                                                        -PasswordChangeNotAllowed $false
                        $testTargetResourceResult | Should Be $true
                    }
                    
                    It 'Should return true when user Absent and Ensure = Absent' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $absentUserName `
                                                                        -Ensure 'Absent'
                        $testTargetResourceResult | Should Be $true
                    }

                    It 'Should return false when user Absent and Ensure = Present' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $absentUserName `
                                                                        -Ensure 'Present'
                        $testTargetResourceResult | Should Be $false
                    }
                    
                    It 'Should return false when user Present and Ensure = Absent' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Ensure 'Absent'
                        $testTargetResourceResult | Should Be $false
                    }
                    
                    It 'Should return false when Password is wrong' -Skip:$script:skipMe {
                        Mock -CommandName Test-CredentialsValidOnNanoServer { return $false }
                        
                        $badPassword = 'WrongPassword'
                        $secureBadPassword = ConvertTo-SecureString $badPassword -AsPlainText -Force
                        $badTestCredential = New-Object PSCredential ($existingUserName, $secureBadPassword)
                        
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Password $badTestCredential
                        $testTargetResourceResult | Should Be $false
                    }
                    
                    It 'Should return false when user Present and wrong Description' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Description 'Wrong description'
                        $testTargetResourceResult | Should Be $false
                    }

                    It 'Should return false when FullName is incorrect' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -FullName 'Wrong FullName'
                        $testTargetResourceResult | Should Be $false 
                    }
                    
                    It 'Should return false when Disabled is incorrect' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -Disabled $true
                        $testTargetResourceResult | Should Be $false 
                    }
                    
                    It 'Should return false when PasswordNeverExpires is incorrect' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -PasswordNeverExpires $true
                        $testTargetResourceResult | Should Be $false 
                    }
                    
                    It 'Should return false when PasswordChangeNotAllowed is incorrect' -Skip:$script:skipMe {
                        $testTargetResourceResult = Test-TargetResource -UserName $existingUserName `
                                                                        -PasswordChangeNotAllowed $true
                        $testTargetResourceResult | Should Be $false 
                    }
                }
            }
            
            Describe 'xUserResource/Assert-UserNameValid' {
                It 'Should not throw when username contains all valid chars' {
                    { Assert-UserNameValid -UserName 'abc123456!f_t-l098s' } | Should Not Throw
                }
                
                It 'Should throw InvalidArgumentError when username contains only whitespace and dots' {
                    $invalidName = ' . .. .     '
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorId = 'UserNameHasOnlyWhiteSpacesAndDots'
                    $errorMessage = "The name $invalidName cannot be used."
                    $exception = New-Object System.ArgumentException $errorMessage;
                    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
                    { Assert-UserNameValid -UserName $invalidName } | Should Throw $errorRecord
                }
                
                It 'Should throw InvalidArgumentError when username contains an invalid char' {
                    $invalidName = 'user|name'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorId = 'UserNameHasInvalidCharachter'
                    $errorMessage = "The name $invalidName cannot be used."
                    $exception = New-Object System.ArgumentException $errorMessage;
                    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
                    { Assert-UserNameValid -UserName $invalidName } | Should Throw $errorRecord
                }
            }
        }
        finally
        {
            Remove-User -UserName $existingUserName
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}

