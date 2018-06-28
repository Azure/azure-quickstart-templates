configuration Sample_RemoveSome32BitHandlers
{
    param
    (
        # Target nodes to apply the configuration
        [string[]]$NodeName = 'localhost'
    )

    # Import the module that defines custom resources
    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    Node $NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name   = 'Web-Server'
        }

        xIisHandler aspq_ISAPI_4_0_32bit
        {
            Name   = 'aspq-ISAPI-4.0_32bit'
            Ensure = 'Absent'
        }

        xIisHandler cshtm_ISAPI_4_0_32bit
        {
            Name   = 'cshtm-ISAPI-4.0_32bit'
            Ensure = 'Absent'
        }

        xIisHandler cshtml_ISAPI_4_0_32bit
        {
            Name   = 'cshtml-ISAPI-4.0_32bit'
            Ensure = 'Absent'
        }

        xIisHandler vbhtm_ISAPI_4_0_32bit
        {
            Name   = 'vbhtm-ISAPI-4.0_32bit'
            Ensure = 'Absent'
        }

        xIisHandler vbhtml_ISAPI_4_0_32bit
        {
            Name   = 'vbhtml-ISAPI-4.0_32bit'
            Ensure = 'Absent'
        }

    }
}
