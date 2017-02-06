ConvertFrom-StringData @'
    DestinationPathIsExistingFile=DestinationPath '{0}' is existing file on the machine.
    DestinationPathIsExistingPath=DestinationPath '{0}' is existing directory on the machine.
    FileExistsInDestinationPath=File '{0}' exists in DestinationPath.
    DestinationPathUnknownType=DestinationPath '{0}' has unknown type '{1}'.
    DestinationPathDoesNotExist=DestinationPath '{0}' doesn't exist on the machine.
    InvalidWebUriError=Specified URI is not valid: "{0}". Only http, https or file paths are accepted.
    InvalidDestinationPathSchemeError=Specified DestinationPath is not valid: "{0}". DestinationPath should be absolute path.
    DestinationPathIsUncError=Specified DestinationPath is not valid: "{0}". DestinationPath should be local path instead of UNC path.
    DestinationPathHasInvalidCharactersError=Specified DestinationPath is not valid: "{0}". DestinationPath should be contains following characters: * ? " < > |
    DestinationPathEndsWithInvalidCharacterError=Specified DestinationPath is not valid: "{0}". DestinationPath should not end with / or \\
    DownloadOutOfMemoryException=Invoking web request failed with OutOfMemoryException- Possible cause is the requested file being too big. {0}
    DownloadException=Invoking web request failed with error. {0}
    DownloadingURI=Downloading '{1}' to '{0}'.
    CacheReflectsCurrentState=Cache reflects current state. No need for downloading file.
    CacheIsEmptyOrNotMatchCurrentState=Cache is empty or it doesn't reflect current state. File will be downloaded.
    MatchSourceFalse=MatchSource is false. No need for downloading file.
    CacheLookingForPath=Looking for cache path '{0}'.
    CacheNotFoundForPath=No cache found for DestinationPath '{0}' and Uri '{1}' CacheKey '{2}'.
    CacheFoundForPath=Found cache found for DestinationPath '{0}' and Uri '{1}' CacheKey '{2}'.
    UpdatingCache=Updating cache for DestinationPath '{0}' and Uri '{1}' CacheKey '{2}'.
'@
