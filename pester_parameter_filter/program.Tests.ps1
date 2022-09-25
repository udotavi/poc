BeforeAll {
  . $PSScriptRoot/program.ps1
  function myFunction () {
    param($name)
  }
}

Describe "Main" {
  Context "Context: 1" {
    BeforeAll {
      # Mock myFunction { return "federer" }
      Mock myFunction -parameterFilter { $name -eq "roger" } { return "federer" }
      Mock myFunction -parameterFilter { $name -eq "rafa" } { return "nadal" }
      Mock Write-Output
      Main
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName Write-Output -Exactly -Times 15 -Scope Context
    }
  }
}