
$a = @(
"Standard_D2_v3", "Standard_D1",
"Standard_D2_v3", "Standard_D1_v2",
"Standard_D2s_v3", "Standard_DC1s_v2",
"Standard_D2s_v3", "Standard_DS1",
"Standard_D2s_v3", "Standard_DS1_v2",
"Standard_D4_v3", "Standard_D11",
"Standard_D4_v3", "Standard_D11_v2",
"Standard_D4_v3", "Standard_D11_v2_Promo",
"Standard_D2_v3", "Standard_D2",
"Standard_D2_v3", "Standard_D2_v2",
"Standard_D2_v3", "Standard_D2_v2_Promo",
"Standard_D2s_v3", "Standard_DC2s_v2",
"Standard_D4s_v3", "Standard_DS11",
"Standard_D4s_v3", "Standard_DS11_v2",
"Standard_D4s_v3", "Standard_DS11_v2_Promo",
"Standard_D4s_v3", "Standard_DS11-1_v2",
"Standard_D2s_v3", "Standard_DS2",
"Standard_D2s_v3", "Standard_DS2_v2",
"Standard_D2s_v3", "Standard_DS2_v2_Promo",
"Standard_D4_v3", "Standard_D12",
"Standard_D4_v3", "Standard_D12_v2",
"Standard_D4_v3", "Standard_D12_v2_Promo",
"Standard_D4_v3", "Standard_D3",
"Standard_D4_v3", "Standard_D3_v2",
"Standard_D4_v3", "Standard_D3_v2_Promo",
"Standard_D4_v3", "Standard_DC4s_v2",
"Standard_D4s_v3", "Standard_DS12",
"Standard_D4s_v3", "Standard_DS12_v2",
"Standard_D4s_v3", "Standard_DS12_v2_Promo",
"Standard_D4s_v3", "Standard_DS12-1_v2",
"Standard_D4s_v3", "Standard_DS12-2_v2",
"Standard_D4s_v3", "Standard_DS3",
"Standard_D4s_v3", "Standard_DS3_v2",
"Standard_D4s_v3", "Standard_DS3_v2_Promo",
"Standard_D8_v3", "Standard_D13",
"Standard_D8_v3", "Standard_D13_v2",
"Standard_D8_v3", "Standard_D13_v2_Promo",
"Standard_D8_v3", "Standard_D4",
"Standard_D8_v3", "Standard_D4_v2",
"Standard_D8_v3", "Standard_D4_v2_Promo",
"Standard_D8_v3", "Standard_DC8_v2",
"Standard_D8s_v3", "Standard_DS13",
"Standard_D8s_v3", "Standard_DS13_v2",
"Standard_D8s_v3", "Standard_DS13_v2_Promo",
"Standard_D8s_v3", "Standard_DS13-2_v2",
"Standard_D8s_v3", "Standard_DS13-4_v2",
"Standard_D8s_v3", "Standard_DS4",
"Standard_D8s_v3", "Standard_DS4_v2",
"Standard_D8s_v3", "Standard_DS4_v2_Promo",
"Standard_D16_v3", "Standard_D14",
"Standard_D16_v3", "Standard_D14_v2",
"Standard_D16_v3", "Standard_D14_v2_Promo",
"Standard_D16_v3", "Standard_D5_v2",
"Standard_D16_v3", "Standard_D5_v2_Promo",
"Standard_D16s_v3", "Standard_DS14",
"Standard_D16s_v3", "Standard_DS14_v2",
"Standard_D16s_v3", "Standard_DS14_v2_Promo",
"Standard_D16s_v3", "Standard_DS14-4_v2",
"Standard_D16s_v3", "Standard_DS14-8_v2",
"Standard_D16s_v3", "Standard_DS5_v2",
"Standard_D16s_v3", "Standard_DS5_v2_Promo",
"Standard_D32_v3", "Standard_D15_v2",
"Standard_D32s_v3", "Standard_DS15_v2"
)

# build a hashtable of the map

$i = 0
$map = @()
do {
    $mapItem = @{
        old = $a[$i+1]
        new = $a[$i]
    }
    $map = $map + $mapItem

    $i = $i + 2
} until ($i -ge $a.Length)

# find all of the json files 

$jsonFiles = Get-ChildItem -Path "*.json" -Recurse

foreach($f in $jsonFiles){
    #Write-host $f.FullName
    $json = Get-Content $f.FullName -Raw
    
    # Check to see if it's a template or param file
    if($json -like '*deploymentTemplate.json#"*' -or $json -like '*deploymentParameters.json#"*'){
        #Write-Host "Searching... $($f.name)"
        $IsFileChanged = $false
        foreach($size in $map){
            if($json -like "*`"$($size.old)`"*"){
                $IsFileChanged = $true
                Write-Host "found `"$($size.old)`" in $($f.fullname)"
                $json = $json -ireplace "`"$($size.old)`"", "`"$($size.new)`""
            }
        }
        If($IsFileChanged){
            $json | Set-Content -Path $f.FullName
        }
    }
}