Import-LocalizedData LocalizedData -filename xPDT.strings.psd1

function ThrowInvalidArgumentError
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $errorId,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $errorMessage
    )

    $errorCategory=[System.Management.Automation.ErrorCategory]::InvalidArgument
    $exception = New-Object System.ArgumentException $errorMessage;
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}

function ResolvePath
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path
    )

    $Path = [Environment]::ExpandEnvironmentVariables($Path)
    if(IsRootedPath $Path)
    {
        if(!(Test-Path $Path -PathType Leaf))
        {
            ThrowInvalidArgumentError "CannotFindRootedPath" ($LocalizedData.InvalidArgumentAndMessage -f ($LocalizedData.InvalidArgument -f "Path",$Path), $LocalizedData.FileNotFound)
        }
        return $Path
    }
    else
    {
        $Path = (Get-Item -Path $Path -ErrorAction SilentlyContinue).FullName
        if(!(Test-Path $Path -PathType Leaf))
        {
            ThrowInvalidArgumentError "CannotFindRootedPath" ($LocalizedData.InvalidArgumentAndMessage -f ($LocalizedData.InvalidArgument -f "Path",$Path), $LocalizedData.FileNotFound)
        }
        return $Path
    }
    if([string]::IsNullOrEmpty($env:Path))
    {
        ThrowInvalidArgumentError "EmptyEnvironmentPath" ($LocalizedData.InvalidArgumentAndMessage -f ($LocalizedData.InvalidArgument -f "Path",$Path), $LocalizedData.FileNotFound)
    }
    if((Split-Path $Path -Leaf) -ne $Path)
    {
        ThrowInvalidArgumentError "NotAbsolutePathOrFileName" ($LocalizedData.InvalidArgumentAndMessage -f ($LocalizedData.InvalidArgument -f "Path",$Path), $LocalizedData.AbsolutePathOrFileName)
    }
    foreach($rawSegment in $env:Path.Split(";"))
    {
        $segment = [Environment]::ExpandEnvironmentVariables($rawSegment)
        $segmentRooted = $false
        try
        {
            $segmentRooted=[IO.Path]::IsPathRooted($segment)
        }
        catch {}
        if(!$segmentRooted)
        {
            continue
        }
        $candidate = join-path $segment $Path
        if(Test-Path $candidate -PathType Leaf)
        {
            return $candidate
        }
    }
    ThrowInvalidArgumentError "CannotFindRelativePath" ($LocalizedData.InvalidArgumentAndMessage -f ($LocalizedData.InvalidArgument -f "Path",$Path), $LocalizedData.FileNotFound)
}

function IsRootedPath
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path
    )

    try
    {
        return [IO.Path]::IsPathRooted($Path)
    }
    catch
    {
        ThrowInvalidArgumentError "CannotGetIsPathRooted" ($LocalizedData.InvalidArgumentAndMessage -f ($LocalizedData.InvalidArgument -f "Path",$Path), $_.Exception.Message)
    }
}

function ExtractArguments
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        $functionBoundParameters,
        
        [parameter(Mandatory = $true)]
        [string[]]
        $argumentNames,
        
        [string[]]
        $newArgumentNames
    )

    $returnValue=@{}

    for($i=0;$i -lt $argumentNames.Count;$i++)
    {
        $argumentName = $argumentNames[$i]

        if($newArgumentNames -eq $null)
        {
            $newArgumentName = $argumentName
        }
        else
        {
            $newArgumentName = $newArgumentNames[$i]
        }

        if($functionBoundParameters.ContainsKey($argumentName))
        {
            $null = $returnValue.Add($newArgumentName,$functionBoundParameters[$argumentName])
        }
    }

    return $returnValue
}

function CallPInvoke
{
    $script:ProgramSource = @"
using System;
using System.Collections.Generic;
using System.Text;
using System.Security;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Security.Principal;
using System.ComponentModel;
using System.IO;

namespace Source
{
    [SuppressUnmanagedCodeSecurity]
    public static class NativeMethods
    {
        //The following structs and enums are used by the various Win32 API's that are used in the code below
        
        [StructLayout(LayoutKind.Sequential)]
        public struct STARTUPINFO
        {
            public Int32 cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public Int32 dwX;
            public Int32 dwY;
            public Int32 dwXSize;
            public Int32 dwXCountChars;
            public Int32 dwYCountChars;
            public Int32 dwFillAttribute;
            public Int32 dwFlags;
            public Int16 wShowWindow;
            public Int16 cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public Int32 dwProcessID;
            public Int32 dwThreadID;
        }

        [Flags]
        public enum LogonType
        {
            LOGON32_LOGON_INTERACTIVE = 2,
            LOGON32_LOGON_NETWORK = 3,
            LOGON32_LOGON_BATCH = 4,
            LOGON32_LOGON_SERVICE = 5,
            LOGON32_LOGON_UNLOCK = 7,
            LOGON32_LOGON_NETWORK_CLEARTEXT = 8,
            LOGON32_LOGON_NEW_CREDENTIALS = 9
        }

        [Flags]
        public enum LogonProvider
        {
            LOGON32_PROVIDER_DEFAULT = 0,
            LOGON32_PROVIDER_WINNT35,
            LOGON32_PROVIDER_WINNT40,
            LOGON32_PROVIDER_WINNT50
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct SECURITY_ATTRIBUTES
        {
            public Int32 Length;
            public IntPtr lpSecurityDescriptor;
            public bool bInheritHandle;
        }

        public enum SECURITY_IMPERSONATION_LEVEL
        {
            SecurityAnonymous,
            SecurityIdentification,
            SecurityImpersonation,
            SecurityDelegation
        }

        public enum TOKEN_TYPE
        {
            TokenPrimary = 1,
            TokenImpersonation
        }

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        internal struct TokPriv1Luid
        {
            public int Count;
            public long Luid;
            public int Attr;
        }

        public const int GENERIC_ALL_ACCESS = 0x10000000;
        public const int CREATE_NO_WINDOW = 0x08000000;
        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
        internal const string SE_INCRASE_QUOTA = "SeIncreaseQuotaPrivilege";

        [DllImport("kernel32.dll",
              EntryPoint = "CloseHandle", SetLastError = true,
              CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern bool CloseHandle(IntPtr handle);

        [DllImport("advapi32.dll",
              EntryPoint = "CreateProcessAsUser", SetLastError = true,
              CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern bool CreateProcessAsUser(
            IntPtr hToken, 
            string lpApplicationName, 
            string lpCommandLine,
            ref SECURITY_ATTRIBUTES lpProcessAttributes, 
            ref SECURITY_ATTRIBUTES lpThreadAttributes,
            bool bInheritHandle, 
            Int32 dwCreationFlags, 
            IntPtr lpEnvrionment,
            string lpCurrentDirectory, 
            ref STARTUPINFO lpStartupInfo,
            ref PROCESS_INFORMATION lpProcessInformation
            );

        [DllImport("advapi32.dll", EntryPoint = "DuplicateTokenEx")]
        public static extern bool DuplicateTokenEx(
            IntPtr hExistingToken, 
            Int32 dwDesiredAccess,
            ref SECURITY_ATTRIBUTES lpThreadAttributes,
            Int32 ImpersonationLevel, 
            Int32 dwTokenType,
            ref IntPtr phNewToken
            );

        [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern Boolean LogonUser(
            String lpszUserName,
            String lpszDomain,
            String lpszPassword,
            LogonType dwLogonType,
            LogonProvider dwLogonProvider,
            out IntPtr phToken
            );

        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool AdjustTokenPrivileges(
            IntPtr htok, 
            bool disall,
            ref TokPriv1Luid newst, 
            int len, 
            IntPtr prev, 
            IntPtr relen
            );

        [DllImport("kernel32.dll", ExactSpelling = true)]
        internal static extern IntPtr GetCurrentProcess();

        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool OpenProcessToken(
            IntPtr h, 
            int acc, 
            ref IntPtr phtok
            );

        [DllImport("advapi32.dll", SetLastError = true)]
        internal static extern bool LookupPrivilegeValue(
            string host, 
            string name,
            ref long pluid
            );

        public static void CreateProcessAsUser(string strCommand, string strDomain, string strName, string strPassword)
        {
            var hToken = IntPtr.Zero;
            var hDupedToken = IntPtr.Zero;
            TokPriv1Luid tp;
            var pi = new PROCESS_INFORMATION();
            var sa = new SECURITY_ATTRIBUTES();
            sa.Length = Marshal.SizeOf(sa);
            Boolean bResult = false;
            try
            {
                bResult = LogonUser(
                    strName,
                    strDomain,
                    strPassword,
                    LogonType.LOGON32_LOGON_BATCH,
                    LogonProvider.LOGON32_PROVIDER_DEFAULT,
                    out hToken
                    );
                if (!bResult) 
                { 
                    throw new Win32Exception("The user could not be logged on. Ensure that the user has an existing profile on the machine and that correct credentials are provided. Logon error #" + Marshal.GetLastWin32Error().ToString()); 
                }
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                bResult = OpenProcessToken(
                        hproc, 
                        TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, 
                        ref htok
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Open process token error #" + Marshal.GetLastWin32Error().ToString());
                }
                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_ENABLED;
                bResult = LookupPrivilegeValue(
                    null, 
                    SE_INCRASE_QUOTA, 
                    ref tp.Luid
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Error in looking up privilege of the process. This should not happen if DSC is running as LocalSystem Lookup privilege error #" + Marshal.GetLastWin32Error().ToString());
                }
                bResult = AdjustTokenPrivileges(
                    htok, 
                    false, 
                    ref tp, 
                    0, 
                    IntPtr.Zero, 
                    IntPtr.Zero
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Token elevation error #" + Marshal.GetLastWin32Error().ToString());
                }
                
                bResult = DuplicateTokenEx(
                    hToken,
                    GENERIC_ALL_ACCESS,
                    ref sa,
                    (int)SECURITY_IMPERSONATION_LEVEL.SecurityIdentification,
                    (int)TOKEN_TYPE.TokenPrimary,
                    ref hDupedToken
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Duplicate Token error #" + Marshal.GetLastWin32Error().ToString());
                }
                var si = new STARTUPINFO();
                si.cb = Marshal.SizeOf(si);
                si.lpDesktop = "";
                bResult = CreateProcessAsUser(
                    hDupedToken,
                    null,
                    strCommand,
                    ref sa, 
                    ref sa,
                    false, 
                    0, 
                    IntPtr.Zero,
                    null, 
                    ref si, 
                    ref pi
                    );
                if(!bResult)
                {
                    throw new Win32Exception("The process could not be created. Create process as user error #" + Marshal.GetLastWin32Error().ToString());
                }
            }
            finally
            {
                if (pi.hThread != IntPtr.Zero)
                {
                    CloseHandle(pi.hThread);
                }
                if (pi.hProcess != IntPtr.Zero)
                {
                    CloseHandle(pi.hProcess);
                }
                 if (hDupedToken != IntPtr.Zero)
                {
                    CloseHandle(hDupedToken);
                }
            }
        }
    }
}

"@
    Add-Type -TypeDefinition $ProgramSource -ReferencedAssemblies "System.ServiceProcess"
}

function GetWin32Process
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [String]
        $Arguments,

        [PSCredential]
        $Credential
    )

    $fileName = [io.path]::GetFileNameWithoutExtension($Path)
    $GetProcesses = @(Get-Process -Name $fileName -ErrorAction SilentlyContinue)
    $Processes = foreach($process in $GetProcesses)
    {
        if($Process.Path -ieq $Path)
        {
            try
            {
                [wmi]"Win32_Process.Handle='$($Process.Id)'"
            }
            catch
            {
            }
        }
    }
    if($PSBoundParameters.ContainsKey('Credential'))
    {
        $Processes = $Processes | Where-Object {(GetWin32ProcessOwner $_) -eq $Credential.UserName}
    }
    if($Arguments -eq $null) {$Arguments = ""}
    $Processes = $Processes | Where-Object {(GetWin32ProcessArgumentsFromCommandLine $_.CommandLine) -eq $Arguments}

    return $Processes
}

function GetWin32ProcessOwner
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNull()]
        $Process
    )

    try
    {
        $Owner = $Process.GetOwner()
    }
    catch
    {}
    if(($owner.Domain -ne $null) -and ($owner.Domain -ne $env:COMPUTERNAME))
    {
        return $Owner.Domain + "\" + $Owner.User
    }
    else                
    {
        return $Owner.User
    }
}

function GetWin32ProcessArgumentsFromCommandLine
{
    param
    (
        [String]
        $commandLine
    )

    if($commandLine -eq $null)
    {
        return ""
    }
    $commandLine=$commandLine.Trim()
    if($commandLine.Length -eq 0)
    {
        return ""
    }
    if($commandLine[0] -eq '"')
    {
        $charToLookfor=[char]'"'
    }
    else
    {
        $charToLookfor=[char]' '
    }
    $endOfCommand=$commandLine.IndexOf($charToLookfor ,1)
    if($endOfCommand -eq -1)
    {
        return ""
    }
    return $commandLine.Substring($endOfCommand+1).Trim()
}

function StartWin32Process
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [String]
        $Arguments,

        [PSCredential]
        $Credential,

        [Switch]
        $AsTask
    )

    $GetArguments = ExtractArguments $PSBoundParameters ("Path","Arguments","Credential")
    $Processes = @(GetWin32Process @getArguments)
    if ($processes.Count -eq 0)
    {
        if($PSBoundParameters.ContainsKey("Credential"))
        {
            if($AsTask)
            {
                $ActionArguments = ExtractArguments $PSBoundParameters `
                        ("Path",    "Arguments") `
                        ("Execute", "Argument")
                if([string]::IsNullOrEmpty($Arguments))
                {
                    $null = $ActionArguments.Remove("Argument")
                }
                $TaskGuid = [guid]::NewGuid().ToString()
                $Action = New-ScheduledTaskAction @ActionArguments
                $null = Register-ScheduledTask -TaskName "xPDT $TaskGuid" -Action $Action -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password -RunLevel Highest
                $err = Start-ScheduledTask -TaskName "xPDT $TaskGuid"
            }
            else
            {
                try
                {
                    CallPInvoke
                    [Source.NativeMethods]::CreateProcessAsUser(("$Path " + $Arguments),$Credential.GetNetworkCredential().Domain,$Credential.GetNetworkCredential().UserName,$Credential.GetNetworkCredential().Password)
                }
                catch
                {
                    $exception = New-Object System.ArgumentException $_
                    $errorCategory = [System.Management.Automation.ErrorCategory]::OperationStopped
                    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, "Win32Exception", $errorCategory, $null
                    $err = $errorRecord
                }
            }
        }
        else
        {
            $StartArguments = ExtractArguments $PSBoundParameters `
                    ("Path",     "Arguments",    "Credential") `
                    ("FilePath", "ArgumentList", "Credential")
            if([string]::IsNullOrEmpty($Arguments))
            {
                $null = $StartArguments.Remove("ArgumentList")
            }
            $err = Start-Process @StartArguments
        }
        if($err -ne $null)
        {
            throw $err
        }
        if (!(WaitForWin32ProcessStart @GetArguments))
        {
#            ThrowInvalidArgumentError "FailureWaitingForProcessesToStart" ($LocalizedData.ErrorStarting -f $Path,$LocalizedData.FailureWaitingForProcessesToStart)
        }
    }
    else
    {
        return ($LocalizedData.ProcessAlreadyStarted -f $Path,$Processes.ProcessId)
    }
    $Processes = @(GetWin32Process @getArguments)
    return ($LocalizedData.ProcessStarted -f $Path,$Processes.ProcessId)
}

function WaitForWin32ProcessStart
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [String]
        $Arguments,

        [PSCredential]
        $Credential,

        [Int]
        $Delay = 60000
    )

    $start = [DateTime]::Now
    $GetArguments = ExtractArguments $PSBoundParameters ("Path","Arguments","Credential")
    do
    {
        $value = @(GetWin32Process @GetArguments).Count -ge 1
    } while(!$value -and ([DateTime]::Now - $start).TotalMilliseconds -lt $Delay)
    
    return $value
}

function WaitForWin32ProcessEnd
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [String]
        $Arguments,

        [PSCredential]
        $Credential
    )

    $GetArguments = ExtractArguments $PSBoundParameters ("Path","Arguments","Credential")
    While (WaitForWin32ProcessStart @GetArguments -Delay 1000)
    {
        Start-Sleep 1
    }
    Get-ScheduledTask | Where-Object {($_.TaskName.StartsWith("xPDT")) -and ($_.Actions.Execute -eq $Path) -and ($_.Actions.Arguments -eq $Arguments)} | Where-Object {$_ -ne $null} | Unregister-ScheduledTask -Confirm:$false
}

function NetUse
{
    param
    (   
        [parameter(Mandatory)]
        [string]
        $SourcePath,
        
        [parameter(Mandatory)]
        [PSCredential]
        $Credential,
        
        [string]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present"
    )

    if(($SourcePath.Length -ge 2) -and ($SourcePath.Substring(0,2) -eq "\\"))
    {
        $args = @()
        if ($Ensure -eq "Absent")
        {
            $args += "use", $SourcePath, "/del"
        }
        else 
        {
            $args += "use", $SourcePath, $($Credential.GetNetworkCredential().Password), "/user:$($Credential.GetNetworkCredential().Domain)\$($Credential.GetNetworkCredential().UserName)"
        }

        &"net" $args
    }
}

function GetxPDTVariable
{
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Component,

        [parameter(Mandatory = $true)]
        [System.String]
        $Version,

        [parameter(Mandatory = $true)]
        [System.String]
        $Role,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,
        
        [System.String]
        $Update = "Latest"
    )

    $xPDT = [XML](Get-Content "$PSScriptRoot\xPDT.xml")
    $xPDT.SelectSingleNode("//xPDT/Component[@Name='$Component' and @Version='$Version']/Role[@Name='$Role']/Update[@Name='$Update']/Variable[@Name='$Name']").Value
}

Export-ModuleMember ResolvePath,StartWin32Process,WaitForWin32ProcessEnd,NetUse,GetxPDTVariable
