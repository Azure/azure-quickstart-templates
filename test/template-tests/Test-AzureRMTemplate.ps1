function Test-AzureRMTemplate
{
    <#
    .Synopsis
Tests an Azure Resource Manager Template
    .Description
Validates one or more Azure Resource Manager Templates.
    .Notes
Test-AzureRMTemplate validates an Azure Resource Manager template using a number of small test scripts.

Test scripts can be found in /testcases/GroupName, or provided with the -TestScript parameter.

Each test script has access to a set of well-known variables:

* TemplateFullPath (The full path to the template file)
* TemplateFileName (The name of the template file)
* TemplateText (The template text)
* TemplateObject (The template object)
* FolderName (The name of the directory containing the template file)
* FolderFiles (a hashtable of each file in the folder)
* IsMainTemplate (a boolean indicating if the template file name is mainTemplate.json)
* CreateUIDefintionFullPath (the full path to createUIDefintion.json)
* CreateUIDefinitionText (the text of createUIDefintion.json)
* CreateUIDefinitionObject ( the createUIDefintion object)
* HasCreateUIDefintion (a boolean indicating if the directory includes createUIDefintion.json)
* MainTemplateText (the text of the main template file)
* MainTemplateObject (the main template file, converted from JSON)
* MainTemplateResources (the resources and child resources of the main template)
* MainTemplateParameters (a hashtable containing the parameters found in the main template)
* MainTemplateVariables (a hashtable containing the variables found in the main template)
* MainTemplateOutputs (a hashtable containing the outputs found in the main template) 

    #>
    [CmdletBinding(DefaultParameterSetName='NearbyTemplate')]
    param(
    # The path to an Azure resource manager template
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true,ParameterSetName='SpecificTemplate')]
    [Alias('Fullname','Path')]
    [string]
    $TemplatePath,

    # One or more test cases or groups.  If this parameter is provided, only those test cases and groups will be run.
    [Parameter(Position=1)]
    [Alias('Tests')]
    [string[]]
    $Test,

    # If provided, will only validate files in the template directory matching one of these wildcards.
    [Parameter(Position=2)]
    [Alias('Files')]
    [string[]]
    $File,

    # A set of test cases.  If not provided, the files in /testcases will be used as input.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($k in $_.Keys) {
            if ($k -isnot [string]) {
                throw "All keys must be strings"
            }
        }
        foreach ($v in $_.Values) {
            if ($v -isnot [ScriptBlock] -and $v -isnot [string]) {
                throw "All values must be script blocks or strings"
            }
        }
        return $true
    })]
    [Alias('TestCases')]
    [Collections.IDictionary]
    $TestCase = [Ordered]@{},

    # A set of test groups.  Test groups will be automatically populated by the directory names in /testcases.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($k in $_.Keys) {
            if ($k -isnot [string]) {
                throw "All keys must be strings"
            }
        }
        foreach ($v in $_.Values) {
            if ($v -isnot [string]) {
                throw "All values must be strings"
            }
        }
        return $true
    })]
    [Collections.IDictionary]
    $TestGroup = [Ordered]@{},


    # If provided, will skip any tests in this list.
    [string[]]
    $Skip,

    # If set, will run tests in Pester.
    [switch]
    $Pester)

    begin {
        # First off, let's get all of the built-in test scripts.   
        $testCaseSubdirectory = 'testcases'
        $myLocation =  $MyInvocation.MyCommand.ScriptBlock.File  
        $testScripts= @($myLocation| # To do that, we start from the current file,
            Split-Path | # get the current directory,
            Get-ChildItem -Filter $testCaseSubdirectory | # get the cases directory, 
            Get-ChildItem -Filter *.test.ps1 -Recurse)  # and get all test.ps1 files within it.


        $builtInTestCases = @{}
        # Next we'll define some human-friendly built-in groups.        
        $builtInGroups = @{
            'all' = 'deploymentTemplate', 'createUIDefinition'
            'mainTemplateTests' = 'deploymentTemplate'
        }


        # Now we loop over each potential test script
        foreach ($testScript  in $testScripts) {
            # The test file name (minus .test.ps1) becomes the name of the test.           
            $TestName = $testScript.Name -ireplace '\.test\.ps1$', '' -replace '_', ' ' -replace '-', ' '
            $testDirName = $testScript.Directory.Name
            if ($testDirName -ne $testCaseSubdirectory) { # If the test case was in a subdirectory
                if (-not $builtInGroups.$testDirName) {
                    $builtInGroups.$testDirName = @()
                }
                # then the subdirectory name is the name of the test group.
                $builtInGroups.$testDirName += $TestName
            } else {
                # If there was no subdirectory, put the test in a special group called "ungrouped".
                if (-not $builtInGroups.Ungrouped) {
                    $builtInGroups.Ungrouped = @()
                }
                $builtInGroups.Ungrouped += $TestName
            } 
            $builtInTestCases[$testName] = $testScript.Fullname
        }
        
        # This lets our built-in groups be automatically defined by their file structure.

        if (-not $script:AlreadyLoadedCache) { $script:AlreadyLoadedCache = @{} }
        # Next we want to load the cached items
        $cacheDir = $myLocation | Split-Path | Join-Path -ChildPath cache
        $cacheItemNames = @(foreach ($cacheFile in (Get-ChildItem -Path $cacheDir -Filter *.cache.json)) {
            $cacheName = $cacheFile.Name -replace '\.cache\.json', ''
            if (-not $script:AlreadyLoadedCache[$cacheFile.Name]) {
                $script:AlreadyLoadedCache[$cacheFile.Name] = 
                    [IO.File]::ReadAllText($cacheFile.Fullname) | ConvertFrom-Json
                
            }
            $cacheData = $script:AlreadyLoadedCache[$cacheFile.Name]
            $ExecutionContext.SessionState.PSVariable.Set($cacheName, $cacheData)
            $cacheName
        })


        # Next we want to declare some internal functions:
        #*Test-Case (executes a test, given a set of parameters) 
        function Test-Case($TheTest, $TestParameters = @{}) {            
            $testCommandParameters = 
                if ($TheTest -is [ScriptBlock]) {
                    $function:f = $TheTest
                    ([Management.Automation.CommandMetaData]$function:f).Parameters
                    Remove-Item function:f                
                } elseif ($TheTest -is [string]) {
                    $testCmd = $ExecutionContext.SessionState.InvokeCommand.GetCommand($TheTest, 'ExternalScript')
                    if (-not $testCmd) { return } 
                    ([Management.Automation.CommandMetaData]$testCmd).Parameters
                } else {
                    return
                }
            $testInput = @{} + $TestParameters
            
            foreach ($k in @($testInput.Keys)) {
                if (-not $testCommandParameters.ContainsKey($k)) {                    
                    $testInput.Remove($k)
                }
            }
            
            if (-not $Pester) {
                & $TheTest @testInput 2>&1 3>&1
            } else {
                & $TheTest @testInput
            }            
        }

        #*Test-Group (executes a group of tests)
        function Test-Group {                
            $testQueue = [Collections.Queue]::new(@($GroupName))
            while ($testQueue.Count) {
                $dq = $testQueue.Dequeue()
                if ($TestGroup.$dq) {
                    foreach ($_ in $TestGroup.$dq) {
                        $testQueue.Enqueue($_)
                    }
                    continue
                }

                if ($ValidTestList -and $ValidTestList -notcontains $dq) {
                    continue
                }

                if (-not $Pester) {
                    $testStartedAt = [DateTime]::Now
                    $testCaseOutput = Test-Case $testCase.$dq $TestInput 2>&1 3>&1
                    $testTook = [DateTime]::Now - $testStartedAt
                    
                    $testErrors = 
                        @(foreach ($_ in $testCaseOutput) {
                            if ($_ -is [Exception] -or $_ -is [Management.Automation.ErrorRecord]) { $_ }
                        })

                    $testWarnings = 
                        @(foreach ($_ in $testCaseOutput) {
                            if ($_ -is [Management.Automation.WarningRecord]) { $_ }
                        })
                    
                    New-Object PSObject -Property ([Ordered]@{
                        pstypename = 'Template.Validation.Test.Result'
                        Errors = $testErrors
                        Warnings = $testWarnings
                        Passed = $testErrors.Count -lt 1
                        Group = $GroupName
                        Name = $dq
                        Timespan = $testTook
                        File = $fileInfo
                    })
                } else {
                    it $dq {
                        # Pester tests only fail on a terminating error, 
                        $errorMessages = Test-Case $testCase.$dq $TestInput 2>&1 |
                            Where-Object { $_ -is [Management.Automation.ErrorRecord] } | 
                            # so collect all non-terminating errors.
                            Select-Object -ExpandProperty Exception |
                            Select-Object -ExpandProperty Message
                        
                        if ($errorMessages) { # If any were found,
                            throw ($errorMessages -join ([Environment]::NewLine)) # throw.
                        }
                    }
                }                                               
            }
        }

        #*Test-FileList (tests a list of files)
        function Test-FileList {
            foreach ($fileInfo in $FolderFiles) {
                $matchingGroups = 
                    @(if ($fileInfo.Schema) {
                        foreach ($key in $TestGroup.Keys) {
                            if ("$key".StartsWith("_") -or "$key".StartsWith('.')) { continue } 
                            if ($fileInfo.Schema -match $key) {
                                $key
                            }
                        }
                    } else {
                        foreach ($key in $TestGroup.Keys) {
                            if ($fileInfo.Extension -eq '.json' -and 
                                ($fileInfo.Name -ireplace '\.test\.ps1', '') -match $key) {
                                $key; continue
                            }
                            if (-not ("$key".StartsWith('_') -or "$key".StartsWith('.'))) { continue } 
                            if ($fileInfo.Extension -eq "$key".Replace('_', '.')) {
                                $key
                            }
                        }
                    })

                if ($TestGroup.Ungrouped) {
                    $matchingGroups += 'Ungrouped'
                }

                if (-not $matchingGroups) { continue } 
                if ($fileInfo.Schema -like '*deploymentTemplate*') {                     
                    $isMainTemplate = 'mainTemplate.json', 'azureDeploy.json', 'prereq.azuredeploy.json' -contains $fileInfo.Name
                    $templateFileName = $fileInfo.Name
                    $TemplateObject = $fileInfo.Object
                    $TemplateText = $fileInfo.Text
                }
                foreach ($groupName in $matchingGroups) {                    
                    $testInput = @{}
                    foreach ($_ in $WellKnownVariables) {
                        $testInput[$_] = $ExecutionContext.SessionState.PSVariable.Get($_).Value
                    }
                    $ValidTestList = if ($test) {
                        @(Get-TestGroups ($test -replace '-',' ') -includeTest)
                    } else {
                        $null
                    }
                    if (-not $Pester) {
                        $context = "$($fileInfo.Name)->$groupName"
                        Test-Group
                    } else {
                        context "$($fileInfo.Name)->$groupName" ${function:Test-Group}

                    }
                }
            }
                
        }
        
        #*Get-TestGroups (expands nested test groups)
        function Get-TestGroups([string[]]$GroupName, [switch]$includeTest) {
            foreach ($_ in $GroupName) {
                if ($TestGroup[$_]) {
                    Get-TestGroups $testGroup[$_] -includeTest:$includeTest
                } elseif ($IncludeTest -and $TestCase[$_]) {
                    $_
                }
            }
        }
        
        $accumulatedTemplates = [Collections.Arraylist]::new()    
    }

    process {
        # If no template was passed,
        if ($PSCmdlet.ParameterSetName -eq 'NearbyTemplate') {
            # attempt to find one in the current directory and it's subdirectories 
            $possibleJsonFiles = @(Get-ChildItem -Filter *.json -Recurse |
                Sort-Object Name -Descending | # (sort by name descending so that MainTemplate.json comes first).
                Where-Object {
                    'azureDeploy.json', 'mainTemplate.json' -contains $_.Name 
                })
                
            
            # If more than one template was found, warn which one we'll be testing.
            if ($possibleJsonFiles.Count -gt 1) {
                Write-Error "More than one potential template file found beneath '$pwd'.  Please have only azureDeploy.json or mainTemplate.json, not both."
                return
            }
            
            
            # If no potential files were found, write and error and return.
            if (-not $possibleJsonFiles) {
                Write-Error "No potential templates found beneath '$pwd'.  Templates should be named azureDeploy.json or mainTemplate.json."
                return
            }


            # If we could find a potential json file, recursively call yourself.
            $possibleJsonFiles | 
                Select-Object -First 1 |
                Test-AzureRMTemplate @PSBoundParameters
                             
            return
        }

        # First, merge the built-in groups and test cases with any supplied by the user.
        foreach ($kv in $builtInGroups.GetEnumerator()) {
            if (-not $testGroup[$kv.Key]) {
                $TestGroup[$kv.Key] = $kv.Value            
            }
        }
        foreach ($kv in $builtInTestCases.GetEnumerator()) {
            if (-not $testCase[$kv.Key]) {
                $TestCase[$kv.Key]= $kv.Value
            }
        }

        $null = $accumulatedTemplates.Add($TemplatePath)
    }

    end {
        $c, $t = 0, $accumulatedTemplates.Count
        $progId = Get-Random

        foreach ($TemplatePath in $accumulatedTemplates) {
            $C++
            $p = $c * 100 / $t
            $templateFileName = $TemplatePath | Split-Path -Leaf
            Write-Progress "Validating Templates" "$templateFileName" -PercentComplete $p -Id $progId
            $expandedTemplate =Expand-AzureRMTemplate -TemplatePath $templatePath
            if (-not $expandedTemplate) { continue }
            foreach ($kv in $expandedTemplate.GetEnumerator()) {
                $ExecutionContext.SessionState.PSVariable.Set($kv.Key, $kv.Value)
            }
            $wellKnownVariables = @($expandedTemplate.Keys) + $cacheItemNames

            # If a file list was provided,
            if ($PSBoundParameters.File) {
                $FolderFiles = @(foreach ($ff in $FolderFiles) { # filter the folder files. 
                    $matched = @(foreach ($_ in $file) {
                        $ff.Name -like $_ # If file the name matched any of valid patterns.
                    })
                    if ($matched -eq $true) 
                    {
                        $ff # then we include it.   
                    }
                })
            }
        
        
        
            # Now that the filelist and test groups are set up, we use Test-FileList to test the list of files.                   
            if ($Pester) {
                $IsPesterLoaded? = $(
                    $loadedModules = Get-module
                    foreach ($_ in $loadedModules) { 
                        if ($_.Name -eq 'Pester') {
                            $true
                            break
                        }
                    }
                )
                $DoesPesterExist? = 
                    if ($IsPesterLoaded?) {
                        $true
                    } else {
                        $env:PSModulePath -split ';' | 
                            Get-ChildItem -Filter Pester |
                            Import-Module -Global -PassThru        
                    }

                if (-not $DoesPesterExist?){
                    Write-Warning "Pester not found.  Please install Pester (Install-Module Pester)"
                    $Pester = $false
                }
            }
        
            if (-not $Pester) { # If we're not running Pester, 
                Test-FileList # we just call it directly.
            }
            else { 
                # If we're running Pester, we pass the function defintion as a parameter to describe.
                describe "Validating Azure Template $TemplateName" ${function:Test-FileList}
            }

        }

        Write-Progress "Validating Templates" "Complete" -Completed -Id $progId        
    }    
}