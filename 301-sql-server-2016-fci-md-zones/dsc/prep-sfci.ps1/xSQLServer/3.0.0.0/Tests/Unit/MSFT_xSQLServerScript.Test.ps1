<#
    .SYNOPSIS
       Automated unit test for MSFT_xSQLServerScript DSC Resource
#>


$Script:DSCModuleName      = 'MSFT_xSQLServerScript' 
$Script:DSCResourceName    = 'MSFT_xSQLServerScript' 

#region HEADER

# Unit Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 

#endregion HEADER

Add-Type -ErrorAction SilentlyContinue -TypeDefinition @'
namespace Microsoft.SqlServer.Management.PowerShell
{
    public class SqlPowerShellSqlExecutionException : System.Exception
    {
        public SqlPowerShellSqlExecutionException()
        {
        }
    }
}
'@ 

# Begin Testing
try
{
    #region Pester Test Initialization
        Function script:Invoke-SqlCmd {}
    #endregion Pester Test Initialization

    #region Test Sql script throws an error
    Describe 'Test Sql script throws an error' {
        Mock -CommandName Import-Module -MockWith {}        

        $testParameters = @{
            ServerInstance = $env:COMPUTERNAME 
            SetFilePath = "set.sql" 
            GetFilePath = "get.sql" 
            TestFilePath = "test.sql"
        }

        It 'Get method returns successfully' {         
            Mock -CommandName Invoke-SqlCmd -MockWith { "" }

            $result = Get-TargetResource @testParameters

            $result.ServerInstance | should be $testParameters.ServerInstance
            $result.SetFilePath | should be $testParameters.SetFilePath
            $result.GetFilePath | should be $testParameters.GetFilePath
            $result.TestFilePath | should be $testParameters.TestFilePath
            $result.GetType() | should be "hashtable"
        }

        It 'Test method returns false' {
            Mock -CommandName Invoke-SqlCmd -MockWith { throw New-Object Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException}

            Test-TargetResource @testParameters | should be $false
        }

        It 'Set method calls Invoke-SqlCmd' {
            Mock -CommandName Invoke-SqlCmd -MockWith { "" } -Verifiable

            $result = Set-TargetResource @testParameters

            Assert-MockCalled -CommandName Invoke-SqlCmd -Times 1
        }
    }
    #endregion Test Sql script throws an error

    #region Test Sql script returns null
    Describe 'Test Sql script returns null' {
        Mock -CommandName Import-Module -MockWith {}        
        Mock -CommandName Invoke-SqlCmd -MockWith { $null }

        $testParameters = @{
            ServerInstance = $env:COMPUTERNAME 
            SetFilePath = "set.sql" 
            GetFilePath = "get.sql" 
            TestFilePath = "test.sql"
        }

        It 'Get method returns successfully' {                     
            $result = Get-TargetResource @testParameters

            $result.ServerInstance | should be $testParameters.ServerInstance
            $result.SetFilePath | should be $testParameters.SetFilePath
            $result.GetFilePath | should be $testParameters.GetFilePath
            $result.TestFilePath | should be $testParameters.TestFilePath
            $result.GetType() | should be "hashtable"
        }

        It 'Test method returns true' {
            Test-TargetResource @testParameters | should be $true
        }
    }
    #endregion Test Sql script returns null

    #region Get SQl script throws and error
    Describe 'Get SQl script throws and error' {
        Mock -CommandName Import-Module -MockWith {}

        $testParameters = @{
            ServerInstance = $env:COMPUTERNAME 
            SetFilePath = "set.sql" 
            GetFilePath = "get.sql" 
            TestFilePath = "test.sql"
        }

        It 'Get throws when get sql script throws' {                     
            $throwMessage = "Failed to run SQL Script"

            Mock -CommandName Invoke-SqlCmd -MockWith { Throw $throwMessage }

            { Get-TargetResource @testParameters } | should throw $throwMessage
        }

        It 'Test method returns true' {
            Mock -CommandName Invoke-SqlCmd -MockWith { $null }

            Test-TargetResource @testParameters | should be $true
        }
    }
    #endregion

    #region Set-TargetResource throws when Set Sql script throws
    Describe 'Set-TargetResource throws when Set Sql script throws' {
        Mock -CommandName Import-Module -MockWith {}       
        Mock -CommandName Invoke-SqlCmd -MockWith { $null }

        $testParameters = @{
            ServerInstance = $env:COMPUTERNAME 
            SetFilePath = "set.sql" 
            GetFilePath = "get.sql" 
            TestFilePath = "test.sql"
        }

        It 'Get method returns successfully' {      
            $result = Get-TargetResource @testParameters

            $result.ServerInstance | should be $testParameters.ServerInstance
            $result.SetFilePath | should be $testParameters.SetFilePath
            $result.GetFilePath | should be $testParameters.GetFilePath
            $result.TestFilePath | should be $testParameters.TestFilePath
            $result.GetType() | should be "hashtable"
        }

        It 'Test method returns true' {
            Test-TargetResource @testParameters | should be $true
        }

        It 'Set method throws' {
            $throwMessage = "Failed to execute set Sql script"

            Mock -CommandName Invoke-SqlCmd -MockWith { throw $throwMessage }

            { Set-TargetResource @testParameters } | should throw $throwMessage
        }
    }
    #endregion

    #region Failed to import SQLPS module
    Describe 'Failed to import SQLPS module' {
        $throwMessage = "Failed to import module SQLPS"

        Mock -CommandName Import-Module -MockWith { throw $throwMessage }        

        $testParameters = @{
            ServerInstance = $env:COMPUTERNAME 
            SetFilePath = "set.sql" 
            GetFilePath = "get.sql" 
            TestFilePath = "test.sql"
        }

        It 'Get method throws' {         
            { $result = Get-TargetResource @testParameters } | should throw $throwMessage
        }

        It 'Test method throws' {
            { Test-TargetResource @testParameters } | should throw $throwMessage
        }

        It 'Set method throws' {
            { Set-TargetResource @testParameters} | should throw $throwMessage
        }
    }
    #endregion

}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    #endregion
}
