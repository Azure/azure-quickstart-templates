$Properties = @{
                SourceDomain    = New-xDscResourceProperty -Name SourceDomainName -Type String -Attribute Key `
                                                           -Description 'Name of the AD domain that is requesting the trust'
                TargetDomain    = New-xDscResourceProperty -Name TargetDomainName -Type String -Attribute Key `
                                                           -Description 'Name of the AD domain that is being trusted'
                TargetAdminCred = New-xDscResourceProperty -Name TargetDomainAdministratorCredential -Type PSCredential -Attribute Required `
                                                           -Description 'Credentials to authenticate to the target domain'
                TrustDirection  = New-xDscResourceProperty -Name TrustDirection -Type String -Attribute Required -ValidateSet 'Bidirectional','Inbound','Outbound' `
                                                           -Description 'Direction of trust'
                TrustType       = New-xDscResourceProperty -Name TrustType -Type String -Attribute Required -ValidateSet 'CrossLink','External','Forest','Kerberos','ParentChild','TreeRoot','Unknown' `
                                                           -Description 'Type of trust'
                Ensure    = New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet 'Present','Absent' `
                                                     -Description 'Should this resource be present or absent'
                
            }
New-xDscResource -Name MSFT_xADDomainTrust -Property $Properties.Values -Path . -ModuleName xActiveDirectory -FriendlyName xADDomainTrust -Force

