$TestWaitForVolume = @{
    DriveLetter      = 'C'
    RetryIntervalSec = 1
    RetryCount       = 2
}

configuration MSFT_xWaitForVolume_Config {
    Import-DscResource -ModuleName xStorage
    node localhost {
        xWaitForVolume Integration_Test {
            DriveLetter      = $TestWaitForVolume.DriveLetter
            RetryIntervalSec = $TestWaitForVolume.RetryIntervalSec
            RetryCount       = $TestWaitForVolume.RetryCount
        }
    }
}
