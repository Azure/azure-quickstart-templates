### Running Tests

Tests can be run directly in PowerShell, or run from the command line using a wrapper script.

You can run the full suite of tests by using Test-AzureRMTemplate.cmd (on Windows) or Test-AzureRMTemplate.sh (on Linux), and passing in the path to a template.

This will run the full suite of applicable tests on your template.  To run a specific group of tests, use:


    Test-AzureRMTemplate -TemplatePath $thePathToYourTemplate -Test deploymentTemplate 
    # This will run deployment template tests on all appropriate files
    <# There are currently three groups of tests:
        * deploymentTemplate (aka MainTemplateTests)
        * createUIDefinition
        * all
    #>
    
    Test-AzureRMTemplate -TemplatePath $thePathToYourTemplate -Test "Resources Should Have Location" 
    # This will run the specific test, 'Resources Should have Location', on all appropriate files

    Test-AzureRMTemplate -TemplatePath $thePathToYourTemplate -Test "Resources Should Have Location" -File MyNestedTemplate.json 
    # This will run the specific test, 'Resources Should have Location', but only on MyNestedTemplate.json        
      


#### Running Tests on Linux

Before you run the tests on Linux, you'll need to [install PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6).

#### Running Tests in PowerShell

To run the tests in PowerShell, you'll need to import the module.

    Import-Module .\AzRMTester.psd1 # assuming you're in the same directory as .\AzRMTester.psd1

You can then test a particular path by using:

    Test-AzureRMTemplate -TemplatePath $TemplateFileOrFolder

### Running Tests from the Command Line

You can use a BASH file or Command Script to run on the command line.  To do so, simply call Test-AzureRMTemplate.sh (or .cmd).  This will pass the arguments down to the PowerShell script.  To get help, pass a -?


### Inspecting Test Results

By default, tests are run in Pester, which displays output in a colorized format, but does not return individual failures to the pipeline.  
To inspect the results, use the -NoPester flag and assign the results to a variable 
(you must be running in PowerShell):

    $TestResults = Test-AzureRMTemplate -TemplatePath $TemplateFileOrFolder -NoPester

To see failures, use Where-Object to filter the results

    $TestFailures =  $TestResults | Where-Object { -not $_.Passed }

Many test failures will return a TargetObject, for instance, the exact property within a template that had an issue.  To extract out target objects from an error, use:

    $FailureTargetObjects = $TestFailures |
        Select-Object -ExpandProperty Errors | 
        Select-Object -ExpandProperty TargetObject


Please note that not all test cases will return a target object.  If no target object is returned, the target should be clear from the text of the error.