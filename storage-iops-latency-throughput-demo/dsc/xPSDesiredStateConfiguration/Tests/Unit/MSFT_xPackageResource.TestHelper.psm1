<#
    .SYNOPSIS
        Clears the xPackage cache.
#>
function Clear-xPackageCache
{
    [CmdletBinding()]
    param ()

    $xPackageCacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\" + `
        "BuiltinProvCache\MSFT_xPackageResource"

    Remove-Item -Path $xPackageCacheLocation -ErrorAction 'SilentlyContinue' -Recurse
}

<#
    .SYNOPSIS
        Tests if the package with the given name is installed.

    .PARAMETER Name
        The name of the package to test for.
#>
function Test-PackageInstalledByName
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [String]
        $Name
    )

    $uninstallRegistryKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    $uninstallRegistryKeyWow64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'

    $productEntry = $null

    foreach ($registryKeyEntry in (Get-ChildItem -Path @( $uninstallRegistryKey, $uninstallRegistryKeyWow64) -ErrorAction 'Ignore' ))
    {
        if ($Name -eq (Get-LocalizedRegistryKeyValue -RegistryKey $registryKeyEntry -ValueName 'DisplayName'))
        {
            $productEntry = $registryKeyEntry
            break
        }
    }

    return ($null -ne $productEntry)
}

<#
    .SYNOPSIS
        Mimics a simple http or https file server.

    .PARAMETER FilePath
        The path to the file to add on the mock file server.

    .PARAMETER Https
        Indicates that the new file server should use https.
        Otherwise the new file server will use http.
#>
function New-MockFileServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FilePath,

        [Switch]
        $Https
    )

    if ($null -eq (Get-NetFirewallRule -DisplayName 'UnitTestRule' -ErrorAction 'SilentlyContinue'))
    {
        New-NetFirewallRule -DisplayName 'UnitTestRule' -Direction 'Inbound' -Program "$PSHome\powershell.exe" -Authentication 'NotRequired' -Action 'Allow'
    }

    netsh advfirewall set allprofiles state off

    Start-Job -ArgumentList @( $FilePath ) -ScriptBlock {
        
        # Create certificate
        $certificate = Get-ChildItem -Path 'Cert:\LocalMachine\My' -Recurse | Where-Object { $_.EnhancedKeyUsageList.FriendlyName -eq 'Server Authentication' }

        if ($certificate.Count -gt 1)
        {
            # Just use the first one
            $certificate = $certificate[0]
        }
        elseif ($certificate.count -eq 0)
        {
            # Create a self-signed one
            $certificate = New-SelfSignedCertificate -CertStoreLocation 'Cert:\LocalMachine\My' -DnsName $env:computerName
        }

        $hash = $certificate.Thumbprint

        # Use net shell command to directly bind certificate to designated testing port
        netsh http add sslcert ipport=0.0.0.0:1243 certhash=$hash appid='{833f13c2-319a-4799-9d1a-5b267a0c3593}' clientcertnegotiation=enable

        # Start listening endpoints
        $httpListener = New-Object -TypeName 'System.Net.HttpListener'

        if ($Https)
        {
            $httpListener.Prefixes.Add([Uri]'https://localhost:1243')
        }
        else
        {
            $httpListener.Prefixes.Add([Uri]'http://localhost:1242')
        }

        $httpListener.AuthenticationSchemes = [System.Net.AuthenticationSchemes]::Negotiate
        $httpListener.Start()

        # Create a pipe to flag http/https client
        $pipe = New-Object -TypeName 'System.IO.Pipes.NamedPipeClientStream' -ArgumentList @( '\\.\pipe\dsctest1' )
        $pipe.Connect()
        $pipe.Dispose()
        
        # Prepare binary buffer for http/https response
        $fileInfo = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList @( $args[0] )
        $numBytes = $fileInfo.Length
        $fileStream = New-Object -TypeName 'System.IO.FileStream' -ArgumentList @(  $args[0], 'Open' )
        $binaryReader = New-Object -TypeName 'System.IO.BinaryReader' -ArgumentList @( $fileStream )
        [Byte[]] $buf = $binaryReader.ReadBytes($numBytes)
        $fileStream.Close()

        # Send response
        $response = ($httpListener.GetContext()).Response
        $response.ContentType = 'application/octet-stream'
        $response.ContentLength64 = $buf.Length
        $response.OutputStream.Write($buf, 0, $buf.Length)
        $response.OutputStream.Flush()

        # Wait for client to finish downloading
        $pipe = New-Object -TypeName 'System.IO.Pipes.NamedPipeServerStream' -ArgumentList @( '\\.\pipe\dsctest2' )
        $pipe.WaitForConnection()
        $pipe.Dispose()

        $response.Dispose()
        $httpListener.Stop()
        $httpListener.Close()

        # Close pipe
    
        # Use net shell command to clean up the certificate binding
        netsh http delete sslcert ipport=0.0.0.0:1243
    }

    netsh advfirewall set allprofiles state on
}

<#
    .SYNOPSIS
        Creates a new test executable.

    .PARAMETER DestinationPath
        The path at which to create the test executable.
#>
function New-TestExecutable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$DestinationPath
    )
    
    if (Test-Path -Path $DestinationPath)
    {
        Write-Verbose -Message "Removing old executable at $DestinationPath..."
        Remove-Item -Path $DestinationPath -Force
    }

    $testExecutableCode = @'
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Management;
    using System.Text;
    using System.Threading.Tasks;
    using System.Management.Automation;
    using System.Management.Automation.Runspaces;
    using System.Runtime.InteropServices;
    namespace Providers.Package.UnitTests.MySuite
    {
        class ExeTestClass
        {
            public static void Main(string[] args)
            {
                string cmdline = System.Environment.CommandLine;
                Console.WriteLine("Cmdline was " + cmdline);
                int endIndex = cmdline.IndexOf("\"", 1);
                string self = cmdline.Substring(0, endIndex);
                string other = cmdline.Substring(self.Length + 1);
                string msiexecpath = System.IO.Path.Combine(System.Environment.SystemDirectory, "msiexec.exe");

                self = self.Replace("\"", "");
                string packagePath = System.IO.Path.Combine(System.IO.Path.GetDirectoryName(self), "DSCSetupProject.msi");

                string msiexecargs = String.Format("/i {0} {1}", packagePath, other);
                System.Diagnostics.Process.Start(msiexecpath, msiexecargs).WaitForExit();
            }
        }
    }
'@

    Add-Type -TypeDefinition $testExecutableCode -OutputAssembly $DestinationPath -OutputType 'ConsoleApplication'
}

<#
    .SYNOPSIS
        Creates a new MSI package for testing.

    .PARAMETER DestinationPath
        The path at which to create the test msi file.
#>
function New-TestMsi
{
    [CmdletBinding()]
    param    
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DestinationPath
    )

    #region msiContentInBase64
    $msiContentInBase64 = '0M8R4KGxGuEAAAAAAAAAAAAAAAAAAAAAPgAEAP7/DAAGAAAAAAAAAAEAAAABAAAAAQA' + `
        'AAAAAAAAAEAAAAgAAAAEAAAD+////AAAAAAAAAAD/////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '////////////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP3////+/////v///wYAAAD+////BAAAAP7////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '////////////////////////////////////////////////////////////9SAG8AbwB0ACAARQBuAHQAcgB' + `
        '5AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFgAFAP//////////CQAAAIQQ' + `
        'DAAAAAAAwAAAAAAAAEYAAAAAAAAAAAAAAADwRqG1qh/OAQMAAAAAEwAAAAAAAAUAUwB1AG0AbQBhAHIAeQBJA' + `
        'G4AZgBvAHIAbQBhAHQAaQBvAG4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoAAIA////////////////AA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADwCAAAAAAAAQEj/P+RD7EHkRaxEMUgAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAgETAAAABAAAAP////8A' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJAAAAOAcAAAAAAABASMpBMEOxOztCJkY3QhxCN' + `
        'EZoRCZCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGAACAQsAAAAKAAAA/////w' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACYAAAAwAAAAAAAAAEBIykEwQ7E/Ej8oRThCsUE' + `
        'oSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUAAIBDAAAAP//////////' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJwAAABgAAAAAAAAAQEjKQflFzkaoQfhFKD8oR' + `
        'ThCsUEoSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABgAAgD///////////////' + `
        '8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoAAAAKgAAAAAAAABASIxE8ERyRGhEN0gAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgACAP//////////////' + `
        '/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACkAAAAMAAAAAAAAAEBIDUM1QuZFckU8SAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOAAIADgAAAAIAAAD///' + `
        '//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKgAAABIAAAAAAAAAQEgPQuRFeEUoSAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAgD/////////////' + `
        '//8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAArAAAAEAAAAAAAAABASA9C5EV4RSg7MkSzR' + `
        'DFC8UU2SAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFgACAQcAAAADAAAA//' + `
        '///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAEAAAAAAAAAEBIUkT2ReRDrzs7QiZ' + `
        'GN0IcQjRGaEQmQgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaAAIBBQAAAAEAAAD/' + `
        '////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALQAAAHIAAAAAAAAAQEhSRPZF5EOvPxI/K' + `
        'EU4QrFBKEgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABYAAgH///////////' + `
        '////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAvAAAAMAAAAAAAAABASBVBeETmQoxE8UH' + `
        'sRaxEMUgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAACAP//////////' + `
        '/////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAEAAAAAAAAAEBIWUXyRGhFN0cAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAIBDwAAAP////' + `
        '//////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMQAAACQAAAAAAAAAQEgbQipD9kU1RwA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAgEQAAAADQAA' + `
        'AP////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyAAAADAAAAAAAAABASN5EakXkQShIA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAACAP////////' + `
        '///////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADMAAAAgAAAAAAAAAEBIfz9kQS9CNkg' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAIBEQAAAAgA' + `
        'AAD/////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANAAAACAAAAAAAAAAQEg/O/JDOESxR' + `
        'QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAgD///////' + `
        '////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA1AAAAWAIAAAAAAABASD8/d0VsRGo' + `
        '+skQvSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAACAP//////' + `
        '/////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD8AAAAYAwAAAAAAAEBIPz93RWxEa' + `
        'jvkRSRIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAIBBgAAAB' + `
        'IAAAD/////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABQAAAFAaAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/////' + `
        '//////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////' + `
        '///////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////' + `
        '////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///' + `
        '////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//' + `
        '/////////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//' + `
        '//////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/' + `
        '//////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP' + `
        '///////////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        '////////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'D///////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AP///////////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AA////////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQA' + `
        'AAAIAAAADAAAABAAAAAUAAAAGAAAABwAAAAgAAAD+////CgAAAAsAAAAMAAAADQAAAA4AAAAPAAAAEAAAABEA' + `
        'AAASAAAAEwAAABQAAAAVAAAAFgAAABcAAAAYAAAAGQAAABoAAAAbAAAAHAAAAB0AAAAeAAAAHwAAACAAAAAhA' + `
        'AAAIgAAACMAAAAkAAAAJQAAAP7////+/////v////7////+/////v////7////+////LgAAAP7////+/////v' + `
        '////7////+/////v////7///82AAAANwAAADgAAAA5AAAAOgAAADsAAAA8AAAAPQAAAD4AAAD+////QAAAAEE' + `
        'AAABCAAAAQwAAAEQAAABFAAAARgAAAEcAAABIAAAASQAAAEoAAABLAAAA/v//////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '/////////////////////////////////////////////////////////////////////////////////////' + `
        '///////////////////7/AAAGAQIAAAAAAAAAAAAAAAAAAAAAAAEAAADghZ/y+U9oEKuRCAArJ7PZMAAAAAwC' + `
        'AAAOAAAAAQAAAHgAAAACAAAAgAAAAAMAAACgAAAABAAAAMQAAAAFAAAA9AAAAAYAAAAIAQAABwAAAGwBAAAJA' + `
        'AAAgAEAAAwAAACwAQAADQAAALwBAAAOAAAAyAEAAA8AAADQAQAAEgAAANgBAAATAAAABAIAAAIAAADkBAAAHg' + `
        'AAABYAAABJbnN0YWxsYXRpb24gRGF0YWJhc2UAAAAeAAAAGwAAAEEgcGFja2FnZSBmb3IgdW5pdCB0ZXN0aW5' + `
        'nAAAeAAAAKAAAAE1pY3Jvc29mdCBVbml0IFRlc3RpbmcgR3VpbGQgb2YgQW1lcmljYQAeAAAACgAAAEluc3Rh' + `
        'bGxlcgAAAB4AAABcAAAAVGhpcyBpbnN0YWxsZXIgZGF0YWJhc2UgY29udGFpbnMgdGhlIGxvZ2ljIGFuZCBkY' + `
        'XRhIHJlcXVpcmVkIHRvIGluc3RhbGwgRFNDVW5pdFRlc3RQYWNrYWdlLgAeAAAACwAAAEludGVsOzEwMzMAAB' + `
        '4AAAAnAAAAe0YxN0FGREExLUREMEItNDRFNi1CNDczLTlFQkUyREJEOUVBOX0AAEAAAAAAAOO0qh/OAUAAAAA' + `
        'AAOO0qh/OAQMAAADIAAAAAwAAAAIAAAAeAAAAIwAAAFdpbmRvd3MgSW5zdGFsbGVyIFhNTCAoMy43LjEyMDQu' + `
        'MCkAAAMAAAACAAAAAAAAAAYABgAGAAYABgAGAAYABgAGAAYACgAKACIAIgAiACkAKQApACoAKgAqACsAKwArA' + `
        'CsAKwArADEAMQAxAD4APgA+AD4APgA+AD4APgBNAE0AUgBSAFIAUgBSAFIAUgBSAGAAYABgAGEAYQBhAGIAYg' + `
        'BmAGYAZgBmAGYAZgByAHIAdgB2AHYAdgB2AHYAgACAAIAAgACAAIAAgAACAAUACwAMAA0ADgAPABAAEQASAAc' + `
        'ACQAjACUAJwAjACUAJwAjACUAJwAlACsALQAwADMANgAxADoAPAALADAAMwA+AEAAQgBFAEcATgBQACcAMwBQ' + `
        'AFIAVQBYAFoAXAAjACUAJwAjACUAJwALACUAZwBpAGsAbQBvAHEABwByAAEABwBQAHYAeAB6ADMAXACBAIMAh' + `
        'QCJAIsACAAIABgAGAAYABgAGAAIABgAGAAIAAgACAAYABgACAAYABgACAAYABgAGAAIABgACAAIABgACAAYAA' + `
        'gAGAAYAAgACAAYABgAGAAIAAgACAAIABgACAAIAAgACAAYABgACAAYABgACAAYABgACAAIAAgACAAYABgAGAA' + `
        'YAAgACAAYABgACAAIAAgACAAIABgACAAYABgAGAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAgAEAAAAAAAAA' + `
        'AAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAA/P//fwAAAAAAAAAA/P//fwAAAAAAAAAA/P//fwAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAACAAAAAAAAAAA' + `
        'ABAACAAAAAgAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAA/P//fwAAAAAAAAAA/P//fwAAAAAAAAA' + `
        'AAQAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////fwAAAAAAAACAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAACA/////wAAAAAAAAAA/////wAAA' + `
        'AAAAAAAAAAAAAAAAAD/fwCAAAAAAAAAAAD/fwCAAAAAAAAAAAD/fwCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/38AgP9/AIAAAAAAAAAAAP//////fwCAAAA' + `
        'AAAAAAAAAAAAA/////wAAAAAAAAAAAAAAAAAAAAD/fwCAAAAAAAAAAAD/fwCAAAAAAAAAAAD/fwCA/////wAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAACAAAAAAP////8AAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAxAAAANw' + `
        'AAADEAAAAAADEAAAAAAD4AAAAAAAAAPgArAAAAAAArAAAAAAAAAFIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAArAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAYAAAAGAAAABgAAAAAABgAAAAAABgAAAAAAAAAGAAYAAAAAAAYAAAAAAA' + `
        'AABgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAAAAAAAAB' + `
        'MAEwAfAB8AAAAAAAAAAAATAAAAAAAAABMAJQAAABMAJQAAABMAJQAAACUAEwAuABMAAAATABMAEwA8AB8ASQA' + `
        'AABMAEwAfAAAAAAATABMAAAAAABMAEwBWAAAAWgBcABMAJQAAABMAJQAAAGQAJQAAAAAAHwBtAB8AcgAfABMA' + `
        'ZABkABMAEwAAAHsAAABcAC4AHwAfAGQASQAAAAAAAAAAAB0AAAAAABYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAVACEAIAAeABw' + `
        'AGgAXABsAGQAAAAAAJAAmACgAJAAmACgAJAAmACgANQAsAC8AMgA0ADgAOQA7AD0ARABKAEwAPwBBAEMARgBI' + `
        'AE8AUQBfAF4AVABTAFcAWQBbAF0AJAAmACgAJAAmACgAZQBjAGgAagBsAG4AcABzAHUAdAB9AH4AfwB3AHkAf' + `
        'ACIAIcAggCEAIYAigCMAAAAAAAAAAAAjQCOAI8AkACRAJIAkwCUAAAAAAAAAAAAAAAAAAAAAAAgg4SD6IN4hd' + `
        'yFPI+gj8iZAAAAAAAAAAAAAAAAAAAAAI0AjgCPAJUAAAAAAAAAAAAgg4SD6IMUhQAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACNAI8AkACRAJQAlgCXAAAAAAAAAAAAAAAAAAAAIIPog3iF3IXImZyY' + `
        'AJkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmACZAJoABIAAAJsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJoAnACeAJwAngAAAJ0AnwCgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAChAAAAogAAAAKAAYAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoQCYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI0AjgCPAJAAkQCUAJYAlwCjAKQApQCmAKcAqACpAKoAqwCsAK0AA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgg4SD6IN4hdyFyJmcmACZGYBkgLyCsIRAhg' + `
        'iHKIqIk3CX1Jd5hQAAAAAAAAAAAAAAAAAAjQCOAI8AlQCjAKQApQCmAAAAAAAAAAAAAAAAAAAAAAAgg4SD6IM' + `
        'UhRmAZIC8grCEAAAAAAAAAAAAAAAAAAAAAK4ArwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACBALAAsgC0ALYAuAC6AL0AvwC8ALEAswC1ALcAuQC7AL4AwAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmwACgMEAwgDDAJgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALwAvAAAALsAuwAAAAAAAAABAACAAgAAgAAAAADEAMUAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGACIAKQAqACsAMQA+AE0AUgBgAGEAYgBmAHIAdgCAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABgAGAAYABgAGAAYABgAGAAYABgAiACIAIgApACkAKQAqACoAK' + `
        'gArACsAKwArACsAKwAxADEAMQA+AD4APgA+AD4APgA+AD4ATQBNAFIAUgBSAFIAUgBSAFIAUgBgAGAAYABhAG' + `
        'EAYQBiAGIAZgBmAGYAZgBmAGYAcgByAHYAdgB2AHYAdgB2AIAAgACAAIAAgACAAIAAAYACgAOABIAFgAaAB4A' + `
        'IgAmACoABgAKAA4ABgAKAA4ABgAKAA4ABgAKAA4AEgAWABoABgAKAA4ABgAKAA4AEgAWABoAHgAiAAYACgAGA' + `
        'AoADgASABYAGgAeACIABgAKAA4ABgAKAA4ABgAKAAYACgAOABIAFgAaAAYACgAGAAoADgASABYAGgAGAAoADg' + `
        'ASABYAGgAeAAgAFABAAEgAPABEADgANAAwACwAjACUAJwAjACUAJwAjACUAJwArAC0AMAAzACUANgAxADoAPA' + `
        'A+AEAAQgALAEUARwAwADMATgBQAFIAUABVAFgAWgBcADMAJwAjACUAJwAjACUAJwAlAAsAZwBpAGsAbQBvAHE' + `
        'AcgAHAHYAeAB6AAEABwBQAIEAgwCFAFwAMwCJAIsAIK0grQSNBJEEkf+dApUgnf+d/51Irf+dApVIrf+dApVI' + `
        'rf+dApVIrSadSI0Chf+dSJ1IrUid/48mrSadQJ//nwKVAoVInQKFJq1IrUitSI3/jwSBSJ0UnQKVBIFIrf+dA' + `
        'pVIrf+dApX/rf+PAqUEgUCf/50gnUidSK0Aj0itAoX/j/+fAJ9IjSatFL0Uvf+9BKH/nUiNAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAIABQACAAAAAAAAAAAABgACAAsAFQAFAAUAAQA' + `
        'mAAoAAQATAAIACwAGAAMAAgAIAAIACQACAAgAAgBudGVnZXIgdG8gZGV0ZXJtaW5lIHNvcnQgb3JkZXIgZm9y' + `
        'IHRhYmxlLkxhc3RTZXF1ZW5jZUZpbGUgc2VxdWVuY2UgbnVtYmVyIGZvciB0aGUgbGFzdCBmaWxlIGZvciB0a' + `
        'GlzIG1lZGlhLkRpc2tQcm9tcHREaXNrIG5hbWU6IHRoZSB2aXNpYmxlIHRleHQgYWN0dWFsbHkgcHJpbnRlZC' + `
        'BvbiB0aGUgZGlzay4gIFRoaXMgd2lsbCBiZSB1c2VkIHRvIHByb21wdCB0aGUgdXNlciB3aGVuIHRoaXMgZGl' + `
        'zayBuZWVkcyB0byBiZSBpbnNlcnRlZC5DYWJpbmV0SWYgc29tZSBvciBhbGwgb2YgdGhlIGZpbGVzIHN0b3Jl' + `
        'ZCBvbiB0aGUgbWVkaWEgYXJlIGNvbXByZXNzZWQgaW4gYSBjYWJpbmV0LCB0aGUgbmFtZSBvZiB0aGF0IGNhY' + `
        'mluZXQuVm9sdW1lTGFiZWxUaGUgbGFiZWwgYXR0cmlidXRlZCB0byB0aGUgdm9sdW1lLlNvdXJjZVByb3Blcn' + `
        'R5VGhlIHByb3BlcnR5IGRlZmluaW5nIHRoZSBsb2NhdGlvbiBvZiB0aGUgY2FiaW5ldCBmaWxlLk5hbWUgb2Y' + `
        'gcHJvcGVydHksIHVwcGVyY2FzZSBpZiBzZXR0YWJsZSBieSBsYXVuY2hlciBvciBsb2FkZXIuU3RyaW5nIHZh' + `
        'bHVlIGZvciBwcm9wZXJ0eS4gIE5ldmVyIG51bGwgb3IgZW1wdHkuUmVnaXN0cnlQcmltYXJ5IGtleSwgbm9uL' + `
        'WxvY2FsaXplZCB0b2tlbi5Sb290VGhlIHByZWRlZmluZWQgcm9vdCBrZXkgZm9yIHRoZSByZWdpc3RyeSB2YW' + `
        'x1ZSwgb25lIG9mIHJya0VudW0uS2V5UmVnUGF0aFRoZSBrZXkgZm9yIHRoZSByZWdpc3RyeSB2YWx1ZS5UaGU' + `
        'gcmVnaXN0cnkgdmFsdWUgbmFtZS5UaGUgcmVnaXN0cnkgdmFsdWUuRm9yZWlnbiBrZXkgaW50byB0aGUgQ29t' + `
        'cG9uZW50IHRhYmxlIHJlZmVyZW5jaW5nIGNvbXBvbmVudCB0aGF0IGNvbnRyb2xzIHRoZSBpbnN0YWxsaW5nI' + `
        'G9mIHRoZSByZWdpc3RyeSB2YWx1ZS5VcGdyYWRlVXBncmFkZUNvZGVUaGUgVXBncmFkZUNvZGUgR1VJRCBiZW' + `
        'xvbmdpbmcgdG8gdGhlIHByb2R1Y3RzIGluIHRoaXMgc2V0LlZlcnNpb25NaW5UaGUgbWluaW11bSBQcm9kdWN' + `
        '0VmVyc2lvbiBvZiB0aGUgcHJvZHVjdHMgaW4gdGhpcyBzZXQuICBUaGUgc2V0IG1heSBvciBtYXkgbm90IGlu' + `
        'Y2x1ZGUgcHJvZHVjdHMgd2l0aCB0aGlzIHBhcnRpY3VsYXIgdmVyc2lvbi5WZXJzaW9uTWF4VGhlIG1heGltd' + `
        'W0gUHJvZHVjdFZlcnNpb24gb2YgdGhlIHByb2R1Y3RzIGluIHRoaXMgc2V0LiAgVGhlIHNldCBtYXkgb3IgbW' + `
        'F5IG5vdCBpbmNsdWRlIHByb2R1Y3RzIHdpdGggdGhpcyBwYXJ0aWN1bGFyIHZlcnNpb24uQSBjb21tYS1zZXB' + `
        'hcmF0ZWQgbGlzdCBvZiBsYW5ndWFnZXMgZm9yIGVpdGhlciBwcm9kdWN0cyBpbiB0aGlzIHNldCBvciBwcm9k' + `
        'dWN0cyBub3QgaW4gdGhpcyBzZXQuVGhlIGF0dHJpYnV0ZXMgb2YgdGhpcyBwcm9kdWN0IHNldC5SZW1vdmVUa' + `
        'GUgbGlzdCBvZiBmZWF0dXJlcyB0byByZW1vdmUgd2hlbiB1bmluc3RhbGxpbmcgYSBwcm9kdWN0IGZyb20gdG' + `
        'hpcyBzZXQuICBUaGUgZGVmYXVsdCBpcyAiQUxMIi5BY3Rpb25Qcm9wZXJ0eVRoZSBwcm9wZXJ0eSB0byBzZXQ' + `
        'gd2hlbiBhIHByb2R1Y3QgaW4gdGhpcyBzZXQgaXMgZm91bmQuQ29zdEluaXRpYWxpemVGaWxlQ29zdENvc3RG' + `
        'aW5hbGl6ZUluc3RhbGxWYWxpZGF0ZUluc3RhbGxJbml0aWFsaXplSW5zdGFsbEFkbWluUGFja2FnZUluc3Rhb' + `
        'GxGaWxlc0luc3RhbGxGaW5hbGl6ZUV4ZWN1dGVBY3Rpb25QdWJsaXNoRmVhdHVyZXNQdWJsaXNoUHJvZHVjdF' + `
        'Byb2R1Y3RDb21wb25lbnR7OTg5QjBFRDgtREVBRC01MjhELUI4RTMtN0NBRTQxODYyNEQ1fUlOU1RBTExGT0x' + `
        'ERVJEdW1teUZsYWdWYWx1ZVByb2dyYW1GaWxlc0ZvbGRlcnE0cGZqNHo3fERTQ1NldHVwUHJvamVjdFRBUkdF' + `
        'VERJUi5Tb3VyY2VEaXJQcm9kdWN0RmVhdHVyZURTQ1NldHVwUHJvamVjdEZpbmRSZWxhdGVkUHJvZHVjdHNMY' + `
        'XVuY2hDb25kaXRpb25zVmFsaWRhdGVQcm9kdWN0SURNaWdyYXRlRmVhdHVyZVN0YXRlc1Byb2Nlc3NDb21wb2' + `
        '5lbnRzVW5wdWJsaXNoRmVhdHVyZXNSZW1vdmVSZWdpc3RyeVZhbHVlc1dyaXRlUmVnaXN0cnlWYWx1ZXNSZWd' + `
        'pc3RlclVzZXJSZWdpc3RlclByb2R1Y3RSZW1vdmVFeGlzdGluZ1Byb2R1Y3RzTk9UIFdJWF9ET1dOR1JBREVf' + `
        'REVURUNURURBIG5ld2VyIHZlcnNpb24gb2YgW1Byb2R1Y3ROYW1lXSBpcyBhbHJlYWR5IGluc3RhbGxlZC5BT' + `
        'ExVU0VSUzFNYW51ZmFjdHVyZXJNaWNyb3NvZnQgVW5pdCBUZXN0aW5nIEd1aWxkIG9mIEFtZXJpY2FQcm9kdW' + `
        'N0Q29kZXtERUFEQkVFRi04MEM2LTQxRTYtQTFCOS04QkRCOEEwNTAyN0Z9UHJvZHVjdExhbmd1YWdlMTAzM1B' + `
        'yb2R1Y3ROYW1lRFNDVW5pdFRlc3RQYWNrYWdlUHJvZHVjdFZlcnNpb24xLjIuMy40ezgzQkMzNzkyLTgwQzYt' + `
        'NDFFNi1BMUI5LThCREI4QTA1MDI3Rn1TZWN1cmVDdXN0b21Qcm9wZXJ0aWVzV0lYX0RPV05HUkFERV9ERVRFQ' + `
        '1RFRDtXSVhfVVBHUkFERV9ERVRFQ1RFRFdpeFBkYlBhdGhDOlxVc2Vyc1xiZWNhcnJcRG9jdW1lbnRzXFZpc3' + `
        'VhbCBTdHVkaW8gMjAxMFxQcm9qZWN0c1xEU0NTZXR1cFByb2plY3RcRFNDU2V0dXBQcm9qZWN0XGJpblxEZWJ' + `
        '1Z1xEU0NTZXR1cFByb2plY3Qud2l4cGRiU29mdHdhcmVcRFNDVGVzdERlYnVnRW50cnlbfl1EVU1NWUZMQUc9' + `
        'W0RVTU1ZRkxBR11bfl1XSVhfVVBHUkFERV9ERVRFQ1RFRFdJWF9ET1dOR1JBREVfREVURUNURURzZWQgdG8gZ' + `
        'm9yY2UgYSBzcGVjaWZpYyBkaXNwbGF5IG9yZGVyaW5nLkxldmVsVGhlIGluc3RhbGwgbGV2ZWwgYXQgd2hpY2' + `
        'ggcmVjb3JkIHdpbGwgYmUgaW5pdGlhbGx5IHNlbGVjdGVkLiBBbiBpbnN0YWxsIGxldmVsIG9mIDAgd2lsbCB' + `
        'kaXNhYmxlIGFuIGl0ZW0gYW5kIHByZXZlbnQgaXRzIGRpc3BsYXkuVXBwZXJDYXNlVGhlIG5hbWUgb2YgdGhl' + `
        'IERpcmVjdG9yeSB0aGF0IGNhbiBiZSBjb25maWd1cmVkIGJ5IHRoZSBVSS4gQSBub24tbnVsbCB2YWx1ZSB3a' + `
        'WxsIGVuYWJsZSB0aGUgYnJvd3NlIGJ1dHRvbi4wOzE7Mjs0OzU7Njs4Ozk7MTA7MTY7MTc7MTg7MjA7MjE7Mj' + `
        'I7MjQ7MjU7MjY7MzI7MzM7MzQ7MzY7Mzc7Mzg7NDg7NDk7NTA7NTI7NQAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATmFtZVRhYmxlQ29sdW1uX1Zh' + `
        'bGlkYXRpb25WYWx1ZU5Qcm9wZXJ0eUlkX1N1bW1hcnlJbmZvcm1hdGlvbkRlc2NyaXB0aW9uU2V0Q2F0ZWdvc' + `
        'nlLZXlDb2x1bW5NYXhWYWx1ZU51bGxhYmxlS2V5VGFibGVNaW5WYWx1ZUlkZW50aWZpZXJOYW1lIG9mIHRhYm' + `
        'xlTmFtZSBvZiBjb2x1bW5ZO05XaGV0aGVyIHRoZSBjb2x1bW4gaXMgbnVsbGFibGVZTWluaW11bSB2YWx1ZSB' + `
        'hbGxvd2VkTWF4aW11bSB2YWx1ZSBhbGxvd2VkRm9yIGZvcmVpZ24ga2V5LCBOYW1lIG9mIHRhYmxlIHRvIHdo' + `
        'aWNoIGRhdGEgbXVzdCBsaW5rQ29sdW1uIHRvIHdoaWNoIGZvcmVpZ24ga2V5IGNvbm5lY3RzVGV4dDtGb3JtY' + `
        'XR0ZWQ7VGVtcGxhdGU7Q29uZGl0aW9uO0d1aWQ7UGF0aDtWZXJzaW9uO0xhbmd1YWdlO0lkZW50aWZpZXI7Qm' + `
        'luYXJ5O1VwcGVyQ2FzZTtMb3dlckNhc2U7RmlsZW5hbWU7UGF0aHM7QW55UGF0aDtXaWxkQ2FyZEZpbGVuYW1' + `
        'lO1JlZ1BhdGg7Q3VzdG9tU291cmNlO1Byb3BlcnR5O0NhYmluZXQ7U2hvcnRjdXQ7Rm9ybWF0dGVkU0RETFRl' + `
        'eHQ7SW50ZWdlcjtEb3VibGVJbnRlZ2VyO1RpbWVEYXRlO0RlZmF1bHREaXJTdHJpbmcgY2F0ZWdvcnlUZXh0U' + `
        '2V0IG9mIHZhbHVlcyB0aGF0IGFyZSBwZXJtaXR0ZWREZXNjcmlwdGlvbiBvZiBjb2x1bW5BZG1pbkV4ZWN1dG' + `
        'VTZXF1ZW5jZUFjdGlvbk5hbWUgb2YgYWN0aW9uIHRvIGludm9rZSwgZWl0aGVyIGluIHRoZSBlbmdpbmUgb3I' + `
        'gdGhlIGhhbmRsZXIgRExMLkNvbmRpdGlvbk9wdGlvbmFsIGV4cHJlc3Npb24gd2hpY2ggc2tpcHMgdGhlIGFj' + `
        'dGlvbiBpZiBldmFsdWF0ZXMgdG8gZXhwRmFsc2UuSWYgdGhlIGV4cHJlc3Npb24gc3ludGF4IGlzIGludmFsa' + `
        'WQsIHRoZSBlbmdpbmUgd2lsbCB0ZXJtaW5hdGUsIHJldHVybmluZyBpZXNCYWRBY3Rpb25EYXRhLlNlcXVlbm' + `
        'NlTnVtYmVyIHRoYXQgZGV0ZXJtaW5lcyB0aGUgc29ydCBvcmRlciBpbiB3aGljaCB0aGUgYWN0aW9ucyBhcmU' + `
        'gdG8gYmUgZXhlY3V0ZWQuICBMZWF2ZSBibGFuayB0byBzdXBwcmVzcyBhY3Rpb24uQWRtaW5VSVNlcXVlbmNl' + `
        'QWR2dEV4ZWN1dGVTZXF1ZW5jZUNvbXBvbmVudFByaW1hcnkga2V5IHVzZWQgdG8gaWRlbnRpZnkgYSBwYXJ0a' + `
        'WN1bGFyIGNvbXBvbmVudCByZWNvcmQuQ29tcG9uZW50SWRHdWlkQSBzdHJpbmcgR1VJRCB1bmlxdWUgdG8gdG' + `
        'hpcyBjb21wb25lbnQsIHZlcnNpb24sIGFuZCBsYW5ndWFnZS5EaXJlY3RvcnlfRGlyZWN0b3J5UmVxdWlyZWQ' + `
        'ga2V5IG9mIGEgRGlyZWN0b3J5IHRhYmxlIHJlY29yZC4gVGhpcyBpcyBhY3R1YWxseSBhIHByb3BlcnR5IG5h' + `
        'bWUgd2hvc2UgdmFsdWUgY29udGFpbnMgdGhlIGFjdHVhbCBwYXRoLCBzZXQgZWl0aGVyIGJ5IHRoZSBBcHBTZ' + `
        'WFyY2ggYWN0aW9uIG9yIHdpdGggdGhlIGRlZmF1bHQgc2V0dGluZyBvYnRhaW5lZCBmcm9tIHRoZSBEaXJlY3' + `
        'RvcnkgdGFibGUuQXR0cmlidXRlc1JlbW90ZSBleGVjdXRpb24gb3B0aW9uLCBvbmUgb2YgaXJzRW51bUEgY29' + `
        'uZGl0aW9uYWwgc3RhdGVtZW50IHRoYXQgd2lsbCBkaXNhYmxlIHRoaXMgY29tcG9uZW50IGlmIHRoZSBzcGVj' + `
        'aWZpZWQgY29uZGl0aW9uIGV2YWx1YXRlcyB0byB0aGUgJ1RydWUnIHN0YXRlLiBJZiBhIGNvbXBvbmVudCBpc' + `
        'yBkaXNhYmxlZCwgaXQgd2lsbCBub3QgYmUgaW5zdGFsbGVkLCByZWdhcmRsZXNzIG9mIHRoZSAnQWN0aW9uJy' + `
        'BzdGF0ZSBhc3NvY2lhdGVkIHdpdGggdGhlIGNvbXBvbmVudC5LZXlQYXRoRmlsZTtSZWdpc3RyeTtPREJDRGF' + `
        '0YVNvdXJjZUVpdGhlciB0aGUgcHJpbWFyeSBrZXkgaW50byB0aGUgRmlsZSB0YWJsZSwgUmVnaXN0cnkgdGFi' + `
        'bGUsIG9yIE9EQkNEYXRhU291cmNlIHRhYmxlLiBUaGlzIGV4dHJhY3QgcGF0aCBpcyBzdG9yZWQgd2hlbiB0a' + `
        'GUgY29tcG9uZW50IGlzIGluc3RhbGxlZCwgYW5kIGlzIHVzZWQgdG8gZGV0ZWN0IHRoZSBwcmVzZW5jZSBvZi' + `
        'B0aGUgY29tcG9uZW50IGFuZCB0byByZXR1cm4gdGhlIHBhdGggdG8gaXQuVW5pcXVlIGlkZW50aWZpZXIgZm9' + `
        'yIGRpcmVjdG9yeSBlbnRyeSwgcHJpbWFyeSBrZXkuIElmIGEgcHJvcGVydHkgYnkgdGhpcyBuYW1lIGlzIGRl' + `
        'ZmluZWQsIGl0IGNvbnRhaW5zIHRoZSBmdWxsIHBhdGggdG8gdGhlIGRpcmVjdG9yeS5EaXJlY3RvcnlfUGFyZ' + `
        'W50UmVmZXJlbmNlIHRvIHRoZSBlbnRyeSBpbiB0aGlzIHRhYmxlIHNwZWNpZnlpbmcgdGhlIGRlZmF1bHQgcG' + `
        'FyZW50IGRpcmVjdG9yeS4gQSByZWNvcmQgcGFyZW50ZWQgdG8gaXRzZWxmIG9yIHdpdGggYSBOdWxsIHBhcmV' + `
        'udCByZXByZXNlbnRzIGEgcm9vdCBvZiB0aGUgaW5zdGFsbCB0cmVlLkRlZmF1bHREaXJUaGUgZGVmYXVsdCBz' + `
        'dWItcGF0aCB1bmRlciBwYXJlbnQncyBwYXRoLkZlYXR1cmVQcmltYXJ5IGtleSB1c2VkIHRvIGlkZW50aWZ5I' + `
        'GEgcGFydGljdWxhciBmZWF0dXJlIHJlY29yZC5GZWF0dXJlX1BhcmVudE9wdGlvbmFsIGtleSBvZiBhIHBhcm' + `
        'VudCByZWNvcmQgaW4gdGhlIHNhbWUgdGFibGUuIElmIHRoZSBwYXJlbnQgaXMgbm90IHNlbGVjdGVkLCB0aGV' + `
        'uIHRoZSByZWNvcmQgd2lsbCBub3QgYmUgaW5zdGFsbGVkLiBOdWxsIGluZGljYXRlcyBhIHJvb3QgaXRlbS5U' + `
        'aXRsZVNob3J0IHRleHQgaWRlbnRpZnlpbmcgYSB2aXNpYmxlIGZlYXR1cmUgaXRlbS5Mb25nZXIgZGVzY3Jpc' + `
        'HRpdmUgdGV4dCBkZXNjcmliaW5nIGEgdmlzaWJsZSBmZWF0dXJlIGl0ZW0uRGlzcGxheU51bWVyaWMgc29ydC' + `
        'BvcmRlciwgdXNlZCB0byBmb3JjZSBhIHNwZWNpZmljIGRpc3BsYXkgb3JkZXJpbmcuTGV2ZWxUaGUgaW5zdGF' + `
        'sbCBsZXZlbCBhdCB3aGljaCByZWNvcmQgd2lsbCBiZSBpbml0aWFsbHkgc2VsZWN0ZWQuIEFuIGluc3RhbGwg' + `
        'bGV2ZWwgb2YgMCB3aWxsIGRpc2FibGUgYW4gaXRlbSBhbmQgcHJldmVudCBpdHMgZGlzcGxheS5VcHBlckNhc' + `
        '2VUaGUgbmFtZSBvZiB0aGUgRGlyZWN0b3J5IHRoYXQgY2FuIGJlIGNvbmZpZ3VyZWQgYnkgdGhlIFVJLiBBIG' + `
        '5vbi1udWxsIHZhbHVlIHdpbGwgZW5hYmxlIHRoZSBicm93c2UgYnV0dG9uLjA7MTsyOzQ7NTs2Ozg7OTsxMDs' + `
        'xNjsxNzsxODsyMDsyMTsyMjsyNDsyNTsyNjszMjszMzszNDszNjszNzszODs0ODs0OTs1MDs1Mjs1Mzs1NEZl' + `
        'YXR1cmUgYXR0cmlidXRlc0ZlYXR1cmVDb21wb25lbnRzRmVhdHVyZV9Gb3JlaWduIGtleSBpbnRvIEZlYXR1c' + `
        'mUgdGFibGUuQ29tcG9uZW50X0ZvcmVpZ24ga2V5IGludG8gQ29tcG9uZW50IHRhYmxlLkZpbGVQcmltYXJ5IG' + `
        'tleSwgbm9uLWxvY2FsaXplZCB0b2tlbiwgbXVzdCBtYXRjaCBpZGVudGlmaWVyIGluIGNhYmluZXQuICBGb3I' + `
        'gdW5jb21wcmVzc2VkIGZpbGVzLCB0aGlzIGZpZWxkIGlzIGlnbm9yZWQuRm9yZWlnbiBrZXkgcmVmZXJlbmNp' + `
        'bmcgQ29tcG9uZW50IHRoYXQgY29udHJvbHMgdGhlIGZpbGUuRmlsZU5hbWVGaWxlbmFtZUZpbGUgbmFtZSB1c' + `
        '2VkIGZvciBpbnN0YWxsYXRpb24sIG1heSBiZSBsb2NhbGl6ZWQuICBUaGlzIG1heSBjb250YWluIGEgInNob3' + `
        'J0IG5hbWV8bG9uZyBuYW1lIiBwYWlyLkZpbGVTaXplU2l6ZSBvZiBmaWxlIGluIGJ5dGVzIChsb25nIGludGV' + `
        'nZXIpLlZlcnNpb25WZXJzaW9uIHN0cmluZyBmb3IgdmVyc2lvbmVkIGZpbGVzOyAgQmxhbmsgZm9yIHVudmVy' + `
        'c2lvbmVkIGZpbGVzLkxhbmd1YWdlTGlzdCBvZiBkZWNpbWFsIGxhbmd1YWdlIElkcywgY29tbWEtc2VwYXJhd' + `
        'GVkIGlmIG1vcmUgdGhhbiBvbmUuSW50ZWdlciBjb250YWluaW5nIGJpdCBmbGFncyByZXByZXNlbnRpbmcgZm' + `
        'lsZSBhdHRyaWJ1dGVzICh3aXRoIHRoZSBkZWNpbWFsIHZhbHVlIG9mIGVhY2ggYml0IHBvc2l0aW9uIGluIHB' + `
        'hcmVudGhlc2VzKVNlcXVlbmNlIHdpdGggcmVzcGVjdCB0byB0aGUgbWVkaWEgaW1hZ2VzOyBvcmRlciBtdXN0' + `
        'IHRyYWNrIGNhYmluZXQgb3JkZXIuSW5zdGFsbEV4ZWN1dGVTZXF1ZW5jZUluc3RhbGxVSVNlcXVlbmNlTGF1b' + `
        'mNoQ29uZGl0aW9uRXhwcmVzc2lvbiB3aGljaCBtdXN0IGV2YWx1YXRlIHRvIFRSVUUgaW4gb3JkZXIgZm9yIG' + `
        'luc3RhbGwgdG8gY29tbWVuY2UuRm9ybWF0dGVkTG9jYWxpemFibGUgdGV4dCB0byBkaXNwbGF5IHdoZW4gY29' + `
        'uZGl0aW9uIGZhaWxzIGFuZCBpbnN0YWxsIG11c3QgYWJvcnQuTWVkaWFEaXNrSWRQcmltYXJ5IGtleSwgaQgA' + `
        'AgAIAAIACAACAAoAFgANAAEADgABAAMAAQAeAAEAAQAnABUAAQAVAAEANgABACQAAQD1AAEADwABAAQACQAgA' + `
        'AEAFQABABQABwAGAAoAQgAFAAkAFQCfAAUACAAMAG8ABQAPAAcAEwAHAAkAEgA7AAEACwACAAQAAgA+AAEACg' + `
        'AEAAkADADSAAEACgAIACcAAQDoAAEABwACABwAAQDjAAEAhgABABAAAgCmAAEACgADACkAAQAHABUAOQABAA4' + `
        'AAgCUAAEABQACAC4AAQA6AAEABwACAD4AAQAFAAIAgQABAAkAAgBrAAEAUQABABIAAQARAAUACAACAB8AAQAK' + `
        'AAYAIQABAAQAFABzAAEAOQABAAgAAgAIAAEAYwABAAgAAgAlAAEABwADAEEAAQAIAAYAPwABAHYAAQBKAAEAF' + `
        'gAHABEABwAPAAUASAABAAkABABIAAEABQANAAYAAgA3AAEADAACADYAAQAKAAIAhAABAAcAAwBmAAEACwACAC' + `
        'MAAQAGAAIACAAIADcAAQA+AAEAMAABAAgADwAhAAEABAACAD8AAQADAAIABwABAB8AAQAYAAEAEwABAG4AAQA' + `
        'HAA8ACwADADsAAQAKAAIAfgABAAoAAgB+AAEAYAABACMAAQAGAAIAYAABAA4AAgA4AAEADgAFAAgABAAMAAUA' + `
        'DwADABEAAwATAAEADAABAA8AAwANAAIADwACAA4AAgAQAAMAJgABAA0AAgAOAAIAEgACABgAAQAJAAIAAQABA' + `
        'AkAAQAOAAIADwABABMAAgAQAAIAEQACABQAAgARAAEAEQABABQAAQATAAEADAABAA8AAQAWAAEAGgABADYAAQ' + `
        'AIAAEAAQABAAwAAQAnAAEACwABACYAAQAPAAEABAABAAsAAQASAAEADgABAAcAAwAmAAMAFgABACsAAQAKAAE' + `
        'AdgABABAAAQAKAAEAGwABABQAAQAWAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' + `
        'AAAAAAAAAAAAAAAAAAA='
    #endregion

    $msiContentInBytes = [System.Convert]::FromBase64String($msiContentInBase64)

    Set-Content -Path $DestinationPath -Value $msiContentInBytes -Encoding 'Byte' | Out-Null
}

<#
    .SYNOPSIS
        Retrieves a localized registry key value.

    .PARAMETER RegistryKey
        The registry key to retrieve the value from.

    .PARAMETER ValueName
        The name of the value to retrieve.
#>
function Get-LocalizedRegistryKeyValue
{
    [CmdletBinding()]
    param
    (
        [Object]
        $RegistryKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ValueName
    )

    $localizedRegistryKeyValue = $RegistryKey.GetValue('{0}_Localized' -f $ValueName)
    
    if ($null -eq $localizedRegistryKeyValue)
    {
        $localizedRegistryKeyValue = $RegistryKey.GetValue($ValueName)
    }

    return $localizedRegistryKeyValue
}

Export-ModuleMember -Function `
    New-TestMsi, `
    Clear-xPackageCache, `
    New-MockFileServer, `
    New-TestExecutable, `
    Test-PackageInstalledByName
