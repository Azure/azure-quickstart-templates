function Find-VarsFromWriteHostOutput {
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]
        $InputObject
    ) 
    $vars = New-Object -type "Hashtable"

    $InputObject | ForEach-Object {
        if ($_ -match "##vso\[task.setvariable variable=([a-zA-Z.]+)\](.+)") {
            $var = $Matches[1]
            $value = $Matches[2]

            # Convert variable name from xxx.yyy.zzz to XXX_YYY_ZZZ
            $var = $var.ToUpperInvariant().Replace(".", "_")
            $vars[$var] = $value
            Write-Host "$var = '$value'"
        }
    }

    return $vars
}
