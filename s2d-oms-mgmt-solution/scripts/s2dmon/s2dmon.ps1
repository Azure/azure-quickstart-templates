###############################################################################
#                                                                             #
#   File name       PSService.ps1                                             #
#                                                                             #
#   Description     A sample service in a standalone PowerShell script        #
#                                                                             #
#   Notes           The latest PSService.ps1 version is available in GitHub   #
#                   repository https://github.com/JFLarvoire/SysToolsLib/ ,   #
#                   in the PowerShell subdirectory.                           #
#                   Please report any problem in the Issues tab in that       #
#                   GitHub repository in                                      #
#                   https://github.com/JFLarvoire/SysToolsLib/issues	      #
#                   If you do submit a pull request, please add a comment at  #
#                   the end of this header with the date, your initials, and  #
#		    a description of the changes. Also update $scriptVersion. #
#                                                                             #
#                   The initial version of this script was described in an    #
#                   article published in the May 2016 issue of MSDN Magazine. #
#                   https://msdn.microsoft.com/en-us/magazine/mt703436.aspx   #
#                   This updated version has one major change:                #
#                   The -Service handler in the end has been rewritten to be  #
#                   event-driven, with a second thread waiting for control    #
#                   messages coming in via a named pipe.                      #
#                   This allows fixing a bug of the original version, that    #
#                   did not stop properly, and left a zombie process behind.  #
#                   The drawback is that the new code is significantly longer,#
#                   due to the added PowerShell thread management routines.   #
#                   On the other hand, these thread management routines are   #
#                   reusable, and will allow building much more powerful      #
#                   services.                                                 #
#                                                                             #
#                   Dynamically generates a small PSService.exe wrapper       #
#                   application, that in turn invokes this PowerShell script. #
#                                                                             #
#                   Some arguments are inspired by Linux' service management  #
#                   arguments: -Start, -Stop, -Restart, -Status               #
#                   Others are more in the Windows' style: -Setup, -Remove    #
#                                                                             #
#                   The actual start and stop operations are done when        #
#                   running as SYSTEM, under the control of the SCM (Service  #
#                   Control Manager).                                         #
#                                                                             #
#                   To create your own service, make a copy of this file and  #
#                   rename it. The file base name becomes the service name.   #
#                   Then implement your own service code in the if ($Service) #
#                   {block} at the very end of this file. See the TO DO       #
#                   comment there.                                            #
#                   There are global settings below the script param() block. #
#                   They can easily be changed, but the defaults should be    #
#                   suitable for most projects.                               #
#                                                                             #
#                   Service installation and usage: See the dynamic help      #
#                   section below, or run: help .\PSService.ps1 -Detailed     #
#                                                                             #
#   History                                                                   #
#    2015-07-10 JFL jf.larvoire@hpe.com created this script.                  #
#    2015-10-13 JFL Made this script completely generic, and added comments   #
#                   in the header above.                                      #
#    2016-01-02 JFL Moved the Event Log name into new variable $logName.      #
#                   Improved comments.                                        #
#    2016-01-05 JFL Fixed the StartPending state reporting.                   #
#    2016-03-17 JFL Removed aliases. Added missing explicit argument names.   #
#    2016-04-16 JFL Moved the official repository on GitHub.                  #
#    2016-04-21 JFL Minor bug fix: New-EventLog did not use variable $logName.#
#    2016-05-25 JFL Bug fix: The service task was not properly stopped; Its   #
#                   finally block was not executed, and a zombie task often   #
#                   remained. Fixed by using a named pipe to send messages    #
#                   to the service task.                                      #
#    2016-06-05 JFL Finalized the event-driven service handler.               #
#                   Fixed the default command setting in PowerShell v2.       #
#                   Added a sample -Control option using the new pipe.        #
#    2016-06-08 JFL Rewrote the pipe handler using PSThreads instead of Jobs. #
#    2016-06-09 JFL Finalized the PSThread management routines error handling.#
#                   This finally fixes issue #1.                              #
#    2016-08-22 JFL Fixed issue #3 creating the log and install directories.  #
#		    Thanks Nischl.					      #
#    2016-09-06 JFL Fixed issue #4 detecting the System account. Now done in  #
#		    a language-independent way. Thanks A Gonzalez.	      #
#    2016-09-19 JFL Fixed issue #5 starting services that begin with a number.#
#                   Added a $ServiceDescription string global setting, and    #
#                   use it for the service registration.                      #
#                   Added comments about Windows event logs limitations.      #
#    2016-11-17 RBM Fixed issue #6 Mangled hyphen in final Unregister-Event.  #
#                                                                             #
###############################################################################
#Requires -version 2

<#
  .SYNOPSIS
    A sample Windows service, in a standalone PowerShell script.

  .DESCRIPTION
    This script demonstrates how to write a Windows service in pure PowerShell.
    It dynamically generates a small PSService.exe wrapper, that in turn
    invokes this PowerShell script again for its start and stop events.

  .PARAMETER Start
    Start the service.

  .PARAMETER Stop
    Stop the service.

  .PARAMETER Restart
    Stop then restart the service.

  .PARAMETER Status
    Get the current service status: Not installed / Stopped / Running

  .PARAMETER Setup
    Install the service.

  .PARAMETER Remove
    Uninstall the service.

  .PARAMETER Service
    Run the service in the background. Used internally by the script.
    Do not use, except for test purposes.

  .PARAMETER Control
    Send a control message to the service thread.

  .PARAMETER Version
    Display this script version and exit.

  .EXAMPLE
    # Setup the service and run it for the first time
    C:\PS>.\PSService.ps1 -Status
    Not installed
    C:\PS>.\PSService.ps1 -Setup
    C:\PS># At this stage, a copy of PSService.ps1 is present in the path
    C:\PS>PSService -Status
    Stopped
    C:\PS>PSService -Start
    C:\PS>PSService -Status
    Running
    C:\PS># Load the log file in Notepad.exe for review
    C:\PS>notepad ${ENV:windir}\Logs\PSService.log

  .EXAMPLE
    # Stop the service and uninstall it.
    C:\PS>PSService -Stop
    C:\PS>PSService -Status
    Stopped
    C:\PS>PSService -Remove
    C:\PS># At this stage, no copy of PSService.ps1 is present in the path anymore
    C:\PS>.\PSService.ps1 -Status
    Not installed

  .EXAMPLE
    # Send a control message to the service, and verify that it received it.
    C:\PS>PSService -Control Hello
    C:\PS>Notepad C:\Windows\Logs\PSService.log
    # The last lines should contain a trace of the reception of this Hello message
#>

[CmdletBinding(DefaultParameterSetName='Status')]
Param(
  [Parameter(ParameterSetName='Start', Mandatory=$true)]
  [Switch]$Start,               # Start the service

  [Parameter(ParameterSetName='Stop', Mandatory=$true)]
  [Switch]$Stop,                # Stop the service

  [Parameter(ParameterSetName='Restart', Mandatory=$true)]
  [Switch]$Restart,             # Restart the service

  [Parameter(ParameterSetName='Status', Mandatory=$false)]
  [Switch]$Status = $($PSCmdlet.ParameterSetName -eq 'Status'), # Get the current service status

  [Parameter(ParameterSetName='Setup', Mandatory=$true)]
  [Switch]$Setup,               # Install the service

  [Parameter(ParameterSetName='Setup', Mandatory=$true)]
  [System.Management.Automation.CredentialAttribute()]$OMSWorkspaceCreds,

  [Parameter(ParameterSetName='Remove', Mandatory=$true)]
  [Switch]$Remove,              # Uninstall the service

  [Parameter(ParameterSetName='Service', Mandatory=$true)]
  [Switch]$Service,             # Run the service

  [Parameter(ParameterSetName='Control', Mandatory=$true)]
  [String]$Control = $null,     # Control message to send to the service

  [Parameter(ParameterSetName='Version', Mandatory=$true)]
  [Switch]$Version              # Get this script version
)

$scriptVersion = "2016-11-17"

# This script name, with various levels of details
$argv0 = Get-Item $MyInvocation.MyCommand.Definition
$script = $argv0.basename               # Ex: PSService
$scriptName = $argv0.name               # Ex: PSService.ps1
$scriptFullName = $argv0.fullname       # Ex: C:\Temp\PSService.ps1

# Global settings
$serviceName = $script                  # A one-word name used for net start commands
$serviceDisplayName = "S2DMon"
$ServiceDescription = "Service for sending S2D data to OMS"
$pipeName = "Service_$serviceName"      # Named pipe name. Used for sending messages to the service task
# $installDir = "${ENV:ProgramFiles}\$serviceName" # Where to install the service files
$installDir = "${ENV:windir}\System32"  # Where to install the service files
$scriptCopy = "$installDir\$scriptName"
$exeName = "$serviceName.exe"
$exeFullName = "$installDir\$exeName"
# Variables for Key File
$KeyFileName = "$serviceName.key"
$KeyFileFullName = "$installDir\$KeyFileName"
# Variables for Workspace Key file
$credFileName = "$serviceName.cred"
$credFileFullName = "$installDir\$credFileName"
# Variables for Workspace ID file
$workspaceIdFileName = "$serviceName.id"
$workspaceIdFileFullName = "$installDir\$workspaceIdFileName"
$logDir = "${ENV:windir}\Logs"          # Where to log the service messages
$logFile = "$logDir\$serviceName.log"
$logName = "Application"                # Event Log name (Unrelated to the logFile!)
# Note: The current implementation only supports "classic" (ie. XP-compatble) event logs.
#	To support new style (Vista and later) "Applications and Services Logs" folder trees, it would
#	be necessary to use the new *WinEvent commands instead of the XP-compatible *EventLog commands.
# Gotcha: If you change $logName to "NEWLOGNAME", make sure that the registry key below does not exist:
#         HKLM\System\CurrentControlSet\services\eventlog\Application\NEWLOGNAME
#	  Else, New-EventLog will fail, saying the log NEWLOGNAME is already registered as a source,
#	  even though "Get-WinEvent -ListLog NEWLOGNAME" says this log does not exist!

# If the -Version switch is specified, display the script version and exit.
if ($Version) {
  Write-Output $scriptVersion
  return
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Now                                                       #
#                                                                             #
#   Description     Get a string with the current time.                       #
#                                                                             #
#   Notes           The output string is in the ISO 8601 format, except for   #
#                   a space instead of a T between the date and time, to      #
#                   improve the readability.                                  #
#                                                                             #
#   History                                                                   #
#    2015-06-11 JFL Created this routine.                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Now {
  Param (
    [Switch]$ms,        # Append milliseconds
    [Switch]$ns         # Append nanoseconds
  )
  $Date = Get-Date
  $now = ""
  $now += "{0:0000}-{1:00}-{2:00} " -f $Date.Year, $Date.Month, $Date.Day
  $now += "{0:00}:{1:00}:{2:00}" -f $Date.Hour, $Date.Minute, $Date.Second
  $nsSuffix = ""
  if ($ns) {
    if ("$($Date.TimeOfDay)" -match "\.\d\d\d\d\d\d") {
      $now += $matches[0]
      $ms = $false
    } else {
      $ms = $true
      $nsSuffix = "000"
    }
  } 
  if ($ms) {
    $now += ".{0:000}$nsSuffix" -f $Date.MilliSecond
  }
  return $now
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Log                                                       #
#                                                                             #
#   Description     Log a string into the PSService.log file                  #
#                                                                             #
#   Arguments       A string                                                  #
#                                                                             #
#   Notes           Prefixes the string with a timestamp and the user name.   #
#                   (Except if the string is empty: Then output a blank line.)#
#                                                                             #
#   History                                                                   #
#    2016-06-05 JFL Also prepend the Process ID.                              #
#    2016-06-08 JFL Allow outputing blank lines.                              #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Log () {
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [String]$string
  )
  if (!(Test-Path $logDir)) {
    New-Item -ItemType directory -Path $logDir | Out-Null
  }
  if ($String.length) {
    $string = "$(Now) $pid $userName $string"
  }
  $string | Out-File -Encoding ASCII -Append "$logFile"
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Start-PSThread                                            #
#                                                                             #
#   Description     Start a new PowerShell thread                             #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes           Returns a thread description object.                      #
#                   The completion can be tested in $_.Handle.IsCompleted     #
#                   Alternative: Use a thread completion event.               #
#                                                                             #
#   References                                                                #
#    https://learn-powershell.net/tag/runspace/                               #
#    https://learn-powershell.net/2013/04/19/sharing-variables-and-live-objects-between-powershell-runspaces/
#    http://www.codeproject.com/Tips/895840/Multi-Threaded-PowerShell-Cookbook
#                                                                             #
#   History                                                                   #
#    2016-06-08 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

$PSThreadCount = 0              # Counter of PSThread IDs generated so far
$PSThreadList = @{}             # Existing PSThreads indexed by Id

Function Get-PSThread () {
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [int[]]$Id = $PSThreadList.Keys     # List of thread IDs
  )
  $Id | % { $PSThreadList.$_ }
}

Function Start-PSThread () {
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    [ScriptBlock]$ScriptBlock,          # The script block to run in a new thread
    [Parameter(Mandatory=$false)]
    [String]$Name = "",                 # Optional thread name. Default: "PSThread$Id"
    [Parameter(Mandatory=$false)]
    [String]$Event = "",                # Optional thread completion event name. Default: None
    [Parameter(Mandatory=$false)]
    [Hashtable]$Variables = @{},        # Optional variables to copy into the script context.
    [Parameter(Mandatory=$false)]
    [String[]]$Functions = @(),         # Optional functions to copy into the script context.
    [Parameter(Mandatory=$false)]
    [Object[]]$Arguments = @()          # Optional arguments to pass to the script.
  )

  $Id = $script:PSThreadCount
  $script:PSThreadCount += 1
  if (!$Name.Length) {
    $Name = "PSThread$Id"
  }
  $InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
  foreach ($VarName in $Variables.Keys) { # Copy the specified variables into the script initial context
    $value = $Variables.$VarName
    Write-Debug "Adding variable $VarName=[$($Value.GetType())]$Value"
    $var = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($VarName, $value, "")
    $InitialSessionState.Variables.Add($var)
  }
  foreach ($FuncName in $Functions) { # Copy the specified functions into the script initial context
    $Body = Get-Content function:$FuncName
    Write-Debug "Adding function $FuncName () {$Body}"
    $func = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry($FuncName, $Body)
    $InitialSessionState.Commands.Add($func)
  }
  $RunSpace = [RunspaceFactory]::CreateRunspace($InitialSessionState)
  $RunSpace.Open()
  $PSPipeline = [powershell]::Create()
  $PSPipeline.Runspace = $RunSpace
  $PSPipeline.AddScript($ScriptBlock) | Out-Null
  $Arguments | % {
    Write-Debug "Adding argument [$($_.GetType())]'$_'"
    $PSPipeline.AddArgument($_) | Out-Null
  }
  $Handle = $PSPipeline.BeginInvoke() # Start executing the script
  if ($Event.Length) { # Do this after BeginInvoke(), to avoid getting the start event.
    Register-ObjectEvent $PSPipeline -EventName InvocationStateChanged -SourceIdentifier $Name -MessageData $Event
  }
  $PSThread = New-Object PSObject -Property @{
    Id = $Id
    Name = $Name
    Event = $Event
    RunSpace = $RunSpace
    PSPipeline = $PSPipeline
    Handle = $Handle
  }     # Return the thread description variables
  $script:PSThreadList[$Id] = $PSThread
  $PSThread
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Receive-PSThread                                          #
#                                                                             #
#   Description     Get the result of a thread, and optionally clean it up    #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#    2016-06-08 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Receive-PSThread () {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [PSObject]$PSThread,                # Thread descriptor object
    [Parameter(Mandatory=$false)]
    [Switch]$AutoRemove                 # If $True, remove the PSThread object
  )
  Process {
    if ($PSThread.Event -and $AutoRemove) {
      Unregister-Event -SourceIdentifier $PSThread.Name
      Get-Event -SourceIdentifier $PSThread.Name | Remove-Event # Flush remaining events
    }
    try {
      $PSThread.PSPipeline.EndInvoke($PSThread.Handle) # Output the thread pipeline output
    } catch {
      $_ # Output the thread pipeline error
    }
    if ($AutoRemove) {
      $PSThread.RunSpace.Close()
      $PSThread.PSPipeline.Dispose()
      $PSThreadList.Remove($PSThread.Id)
    }
  }
}

Function Remove-PSThread () {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
    [PSObject]$PSThread                 # Thread descriptor object
  )
  Process {
    $_ | Receive-PSThread -AutoRemove | Out-Null
  }
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Send-PipeMessage                                          #
#                                                                             #
#   Description     Send a message to a named pipe                            #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#    2016-05-25 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Send-PipeMessage () {
  Param(
    [Parameter(Mandatory=$true)]
    [String]$PipeName,          # Named pipe name
    [Parameter(Mandatory=$true)]
    [String]$Message            # Message string
  )
  $PipeDir  = [System.IO.Pipes.PipeDirection]::Out
  $PipeOpt  = [System.IO.Pipes.PipeOptions]::Asynchronous

  $pipe = $null # Named pipe stream
  $sw = $null   # Stream Writer
  try {
    $pipe = new-object System.IO.Pipes.NamedPipeClientStream(".", $PipeName, $PipeDir, $PipeOpt)
    $sw = new-object System.IO.StreamWriter($pipe)
    $pipe.Connect(1000)
    if (!$pipe.IsConnected) {
      throw "Failed to connect client to pipe $pipeName"
    }
    $sw.AutoFlush = $true
    $sw.WriteLine($Message)
  } catch {
    Log "Error sending pipe $pipeName message: $_"
  } finally {
    if ($sw) {
      $sw.Dispose() # Release resources
      $sw = $null   # Force the PowerShell garbage collector to delete the .net object
    }
    if ($pipe) {
      $pipe.Dispose() # Release resources
      $pipe = $null   # Force the PowerShell garbage collector to delete the .net object
    }
  }
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Receive-PipeMessage                                       #
#                                                                             #
#   Description     Wait for a message from a named pipe                      #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes           I tried keeping the pipe open between client connections, #
#                   but for some reason everytime the client closes his end   #
#                   of the pipe, this closes the server end as well.          #
#                   Any solution on how to fix this would make the code       #
#                   more efficient.                                           #
#                                                                             #
#   History                                                                   #
#    2016-05-25 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Receive-PipeMessage () {
  Param(
    [Parameter(Mandatory=$true)]
    [String]$PipeName           # Named pipe name
  )
  $PipeDir  = [System.IO.Pipes.PipeDirection]::In
  $PipeOpt  = [System.IO.Pipes.PipeOptions]::Asynchronous
  $PipeMode = [System.IO.Pipes.PipeTransmissionMode]::Message

  try {
    $pipe = $null       # Named pipe stream
    $pipe = New-Object system.IO.Pipes.NamedPipeServerStream($PipeName, $PipeDir, 1, $PipeMode, $PipeOpt)
    $sr = $null         # Stream Reader
    $sr = new-object System.IO.StreamReader($pipe)
    $pipe.WaitForConnection()
    $Message = $sr.Readline()
    $Message
  } catch {
    Log "Error receiving pipe message: $_"
  } finally {
    if ($sr) {
      $sr.Dispose() # Release resources
      $sr = $null   # Force the PowerShell garbage collector to delete the .net object
    }
    if ($pipe) {
      $pipe.Dispose() # Release resources
      $pipe = $null   # Force the PowerShell garbage collector to delete the .net object
    }
  }
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Start-PipeHandlerThread                                   #
#                                                                             #
#   Description     Start a new thread waiting for control messages on a pipe #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes           The pipe handler script uses function Receive-PipeMessage.#
#                   This function must be copied into the thread context.     #
#                                                                             #
#                   The other functions and variables copied into that thread #
#                   context are not strictly necessary, but are useful for    #
#                   debugging possible issues.                                #
#                                                                             #
#   History                                                                   #
#    2016-06-07 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

$pipeThreadName = "Control Pipe Handler"

Function Start-PipeHandlerThread () {
  Param(
    [Parameter(Mandatory=$true)]
    [String]$pipeName,                  # Named pipe name
    [Parameter(Mandatory=$false)]
    [String]$Event = "ControlMessage"   # Event message
  )
  Start-PSThread -Variables @{  # Copy variables required by function Log() into the thread context
    logDir = $logDir
    logFile = $logFile
    userName = $userName
  } -Functions Now, Log, Receive-PipeMessage -ScriptBlock {
    Param($pipeName, $pipeThreadName)
    try {
      Receive-PipeMessage "$pipeName" # Blocks the thread until the next message is received from the pipe
    } catch {
      Log "$pipeThreadName # Error: $_"
      throw $_ # Push the error back to the main thread
    }
  } -Name $pipeThreadName -Event $Event -Arguments $pipeName, $pipeThreadName
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Receive-PipeHandlerThread                                 #
#                                                                             #
#   Description     Get what the pipe handler thread received                 #
#                                                                             #
#   Arguments       See the Param() block                                     #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#    2016-06-07 JFL Created this function                                     #
#                                                                             #
#-----------------------------------------------------------------------------#

Function Receive-PipeHandlerThread () {
  Param(
    [Parameter(Mandatory=$true)]
    [PSObject]$pipeThread               # Thread descriptor
  )
  Receive-PSThread -PSThread $pipeThread -AutoRemove
}

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        $source                                                   #
#                                                                             #
#   Description     C# source of the PSService.exe stub                       #
#                                                                             #
#   Arguments                                                                 #
#                                                                             #
#   Notes           The lines commented with "SET STATUS" and "EVENT LOG" are #
#                   optional. (Or blocks between "// SET STATUS [" and        #
#                   "// SET STATUS ]" comments.)                              #
#                   SET STATUS lines are useful only for services with a long #
#                   startup time.                                             #
#                   EVENT LOG lines are useful for debugging the service.     #
#                                                                             #
#   History                                                                   #
#                                                                             #
#-----------------------------------------------------------------------------#

$scriptCopyCname = $scriptCopy -replace "\\", "\\" # Double backslashes. (The first \\ is a regexp with \ escaped; The second is a plain string.)
$source = @"
  using System;
  using System.ServiceProcess;
  using System.Diagnostics;
  using System.Runtime.InteropServices;                                 // SET STATUS
  using System.ComponentModel;                                          // SET STATUS

  public enum ServiceType : int {                                       // SET STATUS [
    SERVICE_WIN32_OWN_PROCESS = 0x00000010,
    SERVICE_WIN32_SHARE_PROCESS = 0x00000020,
  };                                                                    // SET STATUS ]

  public enum ServiceState : int {                                      // SET STATUS [
    SERVICE_STOPPED = 0x00000001,
    SERVICE_START_PENDING = 0x00000002,
    SERVICE_STOP_PENDING = 0x00000003,
    SERVICE_RUNNING = 0x00000004,
    SERVICE_CONTINUE_PENDING = 0x00000005,
    SERVICE_PAUSE_PENDING = 0x00000006,
    SERVICE_PAUSED = 0x00000007,
  };                                                                    // SET STATUS ]

  [StructLayout(LayoutKind.Sequential)]                                 // SET STATUS [
  public struct ServiceStatus {
    public ServiceType dwServiceType;
    public ServiceState dwCurrentState;
    public int dwControlsAccepted;
    public int dwWin32ExitCode;
    public int dwServiceSpecificExitCode;
    public int dwCheckPoint;
    public int dwWaitHint;
  };                                                                    // SET STATUS ]

  public enum Win32Error : int { // WIN32 errors that we may need to use
    NO_ERROR = 0,
    ERROR_APP_INIT_FAILURE = 575,
    ERROR_FATAL_APP_EXIT = 713,
    ERROR_SERVICE_NOT_ACTIVE = 1062,
    ERROR_EXCEPTION_IN_SERVICE = 1064,
    ERROR_SERVICE_SPECIFIC_ERROR = 1066,
    ERROR_PROCESS_ABORTED = 1067,
  };

  public class Service_$serviceName : ServiceBase { // $serviceName may begin with a digit; The class name must begin with a letter
    private System.Diagnostics.EventLog eventLog;                       // EVENT LOG
    private ServiceStatus serviceStatus;                                // SET STATUS

    public Service_$serviceName() {
      ServiceName = "$serviceName";
      CanStop = true;
      CanPauseAndContinue = false;
      AutoLog = true;

      eventLog = new System.Diagnostics.EventLog();                     // EVENT LOG [
      if (!System.Diagnostics.EventLog.SourceExists(ServiceName)) {         
        System.Diagnostics.EventLog.CreateEventSource(ServiceName, "$logName");
      }
      eventLog.Source = ServiceName;
      eventLog.Log = "$logName";                                        // EVENT LOG ]
      EventLog.WriteEntry(ServiceName, "$exeName $serviceName()");      // EVENT LOG
    }

    [DllImport("advapi32.dll", SetLastError=true)]                      // SET STATUS
    private static extern bool SetServiceStatus(IntPtr handle, ref ServiceStatus serviceStatus);

    protected override void OnStart(string [] args) {
      EventLog.WriteEntry(ServiceName, "$exeName OnStart() // Entry. Starting script '$scriptCopyCname' -Start"); // EVENT LOG
      // Set the service state to Start Pending.                        // SET STATUS [
      // Only useful if the startup time is long. Not really necessary here for a 2s startup time.
      serviceStatus.dwServiceType = ServiceType.SERVICE_WIN32_OWN_PROCESS;
      serviceStatus.dwCurrentState = ServiceState.SERVICE_START_PENDING;
      serviceStatus.dwWin32ExitCode = 0;
      serviceStatus.dwWaitHint = 2000; // It takes about 2 seconds to start PowerShell
      SetServiceStatus(ServiceHandle, ref serviceStatus);               // SET STATUS ]
      // Start a child process with another copy of this script
      try {
        Process p = new Process();
        // Redirect the output stream of the child process.
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.FileName = "PowerShell.exe";
        p.StartInfo.Arguments = "-c & '$scriptCopyCname' -Start"; // Works if path has spaces, but not if it contains ' quotes.
        p.Start();
        // Read the output stream first and then wait. (To avoid deadlocks says Microsoft!)
        string output = p.StandardOutput.ReadToEnd();
        // Wait for the completion of the script startup code, that launches the -Service instance
        p.WaitForExit();
        if (p.ExitCode != 0) throw new Win32Exception((int)(Win32Error.ERROR_APP_INIT_FAILURE));
        // Success. Set the service state to Running.                   // SET STATUS
        serviceStatus.dwCurrentState = ServiceState.SERVICE_RUNNING;    // SET STATUS
      } catch (Exception e) {
        EventLog.WriteEntry(ServiceName, "$exeName OnStart() // Failed to start $scriptCopyCname. " + e.Message, EventLogEntryType.Error); // EVENT LOG
        // Change the service state back to Stopped.                    // SET STATUS [
        serviceStatus.dwCurrentState = ServiceState.SERVICE_STOPPED;
        Win32Exception w32ex = e as Win32Exception; // Try getting the WIN32 error code
        if (w32ex == null) { // Not a Win32 exception, but maybe the inner one is...
          w32ex = e.InnerException as Win32Exception;
        }    
        if (w32ex != null) {    // Report the actual WIN32 error
          serviceStatus.dwWin32ExitCode = w32ex.NativeErrorCode;
        } else {                // Make up a reasonable reason
          serviceStatus.dwWin32ExitCode = (int)(Win32Error.ERROR_APP_INIT_FAILURE);
        }                                                               // SET STATUS ]
      } finally {
        serviceStatus.dwWaitHint = 0;                                   // SET STATUS
        SetServiceStatus(ServiceHandle, ref serviceStatus);             // SET STATUS
        EventLog.WriteEntry(ServiceName, "$exeName OnStart() // Exit"); // EVENT LOG
      }
    }

    protected override void OnStop() {
      EventLog.WriteEntry(ServiceName, "$exeName OnStop() // Entry");   // EVENT LOG
      // Start a child process with another copy of ourselves
      Process p = new Process();
      // Redirect the output stream of the child process.
      p.StartInfo.UseShellExecute = false;
      p.StartInfo.RedirectStandardOutput = true;
      p.StartInfo.FileName = "PowerShell.exe";
      p.StartInfo.Arguments = "-c & '$scriptCopyCname' -Stop"; // Works if path has spaces, but not if it contains ' quotes.
      p.Start();
      // Read the output stream first and then wait.
      string output = p.StandardOutput.ReadToEnd();
      // Wait for the PowerShell script to be fully stopped.
      p.WaitForExit();
      // Change the service state back to Stopped.                      // SET STATUS
      serviceStatus.dwCurrentState = ServiceState.SERVICE_STOPPED;      // SET STATUS
      SetServiceStatus(ServiceHandle, ref serviceStatus);               // SET STATUS
      EventLog.WriteEntry(ServiceName, "$exeName OnStop() // Exit");    // EVENT LOG
    }

    public static void Main() {
      System.ServiceProcess.ServiceBase.Run(new Service_$serviceName());
    }
  }
"@

#-----------------------------------------------------------------------------#
#                                                                             #
#   Function        Main                                                      #
#                                                                             #
#   Description     Execute the specified actions                             #
#                                                                             #
#   Arguments       See the Param() block at the top of this script           #
#                                                                             #
#   Notes                                                                     #
#                                                                             #
#   History                                                                   #
#                                                                             #
#-----------------------------------------------------------------------------#

# Check if we're running as a real user, or as the SYSTEM = As a service
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$userName = $identity.Name      # Ex: "NT AUTHORITY\SYSTEM" or "Domain\Administrator"
$authority,$name = $username -split "\\"
$isSystem = $identity.IsSystem	# Do not test ($userName -eq "NT AUTHORITY\SYSTEM"), as this fails in non-English systems.
# Log "# `$userName = `"$userName`" ; `$isSystem = $isSystem"

if ($Setup) {Log ""}    # Insert one blank line to separate test sessions logs
Log $MyInvocation.Line # The exact command line that was used to start us

# The following commands write to the event log, but we need to make sure the PSService source is defined.
New-EventLog -LogName $logName -Source $serviceName -ea SilentlyContinue

# Workaround for PowerShell v2 bug: $PSCmdlet Not yet defined in Param() block
$Status = ($PSCmdlet.ParameterSetName -eq 'Status')

if ($Start) {                   # Start the service
  if ($isSystem) { # If running as SYSTEM, ie. invoked as a service
    # Do whatever is necessary to start the service script instance
    Log "$scriptName -Start: Starting script '$scriptFullName' -Service"
    Write-EventLog -LogName $logName -Source $serviceName -EventId 1001 -EntryType Information -Message "$scriptName -Start: Starting script '$scriptFullName' -Service"
    Start-Process PowerShell.exe -ArgumentList ("-c & '$scriptFullName' -Service")
  } else {
    Write-Verbose "Starting service $serviceName"
    Write-EventLog -LogName $logName -Source $serviceName -EventId 1002 -EntryType Information -Message "$scriptName -Start: Starting service $serviceName"
    Start-Service $serviceName # Ask Service Control Manager to start it
  }
  return
}

if ($Stop) {                    # Stop the service
  if ($isSystem) { # If running as SYSTEM, ie. invoked as a service
    # Do whatever is necessary to stop the service script instance
    Write-EventLog -LogName $logName -Source $serviceName -EventId 1003 -EntryType Information -Message "$scriptName -Stop: Stopping script $scriptName -Service"
    Log "$scriptName -Stop: Stopping script $scriptName -Service"
    # Send an exit message to the service instance
    Send-PipeMessage $pipeName "exit" 
  } else {
    Write-Verbose "Stopping service $serviceName"
    Write-EventLog -LogName $logName -Source $serviceName -EventId 1004 -EntryType Information -Message "$scriptName -Stop: Stopping service $serviceName"
    Stop-Service $serviceName # Ask Service Control Manager to stop it
  }
  return
}

if ($Restart) {                 # Restart the service
  & $scriptFullName -Stop
  & $scriptFullName -Start
  return
}

if ($Status) {                  # Get the current service status
  $spid = $null
  $processes = @(Get-WmiObject Win32_Process -filter "Name = 'powershell.exe'" | Where-Object {
    $_.CommandLine -match ".*$scriptCopyCname.*-Service"
  })
  foreach ($process in $processes) { # There should be just one, but be prepared for surprises.
    $spid = $process.ProcessId
    Write-Verbose "$serviceName Process ID = $spid"
  }
  # if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\services\$serviceName") {}
  try {
    $pss = Get-Service $serviceName -ea stop # Will error-out if not installed
  } catch {
    "Not Installed"
    return
  }
  $pss.Status
  if (($pss.Status -eq "Running") -and (!$spid)) { # This happened during the debugging phase
    Write-Error "The Service Control Manager thinks $serviceName is started, but $serviceName.ps1 -Service is not running."
    exit 1
  }
  return
}

if ($Setup) {                   # Install the service
  # Check if it's necessary
  try {
    $pss = Get-Service $serviceName -ea stop # Will error-out if not installed
    # Check if this script is newer than the installed copy.
    if ((Get-Item $scriptCopy -ea SilentlyContinue).LastWriteTime -lt (Get-Item $scriptFullName -ea SilentlyContinue).LastWriteTime) {
      Write-Verbose "Service $serviceName is already Installed, but requires upgrade"
      & $scriptFullName -Remove
      throw "continue"
    } else {
      Write-Verbose "Service $serviceName is already Installed, and up-to-date"
    }
    exit 0
  } catch {
    # This is the normal case here. Do not throw or write any error!
    Write-Debug "Installation is necessary" # Also avoids a ScriptAnalyzer warning
    # And continue with the installation.
  }
  if (!(Test-Path $installDir)) {
    New-Item -ItemType directory -Path $installDir | Out-Null
  }
  # Copy the service script into the installation directory
  if ($ScriptFullName -ne $scriptCopy) {
    Write-Verbose "Installing $scriptCopy"
    Copy-Item $ScriptFullName $scriptCopy

    # Create and Save Key
    $Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | out-file $KeyFileFullName

    # Create and Save file with encrypted Workspace Key
    $WSKey = $OMSWorkspaceCreds.GetNetworkCredential().password | ConvertTo-SecureString -AsPlainText -Force
    $WSKey | ConvertFrom-SecureString -key $Key | Out-File $credFileFullName

    # Create File with Workspace ID
    $OMSWorkspaceCreds.UserName | Out-File $workspaceIdFileFullName
  }
  # Generate the service .EXE from the C# source embedded in this script
  try {
    Write-Verbose "Compiling $exeFullName"
    Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly $exeFullName -OutputType ConsoleApplication -ReferencedAssemblies "System.ServiceProcess" -Debug:$false
  } catch {
    $msg = $_.Exception.Message
    Write-error "Failed to create the $exeFullName service stub. $msg"
    exit 1
  }
  # Register the service
  Write-Verbose "Registering service $serviceName"
  $pss = New-Service $serviceName $exeFullName -DisplayName $serviceDisplayName -Description $ServiceDescription -StartupType Automatic

  return
}

if ($Remove) {                  # Uninstall the service
  # Check if it's necessary
  try {
    $pss = Get-Service $serviceName -ea stop # Will error-out if not installed
  } catch {
    Write-Verbose "Already uninstalled"
    return
  }
  Stop-Service $serviceName # Make sure it's stopped
  # In the absence of a Remove-Service applet, use sc.exe instead.
  Write-Verbose "Removing service $serviceName"
  $msg = sc.exe delete $serviceName
  if ($LastExitCode) {
    Write-Error "Failed to remove the service ${serviceName}: $msg"
    exit 1
  } else {
    Write-Verbose $msg
  }
  # Remove the installed files
  if (Test-Path $installDir) {
    foreach ($ext in ("exe", "pdb", "ps1", "cred", "id", "key")) {
      $file = "$installDir\$serviceName.$ext"
      if (Test-Path $file) {
        Write-Verbose "Deleting file $file"
        Remove-Item $file
      }
    }
    if (!(@(Get-ChildItem $installDir -ea SilentlyContinue)).Count) {
      Write-Verbose "Removing directory $installDir"
      Remove-Item $installDir
    }
  }
  return
}

if ($Control) {                 # Send a control message to the service
  Send-PipeMessage $pipeName $control
}

if ($Service) {                 # Run the service
  Write-EventLog -LogName $logName -Source $serviceName -EventId 1005 -EntryType Information -Message "$scriptName -Service # Beginning background job"
  # Do the service background job
  try {
    # Start the control pipe handler thread
    $pipeThread = Start-PipeHandlerThread $pipeName -Event "ControlMessage"
    ######### TO DO: Implement your own service code here. ##########
    ###### Example that wakes up and logs a line every 10 sec: ######
    # Start a periodic timer
    $timerName = "Sample service timer"
    $period = 60 # seconds
    $timer = new-object System.Timers.Timer
    $timer.Interval = ($period * 1000) # Milliseconds
    $timer.AutoReset = $true # Make it fire repeatedly
    Register-ObjectEvent $timer -EventName Elapsed -SourceIdentifier $timerName -MessageData "TimerTick"
    $timer.start() # Must be stopped in the finally block
    # Now enter the main service event loop
    do { # Keep running until told to exit by the -Stop handler
      $event = Wait-Event # Wait for the next incoming event
      $source = $event.SourceIdentifier
      $message = $event.MessageData
      $eventTime = $event.TimeGenerated.TimeofDay
      Write-Debug "Event at $eventTime from ${source}: $message"
      $event | Remove-Event # Flush the event from the queue
      switch ($message) {
        "ControlMessage" { # Required. Message received by the control pipe thread
          $state = $event.SourceEventArgs.InvocationStateInfo.state
          Write-Debug "$script -Service # Thread $source state changed to $state"
          switch ($state) {
            "Completed" {
              $message = Receive-PipeHandlerThread $pipeThread
              Log "$scriptName -Service # Received control message: $Message"
              if ($message -ne "exit") { # Start another thread waiting for control messages
                $pipeThread = Start-PipeHandlerThread $pipeName -Event "ControlMessage"
              }
            }
            "Failed" {
              $error = Receive-PipeHandlerThread $pipeThread
              Log "$scriptName -Service # $source thread failed: $error"
              Start-Sleep 1 # Avoid getting too many errors
              $pipeThread = Start-PipeHandlerThread $pipeName -Event "ControlMessage" # Retry
            }
          }
        }
        "TimerTick" { # Example. Periodic event generated for this example
          # Check if this node is Cluster Name owner
          $ownerNode = Get-ClusterResource -Name "Cluster Name" | select -ExpandProperty OwnerNode

          If ($ownerNode -eq $env:computername)
          {
            #region Initalization
            # Get the Key
            $key = Get-Content $KeyFileFullName

            # Get Workspace ID
            $OMSWorkspaceIDFromFile = Get-Content $workspaceIdFileFullName

            # Get Workspace Key
            $OMSWorkspaceKeyFromFile  = Get-Content $credFileFullName | ConvertTo-SecureString -Key $key

            # Construct Workspace ID and Key into credentials
            $OMSCredsFromFiles = New-Object -TypeName System.Management.Automation.PSCredential `
                                   -ArgumentList $OMSWorkspaceIDFromFile , $OMSWorkspaceKeyFromFile 
            
            # Log Name
            $logType = "S2D"

            # Time Generated Fields
            $Timestampfield = "Timestamp"


            # Get Server and Cluster names
            $domainfqdn = (Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty domain)
            $ServerName = ($env:computername + "." + $domainfqdn).ToUpper()
            $ClusterName = ((gwmi -class "MSCluster_Cluster" -namespace "root\mscluster" | select -ExpandProperty Name) + "." + $domainfqdn).ToUpper()
            #endregion
          
            #region Get and Send S2D Node Data to OMS
            $NowTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            $s2dNodes = Get-StorageNode
            $nodescount = $s2dNodes.GetEnumerator() | Group-Object nAME | ? { $_.Count -gt 1 }
            if($nodescount)
            {
                $s2dNodes = $s2dNodes | select -Skip 1
            }
            $table  = @()
            foreach ($s2dNode in $s2dNodes)
            {
                
                $s2dreport = $s2dNode | Get-StorageHealthReport -Count 1
                
                foreach ($s2drecord in $s2dreport.itemValue.records)
                {
                  if ($s2drecord.Units -eq 0)
                  {
                      $UnitType = "Bytes"
                  }
                  if ($s2drecord.Units -eq 1)
                  {
                      $UnitType = "BytesPerSecond"
                  }
                  if ($s2drecord.Units -eq 2)
                  {
                      $UnitType = "CountPerSecond"
                  }
                  if ($s2drecord.Units -eq 3)
                  {
                      $UnitType = "Seconds"
                  }
                  if ($s2drecord.Units -eq 4)
                  {
                      $UnitType = "Percentage"
                  }

                  $MetricValueName = $s2drecord.Name + "Value"

                  $sx = New-Object PSObject -Property @{
                    
                    Timestamp = $NowTime
                    MetricLevel = "Node";
                    MetricName = $s2drecord.Name;
                    $MetricValueName = $s2drecord.Value;
                    UnitType = $UnitType;
                    ServerName = $s2dNode.Name.ToUpper();
                    ClusterName = $ClusterName
                  } 
                  $table+=$sx 
                }

                           
            }

            if($table)
            {
                # Convert to JSON
                $jsonTable = $table | ConvertTo-Json -Depth 5

                #Send to OMS
                Send-OMSAPIIngestionFile -customerId $OMSCredsFromFiles.UserName `
                                         -sharedKey $OMSCredsFromFiles.GetNetworkCredential().password `
                                         -body $jsonTable `
                                         -logType $logType `
                                         -TimeStampField $Timestampfield

            }
            #endregion
                      
            #region Get and Send S2D cluster Data to OMS
            $s2dreport = Get-StorageSubSystem Cluster*  | Get-StorageHealthReport
            $NowTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            $table  = @()
            foreach ($s2drecord in $s2dreport.itemValue.records)
            {
              
              if ($s2drecord.Units -eq 0)
              {
                  $UnitType = "Bytes"
              }
              if ($s2drecord.Units -eq 1)
              {
                  $UnitType = "BytesPerSecond"
              }
              if ($s2drecord.Units -eq 2)
              {
                  $UnitType = "CountPerSecond"
              }
              if ($s2drecord.Units -eq 3)
              {
                  $UnitType = "Seconds"
              }
              if ($s2drecord.Units -eq 4)
              {
                  $UnitType = "Percentage"
              }
              
              $MetricValueName = $s2drecord.Name + "Value"
              $sx = New-Object PSObject -Property @{
                
                Timestamp = $NowTime
                MetricLevel = "Cluster";
                MetricName = $s2drecord.Name;
                $MetricValueName = $s2drecord.Value;
                UnitType = $UnitType;
                ClusterName = $ClusterName
              } 
              $table  += $sx 
            }
            
            if($table)
            {
                # Convert to JSON
                $jsonTable = $table | ConvertTo-Json -Depth 5

                #Send to OMS
                Send-OMSAPIIngestionFile -customerId $OMSCredsFromFiles.UserName `
                                         -sharedKey $OMSCredsFromFiles.GetNetworkCredential().password `
                                         -body $jsonTable `
                                         -logType $logType `
                                         -TimeStampField $Timestampfield

            }
            #endregion  

            #region Get and Send S2D Volume Data to OMS
            $volumes = Get-Volume | where {$_.FileSystem -eq "CSVFS" }
            $table  = @()
            $NowTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            if($volumes)
            {
                foreach ($volume in $volumes)
                {
                  $VolumeLabel = $volume.FileSystemLabel
                  $FileSystemType = $volume.FileSystemType
                  $OperationalStatus = $volume.OperationalStatus
                  $HealthStatus = $volume.HealthStatus

                  $s2dreport = Get-Volume -FileSystemLabel $VolumeLabel | Get-StorageHealthReport -Count 1
                  foreach ($s2drecord in $s2dreport.itemValue.records)
                  {
                      if ($s2drecord.Units -eq 0)
                      {
                          $UnitType = "Bytes"
                      }
                      if ($s2drecord.Units -eq 1)
                      {
                          $UnitType = "BytesPerSecond"
                      }
                      if ($s2drecord.Units -eq 2)
                      {
                          $UnitType = "CountPerSecond"
                      }
                      if ($s2drecord.Units -eq 3)
                      {
                          $UnitType = "Seconds"
                      }
                      if ($s2drecord.Units -eq 4)
                      {
                          $UnitType = "Percentage"
                      }

                      $MetricValueName = $s2drecord.Name + "Value"

                      $sx = New-Object PSObject -Property @{
                    
                       Timestamp = $NowTime
                       MetricLevel = "Volume";
                       VolumeLabel = $VolumeLabel;
                       FileSystemType = $FileSystemType;
                       OperationalStatus = $OperationalStatus;
                       HealthStatus = $HealthStatus;
                       MetricName = $s2drecord.Name;
                       $MetricValueName = $s2drecord.Value;
                       UnitType = $UnitType;
                       ClusterName = $ClusterName
                  } 
                  $table  += $sx 
                  }
                
                }

                if($table)
                {
                    # Convert to JSON
                    $jsonTable = $table | ConvertTo-Json -Depth 5

                    #Send to OMS
                    Send-OMSAPIIngestionFile -customerId $OMSCredsFromFiles.UserName `
                                             -sharedKey $OMSCredsFromFiles.GetNetworkCredential().password `
                                             -body $jsonTable `
                                             -logType $logType `
                                             -TimeStampField $Timestampfield

                }
            }
            
            #endregion

            #region Get and Send S2D Cluster Faults to OMS
            $s2dFaults = Get-StorageSubSystem Cluster* | Debug-StorageSubSystem
            $table  = @()
            $NowTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            
            If ($s2dFaults)
            {
                foreach ($s2dFault in $s2dFaults)
                {
                    if ($s2dFault.PerceivedSeverity -eq "Unknown" )
                    {
                        $SeverityNumber = 0
                    }
                    if ($s2dFault.PerceivedSeverity -eq "Information")
                    {
                        $SeverityNumber = 2
                    }
                    if ($s2dFault.PerceivedSeverity -eq "Degraded/Warning")
                    {
                        $SeverityNumber = 3
                    }
                    if ($s2dFault.PerceivedSeverity -eq "Minor")
                    {
                        $SeverityNumber = 4
                    }
                    if ($s2dFault.PerceivedSeverity -eq "Major")
                    {
                        $SeverityNumber = 5
                    }
                    if ($s2dFault.PerceivedSeverity -eq "Critical")
                    {
                        $SeverityNumber = 6
                    }
                    if ($s2dFault.PerceivedSeverity -eq "Fatal/NonRecoverable")
                    {
                        $SeverityNumber = 7
                    }

                    $reason=""
                    foreach ($faultreason in $s2dFault.Reason)
                    {
                        $reason +=$faultreason
                        $reason += " | "
                    }

                    $sx = New-Object PSObject -Property @{
                    
                        Timestamp = $NowTime;
                        SecondTimeStamp = $NowTime;
                        Severity = $s2dFault.PerceivedSeverity;
                        SeverityNumber = $SeverityNumber;
                        FaultLevel = "Cluster";
                        FaultId = $s2dFault.FaultId;
                        FaultingObjectDescription = $s2dFault.FaultingObjectDescription;
                        FaultingObjectLocation = $s2dFault.FaultingObjectLocation;
                        FaultingObjectType = $s2dFault.FaultingObjectType;
                        FaultingObjectUniqueId = $s2dFault.FaultingObjectUniqueId;
                        FaultType = $s2dFault.FaultType;
                        Reason = $s2dFault.Reason;
                        RecommendedActions = $reason;
                        ClusterName = $ClusterName
                  } 
                  $table  += $sx 
                
                }
            }

            if($table)
            {
                # Convert to JSON
                $jsonTable = $table | ConvertTo-Json -Depth 5

                #Send to OMS
                Send-OMSAPIIngestionFile -customerId $OMSCredsFromFiles.UserName `
                                         -sharedKey $OMSCredsFromFiles.GetNetworkCredential().password `
                                         -body $jsonTable `
                                         -logType $logType `
                                         -TimeStampField $Timestampfield

            }
            
            #endregion

            #region Get and Send S2D Volume Faults to OMS
            $volumes = Get-Volume | where {$_.FileSystem -eq "CSVFS" }
            $table  = @()
            $NowTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            if ($volumes)
            {
                foreach ($volume in $volumes)
                {
                    $VolumeLabel = $volume.FileSystemLabel
                    $FileSystemType = $volume.FileSystemType

                    $s2dFaults = Get-Volume -FileSystemLabel $VolumeLabel | Debug-Volume
                    if($s2dFaults)
                    {
                        foreach ($s2dFault in $s2dFaults)
                        {
                            if ($s2dFault.PerceivedSeverity -eq "Unknown" )
                            {
                                $SeverityNumber = 0
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Information")
                            {
                                $SeverityNumber = 2
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Degraded/Warning")
                            {
                                $SeverityNumber = 3
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Minor")
                            {
                                $SeverityNumber = 4
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Major")
                            {
                                $SeverityNumber = 5
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Critical")
                            {
                                $SeverityNumber = 6
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Fatal/NonRecoverable")
                            {
                                $SeverityNumber = 7
                            }

                            $reason=""
                            foreach ($faultreason in $s2dFault.Reason)
                            {
                                $reason +=$faultreason
                                $reason += " | "
                            }
                            
                            $sx = New-Object PSObject -Property @{
                        
                                Timestamp = $NowTime;
                                SecondTimeStamp = $NowTime;
                                Severity = $s2dFault.PerceivedSeverity;
                                SeverityNumber = $SeverityNumber;
                                FaultId = $s2dFault.FaultId;
                                FaultLevel = "Volume";
                                VolumeLabel = $VolumeLabel;
                                FaultingObjectDescription = $s2dFault.FaultingObjectDescription;
                                FaultingObjectLocation = $s2dFault.FaultingObjectLocation;
                                FaultingObjectType = $s2dFault.FaultingObjectType;
                                FaultingObjectUniqueId = $s2dFault.FaultingObjectUniqueId;
                                FaultType = $s2dFault.FaultType;
                                Reason = $s2dFault.Reason;
                                RecommendedActions = $reason;
                                ClusterName = $ClusterName
                            } 
                            $table  += $sx 
                        }
                    }
                    
                }

                if($table)
                {
                    # Convert to JSON
                    $jsonTable = $table | ConvertTo-Json -Depth 5

                    #Send to OMS
                    Send-OMSAPIIngestionFile -customerId $OMSCredsFromFiles.UserName `
                                             -sharedKey $OMSCredsFromFiles.GetNetworkCredential().password `
                                             -body $jsonTable `
                                             -logType $logType `
                                             -TimeStampField $Timestampfield
                }
                
            }
            
            #endregion

            #region Get and Send S2D Share Faults to OMS
            $shares = Get-FileShare | where {$_.ContinuouslyAvailable -eq $true}
            $table  = @()
            $NowTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            if($shares)
            {
                foreach ($share in $shares)
                {
                    $shareName = $share.Name

                    $s2dFaults = Get-FileShare -Name $share.Name | Debug-FileShare
                    if($s2dFaults)
                    {
                        foreach ($s2dFault in $s2dFaults)
                        {
                            if ($s2dFault.PerceivedSeverity -eq "Unknown" )
                            {
                                $SeverityNumber = 0
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Information")
                            {
                                $SeverityNumber = 2
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Degraded/Warning")
                            {
                                $SeverityNumber = 3
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Minor")
                            {
                                $SeverityNumber = 4
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Major")
                            {
                                $SeverityNumber = 5
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Critical")
                            {
                                $SeverityNumber = 6
                            }
                            if ($s2dFault.PerceivedSeverity -eq "Fatal/NonRecoverable")
                            {
                                $SeverityNumber = 7
                            }

                            $reason=""
                            foreach ($faultreason in $s2dFault.Reason)
                            {
                                $reason +=$faultreason
                                $reason += " | "
                            }
                            
                            $sx = New-Object PSObject -Property @{
                        
                                Timestamp = $NowTime;
                                SecondTimeStamp = $NowTime;
                                Severity = $s2dFault.PerceivedSeverity;
                                SeverityNumber = $SeverityNumber;
                                FaultId = $s2dFault.FaultId;
                                FaultLevel = "Share";
                                ShareName = $shareName;
                                FaultingObjectDescription = $s2dFault.FaultingObjectDescription;
                                FaultingObjectLocation = $s2dFault.FaultingObjectLocation;
                                FaultingObjectType = $s2dFault.FaultingObjectType;
                                FaultingObjectUniqueId = $s2dFault.FaultingObjectUniqueId;
                                FaultType = $s2dFault.FaultType;
                                Reason = $s2dFault.Reason;
                                RecommendedActions = $reason;
                                ClusterName = $ClusterName
                            } 
                            $table  += $sx 
                        }
                    }
                    
                }

                if($table)
                {
                    # Convert to JSON
                    $jsonTable = $table | ConvertTo-Json -Depth 5

                    #Send to OMS
                    Send-OMSAPIIngestionFile -customerId $OMSCredsFromFiles.UserName `
                                             -sharedKey $OMSCredsFromFiles.GetNetworkCredential().password `
                                             -body $jsonTable `
                                             -logType $logType `
                                             -TimeStampField $Timestampfield

                }
                
            }
            
            #endregion
          }
           
        }
        default { # Should not happen
          Log "$scriptName -Service # Unexpected event from ${source}: $Message"
        }
      }
    } while ($message -ne "exit")
  } catch { # An exception occurred while runnning the service
    $msg = $_.Exception.Message
    $line = $_.InvocationInfo.ScriptLineNumber
    Log "$scriptName -Service # Error at line ${line}: $msg"
  } finally { # Invoked in all cases: Exception or normally by -Stop
    # Cleanup the periodic timer used in the above example
    Unregister-Event -SourceIdentifier $timerName
    $timer.stop()
    ############### End of the service code example. ################
    # Terminate the control pipe handler thread
    Get-PSThread | Remove-PSThread # Remove all remaining threads
    # Flush all leftover events (There may be some that arrived after we exited the while event loop, but before we unregistered the events)
    $events = Get-Event | Remove-Event
    # Log a termination event, no matter what the cause is.
    Write-EventLog -LogName $logName -Source $serviceName -EventId 1006 -EntryType Information -Message "$script -Service # Exiting"
    Log "$scriptName -Service # Exiting"
  }
  return
}