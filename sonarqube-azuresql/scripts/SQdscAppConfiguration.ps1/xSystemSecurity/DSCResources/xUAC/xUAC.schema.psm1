Configuration xUac
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("AlwaysNotify","NotifyChanges","NotifyChangesWithoutDimming","NeverNotify","NeverNotifyAndDisableAll")]
        [System.String]
        $Setting  
    )
    
    #Initialize variables to default values which is to NotifyChanges.
    $ConsentPromptBehaviorAdmin = 5
    $EnableLua = 1
    $PromptOnSecureDesktop = 1

    switch ($Setting)
    {
        "AlwaysNotify" 
        {
            $ConsentPromptBehaviorAdmin = 2
            $EnableLua = 1
            $PromptOnSecureDesktop = 1
        }    
        "NotifyChanges" 
        {
            $ConsentPromptBehaviorAdmin = 5
            $EnableLua = 1
            $PromptOnSecureDesktop = 1
        }    
        "NotifyChangesWithoutDimming" 
        {
            $ConsentPromptBehaviorAdmin = 5
            $EnableLua = 1
            $PromptOnSecureDesktop = 0
        }    
        "NeverNotify" 
        {
            $ConsentPromptBehaviorAdmin = 0
            $EnableLua = 1
            $PromptOnSecureDesktop = 0
        }    
        "NeverNotifyAndDisableAll" 
        {
            $ConsentPromptBehaviorAdmin = 0
            $EnableLua = 0
            $PromptOnSecureDesktop = 0
        }    
    }

    $UacKey = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    Registry ConsentPromptBehaviorAdmin
    {       
        Ensure = "Present"
        Key = $UacKey
        ValueName = "ConsentPromptBehaviorAdmin"
        ValueData = [string] $ConsentPromptBehaviorAdmin
        ValueType = "Dword"
    }

    Registry EnableLua
    {       
        Ensure = "Present"
        Key = $UacKey
        ValueName = "EnableLUA"
        ValueData = [string] $EnableLua
        ValueType = "Dword"
    }

    Registry PromptOnSecureDesktop
    {       
        Ensure = "Present"
        Key = $UacKey
        ValueName = "PromptOnSecureDesktop"
        ValueData = [string] $PromptOnSecureDesktop
        ValueType = "Dword"
    }
}
       
