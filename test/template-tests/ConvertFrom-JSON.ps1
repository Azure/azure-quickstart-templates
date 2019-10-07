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

    # This RegEx will match block comments in JSON.
    $JSONBlockComments = [Regex]::new('
/\*       # The open comment
(?<Block> # capture the comment block.  It is:
(.|\s)+?  # anything until
(?=\*/)   # the close comment
)\*/      # then match the close comment
', 'IgnoreCase, IgnorePatternWhitespace')
}

process
{
    try {
        if ($PSBoundParameters.InputObject) {
            $_ = $PSBoundParameters.InputObject
        }


        # First, strip block comments
        $inObj = $_
        $in = $JSONBlockComments.Replace($inObj,'')


        $hasComment = [regex]::new('(^|[^:])//') 
        $CommentOrQuote = [Regex]::new("(?<CommentStart>//)|(?<SingleQuote>(?<!')')|(?<DoubleQuote>(?<!\\)`")")

        $in = if (-not $hasComment.IsMatch($in)) { # If the JSON contained no comments, pass it directly down
            $in
        } else {
            $lines = $in -split "(?>\r\n|\n)"
            @(foreach ($line in $lines) { # otherwise, go line by line looking for comments.
                if (-not $hasComment.IsMatch($line)) { $line;continue } # If the line didn't contain a comment, echo it.
            
                $lineParts = $CommentOrQuote.Matches($line) 
                if (-not $lineParts) { 
                    $line
                    continue
                }
                $trimAt = -1
            
                $singleQuoteCounter = 0
                $doubleQuoteCounter = 0  
                foreach ($lp in $lineParts) { # Count up thru the quotes.
                    if ($lp.Groups["SingleQuote"].Success) {
                        $singleQuoteCounter++
                    }
                    if ($lp.Groups["DoubleQuote"].Success) {
                        $doubleQuoteCounter++    
                    }
                    if ($lp.Groups["CommentStart"].Success -and 
                        -not ($singleQuoteCounter % 2) -and 
                        -not ($doubleQuoteCounter % 2)) { # If the comment occurs while the quotes are balanced
                    
                        $trimAt = $lp.Index # that's where we trim.
                        break
                    }
                }
                if ($trimAt -ne -1) { # If we know where to chop the line
                    $line.Substring(0, $trimAt) # get everything up until that point
                } else { # otherwise,
                    $line  # echo the line.
                }
            }) -join [Environment]::NewLine
        }

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