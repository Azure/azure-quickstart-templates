param(
[Parameter(Mandatory=$true,Position=0)]
[string]
$TemplateText
)
if ($TemplateText -like '*providers(*).apiVersions*') {
    Write-Error "providers().apiVersions is not permitted, use a literal apiVersion" -ErrorId ApiVersion.Using.Providers -TargetObject $TemplateText
}