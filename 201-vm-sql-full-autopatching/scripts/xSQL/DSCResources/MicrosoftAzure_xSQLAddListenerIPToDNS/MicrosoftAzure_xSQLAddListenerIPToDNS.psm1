function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LBName,     
        
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LBAddress,
        
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DNSServerName,
                
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainName
    )

   $retVal = @{
        LBName=$LBName
        LBAddress=$LBAddress
        DomainName=$DomainName 
        DNSServerName=$DNSServerName     
    }
    $retVal
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LBName,     
        
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LBAddress,
         
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DNSServerName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainName
    )


    $Stoploop = $false
    $MaximumRetryCount = 5
    $Retrycount = 0
    $SecondsDelay = 0
    
    $DNSServerFQName="${DNSServerName}.${DomainName}"
    
    do
    {
        try
        {
            $error.Clear()
            
            Write-Verbose -Message "Attempt $Retrycount of $MaximumRetryCount ..."
            
            Invoke-command -ScriptBlock ${Function:Update-DNS} -ArgumentList $LBName,$LBAddress,$DomainName -ComputerName $DNSServerFQName -Credential $Credential -ErrorAction SilentlyContinue
            
            if (!$error)
            {
                
                Write-Verbose -Message "Update-DNS successed on $Retrycount of $MaximumRetryCount retrying..."

                $Stoploop = $true
            }
            else 
            {
                throw "Update-DNS Failed."
            }
        }
        catch
        {
            # $_ in the catch block to include more details about the error that occured.
            Write-Warning ("Add Listener IP to DNS failed. Error:" + $error)
            
            if ($Retrycount -ge $MaximumRetryCount)
            {
                Write-Warning ("Add Listener IP to DNS failed all retries")
                $Stoploop = $true
            }
            else
            {
                $SecondsDelay = Get-TruncatedExponentialBackoffDelay -PreviousBackoffDelay $SecondsDelay -LowerBackoffBoundSeconds 10 -UpperBackoffBoundSeconds 120 -BackoffMultiplier 2
                
                Write-Warning -Message "An error has occurred, retrying in $SecondsDelay seconds ..."
                
                Start-Sleep $SecondsDelay
                
                $Retrycount = $Retrycount + 1
            }
        }
    }
    while ($Stoploop -eq $false)
}

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LBName,     
        
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LBAddress,
        
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DNSServerName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainName
    )

    $false
    
}

# This function implement backoff retry algorithm based 
# on exponential backoff. The backoff value is truncated 
# using the upper value after advancing it using the 
# multiplier to govern the maximum backoff internal. 
# The initial value is picked randomly between the minimum
# and upper limit with a bias towards the minimum.
function Get-TruncatedExponentialBackoffDelay([int]$PreviousBackoffDelay, [int]$LowerBackoffBoundSeconds, [int]$UpperBackoffBoundSeconds, [int]$BackoffMultiplier)
{
   [int]$delay = "0"

   if($PreviousBackoffDelay -eq 0)
   {
      $PreviousBackoffDelay = Get-Random -Minimum $LowerBackoffBoundSeconds -Maximum ($LowerBackoffBoundSeconds + ($UpperBackoffBoundSeconds / 2))
      $delay = $PreviousBackoffDelay
   }
   else
   { 
       $delay = ($PreviousBackoffDelay * $BackoffMultiplier);

       if($delay -ge $UpperBackoffBoundSeconds)
       {
           $delay = $UpperBackoffBoundSeconds
       }
       elseif($delay -le $LowerBackoffBoundSeconds)
       {
           $delay = $LowerBackoffBoundSeconds
       }
   }

   return $Result = $delay
}


function Update-DNS
{
    param(
        [string]$LBName,
        [string]$LBAddress,
        [string]$DomainName

        )
               
        $ARecord=Get-DnsServerResourceRecord -Name $LBName -ZoneName $DomainName -ErrorAction SilentlyContinue -RRType A
        if (-not $Arecord)
        {
            Add-DnsServerResourceRecordA -Name $LBName -ZoneName $DomainName -IPv4Address $LBAddress
        }
}

Export-ModuleMember -Function *-TargetResource


