$TestWaitForDisk = @{
    DiskNumber       = 0
    RetryIntervalSec = 1
    RetryCount       = 2
}

configuration MSFT_xWaitForDisk_Config {
    Import-DscResource -ModuleName xStorage
    node localhost {
        xWaitForDisk Integration_Test {
            DiskNumber       = $TestWaitForDisk.DiskNumber
            RetryIntervalSec = $TestWaitForDisk.RetryIntervalSec
            RetryCount       = $TestWaitForDisk.RetryCount
        }
    }
}
