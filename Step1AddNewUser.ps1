# Be sure to have the module named "NTFSSecurity" as you will need it.
# Find-Module NTFSSecurity | Install-Module

Import-Module NTFSSecurity
Import-Module ActiveDirectory

# Create the variables for the different folders and group.
# Group will be the same group you used in the "AddUsersToGroup.ps" Script
# The shares under $UserShare and $archive can be any path except at the \UserGroup\Archive and \UserGroup\Users level.
# These must be constant

$UserShare = "Z:\ShareParent\UserGroup\Users\"
$archive = "Z:\ShareParent\UserGroup\Archive"
$UserGroup = "Group For Users"

# This portion below, pertaining to sending an email of all new files uploaded does not currently work as of version 1.0
# This should work in future iterations.

#$smtpserver = 'mail.contoso.com'
#$port = 587
#$to = User1@contoso.com
#$from = 'Contosoreporting@contoso.com'
$csvfile = 'C:\scripts\FileCloudProject\NewUsers\NewUsers.csv'

# Lines 27-29 look for certain days. All users have a folder created for the upcoming week starting on Saturday. You can of course change this.

[Int]$index = Get-Date  | Select-Object -ExpandProperty DayOfWeek
$daysTillNextSunday = 7 - $index
$NextSunday = (Get-Date).AddDays($daysTillNextSunday).ToString('MM-dd-yyyy')

# Lines 35-47 parses the $UserGroup and creates the directory structure for each user in the group.
# This structure starts after $UserShare to follow like "$UserShare\JohnSmith\Folder1\Week Ending xx-xx-xxxx"
# Following the creation of the folders, like 45 gives Read/Write permission to that user on that folder and all subdirectories.

$newusers = @()
Get-ADGroupMember $UserGroup | ForEach-Object `
{
    if (Test-Path -Path $UserShare$($_.samaccountname) -PathType Container) {
        Write-Host $UserShare$($_.samaccountname) already exists!
    } else {
        $newusers += New-Item "$UserShare$($_.samaccountname)" -itemtype Directory 
            New-Item "$UserShare$($_.samaccountname)\Folder1" -itemtype Directory | `
            New-Item "$UserShare$($_.samaccountname)\Folder1\Week Ending $NextSunday" -ItemType Directory `
            | Format-List name,CreationTime | Export-Csv $csvfile 
        Add-NTFSAccess -Path "$UserShare$($_.samaccountname)" -Account "Contoso\$($_.samaccountname)" -AccessRights Write -AppliesTo SubfoldersAndFilesOnly
    }
}

# Line 52-61 do a lot of the same actions that the previous step did. This creates an archive for the user folders. The next script in the pattern will explain this.

$archiveusers = @()
Get-ADGroupMember $UserGroup | ForEach-Object `
{
    if (Test-Path -Path $archive$($_.samaccountname) -PathType Container) {
        Write-Host $archive$($_.samaccountname) already exists!
    } else {
        $archiveusers += New-Item "$archive$($_.samaccountname)" -itemtype directory | `
        New-item "$archive$($_.samaccountname)\Folder1" -itemtype Directory | `
        Select-Object name, creationtime -First 1
    }
}

#if ($newusers) {
#    $newusers | epcsv $csvfile -NoTypeInformation -Encoding ASCII
#
#   Send-MailMessage `
#        -SmtpServer $smtpserver `
#        -Port $port `
#        -To $to `
#        -From $from `
#        -Attachments $csvfile `
#        -Subject "New Folders on File Cloud" `
#        -Body "New users have been created in the Steel Group file cloud. Please see the attached file for a list of new users!"
#} else {
#    Send-MailMessage `
#        -SmtpServer $smtpserver `
#        -Port $port `
#        -To $to `
#        -From $from `
#        -Subject "No New Users in File Cloud" `
#        -Body "No additional users added this week."
#}