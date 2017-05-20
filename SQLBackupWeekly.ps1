#Written by: Evan Lane
#Version 2.5
#Latest Revision: May 18th 2017
Import-Module BitsTransfer
$today = Get-Date -Format dd-MM-yyyy

#ServerPaths Config#######################################
$backupFol = "C:\SQLBackups\"
$backupFile = "SQLWeekly_$($today).bck"
$netFol = "\\192.168.x.x\<folder>"

#SQL Config###############################################
$sqlUsername = "username"
$sqlPassword = "password"
$sqlServer = "localhost\sqlserver"
$sqlDatabase = "DATABASE" #all Caps

#SMTP Config##############################################
$smtp = $true #set $false for no emails
$mailServer = "mail.domain.com"
$fromAddress = "SQLBackups@domain.com"
$toAddress = "user@domain.com"
$serverName = gc env:computername

#SMTP Message Configs#####################################
$successBody = @"
Complete: Backup Successful!
Output: $backupFile
"@

$errorBody = @"
Error: Backup Failed!
Please investigate $ServerName!
$ErrorMessage
$FailedItem
"@
#####################END USER CONFIG#######################
Try{
OSQL -U $sqlUserName -P $sqlPassword -S $sqlServer -Q "BACKUP DATABASE $sqlDatabase to disk = '$($backupFol)$($backupFile)'"

 Start-BitsTransfer -Source "$($backupFol)$($backupFile)" -Destination "$($netFol)$($backupFile)" -Description "SQLBackup" -DisplayName "SQLBackup"

 if ($smtp -eq $true){
  Send-MailMessage -SmtpServer $mailServer -From $fromAddress -To $toAddress -Subject "$serverName SQL Weekly Backup - Successful" -Body $successBody
 }
}
Catch{
 $ErrorMessage = $_.Exception.Message
 $FailedItem = $_.Exception.ItemName

 if ($smtp -eq $true){
  Send-MailMessage -SmtpServer $mailServer -From $fromAddress -To $toAddress -Subject "$serverName SQL Weekly Backup - Failed" -Body $errorBody
 }
}