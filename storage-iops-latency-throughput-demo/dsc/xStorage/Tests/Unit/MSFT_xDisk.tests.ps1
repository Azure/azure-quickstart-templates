$script:DSCModuleName      = 'xStorage'
$script:DSCResourceName    = 'MSFT_xDisk'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1')

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

# Begin Testing
try
{
    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $script:DSCResourceName {
        #region Pester Test Initialization
        $script:testDriveLetter = 'G'

        $script:mockedDisk0 = [pscustomobject] @{
                Number = 0
                DiskNumber = 0
                IsOffline = $false
                IsReadOnly = $false
                PartitionStyle = 'GPT'
            }

        $script:mockedDisk0Mbr = [pscustomobject] @{
                Number = 0
                DiskNumber = 0
                IsOffline = $false
                IsReadOnly = $false
                PartitionStyle = 'MBR'
            }

        $script:mockedDisk0Offline = [pscustomobject] @{
                Number = 0
                DiskNumber = 0
                IsOffline = $true
                IsReadOnly = $false
                PartitionStyle = 'GPT'
            }

        $script:mockedDisk0OfflineRaw = [pscustomobject] @{
                Number = 0
                DiskNumber = 0
                IsOffline = $true
                IsReadOnly = $false
                PartitionStyle = 'Raw'
            }

        $script:mockedDisk0Readonly = [pscustomobject] @{
                Number = 0
                DiskNumber = 0
                IsOffline = $false
                IsReadOnly = $true
                PartitionStyle = 'GPT'
            }

        $script:mockedDisk0Raw = [pscustomobject] @{
                Number = 0
                DiskNumber = 0
                IsOffline = $false
                IsReadOnly = $false
                PartitionStyle = 'Raw'
            }

        $script:mockedWmi = [pscustomobject] @{BlockSize=4096}

        $script:mockedPartition = [pscustomobject] @{
                DriveLetter = $script:testDriveLetter
                Size = 123
            }

        $script:mockedVolume = [pscustomobject] @{
                FileSystemLabel = 'myLabel'
                DriveLetter = $script:testDriveLetter
                FileSystem = 'NTFS'
            }

        $script:mockedVolumeNoDriveLetter = [pscustomobject] @{
                FileSystemLabel = 'myLabel'
                DriveLetter = ''
                FileSystem = 'NTFS'
            }

        $script:mockedVolumeReFS = [pscustomobject] @{
                FileSystemLabel = 'myLabel'
                DriveLetter = $script:testDriveLetter
                FileSystem = 'ReFS'
            }
        #endregion

        #region functions for mocking pipeline
        # These functions are required to be able to mock functions where
        # values are passed in via the pipeline.
        function Set-Disk {
            Param
            (
                [CmdletBinding()]
                [Parameter(ValueFromPipeline)]
                $InputObject,

                [Boolean]
                $IsOffline,

                [Boolean]
                $IsReadOnly
            )
        }

        function Initialize-Disk {
            Param
            (
                [CmdletBinding()]
                [Parameter(ValueFromPipeline)]
                $InputObject,

                [String]
                $PartitionStyle
            )
        }

        function Get-Partition {
            Param
            (
                [CmdletBinding()]
                [Parameter(ValueFromPipeline)]
                $Disk,

                [String]
                $DriveLetter,

                [Uint32]
                $DiskNumber,

                [Uint32]
                $ParitionNumber
            )
        }

        function Get-Volume {
            Param
            (
                [CmdletBinding()]
                [Parameter(ValueFromPipeline)]
                $Partition,

                [String]
                $DriveLetter
            )
        }

        function Set-Volume {
            Param
            (
                [CmdletBinding()]
                [Parameter(ValueFromPipeline)]
                $InputObject,

                [String]
                $NewFileSystemLabel
            )
        }

        function Format-Volume {
            Param
            (
                [CmdletBinding()]
                [Parameter(ValueFromPipeline)]
                $Partition,

                [String]
                $DriveLetter,

                [String]
                $FileSystem,

                [Boolean]
                $Confirm,

                [String]
                $NewFileSystemLabel,

                [Uint32]
                $AllocationUnitSize
            )
        }
        #endregion

        #region Function Get-TargetResource
        Describe 'MSFT_xDisk\Get-TargetResource' {
            Context 'Online GPT disk with a partition/volume and correct Drive Letter assigned' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedWmi } `
                    -Verifiable

                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-WmiObject

                $resource = Get-TargetResource `
                    -DiskNumber 0 `
                    -DriveLetter $script:testDriveLetter `
                    -Verbose

                It "DiskNumber should be $($script:mockedDisk0.Number)" {
                    $resource.DiskNumber | Should be $script:mockedDisk0.Number
                }

                It "DriveLetter should be $($script:testDriveLetter)" {
                    $resource.DriveLetter | Should be $script:testDriveLetter
                }

                It "Size should be $($script:mockedPartition.Size)" {
                    $resource.Size | Should be $script:mockedPartition.Size
                }

                It "FSLabel should be $($script:mockedVolume.FileSystemLabel)" {
                    $resource.FSLabel | Should be $script:mockedVolume.FileSystemLabel
                }

                It "AllocationUnitSize should be $($script:mockedWmi.BlockSize)" {
                    $resource.AllocationUnitSize | Should be $script:mockedWmi.BlockSize
                }

                It "FSFormat should be $($script:mockedVolume.FileSystem)" {
                    $resource.FSFormat | Should be $script:mockedVolume.FileSystem
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                }
            }

            Context 'Online GPT disk with no partition' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-CimInstance `
                    -Verifiable

                Mock `
                    -CommandName Get-WmiObject `
                    -Verifiable

                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -Verifiable

                $resource = Get-TargetResource `
                    -DiskNumber 0 `
                    -DriveLetter $script:testDriveLetter `
                    -Verbose

                It "DiskNumber should be $($script:mockedDisk0.Number)" {
                    $resource.DiskNumber | Should be $script:mockedDisk0.Number
                }

                It "DriveLetter should be null" {
                    $resource.DriveLetter | Should be $null
                }

                It "Size should be null" {
                    $resource.Size | Should be $null
                }

                It "FSLabel should be empty" {
                    $resource.FSLabel | Should be ''
                }

                It "AllocationUnitSize should be null" {
                    $resource.AllocationUnitSize | Should be $null
                }

                It "FSFormat should be null" {
                    $resource.FSFormat | Should be $null
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-CimInstance -Exactly 1
                    Assert-MockCalled -CommandName Get-WmiObject -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 1
                    Assert-MockCalled -CommandName Get-Partition -Exactly 1
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'MSFT_xDisk\Set-TargetResource' {
            Context 'Offline GPT disk' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0Offline } `
                    -Verifiable

                Mock `
                    -CommandName Set-Disk `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -Verifiable

                Mock `
                    -CommandName New-Partition `
                    -ParameterFilter {
                        $DriveLetter -eq $script:testDriveLetter
                    } `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Format-Volume `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Initialize-Disk
                Mock -CommandName Get-Volume
                Mock -CommandName Set-Partition

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 1
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName New-Partition -Times 1 `
                        -ParameterFilter {
                            $DriveLetter -eq $script:testDriveLetter
                        }
                    Assert-MockCalled -CommandName Format-Volume -Times 1
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                }
            }

            Context 'Readonly GPT disk' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0Readonly } `
                    -Verifiable

                Mock `
                    -CommandName Set-Disk `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -Verifiable

                Mock `
                    -CommandName New-Partition `
                    -ParameterFilter {
                        $DriveLetter -eq $script:testDriveLetter
                    } `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Format-Volume `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Initialize-Disk
                Mock -CommandName Get-Volume
                Mock -CommandName Set-Partition

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 1
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName New-Partition -Times 1 `
                        -ParameterFilter {
                            $DriveLetter -eq $script:testDriveLetter
                        }
                    Assert-MockCalled -CommandName Format-Volume -Times 1
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                }
            }

            Context 'Offline RAW disk' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0OfflineRaw } `
                    -Verifiable

                Mock `
                    -CommandName Set-Disk `
                    -Verifiable

                Mock `
                    -CommandName Initialize-Disk `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -Verifiable

                Mock `
                    -CommandName New-Partition `
                    -ParameterFilter {
                        $DriveLetter -eq $script:testDriveLetter
                    } `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Format-Volume `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-Volume
                Mock -CommandName Set-Partition

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 1
                    Assert-MockCalled -CommandName Initialize-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName New-Partition -Times 1 `
                        -ParameterFilter {
                            $DriveLetter -eq $script:testDriveLetter
                        }
                    Assert-MockCalled -CommandName Format-Volume -Times 1
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                }
            }

            Context 'Online RAW disk' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0Raw } `
                    -Verifiable

                Mock `
                    -CommandName Initialize-Disk `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -Verifiable

                Mock `
                    -CommandName New-Partition `
                    -ParameterFilter {
                        $DriveLetter -eq $script:testDriveLetter
                    } `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Format-Volume `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Set-Disk
                Mock -CommandName Get-Volume
                Mock -CommandName Set-Partition

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 0
                    Assert-MockCalled -CommandName Initialize-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName New-Partition -Times 1 `
                        -ParameterFilter {
                            $DriveLetter -eq $script:testDriveLetter
                        }
                    Assert-MockCalled -CommandName Format-Volume -Times 1
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                }
            }

            Context 'Online GPT disk with no partitions' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -Verifiable

                Mock `
                    -CommandName New-Partition `
                    -ParameterFilter {
                        $DriveLetter -eq $script:testDriveLetter
                    } `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Format-Volume `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Set-Disk
                Mock -CommandName Initialize-Disk
                Mock -CommandName Get-Volume
                Mock -CommandName Set-Partition

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 0
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName New-Partition -Times 1 `
                        -ParameterFilter {
                            $DriveLetter -eq $script:testDriveLetter
                        }
                    Assert-MockCalled -CommandName Format-Volume -Times 1
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                }
            }

            Context 'Online MBR disk' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0Mbr } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Set-Disk
                Mock -CommandName Initialize-Disk
                Mock -CommandName Get-Partition
                Mock -CommandName New-Partition
                Mock -CommandName Format-Volume
                Mock -CommandName Get-Volume
                Mock -CommandName Set-Partition

                $errorRecord = Get-InvalidOperationRecord `
                    -Message ($LocalizedData.DiskAlreadyInitializedError -f `
                        0,$script:mockedDisk0Mbr.PartitionStyle)

                It 'Should throw DiskAlreadyInitializedError' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should Throw $errorRecord
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 0
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 0
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName New-Partition -Times 0
                    Assert-MockCalled -CommandName Format-Volume -Times 0
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                }
            }

            Context 'Online GPT disk with a partition/volume' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Set-Disk
                Mock -CommandName Initialize-Disk
                Mock -CommandName Format-Volume
                Mock -CommandName Set-Partition

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 0
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName New-Partition -Times 0
                    Assert-MockCalled -CommandName Format-Volume -Times 0
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                }
            }

            Context 'Online GPT disk with a partition/volume and no Drive Letter assigned' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeNoDriveLetter } `
                    -Verifiable

                Mock `
                    -CommandName Set-Partition `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Set-Disk
                Mock -CommandName Initialize-Disk
                Mock -CommandName Format-Volume

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 0
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName New-Partition -Times 0
                    Assert-MockCalled -CommandName Format-Volume -Times 0
                    Assert-MockCalled -CommandName Set-Partition -Times 1
                }
            }

            Context 'Online GPT disk with a partition/volume and wrong Drive Letter assigned' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                Mock `
                    -CommandName Set-Partition `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Set-Disk
                Mock -CommandName Initialize-Disk
                Mock -CommandName Format-Volume

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter 'H' `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 0
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName New-Partition -Times 0
                    Assert-MockCalled -CommandName Format-Volume -Times 0
                    Assert-MockCalled -CommandName Set-Partition -Times 1
                }
            }

            Context 'Online GPT disk with a partition/volume and wrong Volume Label assigned' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                Mock `
                    -CommandName Set-Volume `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Set-Disk
                Mock -CommandName Initialize-Disk
                Mock -CommandName Format-Volume
                Mock -CommandName Set-Partition

                It 'Should not throw' {
                    {
                        Set-targetResource `
                            -DiskNumber 0 `
                            -Driveletter $script:testDriveLetter `
                            -FSLabel 'NewLabel' `
                            -Verbose
                    } | Should not throw
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Set-Disk -Times 0
                    Assert-MockCalled -CommandName Initialize-Disk -Times 0
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName New-Partition -Times 0
                    Assert-MockCalled -CommandName Format-Volume -Times 0
                    Assert-MockCalled -CommandName Set-Partition -Times 0
                    Assert-MockCalled -CommandName Set-Volume -Times 1
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'MSFT_xDisk\Test-TargetResource' {
            Mock `
                -CommandName Get-CimInstance `
                -MockWith { $script:mockedWmi }

            Context 'Test disk not initialized' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0Offline } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-Volume
                Mock -CommandName Get-Partition
                Mock -CommandName Get-WmiObject
                Mock -CommandName Get-CimInstance

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0Offline.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -AllocationUnitSize 4096 `
                            -Verbose
                    } | Should not throw
                }

                It 'result should be false' {
                    $script:result | Should be $false
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 0
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0
                }
            }

            Context 'Test disk read only' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0Readonly } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-Volume
                Mock -CommandName Get-Partition
                Mock -CommandName Get-WmiObject
                Mock -CommandName Get-CimInstance

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0Readonly.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -AllocationUnitSize 4096 `
                            -Verbose
                    } | Should not throw
                }

                It 'result should be false' {
                    $script:result | Should be $false
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 0
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0
                }
            }

            Context 'Test online unformatted disk' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0Raw } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-Volume
                Mock -CommandName Get-Partition
                Mock -CommandName Get-WmiObject
                Mock -CommandName Get-CimInstance

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0Raw.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -AllocationUnitSize 4096 `
                            -Verbose
                    } | Should not throw
                }

                It 'result should be false' {
                    $script:result | Should be $false
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 0
                    Assert-MockCalled -CommandName Get-Volume -Times 0
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 0
                }
            }

            Context 'Test mismatching partition size' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedWmi } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-WmiObject

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -AllocationUnitSize 4096 `
                            -Size 124 `
                            -Verbose
                    } | Should not throw
                }

                It 'result should be true' {
                    $script:result | Should be $true
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1
                }
            }

            Context 'Test mismatched AllocationUnitSize' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedWmi } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-Volume
                Mock -CommandName Get-WmiObject

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -AllocationUnitSize 4097 `
                            -Verbose
                    } | Should not throw
                }

                # skipped due to:  https://github.com/PowerShell/xStorage/issues/22
                It 'result should be false' -skip {
                    $script:result | Should be $false
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1
                }
            }

            Context 'Test mismatching FSFormat' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedWmi } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-WmiObject

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -FSFormat 'ReFS' `
                            -Verbose
                    } | Should not throw
                }

                It 'result should be true' {
                    $script:result | Should be $true
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1
                }
            }

            Context 'Test mismatching FSLabel' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedWmi } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-WmiObject

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -FSLabel 'NewLabel' `
                            -Verbose
                    } | Should not throw
                }

                It 'result should be false' {
                    $script:result | Should be $false
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1
                }
            }

            Context 'Test all disk properties matching' {
                # verifiable (should be called) mocks
                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDisk0 } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartition } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolume } `
                    -Verifiable

                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedWmi } `
                    -Verifiable

                # mocks that should not be called
                Mock -CommandName Get-WmiObject

                $script:result = $null

                It 'calling test should not throw' {
                    {
                        $script:result = Test-TargetResource `
                            -DiskNumber $script:mockedDisk0.Number `
                            -DriveLetter $script:mockedVolume.DriveLetter `
                            -AllocationUnitSize 4096 `
                            -Size $script:mockedPartition.Size `
                            -FSLabel $script:mockedVolume.FileSystemLabel `
                            -FSFormat $script:mockedVolume.FileSystem `
                            -Verbose
                    } | Should not throw
                }

                It 'result should be true' {
                    $script:result | Should be $true
                }

                It 'the correct mocks were called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-Disk -Times 1
                    Assert-MockCalled -CommandName Get-Partition -Times 1
                    Assert-MockCalled -CommandName Get-Volume -Times 1
                    Assert-MockCalled -CommandName Get-WmiObject -Times 0
                    Assert-MockCalled -CommandName Get-CimInstance -Times 1
                }
            }
        }
        #endregion
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
