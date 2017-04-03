# Group variable and group name to add users too.

$UserGroup = "Group For Users"

# Imports the CSV file and searches for each user based on email address and adds them to the group in the above variable.

Get-Content 'C:\temp\people.csv' | 
ForEach-Object {
    Get-ADUser -Filter {mail -eq $_} | 
        ForEach-Object { 
            Add-ADGroupMember -Identity $UserGroup -Members $_.samaccountname 
    }
}