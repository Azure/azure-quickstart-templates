# write flag file
mkdir c:\temp -Force
Get-Date > c:\temp\hello.txt

# set registry key for the primary suffix
REG add "HKLM\SOFTWARE\Policies\Microsoft\System\DNSClient" /v "PrimaryDnsSuffix" /t REG_SZ /d $args[0] /f           # for now
REG add "HKLM\SOFTWARE\Policies\Microsoft\System\DNSClient" /v "NV PrimaryDnsSuffix" /t REG_SZ /d $args[0] /f        # for next reboot


# set registry keys to do PTR registration
# ISSUE - requires a reboot to kick off the PTR registration
#REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v RegistrationRefreshInterval /t REG_DWORD /d 60       /f
REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v RegisterReverseLookup       /t REG_DWORD /d 1        /f
REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v RegistrationEnabled         /t REG_DWORD /d 1        /f
REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v RegisterAdapterName         /t REG_DWORD /d 1        /f
REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v UpdateSecurityLevel         /t REG_DWORD /d 16       /f
REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v AdapterDomainName           /t REG_SZ    /d $args[0] /f


# force a registration now (PTR registration will only happen after reboot)
#ipconfig /registerdns
shutdown /r /t 120

