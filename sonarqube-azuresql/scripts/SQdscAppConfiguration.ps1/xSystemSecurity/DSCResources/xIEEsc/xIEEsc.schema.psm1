Configuration xIEEsc
{  
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Administrators","Users")]
        [System.String]
        $UserRole,

        [parameter(Mandatory = $true)]
        [System.Boolean]
        $IsEnabled
    )

    $key = ""
    if ($UserRole -eq "Administrators") 
    {
        $key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
    }
    else
    {
        $key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
    }


    Registry IEEscKey
    {       
        Ensure = "Present"
        Key = $key
        ValueName = "IsInstalled"           
        ValueData = [string][int]$IsEnabled
        ValueType = "Dword"
    }
}
       
