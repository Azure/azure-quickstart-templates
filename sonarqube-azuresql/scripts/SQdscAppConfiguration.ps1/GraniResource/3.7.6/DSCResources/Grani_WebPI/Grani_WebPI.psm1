#region Initialize
$Script:WebPlatformInstaller = [ordered]@{}
$WebPlatformInstaller.RequiredAssemblies = 'C:\Program Files\Microsoft\Web Platform Installer\Microsoft.Web.PlatformInstaller.dll'
$WebPlatformInstaller.Requiredexe = 'C:\Program Files\Microsoft\Web Platform Installer\WebpiCmd-x64.exe'

function New-WebPlatformInstaller
{
    [OutputType([Void])] 
    [CmdletBinding()]
    param()

    if (-not(Test-Path $WebPlatformInstaller.RequiredAssemblies)){ throw New-Object System.IO.FileNotFoundException ("Unable to find the specified file.", $WebPlatformInstaller.RequiredAssemblies) }
    if (-not(Test-Path $WebPlatformInstaller.Requiredexe)){ throw New-Object System.IO.FileNotFoundException ("Unable to find the specified file.", $WebPlatformInstaller.Requiredexe) }

    try
    {
        [reflection.assembly]::LoadWithPartialName("Microsoft.Web.PlatformInstaller") > $null
        Add-Type -Path $WebPlatformInstaller.RequiredAssemblies
    }
    catch
    {
    }
}

New-WebPlatformInstaller

#endregion

#region Resource

function Set-TargetResource
{
    [OutputType([System.String])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Name
    )
    Install-WebPlatformInstallerProgram -ProductId $Name
    if ($?){ Write-Verbose "Installing WebPI Package '$Name' complete."; return; }
}

function Get-TargetResource
{
    [OutputType([HashTable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Name
    )

    $result = Get-WebPlatformInstallerProduct -ProductId $Name -Installed
    return @{
        Name = $result.ProductId
    }
}

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Name
    )

    [bool]$result = (Test-WebPlatformInstallerProductIsInstalled -ProductId $Name) -eq $true
    return $result
}

#endregion

#region Constructor

function New-WebPlatformInstallerInstallManager
{
    [OutputType([Void])]
    [CmdletBinding()]
    param()

    $WebPlatformInstaller.installManager = New-Object Microsoft.Web.PlatformInstaller.InstallManager
}

function New-WebPlatformInstallerProductManager
{
    [OutputType([Void])] 
    [CmdletBinding()]
    param()

    $productManager = New-Object Microsoft.Web.PlatformInstaller.ProductManager
    $productManager.Load()
    $WebPlatformInstaller.productManager = $productManager
    
    Write-Verbose "Remove Blank Keywords Products"
    $WebPlatformInstaller.productManagerProducts = $WebPlatformInstaller.productManager.Products | where Keywords
    $WebPlatformInstaller.productManagerProductsBlankKeyword = $WebPlatformInstaller.productManager.Products | where {$_.Keywords.Name -eq $null}
}

#endregion

#region Product

function Get-WebPlatformInstallerProduct
{
<#
.Synopsis
   Get WebPlatformInstaller Packages.
.DESCRIPTION
   This function will return Product information for WebPlatform Installer.
   You can select 2 mode.
   1. -ProductId will give you availability to filter package.
   2. Omit -ProductId will return all packages.
   
   Make sure No keyword items and IIS Components (Windows Feature) will never checked.
.EXAMPLE
   Get-WebPlatformInstallerProduct
   # Returns All Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -Installed
   # Returns All Installed Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -Available
   # Returns All Available Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -ProductId WDeploy
   # Returns WDeploy Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -ProductId WDeploy -Installed
   # Returns WDeploy Product information if installed
.EXAMPLE
   Get-WebPlatformInstallerProduct -ProductId WDeploy -Available
   # Returns WDeploy Product information if available
#>
    [OutputType([Microsoft.Web.PlatformInstaller.Product[]])] 
    [CmdletBinding(DefaultParameterSetName = "Any")]
    param
    (
        [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1, ValueFromPipeline = 1)]
        [string[]]$ProductId,
        
        [parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "Installed")]
        [switch]$Installed,
        
        [parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "Available")]
        [switch]$Available,

        [switch]$Force
    )

    begin
    {
        if (($null -eq $WebPlatformInstaller.productManagerProducts) -or $Force){ New-WebPlatformInstallerProductManager }

        # Initialize
        if ($PSBoundParameters.ContainsKey('ProductId'))
        {
            $result = $null
            $private:productManagerDic = New-Object 'System.Collections.Generic.Dictionary[[string], [Microsoft.Web.PlatformInstaller.Product]]' ([StringComparer]::OrdinalIgnoreCase)
            $private:productManagerList = New-Object 'System.Collections.Generic.List[Microsoft.Web.PlatformInstaller.Product]'
            $WebPlatformInstaller.productManagerProducts | %{$productManagerDic.Add($_.ProductId, $_)}
        }
    }

    process
    {
        if (-not $PSBoundParameters.ContainsKey('ProductId'))
        {
            Write-Verbose ("Searching All Products.")
            switch ($true)
            {
                $Installed { return $WebPlatformInstaller.productManagerProducts | where {$_.IsInstalled($false) } | sort ProductId }
                $Available { return $WebPlatformInstaller.productManagerProducts | where {-not $_.IsInstalled($false) } | sort ProductId }
                Default { return $WebPlatformInstaller.productManagerProducts | sort ProductId }
            }
        }

        foreach ($id in $ProductId)
        {
            # Search product by ProductId
            Write-Verbose ("Searching ProductId : '{0}'" -f $id)
            $isSuccess = $productManagerDic.TryGetValue($id, [ref]$result)

            # Success
            if ($isSuccess){ $productManagerList.Add($result); continue; }

            # Skip
            if ($id -in $WebPlatformInstaller.productManagerProductsBlankKeyword.ProductId){ [Console]::WriteLine("ProductId '{0}' will skip as it is not supported." -f $id); continue; }

            # Fail
            throw New-Object System.InvalidOperationException ("WebPlatform Installation could not found package '{0}' as valid ProductId. Please select from '{1}'" -f $id, (($WebPlatformInstaller.productManagerProducts.ProductId | sort) -join "', '"))
        }

        switch ($true)
        {
            $Installed { return $productManagerList | where {$_.IsInstalled($false) } | sort ProductId }
            $Available { return $productManagerList | where {-not $_.IsInstalled($false) } | sort ProductId }
            Default { return $productManagerList | sort ProductId }
        }
    }
}

#endregion

#region Install

function Install-WebPlatformInstallerProgram
{
<#
.Synopsis
   Install target Package.
.DESCRIPTION
   This function will install desired Package.
   If Package is already installed, then skip it.
.EXAMPLE
   Install-WebPlatformInstallerProgram -ProductId WDeploy
   # Install WDeploy
#>

    [OutputType([void])] 
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1, ValueFromPipeline = 1)]
        [string[]]$ProductId,

        [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1)]
        [ValidateSet('en', 'fr', 'es', 'de', 'it', 'ja', 'ko', 'ru', 'zh-cn', 'zh-tw', 'cs', 'pl', 'tr', 'pt-br', 'he', 'zh-hk', 'pt-pt')]
        [string]$LanguageCode = 'en'
    )

    process
    {
        Write-Verbose "Checking Product is already installed."
        $ProductId `
        | % {
            if(Test-WebPlatformInstallerProductIsInstalled -ProductId $_){ [Console]::WriteLine("Package '{0}' already installed. Skip installation." -f $_); return; }
            $productIdList.Add($_)
        }
    }

    end
    {
        if (($productIdList | measure).count -eq 0){ return; }
        try
        {
            # Prerequisites
            Write-Verbose "Get Product"
            [Microsoft.Web.PlatformInstaller.Product[]]$product = Get-WebPlatformInstallerProduct -ProductId $productIdList
            if ($null -eq $product){ throw New-Object System.NullReferenceException }

            # Install
            # InstallByNET -LanguageCode $LanguageCode -product $product
            InstallByWebPICmd -Name $ProductId
        }
        catch
        {
            throw $_
        }
        finally
        {
            if ($null -ne $WebPlatformInstaller.installManager){ $WebPlatformInstaller.installManager.Dispose() }
        }
    }

    begin
    {
        # Initialize
        if ($null -eq $WebPlatformInstaller.productManager){ New-WebPlatformInstallerProductManager }
        $productIdList = New-Object 'System.Collections.Generic.List[string]'

        function ShowInstallerContextStatus
        {
            if ($null -ne $WebPlatformInstaller.installManager.InstallerContexts){ $WebPlatformInstaller.installManager.InstallerContexts | Out-String -Stream | Write-Verbose }
        }

        function WatchInstallationStatus
        {
            [OutputType([bool])] 
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [string]$ProductId,

                [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [Microsoft.Web.PlatformInstaller.InstallationState]$PreStatus,

                [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [Microsoft.Web.PlatformInstaller.InstallationState]$PostStatus
            )

            # Skip
            if ($postStatus -eq $preStatus)
            {
                Write-Verbose "Installation not begin"
                return $false
            }

            # Monitor
            ShowInstallerContextStatus
            while($postStatus -ne [Microsoft.Web.PlatformInstaller.InstallationState]::InstallCompleted)
            {
                Start-Sleep -Milliseconds 100
                $postStatus = $WebPlatformInstaller.installManager.InstallerContexts.InstallationState
            }
            ShowInstallerContextStatus
            $logfiles = $WebPlatformInstaller.installManager.InstallerContexts.Installer.LogFiles
            $latestLog = ($logfiles | select -Last 1)
            [Console]::WriteLine(("'{0}' Installation completed. Check Log file at '{1}'" -f ($ProductId -join "', '"), $latestLog))
            Write-Verbose ("Latest Log file is '{0}'." -f (Get-Content -Path $latestLog -Encoding UTF8 -Raw))
            return $true
        }

        function InstallByNET
        {
            [OutputType([void])] 
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [string]$LanguageCode,

                [parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [Microsoft.Web.PlatformInstaller.Product[]]$product
            )

            # Initialize
            New-WebPlatformInstallerInstallManager
            $installer = New-Object 'System.Collections.Generic.List[Microsoft.Web.PlatformInstaller.Installer]'

            # Get Language
            [Microsoft.Web.PlatformInstaller.Language]$language = $WebPlatformInstaller.productManager.GetLanguage($LanguageCode)        

            $product `
            | % {
                Write-Verbose "Get Installer"
                $x = $_.GetInstaller($language)
                if ($null -eq $x.InstallerFile){ [Console]::WriteLine("Package '{0}' detected as no Installer to install. Skip Installation." -f $_.ProductId); return; }
                $installer.Add($x)
                $WebPlatformInstaller.InstallManager.Load($installer)
 
                Write-Verbose "Donwload Installer"
                ShowInstallerContextStatus
                $failureReason = $null
                $success = $WebPlatformInstaller.InstallManager.InstallerContexts | %{ $WebPlatformInstaller.installManager.DownloadInstallerFile($_, [ref]$failureReason) }
                if ((-not $success) -and $failureReason){ throw New-Object System.InvalidOperationException ("Donwloading '{0}' Failed Exception!! Reason : {1}" -f ($ProductId -join "' ,'"), $failureReason ) }
            
                Write-Verbose "Show Donwloaded Installer Status"
                ShowInstallerContextStatus

                # Get Status
                [Microsoft.Web.PlatformInstaller.InstallationState]$preStatus = $WebPlatformInstaller.installManager.InstallerContexts.InstallationState

                Write-Verbose "Start Installation with StartInstallation()"
                $WebPlatformInstaller.installManager.StartInstallation()
                if (WatchInstallationStatus -ProductId $_.ProductId -PreStatus $preStatus -PostStatus $WebPlatformInstaller.installManager.InstallerContexts.InstallationState){ return; }

                Write-Verbose "Start Installation with StartApplicationInstallation()"
                $WebPlatformInstaller.installManager.StartApplicationInstallation()
                if (WatchInstallationStatus -ProductId $_.ProductId -PreStatus $preStatus -PostStatus $WebPlatformInstaller.installManager.InstallerContexts.InstallationState){ return; }

                Write-Verbose "Start Installation with StartSynchronousInstallation()"
                $installResult = $WebPlatformInstaller.installManager.StartSynchronousInstallation()
                if (WatchInstallationStatus -ProductId $_.ProductId -PreStatus $preStatus -PostStatus $WebPlatformInstaller.installManager.InstallerContexts.InstallationState){ return; }
            }
        }

        function InstallByWebPICmd
        {
            [OutputType([Void])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [System.String[]]$Name
            )

            end
            {
                foreach ($x in $Name)
                {
                    Write-Verbose ("Installing package '{0}'" -f $x)
                    [string]$arguments = @(
                        "/Install",
                        "/Products:$x",
                        "/AcceptEula",
                        "/SuppressReboot"
                    )
                    Invoke-WebPICmd -Arguments $arguments
                }
            }

            begin
            {
                Write-Verbose "Start Installation with WebPICmd"
                function Invoke-WebPICmd
                {
                    [OutputType([System.String])]
                    [CmdletBinding()]
                    param
                    (
                        [parameter(Mandatory = $true)]
                        [System.String]$Arguments
                    )

                    $fileName  = "$env:ProgramFiles\Microsoft\Web Platform Installer\WebpiCmd-x64.exe"
                    if (!(Test-Path -Path $fileName)){ throw New-Object System.InvalidOperationException ("Web Platform Installer not installed exception!") }

                    try
                    {
                        $psi = New-Object System.Diagnostics.ProcessStartInfo
                        $psi.CreateNoWindow = $true 
                        $psi.UseShellExecute = $false 
                        $psi.RedirectStandardOutput = $true
                        $psi.RedirectStandardError = $true
                        $psi.FileName = $fileName
                        $psi.Arguments = $Arguments

                        $process = New-Object System.Diagnostics.Process 
                        $process.StartInfo = $psi
                        $process.Start() > $null
                        $output = $process.StandardOutput.ReadToEnd()
                        $process.StandardOutput.ReadLine()
                        $process.WaitForExit() 
                    
                        return $output 
                    }
                    catch
                    {
                        $outputError = $process.StandardError.ReadToEnd()
                        throw $_ + $outputError
                    }
                    finally
                    {
                        if ($null -ne $psi){ $psi = $null}
                        if ($null -ne $process){ $process.Dispose() }
                    }
                }
            }
        }
    }
}

function Test-WebPlatformInstallerProductIsInstalled
{
<#
.Synopsis
   Test target Package is already installed or not.
.DESCRIPTION
   This function will check desired Package is already installed or not yet by Boolean.
   $true  : Means already installed.
   $false : Means not yet installed.
   Pass ProductId which you want to check.
.EXAMPLE
   Test-WebPlatformInstallerProductIsInstalled -ProductId WDeploy
   # Check WDeploy is installed or not.
#>
    [OutputType([bool])] 
    [CmdletBinding(DefaultParameterSetName = "Any")]
    param
    (
        [parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = 1, ValueFromPipeline = 1)]
        [string[]]$ProductId
    )

    # Not use Cached Value
    $result = Get-WebPlatformInstallerProduct -ProductId $ProductId | % {$_.IsInstalled($false)}
    if ($null -ne $result){ Write-Verbose $result }
    return $result
}

#endregion

Export-ModuleMember -Function *-TargetResource