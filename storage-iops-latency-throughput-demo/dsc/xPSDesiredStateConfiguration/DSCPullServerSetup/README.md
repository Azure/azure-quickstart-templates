# DSCPullServer contains utilities to automate DSC module and configuration document packaging and delpoyment on enterprise pull server , and examples

# Publish-DSCModuleAndMof cmdlet
   Use Publish-DSCModuleAndMof cmdlet to package DSC modules that present in $Source or in $ModuleNameList into zip files with the version info and publish them with mof configuration documents that present in $Source on Pull server. 
   Publishes the modules on "$env:ProgramFiles\WindowsPowerShell\DscService\Modules"
   Publishes all mof configuration documents on "$env:ProgramFiles\WindowsPowerShell\DscService\Configuration"
   Use $Force to force packaging the version that exists in $Source folder if a different version of the module exists in powershell module path
   Use $ModuleNameList to specify the names of the modules to be published (all versions if multiple versions of the module are installed) if no DSC module presents in local folder $Source

.EXAMPLE
    Publish-DSCModuleAndMof -Source C:\LocalDepot
       
.EXAMPLE
    $moduleList = @("xWebAdministration", "xPhp")
    Publish-DSCModuleAndMof -Source C:\LocalDepot -ModuleNameList $moduleList

.EXAMPLE
    Publish-DSCModuleAndMof -Source C:\LocalDepot -Force
