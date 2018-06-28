$diff = join-Path ${env:ProgramFiles(x86)} "Beyond compare 2\bc2.exe"
$friendlyName = "xIisModule"
$resourceName = "MSFT_$friendlyName"
$classVersion = "1.0.0"

$scriptRoot = Split-Path $MyInvocation.MyCommand.Path
$originalModuleRoot = join-Path $scriptroot "..\.."
$originalModuleRootPath = Resolve-Path $originalModuleRoot
$moduleRoot = Join-Path $env:temp "$($originalModuleRootPath.path | split-path -Leaf)Temp"

$resources = @()

#Key properties
$resources += New-xDscResourceProperty -Name Path -Type String -Attribute Key -Description "The path to the module, usually a dll, to be added to IIS." 


#Required Properites
$resources += New-xDscResourceProperty -Name Name -Type String -Attribute Required -Description "The logical name of the module to add to IIS." 
$resources += New-xDscResourceProperty -Name RequestPath -Type String -Attribute Required -Description "The allowed request Path example: *.php" 
$resources += New-xDscResourceProperty -Name Verb -Type String[] -Attribute Required -Description "The supported verbs for the module." 

#Write Properties
$resources += New-xDscResourceProperty -Name SiteName -Type String -Attribute Write -Description "The IIS Site to register the module." 
$resources += New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -Description "Should the module be present or absent." -ValidateSet @("Present","Absent") 
$resources += New-xDscResourceProperty -Name ModuleType -Type String -Attribute Write -Description "The type of the module." -ValidateSet @("FastCgiModule")  

#Read Properties
$resources += New-xDscResourceProperty -Name EndPointSetup -Type Boolean -Attribute Read -Description "The End Point is setup.  Such as a Fast Cgi endpoint."



Write-Verbose "updating..." -Verbose

# Create a New template resource to a temporary folder
New-xDscResource -Property $resources -ClassVersion $classVersion -Name $resourceName -Path $moduleRoot -FriendlyName $friendlyName


# Use your favorite diff program to compare and merge the current resource and the existing resource

if((test-Path $diff))
{
    &$diff $originalModuleRoot  $moduleRoot 
}
else
{
    Write-Warning "Diff propgram not found!`r`nUse your favorite diff program to compare and merge:`r`n `t$($originalModuleRootPath.path)`r`n and:`r`n `t$moduleRoot"
}



