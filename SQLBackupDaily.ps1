###Written by: Evan Lane###
###    Version: 2.3     ###
###Updated:May 19th 2017###
#
# This Script will backup your SQL server Daily.
#
$dayOfWeek = (Get-Date).DayOfWeek.ToString().substring(0, 2)

#ServerPaths Config#######################################
$backupFol = "C:\SQLBackups\"
$backupFile = "SQLBackup$($dayOfWeek).bck"

#SQL Config###############################################
$sqlUsername = "username"
$sqlPassword = "password"
$sqlServer = "localhost\sqlserver"
$sqlDatabase = "DATABASE" #All Caps

#SMTP Config##############################################
$smtp = $true #set $false for no emails
$mailServer = "mail.domain.com"
$fromAddress = "SQLBackups@domain.com"
$toAddress = "user@domain.com"
$serverName = gc env:computername

#SMTP Email Messages Config###############################
$sucessBody = @"
Complete: Backup Successful!
Please investigate $ServerName!
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
 OSQL -U $sqlUsername -P $sqlPassword -S $sqlServer -Q "BACKUP DATABASE $sqlDatabase to disk = '$($backupFol)$($backupFile)'"

 if ($smtp -eq $true){
  Send-MailMessage -SmtpServer $mailServer -From $fromAddress -To $toAddress -Subject "$serverName SQL Daily Backup - Successful" -Body $sucessBody
 }
}
Catch{
 $ErrorMessage = $_.Exception.Message
 $FailedItem = $_.Exception.ItemName

 if ($smtp -eq $true){
  Send-MailMessage -SmtpServer $mailServer -From $fromAddress -To $toAddress -Subject "$serverName SQL Daily Backup - Failed" -Body $errorBody
 }
}