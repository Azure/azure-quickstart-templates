configuration MSFT_xMountImage_Dismount_Config {

    Import-DscResource -ModuleName xStorage

    node localhost {
        xMountImage Integration_Test {
            ImagePath          = $Node.ImagePath
            Ensure             = 'Absent'
        }
    }
}
