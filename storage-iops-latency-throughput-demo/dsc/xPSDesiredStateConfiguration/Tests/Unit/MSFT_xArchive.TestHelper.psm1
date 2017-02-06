<#
    .SYNOPSIS
    Converts a hashtable to a file structure.

    .PARAMETER ParentPath
    The path to the directory that should contain the given file structure.

    .PARAMETER ZipFileStructure
    The hashtable defining the zip file structure
    Hashtables are directories.
    Strings are files with the key as the name of the file and the value as the contents.
#>
function ConvertTo-FileStructure
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ParentPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]
        $ZipFileStructure
    )

    foreach ($key in $ZipFileStructure.Keys)
    {
        if ($ZipFileStructure[$key] -is [Hashtable])
        {
            $newDirectoryPath = Join-Path -Path $ParentPath -ChildPath $key
            New-Item -Path $newDirectoryPath -ItemType Directory | Out-Null
            ConvertTo-FileStructure -ParentPath $newDirectoryPath -ZipFileStructure $ZipFileStructure[$key]
        }
        elseif ($ZipFileStructure[$key] -is [String])
        {
            $newFilePath = Join-Path -Path $ParentPath -ChildPath $key
            New-Item -Path $newFilePath -ItemType File | Out-Null
            Set-Content -LiteralPath $newFilePath -Value $ZipFileStructure[$key]
        }
        else
        {
            throw "Zip file structure must be made of strings and Hashtables. Found a different type."
        }
    }
}

<#
    .SYNOPSIS
    Creates a new zip file with the given name from a hashtable describing the file structure.

    .PARAMETER Name
    The name of the zip file to create

    .PARAMETER ZipFileStructure
    The hashtable defining the zip file structure
    Hashtables are directories.
    Strings are files with the key as the name of the file and the value as the contents.
#>
function New-ZipFileFromHashtable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ParentPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]
        $ZipFileStructure
    )

    $expandedZipPath = Join-Path -Path $ParentPath -ChildPath $Name
    New-Item -Path $expandedZipPath -ItemType Directory | Out-Null

    ConvertTo-FileStructure -ParentPath $expandedZipPath -ZipFileStructure $ZipFileStructure

    $compressedZipPath = Join-Path -Path $ParentPath -ChildPath "$Name.zip"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($expandedZipPath, $compressedZipPath, 'NoCompression', $false)
    return $compressedZipPath
}

<#
    .SYNOPSIS
        Tests if two file structures are the same.
        Uses Pester.

    .PARAMETER SourcePath
        The path to the source file to test against.

    .PARAMETER DestinationPath
        The path the to destination file to test.

    .PARAMETER CheckLastWriteTime
        Indicates that the last write times should match.

    .PARAMETER CheckCreationTime
        Indicates that the creation times should match.

    .PARAMETER CheckContents
        Indicates that the contents of the file structures should match.
#>
function Test-FileStructuresMatch
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $SourcePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPath,

        [Switch] $CheckLastWriteTime,

        [Switch] $CheckCreationTime,

        [Switch] $CheckContents
    )

    $sourcePathLength = $SourcePath.Length
    $destinationPathLength = $DestinationPath.Length

    $destinationContents = @{}
    $destinationChildItems = Get-ChildItem -Path $DestinationPath -Recurse

    foreach ($destinationChildItem in $destinationChildItems)
    {
        $destinationContents[$destinationChildItem.FullName.Substring($destinationPathLength)] = $destinationChildItem
    }

    $sourceChildItems = Get-ChildItem -Path $SourcePath -Recurse

    foreach ($sourceChildItem in $sourceChildItems)
    {
        $sourceChildItemName = $sourceChildItem.FullName.Substring($sourcePathLength)
        $destinationChildItem = $destinationContents[$sourceChildItemName]

        $destinationChildItem | Should Not Be $null
        $destinationChildItem.GetType() | Should Be $sourceChildItem.GetType()

        if ($destinationChildItem.GetType() -eq [System.IO.FileInfo])
        {
            if ($CheckLastWriteTime)
            {
                $sourceChildItem.LastWriteTime | Should Be $destinationChildItem.LastWriteTime
            }

            if ($CheckCreationTime)
            {
                $sourceChildItem.CreationTime | Should Be $destinationChildItem.CreationTime
            }

            if ($CheckContents)
            {
                $sourceStream = $null
                $destinationStream = $null

                try
                {
                    $sourceStream = $sourceChildItem.Open()
                    $destinationStream = $destinationChildItem.Open()

                    $sourceFileContents = $sourceStream.Read()
                    $destinationFileContents = $destinationStream.Read()

                    $sourceFileContentsLength = $sourceFileContents.Length

                    $destinationFileContents.Length | Should Be $sourceFileContentsLength

                    for ($fileIndex = 0; $fileIndex -lt $sourceFileContentsLength; $fileIndex++)
                    {
                        $sourceFileContents[$fileIndex] | Should Be $destinationFileContents[$fileIndex]
                    }
                }
                finally
                {
                    if ($null -ne $sourceStream)
                    {
                        $sourceStream.Dispose()
                    }

                    if ($null -ne $destinationStream)
                    {
                        $destinationStream.Dispose()
                    }
                }
            }
        }
    }
}

Export-ModuleMember -Function `
    New-ZipFileFromHashtable, `
    Test-FileStructuresMatch
