#---------------------------------# 
# xDscResourceTests Pester        # 
#---------------------------------#
$DSC = Get-DscResource | Where-Object {$_.Module.Name -eq 'cChoco'}

Describe 'Testing all DSC resources using xDscResource designer.' {
  foreach ($Resource in $DSC)
  { 
    if (-not ($Resource.ImplementedAs -eq 'Composite') ) {
      $ResourceName = $Resource.ResourceType
      $Mof          = Get-ChildItem “$PSScriptRoot\..\” -Filter "$resourcename.schema.mof" -Recurse 
      
      Context “Testing DscResource '$ResourceName' using Test-xDscResource” {
        It 'Test-xDscResource should return $true' {
          Test-xDscResource -Name $ResourceName | Should Be $true
        }    
      }

      Context “Testing DscSchema '$ResourceName' using Test-xDscSchema” {
        It 'Test-xDscSchema should return true' {
          Test-xDscSchema -Path $Mof.FullName | Should Be $true
        }    
      }
    }
  }
}