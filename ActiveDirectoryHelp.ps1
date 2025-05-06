Import-Module ActiveDirectory

# Log file path
$logFile = ".\ADScriptLog.txt"

# Function to log actions to a file
function Log-Action {
    param([string]$Message)
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

# Function to find and optionally disable/delete old user accounts
function OldUserLookup {
    # Prompt for inactivity period
    $age = Read-Host "Enter number of days for inactivity (default is 90)"
    if (-not $age) { $age = 90 }
    $date = (Get-Date).AddDays(-[int]$age)

    # Get users who haven't logged in since the cutoff date
    $users = Get-ADUser -Filter {Enabled -eq $true -and LastLogonDate -lt $date} -Properties LastLogonDate | 
        Select Name, SamAccountName, LastLogonDate
    $users | Export-Csv -NoTypeInformation .\OldUsers.csv

    Write-Host "$($users.Count) old user(s) exported to OldUsers.csv"

    $actions = @()
    foreach ($user in $users) {
        # Prompt for action on each stale user
        $action = Read-Host "Disable (D), Delete (X), or Skip (S) user $($user.SamAccountName)? [D/X/S]"
        switch ($action.ToUpper()) {
            'D' {
                Disable-ADUser -Identity $user.SamAccountName
                Log-Action "Disabled user $($user.SamAccountName)"
                $actions += "Disabled: $($user.SamAccountName)"
            }
            'X' {
                $confirm = Read-Host "Are you sure you want to DELETE $($user.SamAccountName)? Type YES to confirm"
                if ($confirm -eq "YES") {
                    # Remove-ADUser -Identity $user.SamAccountName -Confirm:$false
                    Log-Action "Deleted user $($user.SamAccountName) (deletion command commented out for safety)"
                    $actions += "Deleted: $($user.SamAccountName) (deletion command commented out)"
                }
            }
            default {
                $actions += "Skipped: $($user.SamAccountName)"
            }
        }
    }
    # Summary report
    Write-Host "`nSummary Report:"
    Write-Host "Total old users found: $($users.Count)"
    Write-Host "Actions taken:"
    $actions | ForEach-Object { Write-Host $_ }
}

# Function to find and optionally disable/delete old computer accounts
function OldComputerLookup {
    # Prompt for inactivity period
    $age = Read-Host "Enter number of days for inactivity (default is 90)"
    if (-not $age) { $age = 90 }
    $date = (Get-Date).AddDays(-[int]$age)

    # Get computers that haven't logged in since the cutoff date
    $computers = Get-ADComputer -Filter {Enabled -eq $true -and LastLogonDate -lt $date} -Properties LastLogonDate |
        Select Name, SamAccountName, LastLogonDate
    $computers | Export-Csv -NoTypeInformation .\OldComputers.csv

    Write-Host "$($computers.Count) old computer(s) exported to OldComputers.csv"

    $actions = @()
    foreach ($comp in $computers) {
        # Prompt for action on each stale computer
        $action = Read-Host "Disable (D), Delete (X), or Skip (S) computer $($comp.SamAccountName)? [D/X/S]"
        switch ($action.ToUpper()) {
            'D' {
                Disable-ADComputer -Identity $comp.SamAccountName
                Log-Action "Disabled computer $($comp.SamAccountName)"
                $actions += "Disabled: $($comp.SamAccountName)"
            }
            'X' {
                $confirm = Read-Host "Are you sure you want to DELETE $($comp.SamAccountName)? Type YES to confirm"
                if ($confirm -eq "YES") {
                    # Remove-ADComputer -Identity $comp.SamAccountName -Confirm:$false
                    Log-Action "Deleted computer $($comp.SamAccountName) (deletion command commented out for safety)"
                    $actions += "Deleted: $($comp.SamAccountName) (deletion command commented out)"
                }
            }
            default {
                $actions += "Skipped: $($comp.SamAccountName)"
            }
        }
    }
    # Summary report
    Write-Host "`nSummary Report:"
    Write-Host "Total old computers found: $($computers.Count)"
    Write-Host "Actions taken:"
    $actions | ForEach-Object { Write-Host $_ }
}

# Function to find user folders that do not match AD users
function UserFolderLookup {
    # Prompt for folder path
    $folderPath = Read-Host "Enter the path to user folders (default is C:\Users)"
    if (-not $folderPath) { $folderPath = "C:\Users" }

    # Get folder names and AD users
    $userFolders = Get-ChildItem -Directory $folderPath | Select-Object -ExpandProperty Name
    $adUsers = Get-ADUser -Filter * | Select-Object -ExpandProperty SamAccountName

    # Find folders not matching any AD user
    $orphanedFolders = $userFolders | Where-Object { $_ -notin $adUsers }
    $orphanedFolders | Export-Csv -NoTypeInformation .\OrphanedFolders.csv

    Write-Host "$($orphanedFolders.Count) orphaned user folder(s) exported to OrphanedFolders.csv"
    Log-Action "Checked user folders in $folderPath. Orphaned folders: $($orphanedFolders.Count)"

    # Summary report
    Write-Host "`nSummary Report:"
    Write-Host "Total folders checked: $($userFolders.Count)"
    Write-Host "Orphaned folders found: $($orphanedFolders.Count)"
}

# Function to list all currently locked user accounts
function LockedAccountsLookup {
    # Get locked out users
    $lockedUsers = Get-ADUser -Filter {LockedOut -eq $true} | Select Name, SamAccountName
    $lockedUsers | Export-Csv -NoTypeInformation .\LockedUsers.csv

    Write-Host "$($lockedUsers.Count) locked user account(s) exported to LockedUsers.csv"
    Log-Action "Checked for locked accounts. Locked accounts: $($lockedUsers.Count)"

    # Summary report
    Write-Host "`nSummary Report:"
    Write-Host "Locked accounts found: $($lockedUsers.Count)"
}

# Main menu loop
do {
    Write-Host "`nMenu:"
    Write-Host "1: Old User Lookup"
    Write-Host "2: Old Computer Lookup"
    Write-Host "3: User Folder Lookup"
    Write-Host "4: Check for Locked Accounts"
    Write-Host "5: Exit"
    $choice = Read-Host "Select an option (1-5)"
    switch ($choice) {
        '1' { OldUserLookup }
        '2' { OldComputerLookup }
        '3' { UserFolderLookup }
        '4' { LockedAccountsLookup }
        '5' { Write-Host "Exiting..." }
        default { Write-Host "Invalid selection." }
    }
} while ($choice -ne '5')
