Configuration OMSSERVICE
{

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost {
        Service OMSService
        {
            Name = "HealthService"
            State = "Running"
        } 
    }
}  
