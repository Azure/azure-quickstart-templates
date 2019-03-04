param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)
foreach ($parameter in $templateObject.parameters) {
    $Min = $null
    $Max = $null
    if ($parameter.psobject.properties.item('MaxValue')) {
        if ($parameter.maxValue -isnot [int]) {
            Write-Error "$($Parameter.Name) maxValue is not an [int] (it's a [$($parameter.maxValue.GetType())])" `
                -ErrorId Parameter.Max.Not.Int -TargetObject $parameter
        } else {
            $max = $parameter.maxValue
        }

    }
    if ($parameter.psobject.properties.item('MinValue')) {
        if ($parameter.minValue -isnot [int]) {
            Write-Error "$($Parameter.Name) minValue is not an [int] (it's a [$($parameter.minValue.GetType())])" `
                -ErrorId Parameter.Max.Not.Int -TargetObject $parameter           
        } else {
            $min = $ParameterName.minValue
        }
    }

    if ($max -eq $null -and $min -ne $null){
        Write-Error "$($Parameter.Name) missing max value" -ErrorId Parameter.Missing.Max -TargetObject $parameter           
    }

    if ($max -ne $null -and $min -eq $null){
        Write-Error "$($Parameter.Name) missing min value" -ErrorId Parameter.Missing.Min -TargetObject $parameter           
    }
}