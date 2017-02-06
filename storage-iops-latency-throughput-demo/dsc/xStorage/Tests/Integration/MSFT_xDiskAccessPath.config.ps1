configuration MSFT_xDiskAccessPath_Config {

    Import-DscResource -ModuleName xStorage

    node localhost {
        xDiskAccessPath Integration_Test {
            DiskNumber         = $Node.DiskNumber
            AccessPath         = $Node.AccessPath
            FSLabel            = $Node.FSLabel
        }
    }
}
