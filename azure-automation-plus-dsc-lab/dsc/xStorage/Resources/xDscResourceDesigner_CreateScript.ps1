$modules = 'C:\Program Files\WindowsPowerShell\Modules\'
$modulename = 'xDiskImage'
$Description = 'This module is used to mount ISO or VHD files as local disks.'

if (!(test-path (join-path $modules $modulename))) {

    $modulefolder = mkdir (join-path $modules $modulename)
    New-ModuleManifest -Path (join-path $modulefolder "$modulename.psd1") -Guid $([system.guid]::newguid().guid) -Author 'PowerShell DSC' -CompanyName 'Microsoft Corporation' -Copyright '2015' -ModuleVersion '0.1.0.0' -Description $Description -PowerShellVersion '4.0'

    $standard = @{ModuleName = $modulename
                ClassVersion = '0.1.0.0'
                Path = $modules
                }
    $P = @()
    $P += New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description 'This setting provides a unique name for the configuration'
    $P += New-xDscResourceProperty -Name ImagePath -Type String -Attribute Required -Description 'Specifies the path of the VHD or ISO file'
    $P += New-xDscResourceProperty -Name DriveLetter -Type String -Attribute Write -Description 'Specifies the drive letter after the ISO is mounted'
    $P += New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet 'Present','Absent' -Description 'Determines whether the setting should be applied or removed'
    New-xDscResource -Name MSFT_xMountImage -Property $P -FriendlyName xMountImage @standard
}