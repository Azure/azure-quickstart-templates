#---------------------------------# 
# Pester tests for cChocoInstall  # 
#---------------------------------#
$ResourceName = ((Split-Path $MyInvocation.MyCommand.Path -Leaf) -split '_')[0]
$ResourceFile = (Get-DscResource -Name $ResourceName).Path

Describe "Testing $ResourceName loaded from $ResourceFile" {
  Context “Testing 'Get-TargetResource'” {
    It 'DummyTest $true should be $true' {
      $true | Should Be $true
    }    
  }
}