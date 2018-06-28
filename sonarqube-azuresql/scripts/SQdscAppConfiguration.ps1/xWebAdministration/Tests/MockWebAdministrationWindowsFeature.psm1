
# Suppressing these rule because these functions are from an external module 
# and are only being used as stubs
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
param ()

function Add-WebConfiguration { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268763')]
param(
    [psobject]
    ${Value},

    [string]
    ${Clr},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [hashtable]
    ${AtElement},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [int]
    ${AtIndex},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${AtName},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Add-WebConfigurationLock { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268770')]
param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Type},

    [switch]
    ${Force},

    [switch]
    ${Passthru},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Add-WebConfigurationProperty { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268814')]
param(
    [Parameter(Mandatory=$true)]
    [string]
    ${Name},

    [string]
    ${Type},

    [psobject]
    ${Value},

    [string]
    ${Clr},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [hashtable]
    ${AtElement},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [int]
    ${AtIndex},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${AtName},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Backup-WebConfiguration { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268815')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, HelpMessage='Backup name')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Name})

 
 } 


function Clear-WebCentralCertProvider { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=269642')]
param(
    [switch]
    ${PrivateKeyPassword})

 
 } 


function Clear-WebConfiguration { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268817')]
param(
    [string]
    ${Clr},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Clear-WebRequestTracingSetting { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268818')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Clear-WebRequestTracingSettings { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268818')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function ConvertTo-WebApplication { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268819')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ApplicationPool},

    [switch]
    ${Force},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Disable-WebCentralCertProvider { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=269643')]
param()

 
 } 


function Disable-WebGlobalModule { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268820')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Disable-WebRequestTracing { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268821')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Enable-WebCentralCertProvider { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=269644')]
param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${CertStoreLocation},

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${UserName},

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Password},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${PrivateKeyPassword})

 
 } 


function Enable-WebGlobalModule { 
 [CmdletBinding(DefaultParameterSetName='InputProperties', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268822')]
param(
    [Parameter(ParameterSetName='InputObject', Mandatory=$true, ValueFromPipeline=$true)]
    [psobject]
    ${InputObject},

    [Parameter(ParameterSetName='InputProperties', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ParameterSetName='InputProperties', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Type},

    [Parameter(ParameterSetName='InputProperties', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Enable-WebRequestTracing { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268823')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Directory},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [uint32]
    ${MaxLogFiles},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [uint32]
    ${MaxLogFileSize},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [switch]
    ${CustomActions},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${StatusCodes})

 
 } 


function Get-WebAppDomain { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268825')]
param(
    [Parameter(ParameterSetName='InputObject', ValueFromPipeline=$true)]
    [psobject]
    ${InputObject},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('apppool','pool')]
    [string]
    ${ApplicationPool},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('proc','procid','pid','wp')]
    [ValidateNotNull()]
    [uint32]
    ${ProcessId})

 
 } 


function Get-WebApplication { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268826')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Site},

    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Get-WebAppPoolState { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268827')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Get-WebBinding { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268828')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Protocol},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Port},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${IPAddress},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${HostHeader})

 
 } 


function Get-WebCentralCertProvider { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=269640')]
param(
    [switch]
    ${CertStoreLocation},

    [switch]
    ${UserName},

    [switch]
    ${PrivateKeyPassword},

    [switch]
    ${Enabled})

 
 } 


function Get-WebConfigFile { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268829')]
param(
    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebConfiguration { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268830')]
param(
    [switch]
    ${Recurse},

    [switch]
    ${Metadata},

    [string]
    ${Clr},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebConfigurationBackup { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268831')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true, HelpMessage='Backup name')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Name})

 
 } 


function Get-WebConfigurationLocation { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268832')]
param(
    [Parameter(Position=2, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Name},

    [switch]
    ${Recurse},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebConfigurationLock { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268833')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebConfigurationProperty { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268834')]
param(
    [Parameter(Mandatory=$true)]
    [string[]]
    ${Name},

    [switch]
    ${Recurse},

    [string]
    ${Clr},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebFilePath { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268835')]
param(
    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebGlobalModule { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268836')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Image},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition})

 
 } 


function Get-WebHandler { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268837')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebItemState { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268838')]
param(
    [string]
    ${Protocol},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})


dynamicparam
{
    try {
        $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('WebAdministration\Get-WebItemState', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
        $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
        if ($dynamicParams.Length -gt 0)
        {
            $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
            foreach ($param in $dynamicParams)
            {
                $param = $param.Value

                if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name))
                {
                    $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                    $paramDictionary.Add($param.Name, $dynParam)
                }
            }
            return $paramDictionary
        }
    } catch {
        throw
    }
}

 
 } 


function Get-WebManagedModule { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268839')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Get-WebRequest { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268840')]
param(
    [Parameter(ParameterSetName='InputObject', ValueFromPipeline=$true)]
    [psobject]
    ${InputObject},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('pool')]
    [string]
    ${AppPool},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('proc','procid','pid','wp')]
    [uint32]
    ${Process})

 
 } 


function Get-Website { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268841')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Name})

 
 } 


function Get-WebsiteState { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268842')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Get-WebURL { 
 [CmdletBinding(DefaultParameterSetName='InputPSPath', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268843')]
param(
    [Parameter(ParameterSetName='InputURL', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [uri[]]
    ${Url},

    [Parameter(ParameterSetName='InputPSPath', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath},

    [string]
    ${Accept},

    [switch]
    ${ResponseHeaders},

    [switch]
    ${Content})

 
 } 


function Get-WebVirtualDirectory { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268844')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Site},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Application},

    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function New-WebApplication { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268845')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Site},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${PhysicalPath},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ApplicationPool},

    [switch]
    ${Force})

 
 } 


function New-WebAppPool { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268846')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, HelpMessage='Application pool name')]
    [ValidateNotNull()]
    [string]
    ${Name},

    [switch]
    ${Force})

 
 } 


function New-WebBinding { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268847')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Protocol},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [uint32]
    ${Port},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${IPAddress},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${HostHeader},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [int]
    ${SslFlags},

    [switch]
    ${Force})

 
 } 


function New-WebFtpSite { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268848')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [uint32]
    ${Id},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [uint32]
    ${Port},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${IPAddress},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${HostHeader},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${PhysicalPath},

    [switch]
    ${Force})

 
 } 


function New-WebGlobalModule { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268849')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Image},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition},

    [switch]
    ${Force})

 
 } 


function New-WebHandler { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268850')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Path},

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Verb},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Type},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Modules},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ScriptProcessor},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('File','Directory','Either','Unspecified')]
    [string]
    ${ResourceType},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('None','Read','Write','Script','Execute')]
    [string]
    ${RequiredAccess},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function New-WebManagedModule { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268851')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Type},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function New-Website { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268852')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [uint32]
    ${Id},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [uint32]
    ${Port},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${IPAddress},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [int]
    ${SslFlags},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${HostHeader},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${PhysicalPath},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ApplicationPool},

    [switch]
    ${Ssl},

    [switch]
    ${Force})

 
 } 


function New-WebVirtualDirectory { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268853')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Site},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Application},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${PhysicalPath},

    [switch]
    ${Force})

 
 } 


function Remove-WebApplication { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268854')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Site},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Remove-WebAppPool { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268855')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Remove-WebBinding { 
 [CmdletBinding(DefaultParameterSetName='InputBindingProperties', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268856')]
param(
    [Parameter(ParameterSetName='InputObject', Mandatory=$true, ValueFromPipeline=$true)]
    [psobject]
    ${InputObject},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Protocol},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ParameterSetName='InputBindingInformation', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${BindingInformation},

    [Parameter(ParameterSetName='InputBindingProperties', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${IPAddress},

    [Parameter(ParameterSetName='InputBindingProperties', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Port},

    [Parameter(ParameterSetName='InputBindingProperties', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${HostHeader})

 
 } 


function Remove-WebConfigurationBackup { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268857')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true, HelpMessage='Backup name')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Name})

 
 } 


function Remove-WebConfigurationLocation { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268858')]
param(
    [Parameter(Position=2, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Name},

    [switch]
    ${Recurse},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Remove-WebConfigurationLock { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268859')]
param(
    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Remove-WebConfigurationProperty { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268860')]
param(
    [Parameter(Mandatory=$true)]
    [string]
    ${Name},

    [string]
    ${Clr},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [hashtable]
    ${AtElement},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [int]
    ${AtIndex},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${AtName},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Remove-WebGlobalModule { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268861')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Remove-WebHandler { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268862')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Remove-WebManagedModule { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268863')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Remove-Website { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268864')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Remove-WebVirtualDirectory { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268865')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Site},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Application},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Rename-WebConfigurationLocation { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268866')]
param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Name},

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${NewName},

    [switch]
    ${Recurse},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Restart-WebAppPool { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268867')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name})

 
 } 


function Restart-WebItem { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268868')]
param(
    [string]
    ${Protocol},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})


dynamicparam
{
    try {
        $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('WebAdministration\Restart-WebItem', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
        $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
        if ($dynamicParams.Length -gt 0)
        {
            $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
            foreach ($param in $dynamicParams)
            {
                $param = $param.Value

                if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name))
                {
                    $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                    $paramDictionary.Add($param.Name, $dynParam)
                }
            }
            return $paramDictionary
        }
    } catch {
        throw
    }
}

 
 } 


function Restore-WebConfiguration { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268869')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, HelpMessage='Backup name')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Name})

 
 } 


function Select-WebConfiguration { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268870')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter})

 
 } 


function Set-WebBinding { 
 [CmdletBinding(DefaultParameterSetName='InputBindingProperties', SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268871')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ParameterSetName='InputBindingInformation', Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${BindingInformation},

    [Parameter(ParameterSetName='InputBindingProperties', Position=1, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${IPAddress},

    [Parameter(ParameterSetName='InputBindingProperties', Position=2, ValueFromPipelineByPropertyName=$true)]
    [uint32]
    ${Port},

    [Parameter(ParameterSetName='InputBindingProperties', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${HostHeader},

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${PropertyName},

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Value})

 
 } 


function Set-WebCentralCertProvider { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=269641')]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${CertStoreLocation},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${UserName},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Password},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${PrivateKeyPassword})

 
 } 


function Set-WebCentralCertProviderCredential { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=269645')]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    ${UserName})

 
 } 


function Set-WebConfiguration { 
 [CmdletBinding(DefaultParameterSetName='InputPSObject', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268872')]
param(
    [Parameter(ParameterSetName='InputObject', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [System.Object]
    ${InputObject},

    [Parameter(ParameterSetName='InputPSObject', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('v','val')]
    [psobject]
    ${Value},

    [string]
    ${Metadata},

    [string]
    ${Clr},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Set-WebConfigurationProperty { 
 [CmdletBinding(DefaultParameterSetName='InputPSObject', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268873')]
param(
    [Parameter(Mandatory=$true)]
    [string]
    ${Name},

    [Parameter(ParameterSetName='InputObject', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [System.Object]
    ${InputObject},

    [Parameter(ParameterSetName='InputPSObject', Mandatory=$true)]
    [Alias('v','val')]
    [psobject]
    ${Value},

    [string]
    ${Clr},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [hashtable]
    ${AtElement},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [int]
    ${AtIndex},

    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${AtName},

    [switch]
    ${Force},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Filter},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Set-WebGlobalModule { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268874')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Image})

 
 } 


function Set-WebHandler { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268875')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Path},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Verb},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Type},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Modules},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${ScriptProcessor},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('File','Directory','Either','Unspecified')]
    [string]
    ${ResourceType},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('None','Read','Write','Script','Execute')]
    [string]
    ${RequiredAccess},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Set-WebManagedModule { 
 [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low', HelpUri='http://go.microsoft.com/fwlink/?LinkID=268876')]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Type},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Precondition},

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Location},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Start-WebAppPool { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268877')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [switch]
    ${Passthru})

 
 } 


function Start-WebCommitDelay { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268816')]
param()

 
 } 


function Start-WebItem { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268878')]
param(
    [switch]
    ${Passthru},

    [string]
    ${Protocol},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})


dynamicparam
{
    try {
        $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('WebAdministration\Start-WebItem', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
        $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
        if ($dynamicParams.Length -gt 0)
        {
            $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
            foreach ($param in $dynamicParams)
            {
                $param = $param.Value

                if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name))
                {
                    $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                    $paramDictionary.Add($param.Name, $dynParam)
                }
            }
            return $paramDictionary
        }
    } catch {
        throw
    }
}

 
 } 


function Start-Website { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268879')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [switch]
    ${Passthru})

 
 } 


function Stop-WebAppPool { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268880')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [switch]
    ${Passthru})

 
 } 


function Stop-WebCommitDelay { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268824')]
param(
    [Parameter(Position=2)]
    [bool]
    ${Commit},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})

 
 } 


function Stop-WebItem { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268881')]
param(
    [switch]
    ${Passthru},

    [string]
    ${Protocol},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${PSPath})


dynamicparam
{
    try {
        $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('WebAdministration\Stop-WebItem', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
        $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
        if ($dynamicParams.Length -gt 0)
        {
            $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
            foreach ($param in $dynamicParams)
            {
                $param = $param.Value

                if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name))
                {
                    $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                    $paramDictionary.Add($param.Name, $dynParam)
                }
            }
            return $paramDictionary
        }
    } catch {
        throw
    }
}

 
 } 


function Stop-Website { 
 [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=268882')]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNull()]
    [string]
    ${Name},

    [switch]
    ${Passthru})

 
 } 



