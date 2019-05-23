param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)

# Walk thru each of the parameters in the template object
foreach ($parameterInfo in $templateObject.parameters.psobject.properties) {
    $parameterName = $parameterInfo.Name
    $parameter = $parameterInfo.Value
    $Min = $null
    $Max = $null
    if ($parameter.psobject.properties.item('maxValue')) {
        if ($parameter.maxValue -isnot [int]) {
            Write-Error "$($ParameterName) maxValue is not an [int] (it's a [$($parameter.maxValue.GetType())])" `
                -ErrorId Parameter.Max.Not.Int -TargetObject $parameter
        } else {
            $max = $parameter.maxValue
        }

    }
    if ($parameter.psobject.properties.item('minValue')) {
        if ($parameter.minValue -isnot [int]) {
            Write-Error "$($ParameterName) minValue is not an [int] (it's a [$($parameter.minValue.GetType())])" `
                -ErrorId Parameter.Max.Not.Int -TargetObject $parameter           
        } else {
            $min = $Parameter.minValue
        }
    }

    if ($max -eq $null -and $min -ne $null){
        Write-Error "$ParameterName missing max value" -ErrorId Parameter.Missing.Max -TargetObject $parameter           
    }

    if ($max -ne $null -and $min -eq $null){
        Write-Error "$ParameterName missing min value" -ErrorId Parameter.Missing.Min -TargetObject $parameter           
    }
}