
# Integration Test Config Template Version 1.0.0
param 
(
    [Parameter(Mandatory)]
    [System.String]
    $ConfigurationName
)
        

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
        $Password
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
        }
    }
}
