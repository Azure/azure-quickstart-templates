<#
.EXAMPLE
    This example adds a new section for profile properties to the specified
    user profile service app
#>

    Configuration Example 
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPUserProfileSection PersonalInformationSection
            {
                Name = "PersonalInformationSection"
                UserProfileService = "User Profile Service Application"
                DisplayName = "Personal Information"
                DisplayOrder = 5000
                Ensure = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
