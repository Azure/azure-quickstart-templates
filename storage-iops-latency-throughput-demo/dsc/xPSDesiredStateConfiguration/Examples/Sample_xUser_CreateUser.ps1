Configuration xUserExample
{
    param (
        [System.Management.Automation.PSCredential]
        $PasswordCredential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    xUser xUserExample
    {
        Ensure = 'Present'  # To ensure the user account does not exist, set Ensure to "Absent"
        UserName = 'SomeUserName'
        Password = $PasswordCredential # This needs to be a credential object
    }
}
