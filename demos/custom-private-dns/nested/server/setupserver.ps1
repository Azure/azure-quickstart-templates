# write flag file
mkdir c:\temp -Force
Get-Date > c:\temp\hello.txt

# setup DDNS on the forward zone, the AD dcpromo will have created it
dnscmd.exe /Config $args[0] /AllowUpdate 1
if ($LastExitCode -ne 0)
{
    "exit code configuring forward zone ($args[0]) was non-zero ($LastExitCode), bailing..."
    exit $LastExitCode
}

# work out the name of the reverse zone
$range = $args[1]
$bits = $range.Split("/")
$ip = $bits[0]
$net = $bits[1]
$ipbits = $ip.Split('.')
$zone = ""
switch ($net)
{
    8       { $zone = "$($ipbits[0]).in-addr.arpa." }
    16      { $zone = "$($ipbits[1]).$($ipbits[0]).in-addr.arpa." }
    24      { $zone = "$($ipbits[2]).$($ipbits[1]).$($ipbits[0]).in-addr.arpa." }
    default { 
                Write-Warning "Vnet should be /8 /16 or /24, treating as /8"
                $zone = "$($ipbits[0]).in-addr.arpa." 
            }
}
dnscmd.exe /ZoneAdd $zone /DsPrimary
dnscmd.exe /Config $zone /AllowUpdate 1
if ($LastExitCode -ne 0)
{
    "exit code configuring reverse zone ($args[1]) was non-zero ($LastExitCode), bailing..."
    exit $LastExitCode
}
