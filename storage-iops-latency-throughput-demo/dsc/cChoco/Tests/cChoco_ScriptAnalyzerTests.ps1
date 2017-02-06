#---------------------------------# 
# PSScriptAnalyzer tests          # 
#---------------------------------# 
$Rules   = Get-ScriptAnalyzerRule

#Only run on cChocoInstaller.psm1 for now as this is the only resource that has had code adjustments for PSScriptAnalyzer rules.
$Modules = Get-ChildItem “$PSScriptRoot\..\” -Filter ‘*.psm1’ -Recurse | Where-Object {$_.FullName -match '(cChocoInstaller|cChocoPackageInstall)\.psm1$'}

#---------------------------------# 
# Run Module tests (psm1)         # 
#---------------------------------# 
if ($Modules.count -gt 0) {
  Describe ‘Testing all Modules against default PSScriptAnalyzer rule-set’ {
    foreach ($module in $modules) {
      Context “Testing Module '$($module.FullName)'” {
        foreach ($rule in $rules) {
          It “passes the PSScriptAnalyzer Rule $rule“ {
            (Invoke-ScriptAnalyzer -Path $module.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
          }
        }
      }
    }
  }
}