ConvertFrom-StringData @'
    GettingDiskMessage = Getting Disk '{0}' status for access path '{1}'.
    SettingDiskMessage = Setting Disk '{0}' status for access path '{1}'.
    SetDiskOnlineMessage = Setting disk number '{0}' is online.
    SetDiskReadwriteMessage = Setting disk number '{0}' to read/write.
    CheckingDiskPartitionStyleMessage = Checking disk number '{0}' partition style.
    InitializingDiskMessage = Initializing disk number '{0}'.
    DiskAlreadyInitializedMessage = Disk number '{0}' is already initialized with GPT.
    CreatingPartitionMessage = Creating partition on disk number '{0}' using {1}.
    FormattingVolumeMessage = Formatting the volume as '{0}'.
    SuccessfullyInitializedMessage = Successfully initialized volume and assigned to access path '{0}'.
    ChangingDriveLetterMessage = The volume already exists, changing access path '{0}' to '{1}'.
    AssigningDriveLetterMessage = Assigning access path '{0}'.
    ChangingVolumeLabelMessage = Changing Volume assigned to access path '{0}' label to '{1}'.
    NewPartitionIsReadOnlyMessage = New partition '{1}' on disk '{0}' is readonly. Waiting for it to become writable.
    TestingDiskMessage = Testing Disk '{0}' status for access path '{1}'.
    CheckDiskInitializedMessage = Checking if disk number '{0}' is initialized.
    DiskNotFoundMessage = Disk number '{0}' was not found.
    DiskNotOnlineMessage = Disk number '{0}' is not online.
    DiskReadOnlyMessage = Disk number '{0}' is readonly.
    DiskNotGPTMessage = Disk number '{0}' is initialised with '{1}' partition style. GPT required.
    AccessPathNotFoundMessage = A volume assigned to access path '{0}' was not found.
    SizeMismatchMessage = Volume assigned to access path '{0}' has size {1}, which does not match expected size {2}.
    AllocationUnitSizeMismatchMessage = Volume assigned to access path '{0}' has allocation unit size {1} KB does not match expected allocation unit size {2} KB.
    FileSystemFormatMismatch = Volume assigned to access path '{0}' filesystem format '{1}' does not match expected format '{2}'.
    DriveLabelMismatch = Volume assigned to access path '{0}' label '{1}' does not match expected label '{2}'.
    PartitionAlreadyAssignedMessage = Partition '{1}' is already assigned to access path '{0}'.
    MatchingPartitionNotFoundMessage = Disk number '{0}' already contains paritions, but none match required size.
    MatchingPartitionFoundMessage = Disk number '{0}' already contains paritions, and partition '{1}' matches required size.

    DiskAlreadyInitializedError = Disk number '{0}' is already initialized with {1}.
    NewParitionIsReadOnlyError = New partition '{1}' on disk '{0}' did not become writable in the expected time.
'@
