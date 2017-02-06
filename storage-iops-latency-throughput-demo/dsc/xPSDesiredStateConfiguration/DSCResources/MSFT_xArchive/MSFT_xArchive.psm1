data LocalizedData
{
    # culture="en-US"
    # TODO: Support WhatIf
    ConvertFrom-StringData @'
        InvalidChecksumArgsMessage = Specifying a Checksum without requesting content validation (the Validate parameter) is not meaningful
        InvalidDestinationDirectory = The specified destination directory {0} does not exist or is not a directory
        InvalidSourcePath = The specified source file {0} does not exist or is not a file
        InvalidNetSourcePath = The specified source file {0} is not a valid net source path
        ErrorOpeningExistingFile = An error occurred while opening the file {0} on disk. Please examine the inner exception for details
        ErrorOpeningArchiveFile = An error occurred while opening the archive file {0}. Please examine the inner exception for details
        ItemExistsButIsWrongType = The named item ({0}) exists but is not the expected type, and Force was not specified
        ItemExistsButIsIncorrect = The destination file {0} has been determined not to match the source, but Force has not been specified. Cannot continue
        ErrorCopyingToOutstream = An error was encountered while copying the archived file to {0}
        PackageUninstalled = The archive at {0} was removed from destination {1}
        PackageInstalled = The archive at {0} was unpacked to destination {1}
        ConfigurationStarted = The configuration of MSFT_xArchive is starting
        ConfigurationFinished = The configuration of MSFT_xArchive has completed
        MakeDirectory = Make directory {0}
        RemoveFileAndRecreateAsDirectory = Remove existing file {0} and replace it with a directory of the same name
        RemoveFile = Remove file {0}
        RemoveDirectory = Remove directory {0}
        UnzipFile = Unzip archived file to {0}
        DestMissingOrIncorrectTypeReason = The destination file {0} was missing or was not a file
        DestHasIncorrectHashvalue = The destination file {0} exists but its checksum did not match the origin file
        DestShouldNotBeThereReason = The destination file {0} exists but should not
        UsingKeyToRetrieveHashValue = Using {0} to retrieve hash value
        NoCacheValueFound = No cache value found
        CacheValueFoundReturning = Cache value found, returning {0}
        CacheCorrupt = Cache found, but failed to loaded.  Ignoring Cache.
        Usingtmpkeytosavehashvalue = Using {0} {1} to save hash value
        AboutToCacheValueInputObject = About to cache value {0}
        InUpdateCache = In Update-Cache
        AddingEntryFullNameAsACacheEntry = Adding {0} as a cache entry
        UpdatingCacheObject = Updating CacheObject
        PlacedNewCacheEntry = Placed new cache entry
        NormalizeChecksumReturningChecksum = Normalize-Checksum returning {0}
        PathPathIsAlreadyAccessiableNoMountNeeded. = Path {0} is already accessible. No mount needed.
        PathPathIsNotAValidateNetPath = Path {0} is not a validate net path.
        CreatePsDriveWithPathPath = create psdrive with Path {0}...
        CannotAccessPathPathWithGivenCredential = Cannot access Path {0} with given Credential
        AboutToValidateStandardArguments = About to validate standard arguments
        GoingForCacheEntries = Going for cache entries
        TheCacheWasUpToDateUsingCacheToSatisfyRequests = The cache was up to date, using cache to satisfy requests
        AboutToOpenTheZipFile = About to open the zip file
        CacheUpdatedWithEntries = Cache updated with {0} entries
        Processing = Processing {0}
        InTestTargetResourceDestExistsNotUsingChecksumsContinuing = In Test-TargetResource: {0} exists, not using checksums, continuing
        NotPerformingChecksumTheFileOnDiskHasTheSameWritetTimeAsTheLastTimeWeVerifiedItsContents = Not performing checksum, the file on disk has the same write time as the last time we verified its contents
        DestExistsAndTheHashMatchesEven = {0} exists and the hash matches even though the LastModifiedTime did not. Updating cache
        InTestTargetResourceDestExistsAndTheSelectedTimestampChecksumMatched = In Test-TargetResource: {0} exists and the selected timestamp {1} matched
        RemovePSDriveonRootPsDriveRoot = Remove PSDrive on Root {0}
        RemovingDir = Removing {0}
        HashesOfExistingAndZipFilesMatchRemoving = Hashes of existing and zip files match, removing
        HashDidNotMatchFileHasBeenModifiedSinceItWasExtractedLeaving = Hash did not match, file has been modified since it was extracted. Leaving
        InSetTargetResourceExistsSelectedTimestampMatched = In Set-TargetResource: {0} exists and the selected timestamp {1} matched, removing
        InSetTargetResourceExistsdTheSelectedTimestampNotMatchG = In Set-TargetResource: {0} exists and the selected timestamp {1} did not match, leaving
        ExistingAppearsToBeAnEmptyDirectoryRemovingIt = {0} appears to be an empty directory. Removing it
        LastWriteTimeMtchesWhatWeHaveRecordNotReexaminingChecksum = LastWriteTime of {0} matches what we have on record, not re-examining {1}
        FoundFAtDestWhereGoingToPlaceOneAndHashMatchedContinuing = Found a file at {0} where we were going to place one and hash matched. Continuing
        FoundFileAtDestWhereWeWereGoingToPlaceOneAndHashDidntMatchItWillBeOverwritten = Found a file at $dest where we were going to place one and hash did not match. It will be overwritten
        FoundFileAtDestWhereWeWereGoingToPlaceOneAndDoesNotMatchtTheSourceButForceWasNotSpecifiedErroring = Found a file at {0} where we were going to place one and does not match the source, but Force was not specified. Erroring
        InSetTargetResourceDestExistsAndTheSelectedTimestamp$ChecksumDidNotMatchForceWasSpecifiedWeWillOverwrite = In Set-TargetResource: {0} exists and the selected timestamp {1} did not match. Force was specified, we will overwrite
        FoundAFileAtDestAndTimestampChecksumDoesNotMatchTheSourceButForceWasNotSpecifiedErroring = Found a file at {0} and timestamp {1} does not match the source, but Force was not specified. Erroring
        FoundADirectoryAtDestWhereAFileShouldBeRemoving = Found a directory at {0} where a file should be. Removing
        FoundDirectoryAtDestWhereAFileShouldBeAndForceWasNotSpecifiedErroring = Found a directory at {0} where a file should be and Force was not specified. Erroring.
        WritingToFileDest = Writing to file {0}
        RemovePSDriveonRootDriveRoot = Remove PSDrive on Root {0}
        UpdatingCache = Updating cache
        FolderDirDoesNotExist = Folder {0} does not exist
        ExaminingDirectoryToSeeIfItShouldBeRemoved = Examining {0} to see if it should be removed
        InSetTargetResourceDestExistsAndTheSelectedTimestampChecksumMatchedWillLeaveIt = In Set-TargetResource: {0} exists and the selected timestamp {1} matched, will leave it
'@
}

# Commented-out until more languages are supported
# Import-LocalizedData LocalizedData -FileName 'MSFT_xArchive.strings.psd1'

Import-Module "$PSScriptRoot\..\CommonResourceHelper.psm1"

$script:cacheLocation = "$env:systemRoot\system32\Configuration\BuiltinProvCache\MSFT_ArchiveResource"

function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Destination,

        [Boolean] $Validate = $false,

        [ValidateSet('SHA-1', 'SHA-256', 'SHA-512', 'CreatedDate', 'ModifiedDate')]
        [String] $Checksum,

        [PSCredential] $Credential
    )

    if ($null -eq $Credential)
    {
        $PSBoundParameters.Remove('Credential') > $null
    }

    $ensureValue = 'Absent'
    $testTargetResourceResult = Test-TargetResource @PSBoundParameters

    if ($testTargetResourceResult)
    {
        $ensureValue = 'Present'
    }

    @{
        Ensure = $ensureValue
        Path = $Path
        Destination = $Destination
    }
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Destination,

        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [Boolean] $Validate = $false,

        [ValidateSet('SHA-1', 'SHA-256', 'SHA-512', 'CreatedDate', 'ModifiedDate')]
        [String] $Checksum,

        [Boolean] $Force = $false,

        [PSCredential] $Credential
    )

    if ($Credential)
    {
        $psDrive = Mount-NetworkPath -Path $Path -Credential $Credential
    }

    try
    {
        $ErrorActionPreference = 'Stop'

        Write-Verbose -Message ($LocalizedData.AboutToValidateStandardArguments)

        Assert-PathArgumentValid -Path $Path
        Assert-DestinationArgumentValid -Destination $Destination

        if ($PSBoundParameters.ContainsKey('Checksum'))
        {
            Assert-ValidateAndChecksumArgumentsValid -Validate $Validate -Checksum $Checksum
        }
        else
        {
            Assert-ValidateAndChecksumArgumentsValid -Validate $Validate
        }

        Write-Verbose -Message $LocalizedData.ConfigurationStarted

        if (-not (Test-Path -LiteralPath $Destination))
        {
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }

        $cacheEntry = Get-CacheEntry -Path $Path -Destination $Destination
        $sourceLastWriteTime = (Get-Item -LiteralPath $Path).LastWriteTime

        $cacheUpToDate = $null -ne $cacheEntry -and $null -ne $cacheEntry.SourceLastWriteTime -and $cacheEntry.SourceLastWriteTime -eq $sourceLastWriteTime

        $zipFileHandle = $null
        $archiveEntryNameHashtable = @{}

        try
        {
            if(-not $cacheUpToDate)
            {
                $archiveEntries, $archiveEntryNameHashtable, $zipFileHandle = Open-ZipFile -Path $Path
                Update-Cache -CacheEntryToUpdate $cacheEntry -ArchiveEntries $archiveEntries -Checksum $Checksum -SourceLastWriteTime $sourceLastWriteTime
                $cacheEntry = Get-CacheEntry -Path $Path -Destination $Destination
            }
        }
        finally
        {
            if ($null -ne $zipFileHandle)
            {
                $zipFileHandle.Dispose()
                $zipFileHandle = $null
            }

        }

        $archiveEntries = $cacheEntry.Entries

        if ($Ensure -eq 'Absent')
        {
            $directories = New-Object -TypeName 'System.Collections.Generic.Hashset[String]'

            foreach ($archiveEntry in $archiveEntries)
            {
                $parentDirectory = Split-Path -Path $archiveEntry.FullName

                while (-not [String]::IsNullOrEmpty($parentDirectory))
                {
                    $directories.Add($parentDirectory) | Out-Null
                    $parentDirectory = Split-Path -Path $parentDirectory
                }

                if ($archiveEntry.FullName.EndsWith('\'))
                {
                    $directories.Add($archiveEntry.FullName) | Out-Null
                    continue
                }

                $archiveEntryDestinationPath = Join-Path -Path $Destination -ChildPath $archiveEntry.FullName

                $fileInfoAtDestinationPath = Get-Item -LiteralPath $archiveEntryDestinationPath -ErrorAction SilentlyContinue
                if ($null -eq $fileInfoAtDestinationPath)
                {
                    continue
                }

                # Possible for a folder to have been replaced by a directory of the same name, in which case we must leave it alone
                $fileTypeAtDestinationPath = $fileInfoAtDestinationPath.GetType()
                if ($fileTypeAtDestinationPath -ne [System.IO.FileInfo])
                {
                    continue
                }

                if (-not $Checksum -and $PSCmdlet.ShouldProcess(($LocalizedData.RemoveFile -f $archiveEntryDestinationPath), $null, $null))
                {
                    Write-Verbose -Message ($LocalizedData.RemovingDir -f $archiveEntryDestinationPath)
                    Remove-Item -LiteralPath $archiveEntryDestinationPath
                    continue
                }

                if (Test-ChecksumIsSha -Checksum $Checksum)
                {
                    if ((Test-FileHashMatchesArchiveEntryHash -FilePath $archiveEntryDestinationPath -ArchiveEntry $archiveEntry -HashAlgorithmName $Checksum) -and $PSCmdlet.ShouldProcess(($LocalizedData.RemoveFile -f $archiveEntryDestinationPath), $null, $null))
                    {
                        Write-Verbose -Message ($LocalizedData.HashesOfExistingAndZipFilesMatchRemoving)
                        Remove-Item -LiteralPath $archiveEntryDestinationPath
                    }
                    else
                    {
                        Write-Verbose -Message ($LocalizedData.HashDidNotMatchFileHasBeenModifiedSinceItWasExtractedLeaving)
                    }
                }
                else
                {
                    $relevantTimestamp = Get-RelevantChecksumTimestamp -FileSystemObject $fileInfoAtDestinationPath -Checksum $Checksum
                    if ($relevantTimestamp.Equals($archiveEntry.LastWriteTime.DateTime) -and $PSCmdlet.ShouldProcess(($LocalizedData.RemoveFile -f $archiveEntryDestinationPath), $null, $null))
                    {
                        Write-Verbose -Message ($LocalizedData.InSetTargetResourceexistsselectedtimestampmatched -f $archiveEntryDestinationPath, $Checksum)
                        Remove-Item -LiteralPath $archiveEntryDestinationPath
                    }
                    else
                    {
                        Write-Verbose -Message ($LocalizedData.InSetTargetResourceexistsdtheselectedtimestampnotmatchg -f $archiveEntryDestinationPathg, $Checksum)
                    }
                }
            }

            <#
                    Hashset was useful for dropping dupes in an efficient manner, but it can mess with ordering.
                    Sort according to current culture (directory names can be localized, obviously).
                    Reverse so we hit children before parents.
            #>
            $directories = [System.Linq.Enumerable]::ToList($directories)
            $directories.Sort([System.StringComparer]::InvariantCultureIgnoreCase)
            $directories.Reverse()

            foreach ($directory in $directories)
            {
                Write-Verbose -Message ($LocalizedData.ExaminingDirectoryToSeeIfiItShouldBeRemoved -f $directory)

                $directoryDestinationPath = Join-Path -Path $Destination -ChildPath $directory

                $fileInfoAtDestinationPath = Get-Item -LiteralPath $directoryDestinationPath -ErrorAction SilentlyContinue
                if ($null -ne $fileInfoAtDestinationPath -and $null -ne $fileInfoAtDestinationPath.GetType() -and $fileInfoAtDestinationPath.GetType() -eq [System.IO.DirectoryInfo] -and $fileInfoAtDestinationPath.GetFiles().Count -eq 0 -and $fileInfoAtDestinationPath.GetDirectories().Count -eq 0 `
                        -and $PSCmdlet.ShouldProcess(($LocalizedData.RemoveDirectory -f $fileInfoAtDestinationPath), $null, $null))
                {
                    Write-Verbose -Message ($LocalizedData.ExistingaAppearsToBeAneEmptyDirectoryRemovingit -f $fileInfoAtDestinationPath)
                    Remove-Item -LiteralPath $fileInfoAtDestinationPath
                }
            }

            Write-Verbose ($LocalizedData.PackageUninstalled -f $Path, $Destination)
            Write-Verbose $LocalizedData.ConfigurationFinished
            return
        }

        New-Directory -Path $Destination

        foreach ($archiveEntry in $archiveEntries)
        {
            $archiveEntryDestinationPath = Join-Path -Path $Destination -ChildPath $archiveEntry.FullName

            if ($archiveEntryDestinationPath.EndsWith('\'))
            {
                New-Directory -Path $archiveEntryDestinationPath.TrimEnd("\")
                continue
            }

            $fileInfoAtDestinationPath = Get-Item -LiteralPath $archiveEntryDestinationPath -ErrorAction SilentlyContinue
            if ($null -ne $fileInfoAtDestinationPath)
            {
                if ($fileInfoAtDestinationPath.GetType() -eq [System.IO.FileInfo])
                {
                    if (-not $Validate)
                    {
                        continue
                    }

                    if (Test-ChecksumIsSha -Checksum $Checksum)
                    {
                        if ($fileInfoAtDestinationPath.LastWriteTime.Equals($archiveEntry.ExistingTimestamp))
                        {
                            Write-Verbose -Message ($LocalizedData.LastWriteTimeMtchesWhatWeHaveRecordNotReexaminingChecksum -f $archiveEntryDestinationPath, $Checksum)
                        }
                        else
                        {
                            $fileHashMatchesArchiveEntryHash = Test-FileHashMatchesArchiveEntryHash -FilePath $archiveEntryDestinationPath -ArchiveEntry $archiveEntry -HashAlgorithmName $Checksum

                            if ($fileHashMatchesArchiveEntryHash)
                            {
                                Write-Verbose -Message ($LocalizedData.FoundfatdestwheregoingtoplaceoneandhashmatchedContinuing -f $archiveEntryDestinationPath)

                                $archiveEntry.ExistingItemTimestamp = $fileInfoAtDestinationPath.LastWriteTime
                                continue
                            }
                            else
                            {
                                if ($Force)
                                {
                                    Write-Verbose -Message ($LocalizedData.FoundFileAtDestWhereWeWereGoingToPlaceOneAndHashDidntMatchItWillBeOverwritten -f $archiveEntryDestinationPath)
                                }
                                else
                                {
                                    Write-Verbose -Message ($LocalizedData.FoundFileAtdDestWhereWeWereGoingToPlaceOneAndDoesNotMatchTheSourceButForceWasNotSpecifiedErroring -f $archiveEntryDestinationPath)
                                    New-InvalidOperationException ($LocalizedData.ItemExistsButIsIncorrect -f $archiveEntryDestinationPath)
                                }
                            }
                        }
                    }
                    else
                    {
                        $relevantTimestamp = Get-RelevantChecksumTimestamp -FileSystemObject $fileInfoAtDestinationPath -Checksum $Checksum
                        if ($relevantTimestamp.Equals($archiveEntry.LastWriteTime.DateTime))
                        {
                            Write-Verbose -Message ($LocalizedData.InSetTargetResourceDestExistsAndtTheSelectedTimestampChecksumMatchedWilllLeaveIt -f $archiveEntryDestinationPath, $Checksum)
                            continue
                        }
                        else
                        {
                            if ($Force)
                            {
                                Write-Verbose -Message ($LocalizedData.InSetTargetResourceDestExistsAndTheSelectedTimestamp -f $archiveEntryDestinationPath, $Checksum)
                            }
                            else
                            {
                                Write-Verbose -Message ($LocalizedData.FoundaAFileAtDestAndTimestampChecksumDoesNotMatchTheSourceButForceWasNotSpecifiedErroring -f $archiveEntryDestinationPath, $Checksum)
                                New-InvalidOperationException ($LocalizedData.ItemExistsButIsIncorrect -f $archiveEntryDestinationPath)
                            }
                        }
                    }
                }
                else
                {
                    if ($Force)
                    {
                        Write-Verbose -Message ($LocalizedData.FoundADirectoryAtDestWhereAFileShouldBeRemoving -f $archiveEntryDestinationPath)

                        if ($PSCmdlet.ShouldProcess(($LocalizedData.RemoveDirectory -f $archiveEntryDestinationPath), $null, $null))
                        {
                            Remove-Item -LiteralPath $archiveEntryDestinationPath -Recurse -Force | Out-Null
                        }
                    }
                    else
                    {
                        Write-Verbose -Message ($LocalizedData.FoundDirectoryAtDestWhereAFileShouldBeAndForceWasNotSpecifiedErroring -f $archiveEntryDestinationPath)
                        New-InvalidOperationException ($LocalizedData.ItemExistsButIsWrongType -f $archiveEntryDestinationPath)
                    }
                }
            }

            $archiveEntryDestinationParentPath = Split-Path -Path $archiveEntryDestinationPath
            if (-not (Test-Path -LiteralPath $archiveEntryDestinationParentPath) -and $PSCmdlet.ShouldProcess(($LocalizedData.MakeDirectory -f $archiveEntryDestinationParentPath), $null, $null))
            {
                <#
                        TODO: This is an edge case we need to revisit. We should be correctly handling wrong file types along
                        the directory path if they occur within the archive, but they don't have to. Simple tests demonstrate that
                        the Zip format allows you to have the file within a folder without explicitly having an entry for the folder
                        This solution will fail in such a case IF anything along the path is of the wrong type (e.g. file in a place
                        we expect a directory to be)
                #>
                New-Item -Path $archiveEntryDestinationParentPath -ItemType Directory | Out-Null
            }

            try
            {
                if ($PSCmdlet.ShouldProcess(($LocalizedData.UnzipFile -f $archiveEntryDestinationPath), $null, $null))
                {
                    # If we get here we can safely blow away anything we find.

                    $null, $archiveEntryNameHashtable, $zipFileHandle = Open-ZipFile -Path $Path
                    $archiveFileSourceStream = $null
                    $archiveFileDestinationStream = $null

                    try
                    {
                        Write-Verbose -Message ($LocalizedData.WritingToFileDest -f $archiveEntryDestinationPath)
                        $archiveFileSourceStream = $archiveEntryNameHashtable[$archiveEntry.FullName].Open()
                        $archiveFileDestinationStream = New-Object -TypeName 'System.IO.FileStream' -ArgumentList @( $archiveEntryDestinationPath, 'Create' )
                        $archiveFileSourceStream.CopyTo($archiveFileDestinationStream)
                    }
                    catch
                    {
                        New-InvalidOperationException ($LocalizedData.ErrorCopyingToOutstream -f $archiveEntryDestinationPath) $_
                    }
                    finally
                    {
                        if ($null -ne $archiveFileSourceStream)
                        {
                            $archiveFileSourceStream.Dispose()
                        }

                        if ($null -ne $archiveFileDestinationStream)
                        {
                            $archiveFileDestinationStream.Dispose()
                        }
                    }

                    $newArchiveFileInfo = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList @( $archiveEntryDestinationPath )

                    $updatedTimestamp = $archiveEntry.LastWriteTime.DateTime
                    $archiveEntry.ExistingItemTimestamp = $updatedTimestamp

                    Set-ItemProperty -LiteralPath $archiveEntryDestinationPath -Name 'LastWriteTime' -Value $updatedTimestamp
                    Set-ItemProperty -LiteralPath $archiveEntryDestinationPath -Name 'LastAccessTime' -Value $updatedTimestamp
                    Set-ItemProperty -LiteralPath $archiveEntryDestinationPath -Name 'CreationTime' -Value $updatedTimestamp
                }
            }
            finally
            {
                if ($null -ne $zipFileHandle)
                {
                    $zipFileHandle.Dispose()
                }
            }

            Set-CacheEntry -InputObject $archiveEntry -Path $Path -Destination $Destination
            Write-Verbose -Message ($LocalizedData.PackageInstalled -f $Path, $Destination)
            Write-Verbose -Message $LocalizedData.ConfigurationFinished
        }
    }
    finally
    {
        if ($null -ne $psDrive)
        {
            Write-Verbose -Message ($LocalizedData.RemovePSDriveonRootdriveRoot -f $psDrive.Root)
            Remove-PSDrive $psDrive -Force -ErrorAction SilentlyContinue
        }
    }
}

function Test-TargetResource
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [ValidateSet('Present', 'Absent')]
        [String] $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Destination,

        [Boolean] $Validate = $false,

        [ValidateSet('SHA-1', 'SHA-256', 'SHA-512', 'CreatedDate', 'ModifiedDate')]
        [String] $Checksum = 'SHA-256',

        [Boolean] $Force = $false,

        [PSCredential] $Credential
    )

    if ($null -ne $Credential)
    {
        $psDrive = Mount-NetworkPath -Path $Path -Credential $Credential
    }

    try
    {
        $ErrorActionPreference = 'Stop'

        Write-Verbose -Message ($LocalizedData.AboutToValidateStandardArguments)

        Assert-PathArgumentValid -Path $Path
        Assert-DestinationArgumentValid -Destination $Destination

        if ($PSBoundParameters.ContainsKey('Checksum'))
        {
            Assert-ValidateAndChecksumArgumentsValid -Validate $Validate -Checksum $Checksum
        }
        else
        {
            Assert-ValidateAndChecksumArgumentsValid -Validate $Validate
        }

        Write-Verbose -Message ($LocalizedData.GoingForCacheEntries)

        $result = $true

        $cacheEntry = Get-CacheEntry -Path $Path -Destination $Destination
        $sourceLastWriteTime = (Get-Item -LiteralPath $Path).LastWriteTime

        $cacheUpToDate = $null -ne $cacheEntry -and $null -ne $cacheEntry.SourceLastWriteTime -and $cacheEntry.SourceLastWriteTime -eq $sourceLastWriteTime

        $fileHandle = $null

        try
        {
            $archiveEntries = $null

            if ($cacheUpToDate)
            {
                Write-Verbose -Message ($LocalizedData.TheCacheWasUpToDateUsingCacheToSatisfyRequests)
            }
            else
            {
                Write-Verbose -Message ($LocalizedData.AboutToOpenTheZipFile)
                $archiveEntries, $null, $fileHandle = Open-ZipFile -Path $Path

                Write-Verbose -Message ($LocalizedData.UpdatingCache)
                Update-Cache -CacheEntryToUpdate $cacheEntry -ArchiveEntries $archiveEntries -Checksum $Checksum -SourceLastWriteTime $sourceLastWriteTime
                $cacheEntry = Get-CacheEntry -Path $Path -Destination $Destination

                Write-Verbose -Message ($LocalizedData.CacheUpdatedWithEntries -f $cacheEntry.Entries.Length)
            }

            $archiveEntries = $cacheEntry.Entries

            foreach ($archiveEntry in $archiveEntries)
            {
                $individualResult = $true
                Write-Verbose -Message ($LocalizedData.Processing -f $archiveEntry.FullName)

                $archiveEntryDestinationPath = Join-Path -Path $Destination -ChildPath $archiveEntry.FullName
                if ($archiveEntryDestinationPath.EndsWith('\'))
                {
                    $archiveEntryDestinationPath = $archiveEntryDestinationPath.TrimEnd('\')
                    if (-not (Test-Path -LiteralPath $archiveEntryDestinationPath -PathType Container))
                    {
                        Write-Verbose ($LocalizedData.DestMissingOrIncorrectTypeReason -f $archiveEntryDestinationPath)
                        $individualResult = $result = $false
                    }
                }
                else
                {
                    $archiveEntryDestinationFileInfo = Get-Item -LiteralPath $archiveEntryDestinationPath -ErrorAction Ignore
                    if ($null -eq $archiveEntryDestinationFileInfo)
                    {
                        $individualResult = $result = $false
                    }
                    elseif ($archiveEntryDestinationFileInfo.GetType() -ne [System.IO.FileInfo])
                    {
                        $individualResult = $result = $false
                    }

                    if (-not $Validate)
                    {
                        Write-Verbose -Message ($LocalizedData.InTestTargetResourceDestExistsNotUsingChecksumsContinuing -f $archiveEntryDestinationPath)
                        if (-not $individualResult -and $Ensure -eq 'Present')
                        {
                            Write-Verbose ($LocalizedData.DestMissingOrIncorrectTypeReason -f $archiveEntryDestinationPath)
                        }
                        elseif ($individualResult -and $Ensure -eq 'Absent')
                        {
                            Write-Verbose ($LocalizedData.DestShouldNotBeThereReason -f $archiveEntryDestinationPath)
                        }
                    }
                    else
                    {
                        # If the file is there we need to check if it could possibly fail in a different way
                        # Otherwise we skip all these checks - there's nothing to work with
                        if ($individualResult)
                        {
                            if (Test-ChecksumIsSha -Checksum $Checksum)
                            {
                                if ($archiveEntryDestinationFileInfo.LastWriteTime.Equals($archiveEntry.ExistingItemTimestamp))
                                {
                                    Write-Verbose -Message ($LocalizedData.NotPerformingChecksumTheFileOnDiskHasTheSameWriteTimeAsTheLastTimeWeVerifiedItsContents)
                                }
                                else
                                {
                                    if (-not (Test-FileHashMatchesArchiveEntryHash -FilePath $archiveEntryDestinationPath -ArchiveEntry $archiveEntry -HashAlgorithmName $Checksum))
                                    {
                                        $individualResult = $result = $false
                                    }
                                    else
                                    {
                                        $archiveEntry.ExistingItemTimestamp = $archiveEntryDestinationFileInfo.LastWriteTime
                                        Write-Verbose -Message ($LocalizedData.DestExistsAndTheHashMatchesEven -f $archiveEntryDestinationPath)
                                    }
                                }
                            }
                            else
                            {
                                $archiveEntryTimestamp = Get-RelevantChecksumTimestamp -FileSystemObject $archiveEntryDestinationFileInfo -Checksum $Checksum

                                if (-not $archiveEntryTimestamp.Equals($archiveEntryTimestamp.LastWriteTime.DateTime))
                                {
                                    $individualResult = $result = $false
                                }
                                else
                                {
                                    Write-Verbose -Message ($LocalizedData.InTestTargetResourceDestExistsAndTheSelectedTimestampChecksumMatched -f $archiveEntryDestinationPath, $Checksum)
                                }
                            }
                        }

                        if (-not $individualResult -and $Ensure -eq 'Present')
                        {
                            Write-Verbose ($LocalizedData.DestHasIncorrectHashvalue -f $archiveEntryDestinationPath)
                        }
                        elseif ($individualResult -and $Ensure -eq 'Absent')
                        {
                            Write-Verbose ($LocalizedData.DestShouldNotBeThereReason -f $archiveEntryDestinationPath)
                        }
                    }
                }
            }
        }
        finally
        {
            if ($null -ne $fileHandle)
            {
                $fileHandle.Dispose()
            }
        }

        Set-CacheEntry -InputObject $cacheObj -path $Path -destination $Destination
        $result = $result -eq ('Present' -eq $Ensure)
    }
    finally
    {
        if ($null -ne $psDrive)
        {
            Write-Verbose -Message ($LoalizedData.RemovePSDriveOnRootPSDrive -f $($psDrive.Root))
            Remove-PSDrive -Name $psDrive -Force -ErrorAction SilentlyContinue
        }
    }

    return $result
}

<#
        .SYNOPSIS
        Converts a DSC hash name (with a hyphen) to a PowerShell hash name (without a hyphen).
        The in-box PowerShell Get-FileHash cmdlet takes only hash names without hypens.

        .PARAMETER DscHashName
        The DSC hash name to convert.
#>
function ConvertTo-PowerShellHashAlgorithmName
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $DscHashAlgorithmName
    )

    return $DscHashAlgorithmName.Replace('-', '')
}

<#
        .SYNOPSIS
        Tests if the given Checksum string specifies a SHA hash algorithm.

        .PARAMETER Checksum
        The Checksum string to test.
#>
function Test-ChecksumIsSha
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [String] $Checksum
    )

    return ( ($null -ne $Checksum) -and `
             ($Checksum.Length -ge 3) -and `
             ($Checksum.Substring(0, 3) -ieq 'sha') )
}

<#
        .SYNOPSIS
        Retrieves the entry with the given path and destination from the cache

        .PARAMETER Path
        The path property of the cache entry to retrieve

        .PARAMETER Destination
        The destination property of the cache entry to retrieve
#>
function Get-CacheEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Destination
    )

    $cacheEntry = @{}

    $cacheEntryKey = ($Path + $Destination).GetHashCode()
    Write-Verbose -Message ($LocalizedData.UsingKeyToRetrieveHashValue -f $cacheEntryKey)

    $cacheEntryPath = Join-Path -Path $script:cacheLocation -ChildPath $cacheEntryKey
    if (-not (Test-Path -LiteralPath $cacheEntryPath))
    {
        Write-Verbose -Message ($LocalizedData.NoCacheValueFound)
    }
    else
    {
        # ErrorAction seems to have no affect on this exception, (see: https://microsoft.visualstudio.com/web/wi.aspx?pcguid=cb55739e-4afe-46a3-970f-1b49d8ee7564&id=1185735)
        try
        {
            $cacheEntry = Import-CliXml -LiteralPath $cacheEntryPath
            Write-Verbose -Message ($LocalizedData.CacheValueFoundReturning -f $cacheEntry)
        }
        catch [System.Xml.XmlException]
        {
            Write-Verbose -Message ($LocalizedData.CacheCorrupt)
        }
    }

    return $cacheEntry
}

<#
        .SYNOPSIS
        Sets an entry in the cache.

        .PARAMETER Path
        The path property to use as part of a key for the cache entry.

        .PARAMETER Destination
        The destination property to use as part of a key for the cache entry.

        .PARAMETER InputObject
        The object to store in the cache.
#>
function Set-CacheEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Destination,

        [Object] $InputObject
    )

    $cacheEntryKey = ($Path + $Destination).GetHashCode()

    Write-Verbose -Message ($LocalizedData.UsingTmpKeyToSaveHashValue -f $tmp, $cacheEntryKey)
    $cacheEntryPath = Join-Path -Path $script:cacheLocation -ChildPath $cacheEntryKey

    Write-Verbose -Message ($LocalizedData.AboutToCacheValueInputObject -f $InputObject)
    if (-not (Test-Path -LiteralPath $script:cacheLocation))
    {
        New-Item -Path $script:cacheLocation -ItemType Directory | Out-Null
    }

    Export-CliXml -LiteralPath $cacheEntryPath -InputObject $InputObject
}

<#
        .SYNOPSIS
        Tests if the Path argument to the Archive resource is valid.
        Throws an error if Path is not valid.

        .PARAMETER Path
        The path to test
#>
function Assert-PathArgumentValid
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path
    )

    $ErrorActionPreference = 'Stop'

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf))
    {
        New-InvalidArgumentException -Message ($LocalizedData.InvalidSourcePath -f $Path) -ArgumentName 'Path'
    }
}

<#
        .SYNOPSIS
        Tests if the Destination argument to the Archive resource is valid.
        Throws an error if Destination is not valid.

        .PARAMETER Path
        The destination path to test
#>
function Assert-DestinationArgumentValid
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Destination
    )

    $ErrorActionPreference = 'Stop'

    $destinationFileInfo = Get-Item -LiteralPath $Destination -ErrorAction Ignore
    if ($null -ne $destinationFileInfo -and $destinationFileInfo.GetType() -eq [System.IO.FileInfo])
    {
        New-InvalidArgumentException -Message ($LocalizedData.InvalidDestinationDirectory -f $Destination) -ArgumentName 'Destination'
    }
}

<#
    .SYNOPSIS
        Tests if the Validate and Checksum arguments to the Archive resource are valid.
        Throws an error if they are not valid.

    .PARAMETER Validate
        The Validate value to test

    .PARAMETER Checksum
        The Checksum value to test
#>
function Assert-ValidateAndChecksumArgumentsValid
{
    [CmdletBinding()]
    param
    (
        [Boolean] $Validate,

        [String] $Checksum
    )

    $ErrorActionPreference = 'Stop'

    if ($PSBoundParameters.ContainsKey('Checksum') -and -not $Validate)
    {
        New-InvalidArgumentException -Message ($LocalizedData.InvalidChecksumArgsMessage -f $Checksum) -ArgumentName 'Checksum'
    }
}

<#
        .SYNOPSIS
        Tests if the hash for the given file matches the hash for the given cache entry.

        .PARAMETER FilePath
        The path to the file to test the hash for

        .PARAMETER CacheEntry
        The cache entry to test the hash for

        .PARAMETER HashAlgorithmName
        The name of the hash algorithm to use to retrieve the file's hash
#>
function Test-FileHashMatchesArchiveEntryHash
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $FilePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Object] $ArchiveEntry,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $HashAlgorithmName
    )

    $existingFileStream = $null
    $fileHash = $null

    try
    {
        $existingFileStream = New-Object -TypeName 'System.IO.FileStream' -ArgumentList @( $FilePath, 'Open')
        $powerShellHashAlgorithmName = ConvertTo-PowerShellHashAlgorithmName -DscHashAlgorithmName $HashAlgorithmName
        $fileHash = Get-FileHash -InputStream $existingFileStream -Algorithm $powerShellHashAlgorithmName
    }
    catch
    {
        New-InvalidOperationException -Message ($LocalizedData.ErrorOpeningExistingFile -f $FilePath) -ErrorRecord $_
    }
    finally
    {
        if ($null -ne $existingFileStream)
        {
            $existingFileStream.Dispose()
        }
    }

    $archiveEntryHash = $ArchiveEntry.Checksum

    return ($fileHash.Algorithm -eq $archiveEntryHash.Algorithm) -and ($fileHash.Hash -eq $archiveEntryHash.Hash)
}

<#
        .SYNOPSIS
        Retrieves the appropriate timestamp from the given file system info object based on the given Checksum

        .PARAMETER FileSystemObject
        The file system info object to retrieve the timestamp for

        .PARAMETER Checksum
        The Checksum to retrieve the appropriate timestamp for
#>
function Get-RelevantChecksumTimestamp
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileSystemInfo] $FileSystemObject,

        [String] $Checksum
    )

    if ($Checksum -ieq 'CreatedDate')
    {
        return $FileSystemObject.CreationTime
    }
    else
    {
        return $FileSystemObject.LastWriteTime
    }
}

<#
        .SYNOPSIS
        Updates the given cache entry

        .PARAMETER CacheEntryToUpdate
        The cache entry to update

        .PARAMETER ArchiveEntries
        The archive entries to update the given cache entry with

        .PARAMETER Checksum
        The Checksum to update the given cache entry with

        .PARAMETER SourceLastWriteTime
        The source last write time to update the given cache entry with
#>
function Update-Cache
{
    [CmdletBinding()]
    param
    (
        [Hashtable] $CacheEntryToUpdate,

        [System.IO.Compression.ZipArchiveEntry[]] $ArchiveEntries,

        [String] $Checksum,

        [String] $SourceLastWriteTime
    )

    Write-Verbose -Message ($LocalizedData.InUpdateCache)

    $cacheEntries = New-Object -TypeName 'System.Collections.ArrayList'

    foreach ($archiveEntry in $ArchiveEntries)
    {
        $archiveEntryHash = $null

        if (Test-ChecksumIsSha -Checksum $Checksum)
        {
            $archiveEntryStream = $null
            try
            {
                $archiveEntryStream = $archiveEntry.Open()
                $powerShellHashAlgorithmName = ConvertTo-PowerShellHashAlgorithmName -DscHashAlgorithmName $Checksum
                $archiveEntryHash = Get-FileHash -InputStream $archiveEntryStream -Algorithm $powerShellHashAlgorithmName
            }
            finally
            {
                if ($null -ne $archiveEntryStream)
                {
                    $archiveEntryStream.Dispose()
                }
            }
        }

        $cacheEntry = @{
            FullName = $archiveEntry.FullName
            LastWriteTime = $archiveEntry.LastWriteTime
            Checksum = $archiveEntryHash
        }

        Write-Verbose -Message  ($LoalizedData.AddingEntryFullNameAsACacheEntry -f $archiveEntry.FullName)
        $cacheEntries.Add($cacheEntry) | Out-Null
    }

    Write-Verbose -Message ($LocalizedData.UpdatingCacheObject)

    if ($null -eq $CacheEntryToUpdate)
    {
        $CacheEntryToUpdate = @{}
    }

    $CacheEntryToUpdate['SourceLastWriteTime'] = $SourceLastWriteTime
    $CacheEntryToUpdate['Entries'] = $cacheEntries.ToArray()
    Set-CacheEntry -InputObject $CacheEntryToUpdate -Path $Path -Destination $Destination

    Write-Verbose -Message ($LocalizedData.PlacedNewCacheEntry)
}

<#
        .SYNOPSIS
        Creates a PSDrive to a net share with the given credential.

        .PARAMETER Path
        The file path mount the PSDrive for

        .PARAMETER Credential
        The credential to access the given file path
#>
function Mount-NetworkPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [PSCredential] $Credential
    )

    $psDrive = $null

    # Mount the drive only if not accessible
    if (Test-Path -LiteralPath $Path -ErrorAction Ignore)
    {
        Write-Verbose -Message  ($LocalizedData.PathPathIsAlreadyAccessiableNoMountNeeded -f $Path)
    }
    else
    {
        if (-not $Path.EndsWith('\'))
        {
            $lastBackslashIndex = $Path.LastIndexOf('\')
            if ($lastBackslashIndex -eq -1)
            {
                Write-Verbose -Message ($LocalizedData.PathPathIsNotAValidateNetPath -f $Path)
                New-InvalidOperationException ($LocalizedData.InvalidNetSourcePath -f $Path)
            }
            else
            {
                $Path = $Path.Substring(0, $lastBackslashIndex)
            }
        }

        $newPSDriveArgs = @{
            Name = [Guid]::NewGuid()
            PSProvider = 'FileSystem'
            Root = $Path
            Scope = 'Script'
            Credential = $Credential
        }

        try
        {
            Write-Verbose -Message ($LocalizedData.CreatePSDriveWithPathPath -f $Path)
            $psDrive = New-PSDrive @newPSDriveArgs
        }
        catch
        {
            Write-Verbose -Message ($LocalizedData.CannotAccessPathPathWithGivenCredential -f $Path)
            New-InvalidOperationException -Message ($LocalizedData.ErrorOpeningArchiveFile -f $Path) -ErrorRecord $_
        }
    }

    return $psDrive
}

<#
        .SYNOPSIS
        Creates a new directory at the specified path if it does not already exist.
        If the Force parameter is specified, a file with the same path will be overwritten with a new directory.

        .PARAMETER Path
        The path at which to create the new directory
#>
function New-Directory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path
    )

    $fileInfo = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue

    if ($null -eq $fileInfo)
    {
        Write-Verbose -Message ($LocalizedData.FolderDirDoesNotExist -f $Path)

        if ($PSCmdlet.ShouldProcess(($LocalizedData.MakeDirectory -f $Path), $null, $null))
        {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }
    }
    else
    {
        if ($fileInfo.GetType() -ne [System.IO.DirectoryInfo])
        {
            if ($Force -and $PSCmdlet.ShouldProcess(($LocalizedData.RemoveFileAndRecreateAsDirectory -f $Path), $null, $null))
            {
                Write-Verbose -Message ($LocalizedData.RemovingDir -f $Path)
                Remove-Item -LiteralPath $Path | Out-Null
                New-Item -Path $Path -ItemType Directory | Out-Null
            }
            else
            {
                New-InvalidOperationException ($LocalizedData.ItemExistsButIsWrongType -f $Path)
            }
        }
    }
}

<#
        .SYNOPSIS
        Opens the given zip file.

        .PARAMETER Path
        The path to the zip file to open
#>
function Open-ZipFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path
    )

    if (Test-IsNanoServer)
    {
        Add-Type -AssemblyName System.IO.Compression
    }
    else
    {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    try
    {
        $zipFileHandle = [System.IO.Compression.ZipFile]::OpenRead($Path)
        $archiveEntries = $zipFileHandle.Entries
    }
    catch
    {
        New-InvalidOperationException ($LocalizedData.ErrorOpeningArchiveFile -f $Path) $_
    }

    $archiveEntryNameHashtable = @{}

    foreach ($archiveEntry in $archiveEntries)
    {
        $archiveEntryNameHashtable[$archiveEntry.FullName] = $archiveEntry
    }

    return $archiveEntries, $archiveEntryNameHashtable, $zipFileHandle
}





Export-ModuleMember -Function *-TargetResource
