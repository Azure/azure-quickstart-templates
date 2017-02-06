Import-Module "$PSScriptRoot\..\CommonTestHelper.psm1" -Force

$script:testEnvironment = Enter-DscResourceTestEnvironment `
    -DscResourceModuleName 'xPSDesiredStateConfiguration' `
    -DscResourceName 'MSFT_xPackageResource' `
    -TestType 'Unit'

try
{
    InModuleScope 'MSFT_xPackageResource' {
        Describe 'MSFT_xPackageResource Unit Tests' {
            BeforeAll {
                Import-Module "$PSScriptRoot\MSFT_xPackageResource.TestHelper.psm1" -Force
                Import-Module "$PSScriptRoot\..\CommonTestHelper.psm1"

                $script:skipHttpsTest = $true

                $script:testDirectoryPath = Join-Path -Path $PSScriptRoot -ChildPath 'MSFT_xPackageResourceTests'

                if (Test-Path -Path $script:testDirectoryPath)
                {
                    $null = Remove-Item -Path $script:testDirectoryPath -Recurse -Force
                }

                $null = New-Item -Path $script:testDirectoryPath -ItemType 'Directory'

                $script:msiName = 'DSCSetupProject.msi'
                $script:msiLocation = Join-Path -Path $script:testDirectoryPath -ChildPath $script:msiName
                $script:msiArguments = '/NoReboot'

                $script:packageName = 'DSCUnitTestPackage'
                $script:packageId = '{deadbeef-80c6-41e6-a1b9-8bdb8a05027f}'

                $null = New-TestMsi -DestinationPath $script:msiLocation

                $script:testExecutablePath = Join-Path -Path $script:testDirectoryPath -ChildPath 'TestExecutable.exe'

                $null = New-TestExecutable -DestinationPath $script:testExecutablePath

                $null = Clear-xPackageCache
            }

            BeforeEach {
                $null = Clear-xPackageCache

                if (Test-PackageInstalledByName -Name $script:packageName)
                {
                    $null = Start-Process -FilePath 'msiexec.exe' -ArgumentList @("/x$script:packageId", '/passive') -Wait
                    $null = Start-Sleep -Seconds 1
                }

                if (Test-PackageInstalledByName -Name $script:packageName)
                {
                    throw 'Package could not be removed.'
                }
            }

            AfterAll {
                if (Test-Path -Path $script:testDirectoryPath)
                {
                    $null = Remove-Item -Path $script:testDirectoryPath -Recurse -Force
                }

                $null = Clear-xPackageCache

                if (Test-PackageInstalledByName -Name $script:packageName)
                {
                    $null = Start-Process -FilePath 'msiexec.exe' -ArgumentList @("/x$script:packageId", '/passive') -Wait
                    $null = Start-Sleep -Seconds 1
                }

                if (Test-PackageInstalledByName -Name $script:packageName)
                {
                    throw 'Test output will not be valid - package could not be removed.'
                }
            }

            Context 'Get-TargetResource' {
                It 'Should return only basic properties for absent package' {
                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = $script:packageName
                        ProductId = $script:packageId
                    }

                    $getTargetResourceResult = Get-TargetResource @packageParameters
                    $getTargetResourceResultProperties = @( 'Ensure', 'Name', 'ProductId', 'Installed' )

                    Test-GetTargetResourceResult -GetTargetResourceResult $getTargetResourceResult -GetTargetResourceResultProperties $getTargetResourceResultProperties
                }

                It 'Should return basic and registry properties for present package with registry check parameters specified and CreateCheckRegValue true' {
                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = $script:packageName
                        ProductId = $script:packageId
                        CreateCheckRegValue = $true
                        InstalledCheckRegHive = 'LocalMachine'
                        InstalledCheckRegKey = 'SOFTWARE\xPackageTestKey'
                        InstalledCheckRegValueName = 'xPackageTestValue'
                        InstalledCheckRegValueData = 'installed'
                    }

                    Set-TargetResource -Ensure 'Present' @packageParameters

                    try
                    {
                        Clear-xPackageCache

                        $getTargetResourceResult = Get-TargetResource @packageParameters
                        $getTargetResourceResultProperties = @( 'Ensure', 'Name', 'ProductId', 'Installed', 'CreateCheckRegValue', 'InstalledCheckRegHive', 'InstalledCheckRegKey', 'InstalledCheckRegValueName', 'InstalledCheckRegValueData' )

                        Test-GetTargetResourceResult -GetTargetResourceResult $getTargetResourceResult -GetTargetResourceResultProperties $getTargetResourceResultProperties
                    }
                    finally
                    {
                        $baseRegistryKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default)
                        $baseRegistryKey.DeleteSubKeyTree($packageParameters.InstalledCheckRegKey)
                    }
                }

                It 'Should return full package properties for present package with registry check parameters specified and CreateCheckRegValue false' {
                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = $script:packageName
                        ProductId = $script:packageId
                        CreateCheckRegValue = $false
                        InstalledCheckRegKey = ''
                        InstalledCheckRegValueName = ''
                        InstalledCheckRegValueData = ''
                    }

                    Set-TargetResource -Ensure 'Present' @packageParameters
                    Clear-xPackageCache

                    $getTargetResourceResult = Get-TargetResource @packageParameters
                    $getTargetResourceResultProperties = @( 'Ensure', 'Name', 'ProductId', 'Installed', 'Path', 'InstalledOn', 'Size', 'Version', 'PackageDescription', 'Publisher' )

                    Test-GetTargetResourceResult -GetTargetResourceResult $getTargetResourceResult -GetTargetResourceResultProperties $getTargetResourceResultProperties
                }

                It 'Should return full package properties for present package without registry check parameters specified' {
                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = $script:packageName
                        ProductId = $script:packageId
                    }

                    Set-TargetResource -Ensure 'Present' @packageParameters
                    Clear-xPackageCache

                    $getTargetResourceResult = Get-TargetResource @packageParameters
                    $getTargetResourceResultProperties = @( 'Ensure', 'Name', 'ProductId', 'Installed', 'Path', 'InstalledOn', 'Size', 'Version', 'PackageDescription', 'Publisher' )

                    Test-GetTargetResourceResult -GetTargetResourceResult $getTargetResourceResult -GetTargetResourceResultProperties $getTargetResourceResultProperties
                }
            }

            Context 'Test-TargetResource' {
                It 'Should return correct value when package is absent' {
                    $testTargetResourceResult = Test-TargetResource `
                        -Ensure 'Present' `
                        -Path $script:msiLocation `
                        -ProductId $script:packageId `
                        -Name ([String]::Empty)

                    $testTargetResourceResult | Should Be $false

                    $testTargetResourceResult = Test-TargetResource `
                        -Ensure 'Present' `
                        -Path $script:msiLocation `
                        -Name $script:packageName `
                        -ProductId ([String]::Empty)

                    $testTargetResourceResult | Should Be $false

                    $testTargetResourceResult = Test-TargetResource `
                        -Ensure 'Absent' `
                        -Path $script:msiLocation `
                        -ProductId $script:packageId `
                        -Name ([String]::Empty)

                    $testTargetResourceResult | Should Be $true

                    $testTargetResourceResult = Test-TargetResource `
                        -Ensure 'Absent' `
                        -Path $script:msiLocation `
                        -Name $script:packageName `
                        -ProductId ([String]::Empty)

                    $testTargetResourceResult | Should Be $true
                }

                It 'Should return correct value when package is present without registry parameters' {
                    Set-TargetResource -Ensure 'Present' -Path $script:msiLocation -ProductId $script:packageId -Name ([String]::Empty)

                    Clear-xPackageCache

                    Test-PackageInstalledByName -Name $script:packageName | Should Be $true

                    $testTargetResourceResult = Test-TargetResource `
                            -Ensure 'Present' `
                            -Path $script:msiLocation `
                            -ProductId $script:packageId `
                            -Name ([String]::Empty)

                    $testTargetResourceResult | Should Be $true

                    $testTargetResourceResult = Test-TargetResource `
                        -Ensure 'Present' `
                        -Path $script:msiLocation `
                        -Name $script:packageName `
                        -ProductId ([String]::Empty)

                    $testTargetResourceResult | Should Be $true

                    $testTargetResourceResult = Test-TargetResource `
                        -Ensure 'Absent' `
                        -Path $script:msiLocation `
                        -ProductId $script:packageId `
                        -Name ([String]::Empty)

                    $testTargetResourceResult | Should Be $false

                    $testTargetResourceResult = Test-TargetResource `
                        -Ensure 'Absent' `
                        -Path $script:msiLocation `
                        -Name $script:packageName `
                        -ProductId ([String]::Empty)

                    $testTargetResourceResult | Should Be $false
                }

                $existingPackageParameters = @{
                    Path = $script:testExecutablePath
                    Name = [String]::Empty
                    ProductId = [String]::Empty
                    CreateCheckRegValue = $true
                    InstalledCheckRegHive = 'LocalMachine'
                    InstalledCheckRegKey = 'SOFTWARE\xPackageTestKey'
                    InstalledCheckRegValueName = 'xPackageTestValue'
                    InstalledCheckRegValueData = 'installed'
                }

                It 'Should return present with existing exe and matching registry parameters' {
                    Set-TargetResource -Ensure 'Present' @existingPackageParameters

                    try
                    {
                        $testTargetResourceResult = Test-TargetResource -Ensure 'Present' @existingPackageParameters
                        $testTargetResourceResult | Should Be $true

                        $testTargetResourceResult = Test-TargetResource -Ensure 'Absent' @existingPackageParameters
                        $testTargetResourceResult | Should Be $false
                    }
                    finally
                    {
                        $baseRegistryKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default)
                        $baseRegistryKey.DeleteSubKeyTree($existingPackageParameters.InstalledCheckRegKey)
                    }
                }

                $parametersToMismatchCheck = @( 'InstalledCheckRegKey', 'InstalledCheckRegValueName', 'InstalledCheckRegValueData' )

                foreach ($parameterToMismatchCheck in $parametersToMismatchCheck)
                {
                    It "Should return not present with existing exe and mismatching parameter $parameterToMismatchCheck" {
                        Set-TargetResource -Ensure 'Present' @existingPackageParameters

                        try
                        {
                            $mismatchingParameters = $existingPackageParameters.Clone()
                            $mismatchingParameters[$parameterToMismatchCheck] = 'not original value'

                            Write-Verbose -Message "Test target resource parameters: $( Out-String -InputObject $mismatchingParameters)"

                            $testTargetResourceResult = Test-TargetResource -Ensure 'Present' @mismatchingParameters
                            $testTargetResourceResult | Should Be $false

                            $testTargetResourceResult = Test-TargetResource -Ensure 'Absent' @mismatchingParameters
                            $testTargetResourceResult | Should Be $true
                        }
                        finally
                        {
                            $baseRegistryKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default)
                            $baseRegistryKey.DeleteSubKeyTree($existingPackageParameters.InstalledCheckRegKey)
                        }
                    }
                }
            }

            Context 'Set-TargetResource' {
                It 'Should correctly install and remove a .msi package without registry parameters' {
                    Set-TargetResource -Ensure 'Present' -Path $script:msiLocation -ProductId $script:packageId -Name ([String]::Empty)

                    Test-PackageInstalledByName -Name $script:packageName | Should Be $true

                    $getTargetResourceResult = Get-TargetResource -Path $script:msiLocation -ProductId $script:packageId -Name ([String]::Empty)

                    $getTargetResourceResult.Version | Should Be '1.2.3.4'
                    $getTargetResourceResult.InstalledOn | Should Be ("{0:d}" -f [DateTime]::Now.Date)
                    $getTargetResourceResult.Installed | Should Be $true
                    $getTargetResourceResult.ProductId | Should Be $script:packageId
                    $getTargetResourceResult.Path | Should Be $script:msiLocation

                    # Can't figure out how to set this within the MSI.
                    # $getTargetResourceResult.PackageDescription | Should Be 'A package for unit testing'

                    [Math]::Round($getTargetResourceResult.Size, 2) | Should Be 0.03

                    Set-TargetResource -Ensure 'Absent' -Path $script:msiLocation -ProductId $script:packageId -Name ([String]::Empty)

                    Test-PackageInstalledByName -Name $script:packageName | Should Be $false
                }

                It 'Should correctly install and remove a .msi package with registry parameters' {
                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = [String]::Empty
                        ProductId = $script:packageId
                        CreateCheckRegValue = $true
                        InstalledCheckRegHive = 'LocalMachine'
                        InstalledCheckRegKey = 'SOFTWARE\xPackageTestKey'
                        InstalledCheckRegValueName = 'xPackageTestValue'
                        InstalledCheckRegValueData = 'installed'
                    }

                    Set-TargetResource -Ensure 'Present' @packageParameters

                    try
                    {
                        Test-PackageInstalledByName -Name $script:packageName | Should Be $true

                        $getTargetResourceResult = Get-TargetResource @packageParameters

                        $getTargetResourceResult.Installed | Should Be $true
                        $getTargetResourceResult.ProductId | Should Be $packageParameters.ProductId
                        $getTargetResourceResult.Path | Should Be $packageParameters.Path
                        $getTargetResourceResult.Name | Should Be $packageParameters.Name
                        $getTargetResourceResult.CreateCheckRegValue | Should Be $packageParameters.CreateCheckRegValue
                        $getTargetResourceResult.InstalledCheckRegHive | Should Be $packageParameters.InstalledCheckRegHive
                        $getTargetResourceResult.InstalledCheckRegKey | Should Be $packageParameters.InstalledCheckRegKey
                        $getTargetResourceResult.InstalledCheckRegValueName | Should Be $packageParameters.InstalledCheckRegValueName
                        $getTargetResourceResult.InstalledCheckRegValueData | Should Be $packageParameters.InstalledCheckRegValueData

                        Set-TargetResource -Ensure 'Absent' @packageParameters

                        Test-PackageInstalledByName -Name $script:packageName | Should Be $false
                    }
                    finally
                    {
                        $baseRegistryKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default)
                        $baseRegistryKey.DeleteSubKeyTree($packageParameters.InstalledCheckRegKey)
                    }
                }

                It 'Should correctly install and remove a .exe package with registry parameters' {
                    $packageParameters = @{
                        Path = $script:testExecutablePath
                        Name = [String]::Empty
                        ProductId = [String]::Empty
                        CreateCheckRegValue = $true
                        InstalledCheckRegHive = 'LocalMachine'
                        InstalledCheckRegKey = 'SOFTWARE\xPackageTestKey'
                        InstalledCheckRegValueName = 'xPackageTestValue'
                        InstalledCheckRegValueData = 'installed'
                    }

                    Set-TargetResource -Ensure 'Present' @packageParameters

                    try
                    {
                        Test-TargetResource -Ensure 'Present' @packageParameters | Should Be $true

                        $getTargetResourceResult = Get-TargetResource @packageParameters

                        $getTargetResourceResult.Installed | Should Be $true
                        $getTargetResourceResult.ProductId | Should Be $packageParameters.ProductId
                        $getTargetResourceResult.Path | Should Be $packageParameters.Path
                        $getTargetResourceResult.Name | Should Be $packageParameters.Name
                        $getTargetResourceResult.CreateCheckRegValue | Should Be $packageParameters.CreateCheckRegValue
                        $getTargetResourceResult.InstalledCheckRegHive | Should Be $packageParameters.InstalledCheckRegHive
                        $getTargetResourceResult.InstalledCheckRegKey | Should Be $packageParameters.InstalledCheckRegKey
                        $getTargetResourceResult.InstalledCheckRegValueName | Should Be $packageParameters.InstalledCheckRegValueName
                        $getTargetResourceResult.InstalledCheckRegValueData | Should Be $packageParameters.InstalledCheckRegValueData

                        Set-TargetResource -Ensure 'Absent' @packageParameters

                        Test-TargetResource -Ensure 'Absent' @packageParameters | Should Be $true
                    }
                    finally
                    {
                        $baseRegistryKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default)
                        $baseRegistryKey.DeleteSubKeyTree($packageParameters.InstalledCheckRegKey)
                    }
                }

                It 'Should throw with incorrect product id' {
                    $wrongPackageId = '{deadbeef-80c6-41e6-a1b9-8bdb8a050272}'

                    { Set-TargetResource -Ensure 'Present' -Path $script:msiLocation -ProductId $wrongPackageId -Name ([String]::Empty) } | Should Throw
                }

                It 'Should throw with incorrect name' {
                    $wrongPackageName = 'WrongPackageName'

                    { Set-TargetResource -Ensure 'Present' -Path $script:msiLocation -ProductId ([String]::Empty) -Name $wrongPackageName } | Should Throw
                }

                It 'Should correctly install and remove a package from a HTTP URL' {
                    $baseUrl = 'http://localhost:1242/'
                    $msiUrl = "$baseUrl" + "package.msi"
                    New-MockFileServer -FilePath $script:msiLocation

                    # Test pipe connection as testing server readiness
                    $pipe = New-Object -TypeName 'System.IO.Pipes.NamedPipeServerStream' -ArgumentList @( '\\.\pipe\dsctest1' )
                    $pipe.WaitForConnection()
                    $pipe.Dispose()

                    { Set-TargetResource -Ensure 'Present' -Path $baseUrl -Name $script:packageName -ProductId $script:packageId } | Should Throw

                    Set-TargetResource -Ensure 'Present' -Path $msiUrl -Name $script:packageName -ProductId $script:packageId
                    Test-PackageInstalledByName -Name $script:packageName | Should Be $true

                    Set-TargetResource -Ensure 'Absent' -Path $msiUrl -Name $script:packageName -ProductId $script:packageId
                    Test-PackageInstalledByName -Name $script:packageName | Should Be $false

                    $pipe = New-Object -TypeName 'System.IO.Pipes.NamedPipeClientStream' -ArgumentList @( '\\.\pipe\dsctest2' )
                    $pipe.Connect()
                    $pipe.Dispose()
                }

                It 'Should correctly install and remove a package from a HTTPS URL' -Skip:$script:skipHttpsTest {
                    $baseUrl = 'https://localhost:1243/'
                    $msiUrl = "$baseUrl" + "package.msi"
                    New-MockFileServer -FilePath $script:msiLocation -Https

                    # Test pipe connection as testing server reasdiness
                    $pipe = New-Object -TypeName 'System.IO.Pipes.NamedPipeServerStream' -ArgumentList @( '\\.\pipe\dsctest1' )
                    $pipe.WaitForConnection()
                    $pipe.Dispose()

                    { Set-TargetResource -Ensure 'Present' -Path $baseUrl -Name $script:packageName -ProductId $script:packageId } | Should Throw

                    Set-TargetResource -Ensure 'Present' -Path $msiUrl -Name $script:packageName -ProductId $script:packageId
                    Test-PackageInstalledByName -Name $script:packageName | Should Be $true

                    Set-TargetResource -Ensure 'Absent' -Path $msiUrl -Name $script:packageName -ProductId $script:packageId
                    Test-PackageInstalledByName -Name $script:packageName | Should Be $false

                    $pipe = New-Object -TypeName 'System.IO.Pipes.NamedPipeClientStream' -ArgumentList @( '\\.\pipe\dsctest2' )
                    $pipe.Connect()
                    $pipe.Dispose()
                }

                It 'Should write to the specified log path' {
                    $logPath = Join-Path -Path $script:testDirectoryPath -ChildPath 'TestMsiLog.txt'

                    if (Test-Path -Path $logPath)
                    {
                        Remove-Item -Path $logPath -Force
                    }

                    Set-TargetResource -Ensure 'Present' -Path $script:msiLocation -Name $script:packageName -LogPath $logPath -ProductId ([string]::Empty)

                    Test-Path -Path $logPath | Should Be $true
                    Get-Content -Path $logPath | Should Not Be $null
                }

                It 'Should add space after .MSI installation arguments (#195)' {
                    Mock Invoke-Process -ParameterFilter { $Process.StartInfo.Arguments.EndsWith($script:msiArguments) } { return @{ ExitCode = 0 } }
                    Mock Test-TargetResource { return $false }
                    Mock Get-ProductEntry { return $script:packageId }

                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = [String]::Empty
                        ProductId = $script:packageId
                        Arguments = $script:msiArguments
                    }

                    Set-TargetResource -Ensure 'Present' @packageParameters

                    Assert-MockCalled Invoke-Process -ParameterFilter { $Process.StartInfo.Arguments.EndsWith(" $script:msiArguments") } -Scope It
                }

                It 'Should not check for product installation when rebooted is required (#52)' {
                    Mock Invoke-Process { return [PSCustomObject] @{ ExitCode = 3010 } }
                    Mock Test-TargetResource { return $false }
                    Mock Get-ProductEntry { }

                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = [String]::Empty
                        ProductId = $script:packageId
                    }

                    { Set-TargetResource -Ensure 'Present' @packageParameters } | Should Not Throw
                }

                It 'Should install package using user credentials when specified' {
                    Mock Invoke-PInvoke { }
                    Mock Test-TargetResource { return $false }

                    $packageCredential = [System.Management.Automation.PSCredential]::Empty
                    $packageParameters = @{
                        Path = $script:msiLocation
                        Name = [String]::Empty
                        ProductId = $script:packageId
                        RunAsCredential = $packageCredential
                    }
                    Set-TargetResource -Ensure 'Present' @packageParameters

                    Assert-MockCalled Invoke-PInvoke -ParameterFilter { $Credential -eq $packageCredential} -Scope It
                }
            }

            Context 'Get-MsiTool' {
                It 'Should add MSI tools in the Microsoft.Windows.DesiredStateConfiguration.xPackageResource namespace' {
                    $addTypeResult = @{ Namespace = 'Mock not called' }
                    Mock -CommandName 'Add-Type' -MockWith { $addTypeResult['Namespace'] = $Namespace }

                    $msiTool = Get-MsiTool

                    if (([System.Management.Automation.PSTypeName]'Microsoft.Windows.DesiredStateConfiguration.xPackageResource.MsiTools').Type)
                    {
                        Assert-MockCalled -CommandName 'Add-Type' -Times 0

                        $msiTool | Should Be ([System.Management.Automation.PSTypeName]'Microsoft.Windows.DesiredStateConfiguration.xPackageResource.MsiTools').Type
                    }
                    else
                    {
                        Assert-MockCalled -CommandName 'Add-Type' -Times 1

                        $addTypeResult['Namespace'] | Should Be 'Microsoft.Windows.DesiredStateConfiguration.xPackageResource'
                        $msiTool | Should Be $null
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
