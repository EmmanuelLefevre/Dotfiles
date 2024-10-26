# Load PowerShell Profile
. "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Call function
git_pull

# Close terminal
Write-Host ""
Read-Host -Prompt "Press Enter to close... "
