$script:DSCModuleName      = 'xStorage'
$script:DSCResourceName    = 'MSFT_xMountImage'

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
        $script:DriveLetter = 'X'

        # ISO Related Mocks
        $script:DiskImageISOPath = 'test.iso'

        $script:mockedDiskImageISO = [pscustomobject] @{
            Attached          = $false
            DevicePath        = $null
            FileSize          = 10GB
            ImagePath         = $script:DiskImageISOPath
            Number            = $null
            Size              = 10GB
            StorageType       = 1 ## ISO
        }
        $script:mockedDiskImageAttachedISO = [pscustomobject] @{
            Attached          = $true
            DevicePath        = '\\.\CDROM1'
            FileSize          = 10GB
            ImagePath         = $script:DiskImageISOPath
            Number            = 3
            Size              = 10GB
            StorageType       = 1 ## ISO
        }

        $script:mockedVolumeISO = [pscustomobject] @{
            DriveType         = 'CD-ROM'
            FileSystemType    = 'Unknown'
            ObjectId          = '{1}\\TEST\root/Microsoft/Windows/Storage/Providers_v2\WSP_Volume.ObjectId="{bba18018-e7a1-11e3-824e-806e6f6e6963}:VO:\\?\Volume{cdb2a580-492f-11e5-82e9-40167e85b135}\"'
            UniqueId          = '\\?\Volume{cdb2a580-492f-11e5-82e9-40167e85b135}\'
            DriveLetter       = $script:DriveLetter
            FileSystem        = 'UDF'
            FileSystemLabel   = 'TEST_ISO'
            Path              = '\\?\Volume{cdb2a580-492f-11e5-82e9-40167e85b135}\'
            Size              = 10GB
        }

        $script:mockedGetTargetResourceISO = [pscustomobject] @{
            ImagePath   = $script:DiskImageISOPath
            DriveLetter = $script:DriveLetter
            StorageType = 'ISO'
            Access      = 'ReadOnly'
            Ensure      = 'Present'
        }

        $script:mockedGetTargetResourceNotMountedISO = [pscustomobject] @{
            ImagePath   = $script:DiskImageISOPath
            Ensure      = 'Absent'
        }

        $script:mockedCimInstanceISO = [pscustomobject] @{
            Caption                      = "$($script:DriveLetter):\"
            Name                         = "$($script:DriveLetter):\"
            DeviceID                     = '\\?\Volume{cdb2a580-492f-11e5-82e9-40167e85b135}\'
            Capacity                     = 10GB
            DriveLetter                  = "$($script:DriveLetter):"
            DriveType                    = 5
            FileSystem                   = 'UDF'
            FreeSpace                    = 0
            Label                        = 'TEST_ISO'
        }

        # VHDX Related Mocks
        $script:DiskImageVHDXPath = 'test.vhdx'

        $script:mockedDiskImageVHDX = [pscustomobject] @{
            Attached          = $false
            DevicePath        = $null
            FileSize          = 10GB
            ImagePath         = $script:DiskImageVHDXPath
            Number            = $null
            Size              = 10GB
            StorageType       = 3 ## VHDx
        }

        $script:mockedDiskImageAttachedVHDX = [pscustomobject] @{
            Attached          = $true
            DevicePath        = '\\.\PHYSICALDRIVE3'
            FileSize          = 10GB
            ImagePath         = $script:DiskImageVHDXPath
            Number            = 3
            Size              = 10GB
            StorageType       = 3 ## ISO
        }

        $script:mockedDiskVHDX = [pscustomobject] @{
            DiskNumber         = 3
            PartitionStyle     = 'GPT'
            ObjectId           = '{1}\\TEST\root/Microsoft/Windows/Storage/Providers_v2\WSP_Disk.ObjectId="{bba18018-e7a1-11e3-824e-806e6f6e6963}:DI:\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}"'
            AllocatedSize      = 10GB
            FriendlyName       = 'Msft Virtual Disk'
            IsReadOnly         = $False
            Location           = $script:DiskImageVHDXPath
            Number             = 3
            Path               = '\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}'
            Size               = 10GB
        }

        $script:mockedDiskVHDXReadOnly = [pscustomobject] @{
            DiskNumber         = 3
            PartitionStyle     = 'GPT'
            ObjectId           = '{1}\\TEST\root/Microsoft/Windows/Storage/Providers_v2\WSP_Disk.ObjectId="{bba18018-e7a1-11e3-824e-806e6f6e6963}:DI:\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}"'
            AllocatedSize      = 10GB
            FriendlyName       = 'Msft Virtual Disk'
            IsReadOnly         = $True
            Location           = $script:DiskImageVHDXPath
            Number             = 3
            Path               = '\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}'
            Size               = 10GB
        }

        $script:mockedPartitionVHDX = [pscustomobject] @{
            Type               = 'Basic'
            DiskPath           = '\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}'
            ObjectId           = '{1}\\TEST\root/Microsoft/Windows/Storage/Providers_v2\WSP_Partition.ObjectId="{bba18018-e7a1-11e3-824e-806e6f6e6963}:PR:{00000000-0000-0000-0000-901600000000}\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}"'
            UniqueId           = '{00000000-0000-0000-0000-901600000000}600224803F9B357CABEE50D4F858D17F'
            AccessPaths        = '{X:\, \\?\Volume{73496e75-5f0e-4d1d-9161-9931d7b1bb2f}\}'
            DiskId             = '\\?\scsi#disk&ven_msft&prod_virtual_disk#2&1f4adffe&0&000003#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}'
            DiskNumber         = 3
            DriveLetter        = $script:DriveLetter
            IsReadOnly         = $False
            PartitionNumber    = 2
            Size               = 10GB
        }

        $script:mockedVolumeVHDX = [pscustomobject] @{
            DriveType         = 'Fixed'
            FileSystemType    = 'NTFS'
            ObjectId          = '{1}\\TEST\root/Microsoft/Windows/Storage/Providers_v2\WSP_Volume.ObjectId="{bba18018-e7a1-11e3-824e-806e6f6e6963}:VO:\\?\Volume{73496e75-5f0e-4d1d-9161-9931d7b1bb2f}\"'
            UniqueId          = '\\?\Volume{73496e75-5f0e-4d1d-9161-9931d7b1bb2f}\'
            DriveLetter       = $script:DriveLetter
            FileSystem        = 'NTFS'
            FileSystemLabel   = 'TEST_VHDX'
            Path              = '\\?\Volume{73496e75-5f0e-4d1d-9161-9931d7b1bb2f}\'
            Size              = 10GB
        }

        $script:mockedGetTargetResourceVHDX = [pscustomobject] @{
            ImagePath   = $script:DiskImageVHDXPath
            DriveLetter = $script:DriveLetter
            StorageType = 'VHDX'
            Access      = 'ReadWrite'
            Ensure      = 'Present'
        }

        $script:mockedGetTargetResourceReadOnlyVHDX = [pscustomobject] @{
            ImagePath   = $script:DiskImageVHDXPath
            DriveLetter = $script:DriveLetter
            StorageType = 'VHDX'
            Access      = 'ReadOnly'
            Ensure      = 'Present'
        }

        $script:mockedGetTargetResourceNotMountedVHDX = [pscustomobject] @{
            ImagePath   = $script:DiskImageVHDXPath
            Ensure      = 'Absent'
        }

        $script:mockedCimInstanceVHDX = [pscustomobject] @{
            Caption                      = "$($script:DriveLetter):\"
            Name                         = "$($script:DriveLetter):\"
            DeviceID                     = '\\?\Volume{73496e75-5f0e-4d1d-9161-9931d7b1bb2f}\'
            Capacity                     = 10GB
            DriveLetter                  = "$($script:DriveLetter):"
            DriveType                    = 3
            FileSystem                   = 'NTFS'
            FreeSpace                    = 8GB
            Label                        = 'TEST_VHDX'
        }

        #endregion

        #region Function Get-TargetResource
        Describe 'MSFT_xMountImage\Get-TargetResource' {
            #region functions for mocking pipeline
            # These functions are required to be able to mock functions where
            # values are passed in via the pipeline.
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
            #endregion

            Context 'ISO is not mounted' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageISO } `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Get-Disk
                Mock -CommandName Get-Partition
                Mock -CommandName Get-Volume

                $resource = Get-TargetResource `
                    -ImagePath $script:DiskImageISOPath `
                    -Verbose

                It 'Should return expected values' {
                    $resource.ImagePath   | Should Be $script:DiskImageISOPath
                    $resource.Ensure      | Should Be 'Absent'
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 0
                    Assert-MockCalled -CommandName Get-Partition -Exactly 0
                    Assert-MockCalled -CommandName Get-Volume -Exactly 0
                }
            }

            Context 'ISO is mounted' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageAttachedISO } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeISO } `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Get-Disk
                Mock -CommandName Get-Partition

                $resource = Get-TargetResource `
                    -ImagePath $script:DiskImageISOPath `
                    -Verbose

                It 'Should return expected values' {
                    $resource.ImagePath   | Should Be $script:DiskImageISOPath
                    $resource.DriveLetter | Should Be $script:mockedVolumeISO.DriveLetter
                    $resource.StorageType | Should Be 'ISO'
                    $resource.Access      | Should Be 'ReadOnly'
                    $resource.Ensure      | Should Be 'Present'
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 0
                    Assert-MockCalled -CommandName Get-Partition -Exactly 0
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                }
            }

            Context 'VHDX is not mounted' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageVHDX } `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Get-Disk
                Mock -CommandName Get-Partition
                Mock -CommandName Get-Volume

                $resource = Get-TargetResource `
                    -ImagePath $script:DiskImageVHDXPath `
                    -Verbose

                It 'Should return expected values' {
                    $resource.ImagePath   | Should Be $script:DiskImageVHDXPath
                    $resource.Ensure      | Should Be 'Absent'
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 0
                    Assert-MockCalled -CommandName Get-Partition -Exactly 0
                    Assert-MockCalled -CommandName Get-Volume -Exactly 0
                }
            }

            Context 'VHDX is mounted as ReadWrite' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageAttachedVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDiskVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartitionVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeVHDX } `
                    -Verifiable

                $resource = Get-TargetResource `
                    -ImagePath $script:DiskImageVHDXPath `
                    -Verbose

                It 'Should return expected values' {
                    $resource.ImagePath   | Should Be $script:DiskImageVHDXPath
                    $resource.DriveLetter | Should Be $script:mockedVolumeVHDX.DriveLetter
                    $resource.StorageType | Should Be 'VHDX'
                    $resource.Access      | Should Be 'ReadWrite'
                    $resource.Ensure      | Should Be 'Present'
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 1
                    Assert-MockCalled -CommandName Get-Partition -Exactly 1
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                }
            }

            Context 'VHDX is mounted as ReadOnly' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageAttachedVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDiskVHDXReadOnly } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartitionVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeVHDX } `
                    -Verifiable

                $resource = Get-TargetResource `
                    -ImagePath $script:DiskImageVHDXPath `
                    -Verbose

                It 'Should return expected values' {
                    $resource.ImagePath   | Should Be $script:DiskImageVHDXPath
                    $resource.DriveLetter | Should Be $script:mockedVolumeVHDX.DriveLetter
                    $resource.StorageType | Should Be 'VHDX'
                    $resource.Access      | Should Be 'ReadOnly'
                    $resource.Ensure      | Should Be 'Present'
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 1
                    Assert-MockCalled -CommandName Get-Partition -Exactly 1
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'MSFT_xMountImage\Set-TargetResource' {
            Mock `
                -CommandName Test-ParameterValid `
                -MockWith { $true } `
                -Verifiable

            Context 'ISO is mounted as Drive Letter X and should be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceISO } `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Mount-DiskImageToLetter
                Mock -CommandName Dismount-DiskImage

                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -ImagePath $script:DiskImageISOPath `
                            -DriveLetter $script:DriveLetter `
                            -Ensure 'Present' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                    Assert-MockCalled -CommandName Mount-DiskImageToLetter -Exactly 0
                    Assert-MockCalled -CommandName Dismount-DiskImage -Exactly 0
                }
            }

            Context 'ISO is mounted as Drive Letter X but should be Y' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceISO } `
                    -Verifiable

                Mock `
                    -CommandName Mount-DiskImageToLetter `
                    -Verifiable

                Mock `
                    -CommandName Dismount-DiskImage `
                    -Verifiable

                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -ImagePath $script:DiskImageISOPath `
                            -DriveLetter 'Y' `
                            -Ensure 'Present' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                    Assert-MockCalled -CommandName Mount-DiskImageToLetter -Exactly 1
                    Assert-MockCalled -CommandName Dismount-DiskImage -Exactly 1
                }
            }

            Context 'ISO is not mounted but should be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceNotMountedISO } `
                    -Verifiable

                Mock `
                    -CommandName Mount-DiskImageToLetter `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Dismount-DiskImage

                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -ImagePath $script:DiskImageISOPath `
                            -DriveLetter $script:DriveLetter `
                            -Ensure 'Present' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                    Assert-MockCalled -CommandName Mount-DiskImageToLetter -Exactly 1
                    Assert-MockCalled -CommandName Dismount-DiskImage -Exactly 0
                }
            }

            Context 'ISO is mounted but should not be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceISO } `
                    -Verifiable

                Mock `
                    -CommandName Dismount-DiskImage `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Mount-DiskImageToLetter

                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -ImagePath $script:DiskImageISOPath `
                            -Ensure 'Absent' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                    Assert-MockCalled -CommandName Mount-DiskImageToLetter -Exactly 0
                    Assert-MockCalled -CommandName Dismount-DiskImage -Exactly 1
                }
            }

            Context 'ISO is not mounted and should not be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceNotMountedISO } `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Dismount-DiskImage
                Mock -CommandName Mount-DiskImageToLetter

                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -ImagePath $script:DiskImageISOPath `
                            -Ensure 'Absent' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                    Assert-MockCalled -CommandName Mount-DiskImageToLetter -Exactly 0
                    Assert-MockCalled -CommandName Dismount-DiskImage -Exactly 0
                }
            }

            Context 'VHDX is mounted as ReadOnly but should be ReadWrite' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceReadOnlyVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Mount-DiskImageToLetter `
                    -Verifiable

                Mock `
                    -CommandName Dismount-DiskImage `
                    -Verifiable

                It 'Should not throw exception' {
                    {
                        Set-TargetResource `
                            -ImagePath $script:DiskImageVHDXPath `
                            -DriveLetter $script:DriveLetter `
                            -Access 'ReadWrite' `
                            -Ensure 'Present' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                    Assert-MockCalled -CommandName Mount-DiskImageToLetter -Exactly 1
                    Assert-MockCalled -CommandName Dismount-DiskImage -Exactly 1
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'MSFT_xMountImage\Test-TargetResource' {
            Mock `
                -CommandName Test-ParameterValid `
                -MockWith { $true } `
                -Verifiable

            Context 'ISO is mounted as Drive Letter X and should be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceISO } `
                    -Verifiable

                It 'Should return true' {
                    Test-TargetResource `
                        -ImagePath $script:DiskImageISOPath `
                        -DriveLetter $script:DriveLetter `
                        -Ensure 'Present' `
                        -Verbose | Should Be $True
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                }
            }

            Context 'ISO is mounted as Drive Letter X but should be Y' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceISO } `
                    -Verifiable

                It 'Should return false' {
                    Test-TargetResource `
                        -ImagePath $script:DiskImageISOPath `
                        -DriveLetter 'Y' `
                        -Ensure 'Present' `
                        -Verbose | Should Be $False
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                }
            }

            Context 'ISO is not mounted but should be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceNotMountedISO } `
                    -Verifiable

                It 'Should return false' {
                    Test-TargetResource `
                        -ImagePath $script:DiskImageISOPath `
                        -DriveLetter $script:DriveLetter `
                        -Ensure 'Present' `
                        -Verbose | Should Be $False
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                }
            }

            Context 'ISO is mounted but should not be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceISO } `
                    -Verifiable

                It 'Should return false' {
                    Test-TargetResource `
                        -ImagePath $script:DiskImageISOPath `
                        -Ensure 'Absent' `
                        -Verbose | Should Be $False
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                }
            }

            Context 'ISO is not mounted and should not be' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceNotMountedISO } `
                    -Verifiable

                It 'Should return true' {
                    Test-TargetResource `
                        -ImagePath $script:DiskImageISOPath `
                        -Ensure 'Absent' `
                        -Verbose | Should Be $True
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                }
            }

            Context 'VHDX is mounted as ReadOnly but should be ReadWrite' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Get-TargetResource `
                    -MockWith { $script:mockedGetTargetResourceReadOnlyVHDX } `
                    -Verifiable

                It 'Should return false' {
                    Test-TargetResource `
                        -ImagePath $script:DiskImageVHDXPath `
                        -DriveLetter $script:DriveLetter `
                        -Access 'ReadWrite' `
                        -Ensure 'Present' `
                        -Verbose | Should Be $False
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Test-ParameterValid -Exactly 1
                    Assert-MockCalled -CommandName Get-TargetResource -Exactly 1
                }
            }
        }
        #endregion

        #region Function Test-ParameterValid
        Describe 'MSFT_xMountImage\Test-ParameterValid' {
            Context 'DriveLetter passed, ensure is Absent' {
                It 'Should throw InvalidParameterSpecifiedError exception' {
                    $errorRecord = Get-InvalidOperationRecord `
                        -Message ($LocalizedData.InvalidParameterSpecifiedError -f `
                            'Absent','DriveLetter')

                    {
                        Test-ParameterValid `
                            -ImagePath $script:DiskImageISOPath `
                            -DriveLetter $script:DriveLetter `
                            -Ensure 'Absent' `
                            -Verbose
                    } | Should Throw $errorRecord
                }
            }

            Context 'StorageType passed, ensure is Absent' {
                It 'Should throw InvalidParameterSpecifiedError exception' {
                    $errorRecord = Get-InvalidOperationRecord `
                        -Message ($LocalizedData.InvalidParameterSpecifiedError -f `
                            'Absent','StorageType')

                    {
                        Test-ParameterValid `
                            -ImagePath $script:DiskImageISOPath `
                            -StorageType 'VHD' `
                            -Ensure 'Absent' `
                            -Verbose
                    } | Should Throw $errorRecord
                }
            }

            Context 'Access passed, ensure is Absent' {
                It 'Should throw InvalidParameterSpecifiedError exception' {
                    $errorRecord = Get-InvalidOperationRecord `
                        -Message ($LocalizedData.InvalidParameterSpecifiedError -f `
                            'Absent','Access')

                    {
                        Test-ParameterValid `
                            -ImagePath $script:DiskImageISOPath `
                            -Access 'ReadOnly' `
                            -Ensure 'Absent' `
                            -Verbose
                    } | Should Throw $errorRecord
                }
            }

            Context 'Ensure is Absent, nothing else passed' {
                It 'Should not throw exception' {
                    {
                        Test-ParameterValid `
                            -ImagePath $script:DiskImageISOPath `
                            -Ensure 'Absent' `
                            -Verbose
                    } | Should Not Throw
                }
            }

            Context 'ImagePath passed but not found, ensure is Present' {
                It 'Should throw InvalidParameterSpecifiedError exception' {
                    Mock `
                        -CommandName Test-Path `
                        -MockWith { $false }

                    $errorRecord = Get-InvalidOperationRecord `
                        -Message ($LocalizedData.DiskImageFileNotFoundError -f `
                            $script:DiskImageISOPath)

                    {
                        Test-ParameterValid `
                            -ImagePath $script:DiskImageISOPath `
                            -Ensure 'Present' `
                            -Verbose
                    } | Should Throw $errorRecord
                }
            }

            Context 'ImagePath passed and found, ensure is Present, DriveLetter missing' {
                It 'Should throw InvalidParameterSpecifiedError exception' {
                    Mock `
                        -CommandName Test-Path `
                        -MockWith { $true }

                    $errorRecord = Get-InvalidOperationRecord `
                        -Message ($LocalizedData.InvalidParameterNotSpecifiedError -f `
                            'Present','DriveLetter')

                    {
                        Test-ParameterValid `
                            -ImagePath $script:DiskImageISOPath `
                            -Ensure 'Present' `
                            -Verbose
                    } | Should Throw $errorRecord
                }
            }

            Context 'ImagePath passed and found, ensure is Present, DriveLetter set' {
                It 'Should not throw exception' {
                    Mock `
                        -CommandName Test-Path `
                        -MockWith { $true }
                    {
                        Test-ParameterValid `
                            -ImagePath $script:DiskImageISOPath `
                            -DriveLetter $script:DriveLetter `
                            -Ensure 'Present' `
                            -Verbose
                    } | Should Not Throw
                }
            }

        }
        #endregion

        #region Function Mount-DiskImageToLetter
        Describe 'MSFT_xMountImage\Mount-DiskImageToLetter' {
            #region functions for mocking pipeline
            # These functions are required to be able to mock functions where
            # values are passed in via the pipeline.
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

            function Set-CimInstance {
                Param
                (
                    [CmdletBinding()]
                    [Parameter(ValueFromPipeline)]
                    $InputObject,

                    $Property
                )
            }
            #endregion

            Context 'ISO is specified and gets mounted to correct Drive Letter' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Mount-DiskImage `
                    -Verifiable

                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageISO } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeISO } `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Get-Disk
                Mock -CommandName Get-Partition
                Mock -CommandName Get-CimInstance
                Mock -CommandName Set-CimInstance

                It 'Should not throw exception' {
                    {
                        Mount-DiskImageToLetter `
                            -ImagePath $script:DiskImageISOPath `
                            -DriveLetter $script:DriveLetter `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Mount-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 0
                    Assert-MockCalled -CommandName Get-Partition -Exactly 0
                    Assert-MockCalled -CommandName Get-CimInstance -Exactly 0
                    Assert-MockCalled -CommandName Set-CimInstance -Exactly 0
                }
            }

            Context 'ISO is specified and gets mounted to the wrong Drive Letter' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Mount-DiskImage `
                    -Verifiable

                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageISO } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeISO } `
                    -Verifiable

                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedCimInstanceISO } `
                    -Verifiable

                Mock `
                    -CommandName Set-CimInstance `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Get-Disk
                Mock -CommandName Get-Partition

                It 'Should not throw exception' {
                    {
                        Mount-DiskImageToLetter `
                            -ImagePath $script:DiskImageISOPath `
                            -DriveLetter 'Y' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Mount-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 0
                    Assert-MockCalled -CommandName Get-Partition -Exactly 0
                    Assert-MockCalled -CommandName Get-CimInstance -Exactly 1
                    Assert-MockCalled -CommandName Set-CimInstance -Exactly 1
                }
            }

            Context 'VHDX is specified and gets mounted to correct Drive Letter' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Mount-DiskImage `
                    -Verifiable

                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDiskVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartitionVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeVHDX } `
                    -Verifiable

                # Mocks that should not be called
                Mock -CommandName Get-CimInstance
                Mock -CommandName Set-CimInstance

                It 'Should not throw exception' {
                    {
                        Mount-DiskImageToLetter `
                            -ImagePath $script:DiskImageVHDxPath `
                            -DriveLetter $script:DriveLetter `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Mount-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 1
                    Assert-MockCalled -CommandName Get-Partition -Exactly 1
                    Assert-MockCalled -CommandName Get-CimInstance -Exactly 0
                    Assert-MockCalled -CommandName Set-CimInstance -Exactly 0
                }
            }

            Context 'ISO is specified and gets mounted to the wrong Drive Letter' {
                # Verifiable (should be called) mocks
                Mock `
                    -CommandName Mount-DiskImage `
                    -Verifiable

                Mock `
                    -CommandName Get-DiskImage `
                    -MockWith { $script:mockedDiskImageVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Disk `
                    -MockWith { $script:mockedDiskVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Partition `
                    -MockWith { $script:mockedPartitionVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-Volume `
                    -MockWith { $script:mockedVolumeVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Get-CimInstance `
                    -MockWith { $script:mockedCimInstanceVHDX } `
                    -Verifiable

                Mock `
                    -CommandName Set-CimInstance `
                    -Verifiable

                It 'Should not throw exception' {
                    {
                        Mount-DiskImageToLetter `
                            -ImagePath $script:DiskImageVHDXPath `
                            -DriveLetter 'Y' `
                            -Verbose
                    } | Should Not Throw
                }

                It 'all the get mocks should be called' {
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Mount-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-DiskImage -Exactly 1
                    Assert-MockCalled -CommandName Get-Volume -Exactly 1
                    Assert-MockCalled -CommandName Get-Disk -Exactly 1
                    Assert-MockCalled -CommandName Get-Partition -Exactly 1
                    Assert-MockCalled -CommandName Get-CimInstance -Exactly 1
                    Assert-MockCalled -CommandName Set-CimInstance -Exactly 1
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
