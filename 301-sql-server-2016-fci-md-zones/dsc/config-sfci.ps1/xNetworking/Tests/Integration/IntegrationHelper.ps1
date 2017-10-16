function New-IntegrationLoopbackAdapter
{
    [cmdletbinding()]
    param (
        [String]
        $AdapterName
    )
    # Configure Loopback Adapter
    if ($env:APPVEYOR) {
        # Running in AppVeyor so force silent install of LoopbackAdapter
        $Splat = @{ Force = $true }
    }
    else
    {
        $Splat = @{ Force = $false }
    } # if

    $LoopbackAdapterModuleName = 'LoopbackAdapter'
    $LoopbackAdapterModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$LoopbackAdapterModuleName"
    $LoopbackAdapterModule = Install-ModuleFromPowerShellGallery `
        -ModuleName $LoopbackAdapterModuleName `
        -ModulePath $LoopbackAdapterModulePath `
        @Splat

    if ($LoopbackAdapterModule) {
        # Import the module if it is available
        $LoopbackAdapterModule | Import-Module -Force
    }
    else
    {
        # Module could not/would not be installed - so warn user that tests will fail.
        Throw 'LoopbackAdapter Module could not be installed.'
    } # if

    try
    {
        # Does the loopback adapter already exist?
        $null = Get-LoopbackAdapter `
            -Name $AdapterName
    }
    catch
    {
        # The loopback Adapter does not exist so create it
        $null = New-LoopbackAdapter `
            -Name $AdapterName `
            -ErrorAction Stop `
            @Splat
    } # try
} # function New-IntegrationLoopbackAdapter

function Remove-IntegrationLoopbackAdapter
{
    [cmdletbinding()]
    param (
        [String]
        $AdapterName
    )
    if ($env:APPVEYOR) {
        # Running in AppVeyor so force silent install of LoopbackAdapter
        $Splat = @{ Force = $true }
    }
    else
    {
        $Splat = @{ Force = $false }
    }

    try
    {
        # Does the loopback adapter exist?
        $null = Get-LoopbackAdapter `
            -Name $AdapterName
    }
    catch
    {
        # Loopback Adapter does not exist - do nothing
        return
    }

    # Remove Loopback Adapter
    Remove-LoopbackAdapter `
        -Name $AdapterName `
        @Splat

} # function Remove-IntegrationLoopbackAdapter
