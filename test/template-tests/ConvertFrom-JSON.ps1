function ConvertFrom-Json
{
[CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=217031', RemotingCapability='None')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [AllowEmptyString()]
    [string]
    ${InputObject})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\ConvertFrom-Json', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        $_ | Write-Error
    }
}

process
{
    try {
        $options = 'Multiline,IgnoreCase,IgnorePatternWhitespace'

        if ($PSBoundParameters.InputObject) {
            $_ = $PSBoundParameters.InputObject
        }
        # Strip block comments
        $in = $_ -replace '/\*(?<Block>(?!=\*\/)[\s\S]+)\*/', ''
        # Strip single line comments that are preceeded by whitespace
        #$in =[Regex]::Replace($in,'\s{1,}//(?<Line>.{0,})$', '', $options)

        $lines = $in -split "`n|$([Environment]::NewLine)"

        $in = @(foreach ($line in $lines) {
            $commentStarts = @([Regex]::Matches($line, "(?<CommentStart>//)"))
            if (-not $commentStarts) {
                $line
                continue
            }
            $lineParts = @([Regex]::Matches($line, "(?<CommentStart>//)|(?<SingleQuote>(?<!')')|(?<DoubleQuote>(?<!\\)`")"))

            if (-not $lineParts) { 
                $line
                continue
            }
            $trimAt = -1
            
            $singleQuoteCounter = 0
            $doubleQuoteCounter = 0  
            foreach ($lp in $lineParts) {
                if ($lp.Groups["SingleQuote"].Success) {
                    $singleQuoteCounter++
                }
                if ($lp.Groups["DoubleQuote"].Success) {
                    $doubleQuoteCounter++    
                }
                if ($lp.Groups["CommentStart"].Success -and 
                    -not ($singleQuoteCounter % 2) -and 
                    -not ($doubleQuoteCounter % 2)) {
                    
                    $trimAt = $lp.Index
                    break
                }
            }

            if ($trimAt -ne -1) {
                $line.Substring(0, $trimAt)
            } else {
                $line
            }
        }) -join [Environment]::NewLine


        if ($PSBoundParameters.InputObject) {
            $PSBoundParameters.InputObject = $in
            $steppablePipeline.Process($PSBoundParameters.InputObject)
        } else {
            $steppablePipeline.Process(
                $in
            )    
        }
        
    } catch {
        $_ | Write-Error
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        $_ | Write-Error
    }
}
<#

.ForwardHelpTargetName Microsoft.PowerShell.Utility\ConvertFrom-Json
.ForwardHelpCategory Cmdlet

#>

}