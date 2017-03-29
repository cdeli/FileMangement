Import-Module NTFSSecurity
Import-Module ActiveDirectory

# Lines 6-12 are similar to creating the next weeks folder. The difference is that it runs twice creating the next 2 weeks folders

[Int]$index = Get-Date  | Select-Object -ExpandProperty DayOfWeek
$daysSinceFourthSunday = -28 - $index
$daysTillNextSunday = 7 - $index
$daysTillDoubleSunday = 14 - $index
$FourthSunday = (Get-Date).AddDays($daysSinceFourthSunday).ToString('MM-dd-yyyy')
$NextSunday = (Get-Date).AddDays($daysTillNextSunday).ToString('MM-dd-yyyy')
$DoubleSunday = (Get-Date).AddDays($daysTillDoubleSunday).ToString('MM-dd-yyyy')

$UserShare = "Z:\ShareParent\UserGroup\Users\"
$archive = "Z:\ShareParent\UserGroup\Archive"
$UserGroup = "Group For Users"
$TestReport = "$UserShare$($_.samaccountname)\Reports and Backup\Week Ending ($FourthSunday)"
#$TestTime = "$UserShare$($_.samaccountname)\Time and Expense\Week Ending ($FourthSunday)"

#$smtpserver = 'mail.Contoso.com'
#$port = 587
#$to = User1@contoso.com
#$from = 'Contosoreporting@Contoso.com'
#$ReportArchive = "C:\scripts\FileCloudProject\NewArchive\ReportArchive.csv"
#$TimeArchive = "C:\scripts\FileCloudProject\NewArchive\TimeArchive.csv"

# This portion moves the users folders into an archive, created in the prior script. This archive
# populates with "week ending xx-xx-xxxx" folders after the 6th week of time has passed.
# Once week 7 folders are made the oldest folder is stripped of its permissions for the Users 
# and moves into the archive where the admins of that team have access but the origonal users do not.

$PriorSundayReport = @()
Get-ADGroupMember $UserGroup | ForEach-Object `
{
    if (test-path -path $TestReport -PathType Container) {
        Write-Output $TestReport Does not exist!
    } Else {
        $PriorSundayReport += Move-Item -Path "$UserShare$($_.samaccountname)\Reports and Backup\Week Ending $FourthSunday" `
        -Destination "$archive$($_.samaccountname)\Reports and Backup\" -Force
        Remove-NTFSAccess -Path "$archive$($_.samaccountname)\Reports and Backup\Week Ending $FourthSunday" -Account "Contoso\$($_.samaccountname)" `
        -AccessRights Write -AppliesTo SubfoldersAndFilesOnly
        New-Item "$UserShare$($_.samaccountname)\Reports and Backup\Week Ending $NextSunday" -ItemType Directory
        New-Item "$UserShare$($_.samaccountname)\Reports and Backup\Week Ending $DoubleSunday" -ItemType Directory
    }
}

#if ($PriorSundayReport) {
#    $PriorSundayReport | epcsv $ReportArchive -NoTypeInformation -Encoding ASCII
#
#    Send-MailMessage `
#        -SmtpServer $smtpserver `
#        -Port $port `
#        -To $to `
#        -From $from `
#        -Attachments $ReportArchive `
#        -Subject "Folders added to the Report and Backup Folder" `
#        -Body "Folders ending with the date $FourthSunday have been added to the Report and Backup folder in the File Cloud Steel Archive"
#} else {
#    Send-MailMessage `
#        -SmtpServer $smtpserver `
#        -Port $port `
#        -To $to `
#        -From $from `
#        -Subject "User Count did not change" `
#        -Body "No additional users or folders have been added to the Archive. Please check all current users."
#}

#if ($PriorSundayTime) {
#    $PriorSundayTime | epcsv $TimeArchive -NoTypeInformation -Encoding ASCII
#
#    Send-MailMessage `
#        -SmtpServer $smtpserver `
#        -Port $port `
#        -To $to `
#        -From $from `
#        -Attachments $TimeArchive `
#        -Subject "Folders added to the Report and Backup Folder" `
#        -Body "Folders ending with the date $FourthSunday have been added to the Time and Expense folder in the File Cloud Steel Archive."
#} else {
#    Send-MailMessage `
#        -SmtpServer $smtpserver `
#        -Port $port `
#        -To $to `
#        -From $from `
#        -Subject "User Count did not change" `
#        -Body "No additional users or folders have been added to the Archive. Please check all current users."
#}