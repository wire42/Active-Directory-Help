###############################################################################
#                          Active Directory Management Script                 #
#                                                                             #
# This script provides an interactive menu to help administrators manage      #
# stale user and computer accounts, orphaned user folders, and locked accounts#
# in Active Directory environments.     created by Patrick Elliott            #
###############################################################################

---------------------------
REQUIREMENTS
---------------------------
- PowerShell 5.1 or later
- Active Directory PowerShell module
- Sufficient AD permissions to read, disable, and (optionally) delete accounts
- Run as a user with appropriate rights

---------------------------
USAGE
---------------------------
1. Save the script to a .ps1 file (e.g., ADMenuScript.ps1).
2. Open PowerShell as Administrator.
3. Run the script: .\ADMenuScript.ps1
4. Follow the on-screen menu prompts.

---------------------------
MENU OPTIONS
---------------------------
1: Old User Lookup
    - Finds enabled AD user accounts that have not logged on in a specified number of days.
    - Exports the list to OldUsers.csv.
    - For each user, prompts to Disable, Delete (commented out for safety), or Skip.
    - Actions are logged to ADScriptLog.txt.
    - A summary report is displayed at the end.

2: Old Computer Lookup
    - Finds enabled AD computer accounts that have not logged on in a specified number of days.
    - Exports the list to OldComputers.csv.
    - For each computer, prompts to Disable, Delete (commented out for safety), or Skip.
    - Actions are logged to ADScriptLog.txt.
    - A summary report is displayed at the end.

3: User Folder Lookup
    - Compares user folders in a specified directory (default: C:\Users) with current AD users.
    - Exports orphaned folders (folders with no matching AD account) to OrphanedFolders.csv.
    - Logs the operation and provides a summary report.

4: Check for Locked Accounts
    - Lists all currently locked-out user accounts in AD.
    - Exports the list to LockedUsers.csv.
    - Logs the operation and provides a summary report.

5: Exit
    - Exits the script.

---------------------------
LOGGING
---------------------------
- All actions (disable/delete/lookup) are recorded in ADScriptLog.txt for auditing.

---------------------------
SAFETY NOTES
---------------------------
- The deletion commands for users and computers are commented out for safety.
  To enable deletion, remove the comment symbol (#) from the relevant lines.
- Always review exported CSV files before taking further action.
- Test the script in a non-production environment before using in production.

---------------------------
SUPPORT
---------------------------
For questions or improvements, contact your IT administrator or script author.

###############################################################################
