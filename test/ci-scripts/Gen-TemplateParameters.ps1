<#
This script will process the parameter files than contain GEN values and GET-PREREQ values.
The configuration for GEN values can come from a location config.json file or a url.
The GET-PREREQ values come from a parameter file written by the prereq step in the deployment and written to the location specified by the prereqOutputsFileName param
#>

param(
    [string][Parameter(mandatory = $true)] $configUri,
    [string] $prereqOutputsFileName,
    [string] $TemplateParametersFile = '.\azuredeploy.parameters.json',
    [string] $NewTemplateParametersFile = '.\azuredeploy.parameters.new.json'
)

if ($configUri.StartsWith('http')) {
    #url
    $config = (Invoke-WebRequest "$configUri").Content | ConvertFrom-Json
}
else {
    #Local File
    $config = Get-Content -Path "$configUri" -Raw | ConvertFrom-Json
}

#Write-Host ($config | Out-String)

if ($prereqOutputsFileName) { #Test-Path doesn't work on an empty string
    if (Test-Path $prereqOutputsFileName) {
        #prereqs have to come from a file due to the complexity of getting JSON into a pipeline var
        $PreReqConfig = Get-Content -Path $prereqOutputsFileName -Raw | ConvertFrom-Json
        Write-Host ($PreReqConfig | Out-String)
    }
}

# if a different param file value has been passed (e.g. for Fairfax) look for that file, if it's not found, revert to the default
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))
Write-Host "Searching for parameter file: $TemplateParametersFile"

if (!(Test-Path $TemplateParametersFile)) {
    # if the requested file has \prereqs\ in the path the default filename is different
    if($TemplateParametersFile -like "*\prereqs\*"){
        $defaultParamFile = "\prereq.azuredeploy.parameters.json"
    }else{
        $defaultParamFile = "\azuredeploy.parameters.json"
    }
    $TemplateParametersFile = (Split-Path $TemplateParametersFile) + $defaultParamFile
    Write-Host "Param file not found, using: $TemplateParametersFile"
}

$JsonParameters = Get-Content $TemplateParametersFile -Raw | ConvertFrom-Json
if (($JsonParameters | Get-Member -Type NoteProperty 'parameters') -ne $null) {
    $JsonParameters = $JsonParameters.parameters
}

#Write-Host $JsonParameters

foreach ($p in $JsonParameters.psObject.Properties) {
    if ($p.value.value -like "GEN-*") {
        #Write-Host $p.Value.value
        $token = $p.Value.value.Replace("GEN-", "")
        switch -Wildcard ($token) {
            "UNIQUE*" {
                $num = $token.split("-")
                if ($num.length -eq 2) {
                    $l = $num[1] - 2
                    if ($l -le 0) { $l = 2 }
                }
                else {
                    $l = 16
                }
                $v = "ci" + (New-Guid).ToString().Replace("-", "").ToString().Substring(0, $l)
            }
            "GUID" {
                $v = New-Guid
            }
            "PASSWORD" {
                $v = "cI#" + (New-Guid).ToString().Replace("-", "").Substring(0, 17)
            }
            "PASSWORD-AMP" {
                $v = "cI&" + (New-Guid).ToString().Replace("-", "").Substring(0, 17) # some passwords don't like # so providing an option
            }
            default {
                $v = $config.$token
            }
        }
        
        if($v -eq $null){
            Write-Error "Could not find `"$($p.value.value)`" token in .config.json"
        }
        $JsonParameters.$($p.name).value = $v

    }
    elseif ($p.value.value -like "GET-PREREQ*") {
        
        #get deployment outputs
        $token = $p.Value.value.Replace("GET-PREREQ-", "")
        #Write-Host "Token: $token"
        $v = $PreReqConfig.$token.value
        if($v -eq $null){
            Write-Error "Could not find `"$($p.value.value)`" token in prereq outputs"
        }
        $JsonParameters.$($p.name).value = $v

    }
    # is this a reference parameter
    elseif ($p.value.reference -like "GEN-*"){
        $token = $p.value.reference.Replace("GEN-", "")
        $v = $config.$token
        if($v -eq $null){
            Write-Error "Could not find reference parameter `"$($p.value.reference)`" token in .config.json"
        }
        $JsonParameters.$($p.name) = $v
    }
}

Write-Host "Writing file: $NewTemplateParametersFile"
$JsonParameters | ConvertTo-Json -Depth 30 | Out-File -FilePath $NewTemplateParametersFile
