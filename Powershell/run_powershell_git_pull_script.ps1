# Load PowerShell Profile dynamically (works on all OS paths)
. $PROFILE

# Call function
Update-GitRepositories

# Close terminal
Write-Host ""
Read-Host -Prompt "Press Enter to close... "
