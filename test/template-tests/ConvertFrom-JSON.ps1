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
        throw
    }
}

process
{
    try {
        $options = 'Multiline,IgnoreCase,IgnorePatternWhitespace'

        $in = 
            [Regex]::Replace(
                [Regex]::Replace($_, '/\*(?<Block>[^(/*/)]+)\*/', '', $options),
            '(?<!\:)//(?<Line>.{0,})$', '', $options
            )

        $steppablePipeline.Process(
            $in
        )
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Microsoft.PowerShell.Utility\ConvertFrom-Json
.ForwardHelpCategory Cmdlet

#>

}