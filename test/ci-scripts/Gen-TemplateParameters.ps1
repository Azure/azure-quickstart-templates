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
    $config = (Invoke-WebRequest "$configUri").Content | ConvertFrom-Json  -Depth 30
}
else {
    #Local File
    $config = Get-Content -Path "$configUri" -Raw | ConvertFrom-Json  -Depth 30
}

#Write-Host ($config | Out-String)

if ($prereqOutputsFileName) { #Test-Path doesn't work on an empty string
    if (Test-Path $prereqOutputsFileName) {
        #prereqs have to come from a file due to the complexity of getting JSON into a pipeline var
        $PreReqConfig = Get-Content -Path $prereqOutputsFileName -Raw | ConvertFrom-Json -Depth 30
        Write-Output ($PreReqConfig | Out-String)
    }
}

# if a different param file value has been passed (e.g. for Fairfax) look for that file, if it's not found, revert to the default
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))
Write-Output "Searching for parameter file: $TemplateParametersFile"

if (!(Test-Path $TemplateParametersFile)) {
    # if the requested file has \prereqs\ in the path the default filename is different
    if($TemplateParametersFile -like "*\prereqs\*"){
        $defaultParamFile = "\prereq.azuredeploy.parameters.json"
    }else{
        $defaultParamFile = "\azuredeploy.parameters.json"
    }
    $TemplateParametersFile = (Split-Path $TemplateParametersFile) + $defaultParamFile
    Write-Output "Param file not found, using: $TemplateParametersFile"
}

$txt = Get-Content $TemplateParametersFile -Raw

# We do a text replace rather than try to recurse over an object of different types and then try to write that object back out

# Look for each GEN token with in the param file, and replace the string token with json text
foreach($c in $config.psobject.properties){
    $token = "`"GEN-$($c.name)`""
    $txt = $txt.Replace($token, $($c.value | ConvertTo-Json -Depth 30))
}

# Do the same for prereqs
foreach($p in $PreReqConfig.psobject.properties){
    $token = "`"GET-PREREQ-$($p.name)`""
    $txt = $txt.Replace($token, $($p.value.value | ConvertTo-Json -Depth 30))
}

# Now handle the generated values, replace only the first instance since generated values are unique for each occurence

While($txt.Contains("`"GEN-GUID`"")){
    $v = New-Guid
    [regex]$r = "GEN-GUID"
    $txt = $r.Replace($txt, $v, 1)
}

While($txt.Contains("`"GEN-PASSWORD`"")){
    $v = "cI#" + (New-Guid).ToString().Replace("-", "").Substring(0, 17)
    [regex]$r = "`"GEN-PASSWORD`""
    $txt = $r.Replace($txt, "`"$v`"", 1)
}

While($txt.Contains("`"GEN-PASSWORD-AMP`"")){
    $v = "cI&" + (New-Guid).ToString().Replace("-", "").Substring(0, 17)
    [regex]$r = "`"GEN-PASSWORD-AMP`""
    $txt = $r.Replace($txt, "`"$v`"", 1)
}

While($txt.Contains("`"GEN-UNIQUE`"")){
    $v = "ci" + (New-Guid).ToString().Replace("-", "").ToString().Substring(0, 16)
    [regex]$r = "`"GEN-UNIQUE`""
    $txt = $r.Replace($txt, "`"$v`"", 1) # replace and restore quotes so as not to remove the GEN-UNIQUE-* values
}

While($txt.Contains("`"GEN-UNIQUE-")){
    $numStart = $txt.IndexOf("`"GEN-UNIQUE-") + 12
    $numEnd = $txt.IndexOf("`"", $numStart)
    $l = $txt.Substring($numStart, $numEnd-$numStart)
    $i = [int]::parse($l) - 2 # subtract 2 since 'ci' is prepended
    if($i -gt 24){ $i = 24 } elseif($i -lt 1){ $i = 1}
    Write-Output "length = $i"
    $v = "ci" + (New-Guid).ToString().Replace("-", "").ToString().Substring(0,  $i)
    [regex]$r = "GEN-UNIQUE-$l"
    $txt = $r.Replace($txt, $v, 1)
}

Write-Output $txt

Write-Output "Writing file: $NewTemplateParametersFile"
$txt | Out-File -FilePath $NewTemplateParametersFile
