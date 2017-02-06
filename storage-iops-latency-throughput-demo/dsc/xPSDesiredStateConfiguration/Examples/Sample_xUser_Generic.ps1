param 
(
    [Parameter(Mandatory)]
    [System.String]
    $ConfigurationName
)
        
<#
    Create a custom configuration by passing in whatever
    values you need. $Password is the only param that is
    required since it must be a PSCredential object.
    If you want to create a user with minimal attributes,
    every param except username can be deleted since they
    are optional.
#>

Configuration $ConfigurationName
{
    param 
    (        
        [System.String]
        $UserName = 'Test UserName',
        
        [System.String]
        $Description = 'Test Description',
        
        [System.String]
        $FullName = 'Test Full Name',
        
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',
        
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        $Password,
        
        [System.Boolean]
        $Disabled = $false,

        [System.Boolean]
        $PasswordNeverExpires = $false,

        [System.Boolean]
        $PasswordChangeRequired = $false,

        [System.Boolean]
        $PasswordChangeNotAllowed = $false
    )
    
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'
    
    Node Localhost {

        xUser UserResource1
        {
            UserName = $UserName
            Ensure = $Ensure
            FullName = $FullName
            Description = $Description
            Password = $Password
            Disabled = $Disabled
            PasswordNeverExpires = $PasswordNeverExpires
            PasswordChangeRequired = $PasswordChangeRequired
            PasswordChangeNotAllowed = $PasswordChangeNotAllowed
        }
    }
}
