##########---------- Copy .gitignore_global to current repository ----------##########
function Copy-GlobalGitIgnoreToRepo {
  # Define Path
  $GlobalIgnorePath = Join-Path -Path $HOME -ChildPath ".gitignore_global"
  $LocalIgnorePath  = Join-Path -Path (Get-Location) -ChildPath ".gitignore"

  ######## DYNAMIC HEADER FRAME TITLE ########
  # File exists
  if (Test-Path $LocalIgnorePath) {
    $Title = "UPDATE GLOBAL GIT IGNORE IN YOUR REPOSITORY ?"
  }
  # File is missing
  else {
    $Title = "COPY GLOBAL GIT IGNORE IN YOUR REPOSITORY"
  }

  # Display header frame
  Show-HeaderFrame -Title $Title

  ######## GUARD CLAUSE : GLOBAL FILE MISSING ########
  if (-not (Test-Path $GlobalIgnorePath)) {
    Show-GracefulError -Message "⛔ .gitignore_global not found in your user folder !"
    return
  }

  # Check if repo file exists
  if (Test-Path $LocalIgnorePath) {
    $msgPrefix = " .gitignore"
    $msgSuffix = " file already exists in this repository ⚠️"

    $fullMsg = $msgPrefix + $msgSuffix

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
    Write-Host -NoNewline $msgPrefix -ForegroundColor Cyan
    Write-Host $msgSuffix -ForegroundColor DarkYellow
    Write-Host ""

    Write-Host -NoNewline "Overwrite it with global configuration ? (Y/n): " -ForegroundColor Magenta

    # Ask user permission
    $confirm = Wait-ForUserConfirmation

    if (-not $confirm) {
      $msgPrefix = "❌ Operation cancelled. Local "
      $fileNameStr = " .gitignore"
      $msgSuffix = " file kept."

      $fullMsg = $msgPrefix + $fileNameStr + $msgSuffix

      Write-Host ""
      Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
      Write-Host -NoNewline $msgPrefix -ForegroundColor Red
      Write-Host -NoNewline $fileNameStr -ForegroundColor Cyan
      Write-Host $msgSuffix -ForegroundColor Red
      Write-Host ""
      return
    }
  }
  # File doesn't exist
  else {
    $msgPrefix = "✨ Creating new "
    $fileNameStr = " .gitignore"
    $msgSuffix = " file from global template..."

    $fullMsg = $msgPrefix + $fileNameStr + $msgSuffix

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
    Write-Host -NoNewline $msgPrefix -ForegroundColor Green
    Write-Host -NoNewline $fileNameStr -ForegroundColor Cyan
    Write-Host $msgSuffix -ForegroundColor Green
    Write-Host ""
  }

  # Perform Copy
  try {
    # Read global content
    $RawContent = Get-Content -Path $GlobalIgnorePath
    $FilteredContent = New-Object System.Collections.Generic.List[string]

    foreach ($line in $RawContent) {
      ######## CASE 1 : STOP IF HIT "USER CUSTOMIZATIONS" SECTION ########
      if ($line -match "# USER CUSTOMIZATIONS") {
        # Check if line just before was a separator bar (# ========)
        $lastIndex = $FilteredContent.Count - 1
        if ($lastIndex -ge 0 -and $FilteredContent[$lastIndex] -match "^# ={5,}$") {
          $FilteredContent.RemoveAt($lastIndex)
        }

        break
      }

      ######## CASE 2 : SKIP LINES THAT ARE JUST NUMBERS ########
      if ($line -match "^\d+$") {
        continue
      }

      # Add line to new content list
      [void]$FilteredContent.Add($line)
    }

    # Set content
    Set-FileContentCrossPlatform -Path $LocalIgnorePath -Content $FilteredContent

    $msgPrefix = " .gitignore_global"
    $msgAction = " synchronized in "
    $msgTarget = " .gitignore"
    $msgSuffix = " repository ✅"

    $fullMsg = $msgPrefix + $msgAction + $msgTarget + $msgSuffix

    Write-Host ""
    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
    Write-Host -NoNewline $msgPrefix -ForegroundColor Cyan
    Write-Host -NoNewline $msgAction -ForegroundColor Green
    Write-Host -NoNewline $msgTarget -ForegroundColor Cyan
    Write-Host $msgSuffix -ForegroundColor Green
    Write-Host ""
  }
  catch {
    Show-GracefulError -Message "❌ Error copying file : " -NoCenter -ErrorDetails $_
  }
}
