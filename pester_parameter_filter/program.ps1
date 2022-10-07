# this function is commented out as it may belong to a separate module
# function myFunction() {
#   param($name)

#   if ( $name -eq "roger" ) {
#     return "federer"
#   }
#   else {
#     return "nadal"
#   }
# }

function Main() {

  $counter = 0

  $exec1 = myFunction -name "roger"
  if ($exec1 -eq "federer") {
    Write-Output "execution 1 steps"
    Write-Output "execution 1 steps"
    Write-Output "execution 1 steps"
    Write-Output "execution 1 steps"
    Write-Output "execution 1 steps"
    
    $counter += 1
  }

  $exec2 = myFunction -name "rafa"
  if ($exec2 -eq "nadal") {
    Write-Output "execution 2 steps"
    Write-Output "execution 2 steps"
    Write-Output "execution 2 steps"
    Write-Output "execution 2 steps"
    Write-Output "execution 2 steps"

    $counter += 1
  }

  Write-Host "Counter value is" $counter

  if ($counter -eq 2) {
    Write-Output "other steps"
    Write-Output "other steps"
    Write-Output "other steps"
    Write-Output "other steps"
    Write-Output "other steps"
  }
}

if ($MyInvocation.InvocationName -ne '.') {
  Main
}
