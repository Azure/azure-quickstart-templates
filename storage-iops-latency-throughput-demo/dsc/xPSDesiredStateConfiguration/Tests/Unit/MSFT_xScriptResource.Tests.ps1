$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

# Import CommonTestHelper for Enter-DscResourceTestEnvironment, Exit-DscResourceTestEnvironment
$script:testsFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonTestHelperFilePath = Join-Path -Path $testsFolderFilePath -ChildPath 'CommonTestHelper.psm1'
Import-Module -Name $commonTestHelperFilePath

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DSCResourceModuleName 'xPSDesiredStateConfiguration' `
    -DSCResourceName 'MSFT_xScriptResource' `
    -TestType 'Unit'

try {
    InModuleScope 'MSFT_xScriptResource' {
        $testUsername = 'TestUsername'
        $testPassword = 'TestPassword'
        $secureTestPassword = ConvertTo-SecureString -String $testPassword -AsPlainText -Force

        $script:testCredenital = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @( $testUsername, $secureTestPassword )

        Describe 'xScript\Get-TargetResource' {
            Mock -CommandName 'Invoke-Script' -MockWith { }

            Context 'Specified get script returns null' {
                $getTargetResourceParameters = @{
                    GetScript = 'return $null'
                    TestScript = 'NotUsed'
                    SetScript = 'NotUsed'
                }

                It 'Should throw an error for malformed get script' {
                    $errorMessage = $script:localizedData.GetScriptDidNotReturnHashtable
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Throw $errorMessage
                }
            }

            Mock -CommandName 'Invoke-Script' -MockWith { return "String" }

            Context 'Specified get script returns a string' {
                $getTargetResourceParameters = @{
                    GetScript = 'return "String"'
                    TestScript = 'NotUsed'
                    SetScript = 'NotUsed'
                }

                It 'Should throw an error for malformed get script' {
                    $errorMessage = $script:localizedData.GetScriptDidNotReturnHashtable
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Throw $errorMessage
                }
            }

            $testException = New-Object -TypeName 'System.Exception' -ArgumentList @()
            $newErrorRecoredArguments = @( $testException, 'Test', [System.Management.Automation.ErrorCategory]::InvalidOperation, $null )
            $testErrorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $newErrorRecoredArguments

            Mock -CommandName 'Invoke-Script' -MockWith { return $testErrorRecord }

            Context 'Specified get script throws an error' {
                $getTargetResourceParameters = @{
                    GetScript = 'throw "Error"'
                    TestScript = 'NotUsed'
                    SetScript = 'NotUsed'
                }

                It 'Should throw error from get script' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Throw $testErrorRecord
                }
            }

            $testScriptResult = @{ TestResult = 'Value1' }
            Mock -CommandName 'Invoke-Script' -MockWith { return $testScriptResult }

            Context 'Specified get script returns a hashtable and Credential not specified' {
                $getTargetResourceParameters = @{
                    GetScript = 'return "something"'
                    TestScript = 'NotUsed'
                    SetScript = 'NotUsed'
                }
                
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should use script execution helper to run script' {
                    $expectedScriptBlock = [ScriptBlock]::Create($getTargetResourceParameters.GetScript)

                    $null = Get-TargetResource @getTargetResourceParameters

                    $invokeScriptParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $expectedScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        return $scriptBlockParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Invoke-Script' -ParameterFilter $invokeScriptParameterFilter -Times 1 -Scope 'It'
                }
                
                It 'Should return a hashtable' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return the output from the specified get script' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    Compare-Object -ReferenceObject $testScriptResult -DifferenceObject $getTargetResourceResult | Should Be $null
                }
            }

            Context 'Specified get script returns a hashtable and Credential specified' {
                $getTargetResourceParameters = @{
                    GetScript = 'return "something"'
                    TestScript = 'NotUsed'
                    SetScript = 'NotUsed'
                    Credential = $script:testCredenital
                }
                
                It 'Should not throw' {
                    { $null = Get-TargetResource @getTargetResourceParameters } | Should Not Throw
                }

                It 'Should use script execution helper to run script with the specified Credential' {
                    $expectedScriptBlock = [ScriptBlock]::Create($getTargetResourceParameters.GetScript)

                    $null = Get-TargetResource @getTargetResourceParameters

                    $invokeScriptParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $expectedScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        $credentialParameterCorrect = $null -eq (Compare-Object -ReferenceObject $getTargetResourceParameters.Credential -DifferenceObject $Credential)
                        
                        return $scriptBlockParameterCorrect -and $credentialParameterCorrect 
                    }

                    Assert-MockCalled -CommandName 'Invoke-Script' -ParameterFilter $invokeScriptParameterFilter -Times 1 -Scope 'It'
                }
                
                It 'Should return a hashtable' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    $getTargetResourceResult -is [Hashtable] | Should Be $true
                }

                It 'Should return the output from the specified get script' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters
                    Compare-Object -ReferenceObject $testScriptResult -DifferenceObject $getTargetResourceResult | Should Be $null
                }
            }
        }

        Describe 'xScript\Set-TargetResource' {
            Mock -CommandName 'Invoke-Script' -MockWith { }

            Context 'Specified set script returns correctly and Credential not specified' {
                $setTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'NotUsed'
                    SetScript = '$assignedVariable = "Value1"'
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should use script execution helper to run script' {
                    $expectedScriptBlock = [ScriptBlock]::Create($setTargetResourceParameters.SetScript)

                    Set-TargetResource @setTargetResourceParameters

                    $invokeScriptParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $expectedScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        return $scriptBlockParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Invoke-Script' -ParameterFilter $invokeScriptParameterFilter -Times 1 -Scope 'It'
                }
            }

            Context 'Specified set script returns correctly and Credential specified' {
                $setTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'NotUsed'
                    SetScript = '$assignedVariable = "Value1"'
                    Credential = $script:testCredenital
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                }

                It 'Should use script execution helper to run script with specified Credential' {
                    $expectedScriptBlock = [ScriptBlock]::Create($setTargetResourceParameters.SetScript)

                    Set-TargetResource @setTargetResourceParameters

                    $invokeScriptParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $expectedScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        $credentialParameterCorrect = $null -eq (Compare-Object -ReferenceObject $setTargetResourceParameters.Credential -DifferenceObject $Credential)
                        
                        return $scriptBlockParameterCorrect -and $credentialParameterCorrect 
                    }

                    Assert-MockCalled -CommandName 'Invoke-Script' -ParameterFilter $invokeScriptParameterFilter -Times 1 -Scope 'It'
                }
            }

            $testException = New-Object -TypeName 'System.Exception' -ArgumentList @()
            $newErrorRecoredArguments = @( $testException, 'Test', [System.Management.Automation.ErrorCategory]::InvalidOperation, $null )
            $testErrorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $newErrorRecoredArguments

            Mock -CommandName 'Invoke-Script' -MockWith { return $testErrorRecord }

            Context 'Specified set script returns an error' {
                $setTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'NotUsed'
                    SetScript = 'throw "Error"'
                }

                It 'Should throw error from set script' {
                    { Set-TargetResource @setTargetResourceParameters } | Should Throw $testErrorRecord
                }
            }
        }

        Describe 'xScript\Test-TargetResource' {
            Mock -CommandName 'Invoke-Script' -MockWith { }

            Context 'Specified test script returns null' {
                $testTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'return $null'
                    SetScript = 'NotUsed'
                }

                It 'Should throw an error for malformed test script' {
                    $errorMessage = $script:localizedData.TestScriptDidNotReturnBoolean
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Throw $errorMessage
                }
            }

            $testException = New-Object -TypeName 'System.Exception' -ArgumentList @()
            $newErrorRecoredArguments = @( $testException, 'Test', [System.Management.Automation.ErrorCategory]::InvalidOperation, $null )
            $testErrorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $newErrorRecoredArguments

            Mock -CommandName 'Invoke-Script' -MockWith { return $testErrorRecord }

            Context 'Specified test script returns an error' {
                 $testTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'throw "Error"'
                    SetScript = 'NotUsed'
                }

                It 'Should throw error from test script' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Throw $testErrorRecord
                }
            }

            $expectedBoolean = $true
            Mock -CommandName 'Invoke-Script' -MockWith { return $expectedBoolean }

            Context 'Specified test script returns one boolean and Credential not specified' {
                $testTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'return $true'
                    SetScript = 'NotUsed'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should use script execution helper to run script' {
                    $expectedScriptBlock = [ScriptBlock]::Create($testTargetResourceParameters.TestScript)

                    $null = Test-TargetResource @testTargetResourceParameters

                    $invokeScriptParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $expectedScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        return $scriptBlockParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Invoke-Script' -ParameterFilter $invokeScriptParameterFilter -Times 1 -Scope 'It'
                }
                
                It 'Should return the expected boolean' {
                    $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    $testTargetResourceResult | Should Be $expectedBoolean
                }
            }

            Context 'Specified test script returns one boolean and Credential specified' {
                $testTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'return $true'
                    SetScript = 'NotUsed'
                    Credential = $script:testCredenital
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should use script execution helper to run script with specified Credential' {
                    $expectedScriptBlock = [ScriptBlock]::Create($testTargetResourceParameters.TestScript)

                    $null = Test-TargetResource @testTargetResourceParameters

                    $invokeScriptParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $expectedScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        $credentialParameterCorrect = $null -eq (Compare-Object -ReferenceObject $testTargetResourceParameters.Credential -DifferenceObject $Credential)
                        
                        return $scriptBlockParameterCorrect -and $credentialParameterCorrect 
                    }

                    Assert-MockCalled -CommandName 'Invoke-Script' -ParameterFilter $invokeScriptParameterFilter -Times 1 -Scope 'It'
                }
                
                It 'Should return the expected boolean' {
                    $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    $testTargetResourceResult | Should Be $expectedBoolean
                }
            }

            $expectedBoolean = $false
            Mock -CommandName 'Invoke-Script' -MockWith { return @( (-not $expectedBoolean), $expectedBoolean ) }

            Context 'Specified test script returns multiple booleans' {
                $testTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'return $true, $false'
                    SetScript = 'NotUsed'
                }

                It 'Should not throw' {
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Not Throw
                }

                It 'Should use script execution helper to run script' {
                    $expectedScriptBlock = [ScriptBlock]::Create($testTargetResourceParameters.TestScript)

                    $null = Test-TargetResource @testTargetResourceParameters

                    $invokeScriptParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $expectedScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        return $scriptBlockParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Invoke-Script' -ParameterFilter $invokeScriptParameterFilter -Times 1 -Scope 'It'
                }
                
                It 'Should return the expected boolean' {
                    $testTargetResourceResult = Test-TargetResource @testTargetResourceParameters
                    $testTargetResourceResult | Should Be $expectedBoolean
                }
            }

            Mock -CommandName 'Invoke-Script' -MockWith { return 'Value1' }

            Context 'Specified test script returns a string' {
                $testTargetResourceParameters = @{
                    GetScript = 'NotUsed'
                    TestScript = 'return "MyString"'
                    SetScript = 'NotUsed'
                }

                It 'Should throw an error for malformed test script' {
                    $errorMessage = $script:localizedData.TestScriptDidNotReturnBoolean
                    { $null = Test-TargetResource @testTargetResourceParameters } | Should Throw $errorMessage
                }
            }
        }

        Describe 'xScript\Invoke-Script' {
            Mock -CommandName 'Invoke-Command' -MockWith { }

            Context 'Specified script throws an error' {
                $testErrorMessage = 'Script execution helper test error message'

                $scriptExecutionHelperParameters = @{
                    ScriptBlock = { throw $testErrorMessage }
                }

                It 'Should not throw' {
                    { $null = Invoke-Script @scriptExecutionHelperParameters } | Should Not Throw
                }

                It 'Should return an error record' {
                    $scriptExecutionHelperResult = Invoke-Script @scriptExecutionHelperParameters
                    $scriptExecutionHelperResult -is [System.Management.Automation.ErrorRecord] | Should Be $true
                }

                It 'Should return an error record' {
                    $scriptExecutionHelperResult = Invoke-Script @scriptExecutionHelperParameters
                    $scriptExecutionHelperResult -is [System.Management.Automation.ErrorRecord] | Should Be $true
                }

                It 'Should return error with expected message from script' {
                    $scriptExecutionHelperResult = Invoke-Script @scriptExecutionHelperParameters
                    $scriptExecutionHelperResult.Exception.Message | Should Be $testErrorMessage
                }
            }

            Context 'Specified script returns nothing and Credential specified' {
                $scriptExecutionHelperParameters = @{
                    ScriptBlock = { return $null }
                    Credential = $script:testCredenital
                }

                It 'Should not throw' {
                    { $null = Invoke-Script @scriptExecutionHelperParameters } | Should Not Throw
                }

                It 'Should run script through Invoke-Command using the specified Credential' {
                    $null = Invoke-Script @scriptExecutionHelperParameters

                    $invokeCommandParameterFilter = {
                        $scriptBlockParameterCorrect = $null -eq (Compare-Object -ReferenceObject $scriptExecutionHelperParameters.ScriptBlock.Ast -DifferenceObject $ScriptBlock.Ast)
                        $credentialParameterCorrect = $null -eq (Compare-Object -ReferenceObject $scriptExecutionHelperParameters.Credential -DifferenceObject $Credential)

                        return $scriptBlockParameterCorrect -and $credentialParameterCorrect
                    }

                    Assert-MockCalled -CommandName 'Invoke-Command' -ParameterFilter $invokeCommandParameterFilter -Times 1 -Scope 'It'
                }

                It 'Should return nothing' {
                    $scriptExecutionHelperResult = Invoke-Script @scriptExecutionHelperParameters
                    $scriptExecutionHelperResult | Should Be $null
                }
            }

            Context 'Specified script returns a result and Credential not specified' {
                $testScriptResult = 'Script result'

                $scriptExecutionHelperParameters = @{
                    ScriptBlock = { return $testScriptResult }
                }

                It 'Should not run script through Invoke-Command' {
                    $null = Invoke-Script @scriptExecutionHelperParameters
                    Assert-MockCalled -CommandName 'Invoke-Command' -Times 0 -Scope 'It'
                }

                It 'Should return result of script' {
                    $scriptExecutionHelperResult = Invoke-Script @scriptExecutionHelperParameters
                    $scriptExecutionHelperResult | Should Be $testScriptResult
                } 
            }
        }
    }
}
finally
{
    Exit-DscResourceTestEnvironment -TestEnvironment $script:testEnvironment
}
