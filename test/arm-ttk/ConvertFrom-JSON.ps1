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

    $regexTimeout = [Timespan]'00:00:02.5'

    # This RegEx will match block comments in JSON.
    $JSONBlockComments = [Regex]::new('
/\*         # The open comment
(?<Block>   # capture the comment block.  It is:
(?:.|\s)+?  # anything until
(?=\z|\*/)  # the end of the string or the closing comment
)\*/        # Then match the close comment
', 'IgnoreCase, IgnorePatternWhitespace', $regexTimeout)    
}

process
{
    try {
        if ($PSBoundParameters.InputObject) {
            $_ = $PSBoundParameters.InputObject
        }


        # First, strip block comments
        $inObj = $_
        $in = if ($InputObject.Contains('*/')) { 
            $JSONBlockComments.Replace($inObj,'')
        } else {
            $InputObject
        }

        $hasComment = [regex]::new('(?:^|[^:])//','IgnoreCase',$regexTimeout) 
        $CommentOrQuote = [Regex]::new("(?>(?<CommentStart>//)|(?<SingleQuote>(?<!')')|(?<DoubleQuote>(?<!\\)`"))", 'IgnoreCase', '00:00:15')

        $in = if (-not $hasComment.IsMatch($in)) { # If the JSON contained no comments, pass it directly down
            $in
        } else {
            $lines = $in -split "(?>\r\n|\n)"
            $newlines = foreach ($line in $lines) { # otherwise, go line by line looking for comments.
                $lineHasComments = try { $hasComment.IsMatch($line) } catch {
                    $timeOut = $_ 
                    $false
                } 
                if (-not $lineHasComments) { $line;continue } # If the line didn't contain a comment, echo it.
            
                $lineParts =
                    try { $CommentOrQuote.Matches($line) }
                    catch{ 
                        $timeOut = $_
                    }  
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
            }
            $newlines -join [Environment]::NewLine
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