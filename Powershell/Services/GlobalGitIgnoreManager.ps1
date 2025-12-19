function Set-LoadGlobalGitIgnore {
  $GitGlobalIgnorePath = Join-Path -Path $HOME -ChildPath ".gitignore_global"

  # Flag created or updated
  $WasUpdatedOrCreated = $false

  ######## GUARD CLAUSE : GIT AVAILABILITY ########
  if (-not (Test-GitAvailability -Message "⛔ Git is not installed (or not found in path). Global git ignore config skipped ! ⛔")) {
    return
  }

  # Load default template content
  $DefaultLines = Get-DefaultGlobalGitIgnoreTemplate

  ######## SECURITY : EMPTY TEMPLATE => STOP CLEANLY ########
  if ($null -eq $DefaultLines -or $DefaultLines.Count -eq 0) {
    Show-GracefulError -Message "❌ GlobalGitIgnoreTemplate.txt not found | empty ❌" -NoTrailingNewline

    return
  }

  ######## FILE CREATION/UPDATE ORCHESTRATION ########
  if (-not (Test-Path $GitGlobalIgnorePath)) {
    ######## CASE 1 : FILE DOESN'T EXIST (CREATION) ########
    Initialize-GlobalGitIgnoreFile -Path $GitGlobalIgnorePath -ContentLines $DefaultLines

    $WasUpdatedOrCreated = $true
  }
  ######## CASE 2 : FILE EXIST (UPDATE) ########
  else {
    $WasUpdatedOrCreated = Update-GlobalGitIgnoreFile -Path $GitGlobalIgnorePath -DefaultLines $DefaultLines
  }

  ######## GIT CONFIGURATION ########
  # Only display if file was touched or config is wrong
  Set-GlobalGitIgnoreReference -Path $GitGlobalIgnorePath -ShowMessage $WasUpdatedOrCreated
}
