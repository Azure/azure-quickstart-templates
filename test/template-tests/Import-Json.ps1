function Import-Json
{
    <#
    .Synopsis
        Imports a JSON file.
    .Description
        Imports a file written in JavaScript Object Notation (JSON).
    .Notes
        ConvertFrom-JSON will tell you what is wrong with a chunk of JSON, but not what file contained the error.
        Import-JSON captures errors from ConvertFrom-JSOn and reports them by file.
    #>
    param(
    # The path to the file.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('FullName')]
    [string]$FilePath
    )

    process {
        $resolvedPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($FilePath)
        if (-not $resolvedPath) { return }

        $convertProblems = $null
        [IO.File]::ReadAllText($resolvedPath) | 
            ConvertFrom-Json -ErrorAction SilentlyContinue -ErrorVariable ConvertProblems

        if ($convertProblems) {
            $PSCmdlet.WriteError([Management.Automation.ErrorRecord]::new($convertProblems[0].InnerException, 'Import.Json.Failed', 'InvalidOperation', $FilePath))
        }

    }
}
