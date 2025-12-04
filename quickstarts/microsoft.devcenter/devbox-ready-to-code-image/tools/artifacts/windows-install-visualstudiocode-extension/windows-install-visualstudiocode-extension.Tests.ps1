# In PowerShell 5.1 or later, run:
# - To install Pester: Install-Module Pester -Force
# - To execute tests:  Invoke-Pester -Path <path to test file>
# More is at https://pester.dev/docs/quick-start

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

BeforeAll {
    $global:IsUnderTest = $true
    $retryModuleName = 'windows-retry-utils'
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) "_common/$retryModuleName.psm1") -DisableNameChecking
    
    $marketplaceModuleName = 'windows-visual-studio-marketplace-utils'  
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) "_common/$marketplaceModuleName.psm1") -DisableNameChecking
    
    . (Join-Path $PSScriptRoot "windows-install-visualstudiocode-extension.ps1")

    $script:currentAttempt = 0
    $script:sleepTimes = @()
    Mock -CommandName Start-Sleep -ModuleName $retryModuleName -MockWith { param ($seconds) $script:sleepTimes += $seconds; Write-Host "Sleeping $seconds seconds" }

    Mock Write-Host {}
}

Describe "Confirm-UserRequest Tests" {
    It "Should not throw an error if only ExtensionId is provided" {
        { Confirm-UserRequest -extensionId "test-id" } | Should -Not -Throw
    }

    It "Should not throw an error if only ExtensionName is provided" {
        { Confirm-UserRequest -extensionName "test-name" } | Should -Not -Throw
    }

    It "Should not throw an error if only ExtensionVsixPath is provided" {
        { Confirm-UserRequest -extensionVsixPath "https://example.com/test.vsix" } | Should -Not -Throw
    }

    It "Should throw an error if more than one parameter is provided" {
        { Confirm-UserRequest -extensionId "test-id" -extensionName "test-name" } | Should -Throw
        { Confirm-UserRequest -extensionId "test-id" -extensionVsixPath "https://example.com/test.vsix" } | Should -Throw
        { Confirm-UserRequest -extensionName "test-name" -extensionVsixPath "https://example.com/test.vsix" } | Should -Throw
    }

    It "Should throw an error if ExtensionVsixPath and ExtensionVersion are both provided" {
        { Confirm-UserRequest -extensionVsixPath "https://example.com/test.vsix" -extensionVersion "1.0.0" } | Should -Throw
    }
}

Describe "Import-ExtensionToLocalPath Tests" {
    BeforeEach {
        # Mock dependencies
        Mock Import-RemoteVisualStudioPackageToPath -MockWith {}
        Mock Get-VisualStudioExtension -MockWith {
            return "C:\\Temp\\mocked-extension.vsix"
        }
        function Copy-Item {}
        Mock Copy-Item -MockWith {}
    }

    It "Should download the VSIX file from a URL" {
        Mock Test-Path -MockWith { return $false }

        $result = Import-ExtensionToLocalPath -extensionVsixPath "https://example.com/test.vsix" -downloadLocation "C:\\Temp"

        Assert-MockCalled Copy-Item -Exactly 1
        Assert-MockCalled Import-RemoteVisualStudioPackageToPath -Exactly 1
    }

    It "Should copy the local VSIX file to the download location" {
        Mock Test-Path -MockWith { return $true }

        $result = Import-ExtensionToLocalPath -extensionVsixPath "C:\\myext\\test.vsix" -downloadLocation "C:\\Temp"

        Assert-MockCalled Copy-Item -Exactly 1
        Assert-MockCalled Import-RemoteVisualStudioPackageToPath -Exactly 0
    }

    It "Should throw an error if file path does not exist" {
        Mock Test-Path -MockWith { return $false }

        { Import-ExtensionToLocalPath -extensionVsixPath "C:\\NonExistent\\test.vsix" -downloadLocation "C:\\Temp" } | Should -Throw
    }

    It "Should call Get-VisualStudioExtension for ExtensionName" {
        $result = Import-ExtensionToLocalPath -extensionName "test-name" -extensionVersion "1.0.0" -downloadLocation "C:\\Temp"

        $result | Should -Be "C:\\Temp\\mocked-extension.vsix"
        Assert-MockCalled Get-VisualStudioExtension -Exactly 1 -Scope It
    }

    It "Should call Get-VisualStudioExtension for ExtensionId" {
        $result = Import-ExtensionToLocalPath -extensionId "test-id" -extensionVersion "1.0.0" -downloadLocation "C:\\Temp"

        $result | Should -Be "C:\\Temp\\mocked-extension.vsix"
        Assert-MockCalled Get-VisualStudioExtension -Exactly 1 -Scope It
    }
}

Describe "Main Function Tests" {
    BeforeEach {
        # Mock dependencies
        Mock Confirm-UserRequest {}
        Mock Import-ExtensionToLocalPath -MockWith {
            return "C:\\Temp\\mocked-extension.vsix"
        }
        Mock Resolve-VisualStudioCodeBootstrapPath -MockWith {
            return "C:\\Program Files\\VSCode\\extensions"
        }
        function Get-ChildItem {}
        Mock Get-ChildItem -MockWith {
            return @("mocked-extension1", "mocked-extension2")
        }
        Mock Test-Path -MockWith { return $true }
    }

    It "Should validate user input and download extension" {
        Main -extensionId "test-id"

        Assert-MockCalled Confirm-UserRequest -Exactly 1
        Assert-MockCalled Import-ExtensionToLocalPath -Exactly 1
    }

    It "Should list all installed extensions if emitAllInstalledExtensions is true" {
        Main -extensionId "test-id" -emitAllInstalledExtensions $true

        Assert-MockCalled Get-ChildItem -Exactly 1
    }
}
