Configuration xFileUpload
{
    <# 
    .SYNOPSIS 
        Configuration uploads file or folder to the smb share
    .DESCRIPTION
    .EXAMPLE 
        xFileUpload -destinationPath "\\machine\share" -sourcePath "C:\folder\file" -username "domain\user" -password "password"
    .PARAMETER destinationPath
        Upload destination (has to point to a share or it's existing subfolder) e.g. \\machinename\sharename\destinationfolder
    .PARAMETER sourcePath
        Upload source e.g. C:\folder\file.txt
    .PARAMETER credential
        Credentials to access share where file/folder should be uploaded
    .PARAMETER certificateThumbprint
        Thumbprint of the certificate which should be used for encryption/decryption
    .NOTES
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]

    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $destinationPath,
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]        
        $sourcePath,
        [PSCredential]
        $credential,
        [String]
        $certificateThumbprint
    )

    $cacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltinProvCache\MSFT_xFileUpload"
    
    if ($credential)
    {
        $username = $credential.UserName

        # Encrypt password
        $password = Invoke-Command -ScriptBlock ([ScriptBlock]::Create($getEncryptedPassword)) -ArgumentList $credential, $certificateThumbprint

    }
    
    Script FileUpload 
    {
        # Get script is not implemented cause reusing Script resource's schema does not make sense
        GetScript = { 
            $returnValue = @{
                   
            }

            $returnValue
        };
            
        SetScript = { 

            # Generating credential object if password and username are specified
            $credential = $null
            if (($using:password) -and ($using:username))
            {
                # Validate that certificate thumbprint is specified
                if(-not $using:certificateThumbprint)
                {
                    $errorMessage = "Certificate thumbprint has to be specified if credentials are present."
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "CertificateThumbprintIsRequired", $errorMessage, "InvalidData"
                }

                Write-Debug "Username and password specified."

                # Decrypt password
                $decryptedPassword = Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:getDecryptedPassword)) -ArgumentList $using:password, $using:certificateThumbprint
                
                # Generate credential
                $securePassword = ConvertTo-SecureString $decryptedPassword -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential ($using:username, $securePassword)
            }

            # Validate DestinationPath is UNC path
            if (!($using:destinationPath -as [System.Uri]).isUnc)
            {
                $errorMessage = "Destination path $using:destinationPath is not a valid UNC path."
                Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathIsNotUNCFailure", $errorMessage, "InvalidData"
            }

            # Verify source is localpath
            if (!(($using:sourcePath -as [System.Uri]).Scheme -match "file"))
            {
                $errorMessage = "Source path $using:sourcePath has to be local path."
                Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "SourcePathIsNotLocalFailure", $errorMessage, "InvalidData"
            }

            # Check whether source path is existing file or directory
            $sourcePathType = $null
            if (!(Test-Path $using:sourcePath))
            {
                $errorMessage = "Source path $using:sourcePath does not exist."
                Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "SourcePathDoesNotExistFailure", $errorMessage, "InvalidData"
            }
            else
            {
                $item = Get-Item $using:sourcePath
                switch ($item.GetType().Name)
                {
                    "FileInfo" {
                        $sourcePathType = "File"
                    }

                    "DirectoryInfo" {
                        $sourcePathType = "Directory"
                    }
                }
            }
            Write-Debug "SourcePath $using:sourcePath is of type: $sourcePathType"

            $psDrive = $null

            # Mount the drive only if credentials are specified and it's currently not accessible
            if ($credential)
            {
                if (Test-Path $using:destinationPath -ErrorAction Ignore)
                {
                    Write-Debug "Destination path $using:destinationPath is already accessible. No mount needed."
                }
                else
                {
                    $psDriveArgs = @{ Name = ([guid]::NewGuid()); PSProvider = "FileSystem"; Root = $using:destinationPath; Scope = "Private"; Credential = $credential }
                    try
                    {
                        Write-Debug "Create psdrive with destination path $using:destinationPath..."
                        $psDrive = New-PSDrive @psDriveArgs -ErrorAction Stop
                    }
                    catch
                    {
                        $errorMessage = "Cannot access destination path $using:destinationPath with given Credential"
                        Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathNotAccessibleFailure", $errorMessage, "InvalidData"
                    }
                }
            }

            try
            {
                # Get expected destination path
                $expectedDestinationPath = $null
                if (!(Test-Path $using:destinationPath))
                {
                    # DestinationPath has to exist
                    $errorMessage = "Invalid parameter values: DestinationPath doesn't exist, but has to be existing directory."
                    Throw-TerminatingError -errorMessage $errorMessage -errorCategory "InvalidData" -errorId "DestinationPathDoesNotExistFailure"
                }
                else
                {
                    $item = Get-Item $using:destinationPath
                    switch ($item.GetType().Name)
                    {
                        "FileInfo" {
                            # DestinationPath cannot be file
                            $errorMessage = "Invalid parameter values: DestinationPath is file, but has to be existing directory."
                            Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathCannotBeFileFailure", $errorMessage, "InvalidData"
                        }

                        "DirectoryInfo" {
                            $expectedDestinationPath = Join-Path $using:destinationPath (Split-Path $using:sourcePath -Leaf)
                        }
                    }
                    Write-Debug "ExpectedDestinationPath is $expectedDestinationPath"
                }

                # Copy destination path
                try
                {
                    Write-Debug "Copying $using:sourcePath to $using:destinationPath"
                    Copy-Item -path $using:sourcePath -Destination $using:destinationPath -Recurse -Force -ErrorAction Stop
                }
                catch
                {
                    $errorMessage = "Couldn't copy source path $using:sourcePath to $using:destinationPath : $($_.Exception)"
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "CopyDirectoryOverFileFailure", $errorMessage, "InvalidData"
                }

                # Verify whether expectedDestinationPath was created
                if (!(Test-Path $expectedDestinationPath))
                {
                    $errorMessage = "Destination path $using:destinationPath could not be created"
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathNotCreatedFailure", $errorMessage, "InvalidData"
                }
                # If expectedDestinationPath exists
                else
                {
                    Write-Verbose "$sourcePathType $expectedDestinationPath has been successfully created"

                    # Update cache
                    $uploadedItem = Get-Item $expectedDestinationPath
                    $lastWriteTime = $uploadedItem.LastWriteTimeUtc
                    $inputObject = @{}
                    $inputObject["LastWriteTimeUtc"] = $lastWriteTime
                    $key = [string]::Join("", @($using:destinationPath, $using:sourcePath, $expectedDestinationPath)).GetHashCode().ToString()
                    $path = Join-Path $using:cacheLocation $key
                    if(-not (Test-Path $using:cacheLocation))
                    {
                        mkdir $using:cacheLocation | Out-Null
                    }

                    Write-Debug "Updating cache for DestinationPath = $using:destinationPath and SourcePath = $using:sourcePath. CacheKey = $key"
                    Export-CliXml -Path $path -InputObject $inputObject -Force
                }
            }
            finally
            {
                # Remove PSDrive
                if($psDrive)
                {
                    Write-Debug "Removing PSDrive on root $($psDrive.Root)"
                    Remove-PSDrive $psDrive -Force
                }
            }
        };
            
        TestScript = { 
            
            # Generating credential object if password and username are specified
            $credential = $null
            if (($using:password) -and ($using:username))
            {
                # Validate that certificate thumbprint is specified
                if(-not $using:certificateThumbprint)
                {
                    $errorMessage = "Certificate thumbprint has to be specified if credentials are present."
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "CertificateThumbprintIsRequired", $errorMessage, "InvalidData"
                }

                Write-Debug "Username and password specified. Generating credential"
                
                # Decrypt password
                $decryptedPassword = Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:getDecryptedPassword)) -ArgumentList $using:password, $using:certificateThumbprint

                # Generate credential
                $securePassword = ConvertTo-SecureString $decryptedPassword -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential ($using:username, $securePassword)
            }
            else
            {
                Write-Debug "No credentials specified"
            }

            # Validate DestinationPath is UNC path
            if (!($using:destinationPath -as [System.Uri]).isUnc)
            {
                $errorMessage = "Destination path $using:destinationPath is not a valid UNC path."
                Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathIsNotUNCFailure", $errorMessage, "InvalidData"

            }

            # Check whether source path is existing file or directory (needed for expectedDestinationPath)
            $sourcePathType = $null
            if (!(Test-Path $using:sourcePath))
            {
                $errorMessage = "Source path $using:sourcePath does not exist."
                Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "SourcePathDoesNotExistFailure", $errorMessage, "InvalidData"
            }
            else
            {
                $item = Get-Item $using:sourcePath
                switch ($item.GetType().Name)
                {
                    "FileInfo" {
                        $sourcePathType = "File"
                    }

                    "DirectoryInfo" {
                        $sourcePathType = "Directory"
                    }
                }
            }
            Write-Debug "SourcePath $using:sourcePath is of type: $sourcePathType"

            $psDrive = $null

            # Mount the drive only if credentials are specified and it's currently not accessible
            if ($credential)
            {
                if (Test-Path $using:destinationPath -ErrorAction Ignore)
                {
                    Write-Debug "Destination path $using:destinationPath is already accessible. No mount needed."
                }
                else
                {
                    $psDriveArgs = @{ Name = ([guid]::NewGuid()); PSProvider = "FileSystem"; Root = $using:destinationPath; Scope = "Private"; Credential = $credential }
                    try
                    {
                        Write-Debug "Create psdrive with destination path $using:destinationPath..."
                        $psDrive = New-PSDrive @psDriveArgs -ErrorAction Stop
                    }
                    catch
                    {
                        $errorMessage = "Cannot access destination path $using:destinationPath with given Credential"
                        Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathNotAccessibleFailure", $errorMessage, "InvalidData"
                    }
                }
            }

            try
            {
                # Get expected destination path
                $expectedDestinationPath = $null
                if (!(Test-Path $using:destinationPath))
                {
                    # DestinationPath has to exist
                    $errorMessage = "Invalid parameter values: DestinationPath doesn't exist or is not accessible. DestinationPath has to be existing directory."
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathDoesNotExistFailure", $errorMessage, "InvalidData"
                }
                else
                {
                    $item = Get-Item $using:destinationPath
                    switch ($item.GetType().Name)
                    {
                        "FileInfo" {
                            # DestinationPath cannot be file
                            $errorMessage = "Invalid parameter values: DestinationPath is file, but has to be existing directory."
                            Invoke-Command -ScriptBlock ([ScriptBlock]::Create($using:throwTerminatingError)) -ArgumentList "DestinationPathCannotBeFileFailure", $errorMessage, "InvalidData"
                        }

                        "DirectoryInfo" {
                            $expectedDestinationPath = Join-Path $using:destinationPath (Split-Path $using:sourcePath -Leaf)
                        }
                    }
                    Write-Debug "ExpectedDestinationPath is $expectedDestinationPath"
                }

                # Check whether ExpectedDestinationPath exists and has expected type
                $itemExists = $false
                if (!(Test-Path $expectedDestinationPath))
                {
                    Write-Debug "Expected destination path doesn't exist or is not accessible"
                }
                # If expectedDestinationPath exists
                else
                {
                    $expectedItem = Get-Item $expectedDestinationPath
                    $expectedItemType = $expectedItem.GetType().Name
                        
                    # If expectedDestinationPath has same type as sourcePathType, we need to verify cache to determine whether no upload is needed
                    if ((($expectedItemType -eq "FileInfo") -and ($sourcePathType -eq "File")) -or (($expectedItemType -eq "DirectoryInfo") -and ($sourcePathType -eq "Directory")))
                    {
                        # Get cache
                        Write-Debug "Getting cache for $expectedDestinationPath"
                        $cacheContent = $null
                        $key = [string]::Join("", @($using:destinationPath, $using:sourcePath, $expectedDestinationPath)).GetHashCode().ToString()
                        $path = Join-Path $using:cacheLocation $key
                        Write-Debug "Looking for cache under $path"
                        if (!(Test-Path $path))
                        {
                            Write-Debug "No cache found for DestinationPath = $using:destinationPath and SourcePath = $using:sourcePath. CacheKey = $key"
                        }
                        else
                        {
                            $cacheContent = Import-CliXml $path
                            Write-Debug "Found cache for DestinationPath = $using:destinationPath and SourcePath = $using:sourcePath. CacheKey = $key"
                        }

                        # Verify whether cache reflects current state or upload is needed
                        if ($cacheContent -ne $null -and ($cacheContent.LastWriteTimeUtc -eq $expectedItem.LastWriteTimeUtc))
                        {
                            # No upload needed                                
                            Write-Debug "Cache reflects current state. No need for upload."
                            $itemExists = $true
                        }
                        else
                        {
                            Write-Debug "Cache is empty or it doesn't reflect current state. Upload will be performed."
                        }    
                    }
                    else
                    {
                        Write-Debug "Expected destination path: $expectedDestinationPath is of type $expectedItemType, although source path is $sourcePathType"
                    }
                }
            }
            finally
            {
                # Remove PSDrive
                if($psDrive)
                {
                    Write-Debug "Removing PSDrive on root $($psDrive.Root)"
                    Remove-PSDrive $psDrive -Force
                }
            }

            return $itemExists

        };
    }
}

# Encrypts password using the defined public key
$getEncryptedPassword = @'
    param (
            [Parameter(Mandatory = $true)]
            [PSCredential] $credential,
            [Parameter(Mandatory = $true)]
            [String] $certificateThumbprint
        )

    $value = $credential.GetNetworkCredential().Password
    
    $cert = Invoke-Command -ScriptBlock ([ScriptBlock]::Create($getCertificate)) -ArgumentList $certificateThumbprint
    
    $encryptedPassword = $null

    if($cert)
    {
        # Cast the public key correctly
        $rsaProvider = [System.Security.Cryptography.RSACryptoServiceProvider]$cert.PublicKey.Key
        
        if($rsaProvider -eq $null)
        {
            $errorMessage = "Could not get public key from certificate with thumbprint: $certificateThumbprint . Please verify certificate is valid for encryption."
            Invoke-Command -ScriptBlock ([ScriptBlock]::Create($throwTerminatingError)) -ArgumentList "DecryptionCertificateNotFound", $errorMessage, "InvalidOperation"
        }

        # Convert to a byte array
        $keybytes = [System.Text.Encoding]::UNICODE.GetBytes($value)

        # Add a null terminator to the byte array
        $keybytes += 0
        $keybytes += 0

        # Encrypt using the public key
        $encbytes = $rsaProvider.Encrypt($keybytes, $false)

        # Return a string
        $encryptedPassword = [Convert]::ToBase64String($encbytes)
    }
    else
    {
        $errorMessage = "Could not find certificate which matches thumbprint: $certificateThumbprint . Could not encrypt password"
        Invoke-Command -ScriptBlock ([ScriptBlock]::Create($throwTerminatingError)) -ArgumentList "EncryptionCertificateNot", $errorMessage, "InvalidOperation"
    }

    return $encryptedPassword
'@

# Retrieves certificate by thumbprint
$getCertificate = @'
    param(
        [Parameter(Mandatory = $true)]
        [string] $certificateThumbprint
    )

    $cert = $null

    foreach($certIndex in Get-Childitem cert:\LocalMachine\My)
    {
        if($certIndex.Thumbprint -match $certificateThumbprint)
        {
            $cert = $certIndex
            break
        }
    }

    if(-not $cert)
    {        
        $errorMessage = "Error Reading certificate store for {0}. Please verify thumbprint is correct and certificate belongs to cert:\LocalMachine\My store." -f ${certificateThumbprint};
        Invoke-Command -ScriptBlock ([ScriptBlock]::Create($throwTerminatingError)) -ArgumentList "InvalidPathSpecified", $errorMessage, "InvalidOperation" 
    }
    else
    {
        $cert
    }
'@

# Throws terminating error specified errorCategory, errorId and errorMessage
$throwTerminatingError = @'
    param(
        [parameter(Mandatory = $true)]
        [System.String] 
        $errorId,
        [parameter(Mandatory = $true)]
        [System.String]
        $errorMessage,
        [parameter(Mandatory = $true)]
        $errorCategory
    )

    $exception = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
'@

# Decrypts password using the defined private key
$getDecryptedPassword = @'
    param (
            [Parameter(Mandatory = $true)]
            [String] $value,
            [Parameter(Mandatory = $true)]
            [String] $certificateThumbprint
        )

    $cert = $null

    foreach($certIndex in Get-Childitem cert:\LocalMachine\My)
    {
        if($certIndex.Thumbprint -match $certificateThumbprint)
        {
            $cert = $certIndex
            break
        }
    }

    if(-not $cert)
    {        
        $errorMessage = "Error Reading certificate store for {0}. Please verify thumbprint is correct and certificate belongs to cert:\LocalMachine\My store." -f ${certificateThumbprint};
        $exception = New-Object System.InvalidOperationException $errorMessage 
        $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, "InvalidPathSpecified", "InvalidOperation", $null
        throw $errorRecord
    }

    $decryptedPassword = $null

    # Get RSA provider
    $rsaProvider = [System.Security.Cryptography.RSACryptoServiceProvider]$cert.PrivateKey

    if($rsaProvider -eq $null)
    {
        $errorMessage = "Could not get private key from certificate with thumbprint: $certificateThumbprint . Please verify certificate is valid for decryption."
        $exception = New-Object System.InvalidOperationException $errorMessage 
        $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, "DecryptionCertificateNotFound", "InvalidOperation", $null
        throw $errorRecord
    }

    # Convert to bytes array
    $encBytes = [Convert]::FromBase64String($value)

    # Decrypt bytes
    $decryptedBytes = $rsaProvider.Decrypt($encBytes, $false)
        
    # Convert to string
    $decryptedPassword = [System.Text.Encoding]::Unicode.GetString($decryptedBytes)

    return $decryptedPassword
'@
