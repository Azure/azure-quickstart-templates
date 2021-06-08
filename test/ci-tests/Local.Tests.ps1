Describe "Convert-StringToLines" {
    BeforeAll {
        $newline = [System.Environment]::NewLine

        $ErrorActionPreference = 'Stop'    
        $dataFolder = "$(Split-Path $PSCommandPath -Parent)/data/validate-deploymentfile-tests"

        Import-Module "$(Split-Path $PSCommandPath -Parent)/../ci-scripts/Local.psm1" -Force

        function Test-ConvertStringToLinesAndViceVersa(
            [string]$Original,
            [string[]]$Expected
        ) {
            $a = Convert-StringToLines $Original
            $a | Should -Be $Expected
            $b = Convert-LinesToString $a

            $b | Should -Be $Original
        }
    }
    
    It 'Convert-StringToLines and Convert-LinesToString' {
        Test-ConvertStringToLinesAndViceVersa "" @("")
        Test-ConvertStringToLinesAndViceVersa "abc" @("abc")
        Test-ConvertStringToLinesAndViceVersa "abc`n" @("abc", "")
        Test-ConvertStringToLinesAndViceVersa "abc$($newline)def" @("abc", "def")
        Test-ConvertStringToLinesAndViceVersa "abc$($newline)def$($newline)ghi" @("abc", "def", "ghi")
        Test-ConvertStringToLinesAndViceVersa "abc$($newline)$($newline)def" @("abc", "", "def")
    }
}