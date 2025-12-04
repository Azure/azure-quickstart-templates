# Run the tests from VS Code after installing ms-vscode.powershell extension and Pester (https://pester.dev/docs/quick-start).
# To execute the tests from PowerShell run: Invoke-Pester -Output Detailed <path_to_this_file>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

BeforeAll {
    $global:IsUnderTest = $true
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')
    . (Join-Path $PSScriptRoot 'windows-install-winget-packages.ps1') -Packages 'UNUSED'
}

Describe "CreateDevVhdTests" {
    BeforeEach {
        $global:LASTEXITCODE = 0
        $script:sleepTimes = @()
        Mock -CommandName Start-Sleep -ModuleName windows-retry-utils -MockWith { param ($seconds) $script:sleepTimes += $seconds; Write-Host "Sleeping $seconds seconds" }

        Mock Invoke-Executable {
            param (
                [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
            )

            throw "Must be mocked by the test! Invoking $commandLine."
        }

        Mock Invoke-Executable {
            param (
                [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
            )

            Write-Host "=== [Mock] Invoking $commandLine"
        } -ParameterFilter { $commandLine -like '*winget.exe --info' }

        Mock Invoke-Executable {
            param (
                [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
            )
    
            Write-Host "=== [Mock] Invoking $commandLine"
            $global:LASTEXITCODE = 123
        } -ParameterFilter { $commandLine -like '*robocopy.exe /R:5 /W:5 /S *AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir C:\.tools\Setup\Logs\WinGet' }

        Mock Invoke-Executable {
            param (
                [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
            )
    
            Write-Host "=== [Mock] Invoking $commandLine"
            $global:LASTEXITCODE = 123
        } -ParameterFilter { $commandLine -like 'C:\Windows\System32\icacls.exe "C:\Program Files\WinGet\Packages" /t /q /grant "BUILTIN\Users:(rx)"' }
    }

    It "InstallSuccess_<TestName>" -ForEach @(
        @{
            TestName     = 'SinglePackageNoVersion';
            TestPackages = 'TestPkg_975'
            ExpectedArgs = @('TestPkg_975 ')
        }
        @{
            TestName     = 'SinglePackageWithVersion';
            TestPackages = 'TestPkg_975@2.0.1'
            ExpectedArgs = @('TestPkg_975 --version 2.0.1')
        }
        @{
            TestName     = 'MultiplePackageNoVersion';
            TestPackages = 'TestPkg_975 , Test1Pkg2, ,   ,_Test_Pkg-_'
            ExpectedArgs = @('TestPkg_975 ', 'Test1Pkg2 ', '_Test_Pkg-_ ')
        }
        @{
            TestName     = 'MultiplePackageWithVersion';
            TestPackages = 'TestPkg_975@4.5.6 , Test1Pkg2, ,   ,_Test_Pkg-_@1.2.3   '
            ExpectedArgs = @('TestPkg_975 --version 4.5.6', 'Test1Pkg2 ', '_Test_Pkg-_ --version 1.2.3')
        }
    ) {
        Mock Invoke-Executable {
            param (
                [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
            )

            foreach ($expectedArg in $ExpectedArgs) {
                if ($commandLine -like "*winget.exe install --id $expectedArg --exact --disable-interactivity --silent --no-upgrade --accept-package-agreements --accept-source-agreements --verbose-logs --scope machine --force") {
                    Write-Host "=== [Mock] Invoking $commandLine"
                    return
                }
            }

            throw "Unexpected command: $commandLine"
        }

        Install-WinGet-Packages -Packages $TestPackages
        Should -Invoke Invoke-Executable -Times (3 + $ExpectedArgs.Count) -Exactly
        $script:sleepTimes | Should -Be @()
        $global:LASTEXITCODE | Should -Be 0
    }

    It "InvalidPackageFormat" {
        { 
            Install-WinGet-Packages -Packages 'TestPkg_975@2.0.1@3.0.1'
        } | Should -Throw 'Unexpected format for package TestPkg_975@2.0.1@3.0.1. Expected format is *'
        $script:sleepTimes | Should -Be @()
    }

    It "MissingWinGet" {
        function Get-Command { return $null }
        { Install-WinGet-Packages -Packages 'TestPkg_975' } | Should -Throw 'Could not locate winget.exe'
        $script:sleepTimes | Should -Be @()
    }

    It "ThrowOnInstallFailure" {
        Mock Invoke-Executable {
            param (
                [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
            )

            if ($commandLine -like "*winget.exe install --id TestPkg_1  --exact --disable-interactivity --silent --no-upgrade --accept-package-agreements --accept-source-agreements --verbose-logs --scope machine --force") {
                Write-Host "=== [Mock] Invoking $commandLine"
                return
            }

            if ($commandLine -like '*winget.exe install --id TestPkg_2  --exact --disable-interactivity --silent --no-upgrade --accept-package-agreements --accept-source-agreements --verbose-logs --scope machine --force') {
                $global:LASTEXITCODE = 1
                Write-Host "=== [Mock] Failed command: $commandLine"
                return
            }

            throw "Unexpected command: $commandLine"
        }

        { Install-WinGet-Packages -Packages 'TestPkg_1, TestPkg_2 , TestPkg_3' }  | Should -Throw "Failed to install TestPkg_2 with exit code 1. WinGet return codes are listed at https://github.com/microsoft/winget-cli/blob/master/doc/windows/package-manager/winget/returnCodes.md"
        $script:sleepTimes | Should -Be @(1, 1, 1, 1, 1)
        Should -Invoke Invoke-Executable -Times 8 -Exactly
    }

    It "IgnoreInstallFailure" {
        Mock Invoke-Executable {
            param (
                [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
            )

            foreach ($expectedArg in @('TestPkg_2 ', 'TestPkg_3 ')) {
                if ($commandLine -like "*winget.exe install --id $expectedArg --exact --disable-interactivity --silent --no-upgrade --accept-package-agreements --accept-source-agreements --verbose-logs --scope machine --force") {
                    Write-Host "=== [Mock] Invoking $commandLine"
                    return
                }
            }

            if ($commandLine -like '*winget.exe install --id TestPkg_2  --exact --disable-interactivity --silent --no-upgrade --accept-package-agreements --accept-source-agreements --verbose-logs --scope machine --force') {
                $global:LASTEXITCODE = 1
                Write-Host "=== [Mock] Failed command: $commandLine"
                return
            }

            throw "Unexpected command: $commandLine"
        }

        Install-WinGet-Packages -Packages 'TestPkg_1, TestPkg_2 , TestPkg_3' -IgnorePackageInstallFailures $true
        $script:sleepTimes | Should -Be @(1, 1, 1, 1, 1)
        $global:LASTEXITCODE | Should -Be 0
        Should -Invoke Invoke-Executable -Times 11 -Exactly
    }
}
