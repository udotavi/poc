<#
  .SYNOPSIS
  Change the primary domain of a user
  .Description
  This program will set the value of an additional property "snowBlock"
  to $null or "SNOWBLOCK"
#>

param($mySbMsg, $TriggerMetadata)

$global:ProvidedUserAccounts = @{
  Red   = "example@example1.com"
  Green = "example@example2.com"
  Blue  = "example@example3.com"
  SzC   = "example@example4.com"
}

$global:RequestedPrimaryAccount = "Red"
# $global:ProvidedUserAccounts = @{
#   Red   = $mySbMsg.requestDetails.red
#   Green = $mySbMsg.requestDetails.green
#   Blue  = $mySbMsg.requestDetails.blue
#   SzC   = $mySbMsg.requestDetails.szc
# }

# $global:RequestedPrimaryAccount = $mySbMsg.requestDetails.primary

$global:AccountsFound = @{}

$global:StatusObject = @{
  status     = "Complete"
  statusCode = "200"
  message    = ""
}

function SetStatusObject() {
  # helper function to update StatusObject
  param($status, $statusCode, $message)

  # Write-Output "$status : $statusCode - $message"
  $global:StatusObject.status = $status
  $global:StatusObject.statusCode = $statusCode
  $global:StatusObject.message += $message + "."

  Write-Output $global:StatusObject
}

function SetupConnection() {
  # setup the connection to ms graph
  try {
    Write-Output "Trying to setup connection to AzAccount.."
    Connect-AzAccount -Identity
    $graphAccessToken = (Get-AzAccessToken -ResourceTypeName MSGraph).Token
    Connect-MgGraph -AccessToken $graphAccessToken
  }
  catch {
    Write-Output "$_"
    SetStatusObject -status "Error" -statusCode "400" -message "Cound not setup connection to MS Graph: $_"
  }
}

function GetUserAccount() {
  # checks if a user account is present
  param($UserIdentifier)

  $UserDetails = $False

  try {
    if ($UserIdentifier -like "*example4*") {
      $UserDetails = $(Get-MgUser -Filter "Mail eq $($UserIdentifier)") # need to check
    }
    else {
      $UserDetails = $(Get-MgUser -UserId $UserId)
    }
  }
  catch {
    $UserDetails = $False
  }

  return $UserDetails
}

function CheckUserAccounts() {
  # checks is the user has atleast 2 user accounts and primary account exists

  $global:ProvidedUserAccounts.GetEnumerator() | ForEach-Object { 
    $AccountType = $_.key

    # $UserDetails = $(GetUserAccount -UserIdentifier $_.value)
    $UserDetails = @{
      UserPrincipalName = $_.value
      Id                = "ljalfdsj8243124n14" 
    }

    if (
    ($AccountType -eq "Red" -and $UserDetails.UserPrincipalName -like "*example1.com") -or
    ($AccountType -eq "Green" -and $UserDetails.UserPrincipalName -like "*example2.com") -or
    ($AccountType -eq "Blue" -and $UserDetails.UserPrincipalName -like "*example3.com") -or
    ($AccountType -eq "SzC" -and $UserDetails.UserPrincipalName -like "*example4.com")
    ) {
      $global:AccountsFound = @{$AccountType = $UserDetails.Id }
    }
    else {
      Write-Output "Account Type/Domain mismatch for $AccountType!"
    }

  }

  Write-Output $global:AccountsFound

  if ($null -eq $global:AccountsFound.$global:RequestedPrimaryAccount) {
    SetStatusObject -status "Error" -statusCode "400" -message "Primary account does not exists!"
  }

  if ($global:AccountsFound.Length -lt 2) {
    SetStatusObject -status "Error" -statusCode "400" -message "User must have atleast 2 accounts!"
  }

  # Write-Output $global:StatusObject
}

function ChangePrimaryAccount() {
  # changes the primary account of the user

  $SNOWblock = $ENV:EDF_SnowBlock

  $global:AccountsFound.GetEnumerator() | ForEach-Object {

    $AccountType = $_.key
    $UserAccountId = $_.value

    try {
      if ($AccountType -eq $global:RequestedPrimaryAccount) {
        Update-MgUser -UserID $UserAccountId -AdditionalProperties @{$SNOWblock = "$NULL" }
      }
      else {
        Update-MgUser -UserID $UserAccountId -AdditionalProperties @{$SNOWblock = "SNOWBLOCK" }
      }
    }
    catch {
      Write-Output "$_"
      SetStatusObject -status "Error" -statusCode "400" -message "Could not update user property for Account- $AccountType"
    }
  }

}

function TerminateConnection() {
  # closes the connections with Az and Exchange
  try {
    Disconnect-AzAccount -Confirm:$False
    Disconnect-MgGraph -Confirm:$False
  }
  catch {
    Write-Host "$_"
  }
}

function Main() {
  Write-Output "Process Started - $(Get-Date)"

  Write-Output "Provided User Accounts: $($global:ProvidedUserAccounts)" 
  Write-Output "Requested Primary Account: $($global:RequestedPrimaryAccount)" 

  # tries to setup all the connections
  # SetupConnection

  if ($StatusObject.status -ne "Error") {
    # check if the user has atleast 2 accounts and primary account exists
    CheckUserAccounts
  }

  if ($StatusObject.status -ne "Error") {
    # ChangePrimaryAccount
  }

  # parses execution status/message and sends response
  # $requestType = "dummy_req_type"

  # sourcing SendParseResponse from Modules
  # SendParsedResponse -FunctionName $TriggerMetadata.functionName `
  #   -MySbusMsg $mySbMsg `
  #   -RequestType $requestType `
  #   -StatusObj $StatusObject

  # terminates the Az, Exchange connections
  # TerminateConnection


  Write-Output "Process Completed - $(Get-Date)"
}

Main