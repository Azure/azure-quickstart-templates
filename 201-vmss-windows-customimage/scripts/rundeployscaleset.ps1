
$scalsetDNS='s'+[System.Guid]::NewGuid().toString()
$newstorageaccountname=[System.Guid]::NewGuid().toString().Replace('-','').Substring(1,24)
$newstorageaccountname='a15041784164756b556cc494'
.\deployscaleset.ps1 -location northeurope -resourceGroupName ssrg1 -repoUri https://raw.githubusercontent.com/simongdavies/azure-quickstart-templates/master/201-vmss-windows-customimage/ -scaleSetName windowscustom -newStorageAccountName $newstorageaccountname -scaleSetVMSize Standard_D1 -scaleSetDNSPrefix $scalsetDNS