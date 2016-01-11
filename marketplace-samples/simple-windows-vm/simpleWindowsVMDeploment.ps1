Switch-Azuremode -name AzureResourceManager
# Count of runs
$count = 1

# Variables
$templateFile = "C:\Users\kenazk\Desktop\GitHub\azure-quickstart-templates\marketplace-samples\simple-windows-vm\mainTemplate.json"
$paramsFile = "C:\Users\kenazk\Desktop\GitHub\azure-quickstart-templates\marketplace-samples\simple-windows-vm\parameters.json"
$params = Get-content $paramsFile | convertfrom-json
$location = "westus"
$rgprefix = "SimpleWindowsT1"

# Generate parameter object
$hash = @{};
foreach($param in $params.psobject.Properties)
{
    $hash.Add($param.Name, $param.Value.Value);
}

#Create new Resource Groups and Deployments for each run
for($i = 0; $i -lt $count; $i++)
{
    # Create new Resource Group
    $d = get-date
    $rgname = $rgprefix + '-'+ $d.Year + $d.Month + $d.Day + '-' + $d.Hour + $d.Minute + $d.Second
    New-AzureResourceGroup -Name $rgname -Location $location -Verbose 
    
    # Construct parameter set
    $dsuffix = "" + $d.hour + $d.minute + $d.Second
    $hash.dnsNameForPublicIP = "swvm" + $dsuffix
    $hash.storageAccountName = "sa" + $dsuffix
    $hash.location = $location

    # Run as asynchronous job
    $jobName = "spDeployment-" + $i;
    $sb = {
        param($rgname, $templateFile, $hash)
        function createTemplateDeployment($rgname, $templateFile, $hash)
        {
            $dep = $rgname + "-dep"; 
            New-AzureResourceGroupDeployment -ResourceGroupName $rgname -Name $dep -TemplateFile $templateFile -TemplateParameterObject $hash -Verbose 
        }
        createTemplateDeployment $rgname $templateFile $hash
    }
    $job = start-job -Name $jobName -ScriptBlock $sb -ArgumentList $rgname, $templateFile, $hash

    Start-sleep -s 5
}


