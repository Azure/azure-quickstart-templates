workflow myrunbook{
 param(

        [Parameter(Mandatory=$true)]
        [string] 
        $MediaServices_Name,

        [Parameter(Mandatory=$true)]
        [string] 
        $MediaServices_Keys,

        [Parameter(Mandatory=$true)]
        [string] 
        $Input_StorageAccounts_Name,
    
        [Parameter(Mandatory=$true)]
        [string] 
        $Input_StorageAccounts_Keys,

        [Parameter(Mandatory=$true)]
        [string] 
        $Ouput_StorageAccounts_Name,

        [Parameter(Mandatory=$true)]
        [string] 
        $Output_StorageAccounts_Keys,
    
        [Parameter(Mandatory=$true)]
        [string] 
        $MediaService_StorageAccounts_Name,

        [Parameter(Mandatory=$true)]
        [string] 
        $MediaService_StorageAccounts_Keys

        
    ) 
        <#$MediaServices_Name = "mediag5xazoq27rv36"
        $MediaServices_Keys = "8DJCaLikWortVYQUkPTdo84aT0bkxJdon3e6ukWrcCY="
        $Input_StorageAccounts_Name = "inputg5xazoq27rv36"
        $Input_StorageAccounts_Keys = "Nxq9CDg5fvMnpYE180/fIrhRazVNn7zHlRjbeqRDf0FaHPgwt/6dvf7ZMEv17tu1fBYX43hf0XBaj15RrZW6Hw=="
        $Ouput_StorageAccounts_Name = "outputg5xazoq27rv36"
        $Output_StorageAccounts_Keys = "yJFJN+jes2yrfIpwl8sqo2Xjj97ep9BA11ffcuARe1iMbg0fXT38uTvSOHH7/ykuWziP61skr4NZ90lWcrLuIA=="
        $MediaService_StorageAccounts_Name = "mediabg5xazoq27rv36"
        $MediaService_StorageAccounts_Keys = "NBwzPQb3UAw23FT4aVzHKn2ywYetjQDkYSg2ekgZwx57T4wcJAQh/EkOD63rUQynW4eu1FgZTRiq2w8Ok3/mzA=="#>
        Write-Output $Output_StorageAccounts_Keys
        $MediaServicesApiUrl_SetConfig = "http://mediaservicesapi.azurewebsites.net/api/setconfig"
        $MediaServicesApiUrl_TestConfig = "http://mediaservicesapi.azurewebsites.net/api/testconfig?key="
        $MediaServicesApiUrl_StartJob = "http://mediaservicesapi.azurewebsites.net/api/startjob?Key="

         $headers = @{
            "Content-Type"="application/json"
            "Accept"="application/json"
        } 
                $body = '{'+

                            '"mediaServiceAccountName":' + '"' + $MediaServices_Name + '",'+
                            ' "mediaServicesAccountKey":' + '"' + $MediaServices_Keys + '",'+
                            ' "mediaServicesStorageAccountName":' + '"' + $MediaService_StorageAccounts_Name + '",'+
                            ' "mediaServicesStorageAccountKey":' + '"' + $MediaService_StorageAccounts_Keys + '",'+
                            ' "inputStorageAccountName":' + '"' + $Input_StorageAccounts_Name + '",'+
                            ' "inputStorageAccountKey":' + '"' + $Input_StorageAccounts_Keys + '",'+
                            ' "outputStorageAccountName":' + '"' + $Ouput_StorageAccounts_Name + '",'+
                            ' "outputStorageAccountKey":' + '"' + $Output_StorageAccounts_Keys + '"'+
                               
                       '}'
           # $body = '{"mediaServiceAccountName":"vmediaservicestesting", "mediaServicesAccountKey":"lS5S+O5ocouiXDirGttVV7TTzpaIl0VdNXLnKKGcSj4=", "mediaServicesStorageAccountName":"vmediaservicesstorage", "mediaServicesStorageAccountKey":"ixP3K4Bqt85c/8C5BcINETKHyI67GFp9l1zm3Zdo3NgRIXuNTG6ikkz3S3g6UsycCkyw4z7xm/qXUVMOpeKDvw==", "inputStorageAccountName":"vams1", "inputStorageAccountKey":"AYkjT2P/Kj+NQbfqz1lqZiDj2qs5Jvq9FlhzCztSs9ELU5DXt0P7B2QS0xW57TnkHG27BBDBuNAd8OJW8vMSQg==", "outputStorageAccountName":"vams2output", "outputStorageAccountKey":"pKG92mOKJYQoAZS+AJ46BzPdyuO2juj/FSmHgxI2txssCxwtAxzWUxxBEAPyDt8aIKhTWT+U8hf7gkrr+NG6vA=="}'

        Write-Output $body

        $response1 = Invoke-RestMethod -Uri $MediaServicesApiUrl_SetConfig -Method Post -Body $body -ContentType 'application/json'
        Write-Output $response1

        $tokenkey1="http://mediaservicesapi.azurewebsites.net/api/testconfig?key=$response1"
        Write-Output $tokenkey1

        $response2 = Invoke-RestMethod -Method Get -Uri $tokenkey1 -ContentType 'application/json'
        $token2 = $response2 | ConvertTo-Json
        Write-Output $response2

        $tokenkey2="http://mediaservicesapi.azurewebsites.net/api/startjob?key=$response1"
        Write-Output $tokenkey2
                      
        $response3 = Invoke-RestMethod -Method Get -Uri $tokenkey2 
       
        Write-Output $response3
}
