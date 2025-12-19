##########---------- Initialize .gitignore_global file if missing ----------##########
function Initialize-GlobalGitIgnoreFile {
  param (
    [string]$Path,
    [string[]]$ContentLines
  )

  Show-HeaderFrame -Title "LOAD GLOBAL GIT IGNORE CONFIGURATION"

  # Message 1 : Not Found
  $msgPrefix = " .gitignore_global"
  $msgSuffix = " not found..."

  $fullMsg = $msgPrefix + $msgSuffix

  Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
  Write-Host -NoNewline $msgPrefix -ForegroundColor Cyan
  Write-Host $msgSuffix -ForegroundColor DarkYellow
  Write-Host ""

  # Message 2 : Creating
  $msg = "🔄 Creating it with default template 🔄"

  Write-Host -NoNewline (Get-CenteredPadding -RawMessage $msg)
  Write-Host $msg -ForegroundColor Green

  try {
    # Initialize content
    Set-FileContentCrossPlatform -Path $Path -Content $ContentLines

    $msg = "✅ File created successfully ✅"

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $msg)
    Write-Host $msg -ForegroundColor Green
    Write-Host ""
  }
  catch {
    Show-GracefulError -Message "❌ Error creating default template : " -NoCenter -ErrorDetails $_
  }
}

##########---------- Update .gitignore_global file if exists ----------##########
function Update-GlobalGitIgnoreFile {
  param (
    [string]$Path,
    [string[]]$DefaultLines
  )

  ######## GUARD : FORCE ARRAY ########
  $ExistingLines = @(Get-Content -Path $Path -Encoding UTF8) | ForEach-Object { $_.TrimEnd("`r") }

  # Parse only valid rules from template
  $ParsedTemplate = Get-ParsedDefaultRules -DefaultLines $DefaultLines

  ######## SECURITY : GET FILE CONTENT WITHOUT GENERATED "NEW IGNIRE RULES" SECTION ########
  # Avoid duplication if we run script multiple times
  $CleanFileLines = Get-LinesWithoutNewRules -Lines $ExistingLines

  ######## CALCULATE : MISSING ITEMS ########
  # Ccheck if rules exist in CLEAN file content
  $CleanFileContentForCheck = $CleanFileLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith('#') }

  $ItemsToAdd = @()
  foreach ($item in $ParsedTemplate) {
    if ($CleanFileContentForCheck -notcontains $item.Rule) {
      $ItemsToAdd += $item
    }
  }

  # Calculate truly new rules
  $TrulyNewItems = $ItemsToAdd | Where-Object { $ExistingLines -notcontains $_.Rule }

  # Build new content (clean file + new block at end)
  $NewContent = Build-GlobalGitIgnoreUpdatedContent -BaseLines $CleanFileLines -ItemsToAdd $ItemsToAdd

  # Check if content actually changed
  $CurrentContentString = $ExistingLines -join "`n"
  $NewContentString = $NewContent -join "`n"

  if ($CurrentContentString -eq $NewContentString) {
    return $false
  }

  # If we are here, we have updates
  Show-HeaderFrame -Title "UPDATE GLOBAL GIT IGNORE CONFIGURATION"

  # Display messages
  if ($TrulyNewItems.Count -gt 0) {
    $msgPrefix = "📢 New exclusions added to "
    $fileNameStr = " .gitignore_global"
    $msgSuffix = " 📢"

    $fullMsg = $msgPrefix + $fileNameStr + $msgSuffix

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
    Write-Host -NoNewline $msgPrefix -ForegroundColor DarkYellow
    Write-Host -NoNewline $fileNameStr -ForegroundColor Cyan
    Write-Host $msgSuffix
    Write-Host ""

    Write-Host "New rules added =>" -ForegroundColor DarkBlue

    foreach ($item in $TrulyNewItems) {
      Write-Host "  $($item.Rule)" -ForegroundColor DarkCyan
    }

    Write-Host ""
  }
  else {
    $msgPrefix = "♻️ Synchronizing "
    $fileNameStr = " .gitignore_global"
    $msgSuffix = " structure ♻️"

    $fullMsg = $msgPrefix + $fileNameStr + $msgSuffix

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
    Write-Host -NoNewline $msgPrefix -ForegroundColor DarkYellow
    Write-Host -NoNewline $fileNameStr -ForegroundColor Cyan
    Write-Host -NoNewline $msgSuffix -ForegroundColor DarkYellow
    Write-Host ""
  }

  ######## SECURITY : CREATE BACKUP ########
  Sync-GlobalGitIgnoreBackup -Path $Path -Action "Create"

  # Write changes
  try {
    # Update content
    Set-FileContentCrossPlatform -Path $Path -Content $NewContent

    ######## CLEANUP: DELETE BACKUP ON SUCCESS ########
    Sync-GlobalGitIgnoreBackup -Path $Path -Action "Delete"

    $msgSuccess = "✅ File updated successfully ✅"

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $msgSuccess)
    Write-Host $msgSuccess -ForegroundColor Green
    Write-Host ""

    return $true
  }
  catch {
    Show-GracefulError -Message "❌ Error updating file : " -NoCenter -ErrorDetails $_

    # Backup warning
    $msgPrefix = "⚠️ Backup saved at : "
    $msgSuffix = " $Path.bak"

    $fullMsg = $msgPrefix + $msgSuffix

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
    Write-Host -NoNewline $msgPrefix -ForegroundColor DarkYellow
    Write-Host $msgSuffix -ForegroundColor DarkCyan
    Write-Host ""

    return $false
  }
}

##########---------- Configure .gitignore_global reference ----------##########
function Set-GlobalGitIgnoreReference {
  param (
    [string]$Path,
    [bool]$ShowMessage
  )

  # Get actual config
  $CurrentConfig = git config --global core.excludesfile

  # Cross-Platform normalization
  $NormCurrent = if (-not [string]::IsNullOrWhiteSpace($CurrentConfig)) {
    [System.IO.Path]::GetFullPath($CurrentConfig)
  }
  # Avoid .NET error
  else { "" }

  $NormPath = [System.IO.Path]::GetFullPath($Path)

  ######## GUARD CLAUSE : COMPARE STANDARDIZED VERSIONS ########
  if ($NormCurrent -ne $NormPath) {

    git config --global core.excludesfile $Path

    # Only show if we are in an active context (header already shown)
    if ($ShowMessage) {
      $msgPrefix = "⚓ Git configured to use "
      $msgSuffix = " .gitignore_global"

      $fullMsg = $msgPrefix + $msgSuffix

      Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
      Write-Host -NoNewline $msgPrefix -ForegroundColor DarkYellow
      Write-Host -NoNewline $msgSuffix -ForegroundColor Cyan
      Write-Host ""
    }
  }
}

##########---------- Build updated content for .gitignore_global ----------##########
function Build-GlobalGitIgnoreUpdatedContent {
  param (
    [string[]]$BaseLines,
    [array]$ItemsToAdd
  )

  # Start with clean base
  $NewContent = [System.Collections.Generic.List[string]]::new([string[]]$BaseLines)

  # If no new items to add, just return cleaned file (removes old "NEW IGNORE RULES" block)
  if ($ItemsToAdd.Count -eq 0) {
    return $NewContent
  }

  # Add new rules block at end
  if ($NewContent.Count -gt 0 -and $NewContent[$NewContent.Count - 1] -ne "") {
    $NewContent.Add("")
  }

  $NewContent.Add("# ======================================================================")
  $NewContent.Add("# NEW IGNORE RULES")
  $NewContent.Add("# ======================================================================")

  # Format and sort rules
  $FormattedBlock = Get-FormattedNewRulesBlock -Items $ItemsToAdd
  $NewContent.AddRange([string[]]$FormattedBlock)

  return $NewContent
}

##########---------- Get formatted new rules block (sorting + grouping) ----------##########
function Get-FormattedNewRulesBlock {
  param (
    [array]$Items
  )

  $BlockContent = [System.Collections.Generic.List[string]]::new()

  # Group missing items by category
  $GroupedRules = $Items | Group-Object Category

  foreach ($group in $GroupedRules) {
    $CategoryName =
      # If no category (null or empty), we force "# Others"
      if ([string]::IsNullOrWhiteSpace($group.Name)) {"# Others" }
      # Otherwise, make sure it's properly formatted (double security)
      else { Format-GitIgnoreComment -RawComment $group.Name }

    # Add blank line before new category (if not immediately after header)
    if ($BlockContent.Count -gt 0) {
      $BlockContent.Add("")
    }

    # Add category title
    $BlockContent.Add($CategoryName)

    # Adding rules for this group (sorted alphbetically)
    foreach ($item in ($group.Group | Sort-Object Rule)) {
      $BlockContent.Add($item.Rule)
    }
  }

  return $BlockContent
}

##########---------- Get lines ignoring the new rules section ----------##########
function Get-LinesWithoutNewRules {
  param (
    [string[]]$Lines
  )

  $CleanLines = @()
  $Skipping = $false

  # Scan the file
  for ($i = 0; $i -lt $Lines.Length; $i++) {
    $line = $Lines[$i]

    ######## DETECTION : START OF GENERATED BLOCK ########
    # Look for decoration line followed by "NEW IGNORE RULES"
    if ($line.StartsWith("# ======================================================================") -and
      ($i + 1 -lt $Lines.Length) -and
      ($Lines[$i+1] -match "NEW IGNORE RULES")) {

      $Skipping = $true
    }

    ######## DETECTION : END OF GENERATED BLOCK ########
    if ($Skipping) {
      if ($line -match "USER CUSTOMIZATIONS") {
        # Found user customs (if accidentally placed after), stop skipping
        $Skipping = $false
      }
    }

    if (-not $Skipping) {
      $CleanLines += $line
    }
  }

  # Trim trailing empty lines from clean content
  while ($CleanLines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($CleanLines[-1])) {
    $CleanLines = $CleanLines[0..($CleanLines.Count - 2)]
  }

  return $CleanLines
}

##########---------- Manage Backup (Create/Delete) ----------##########
function Sync-GlobalGitIgnoreBackup {
  param (
    [string]$Path,
    [ValidateSet("Create", "Delete")]
    [string]$Action
  )

  $BackupPath = "$Path.bak"

  if ($Action -eq "Create") {
    Copy-Item -Path $Path -Destination $BackupPath -Force
  }
  elseif ($Action -eq "Delete") {
    if (Test-Path $BackupPath) {
      Remove-Item -Path $BackupPath -Force
    }
  }
}

##########---------- Format comment (capitalize + space) ----------##########
function Format-GitIgnoreComment {
  param (
    [string]$RawComment
  )

  # If not a comment, send it back as is
  if (-not $RawComment.StartsWith("#")) { return $RawComment }

  # Remove "#"" symbol(s) and spaces from beginning
  $CleanText = $RawComment -replace "^#+\s*", ""

  # If empty after cleaning ("#"), simply return "#"
  if ([string]::IsNullOrWhiteSpace($CleanText)) { return "#" }

  # Capitalize first letter
  $FirstLetter = $CleanText.Substring(0, 1).ToUpper()
  $RestOfText = $CleanText.Substring(1)

  # Rebuilt with single guaranteed space
  return "# $FirstLetter$RestOfText"
}

##########---------- Parse template to associate rules with categories ----------##########
function Get-ParsedDefaultRules {
  param (
    [string[]]$DefaultLines
  )

  $RulesCollection = @()
  $CurrentCategory = $null

  foreach ($line in $DefaultLines) {
    # "USER CUSTOMIZATIONS" section of template isn't readable
    if ($line -match "USER CUSTOMIZATIONS") { break }

    # If line is empty, category is reset
    if ([string]::IsNullOrWhiteSpace($line)) {
      $CurrentCategory = $null

      continue
    }

    if ($line.StartsWith("#")) {
      # If comment, it's a category to include
      if ($line -match "====") {
        $CurrentCategory = $null
      }
      else {
        $CurrentCategory = Format-GitIgnoreComment -RawComment $line
      }
    }
    else {
      # If no category defined, go into "Others" category
      $RulesCollection += [PSCustomObject]@{
        Rule     = $line
        Category = $CurrentCategory
      }
    }
  }

  return $RulesCollection
}

##########---------- Provide default .gitignore_global template ----------##########
function Get-DefaultGlobalGitIgnoreTemplate {
  # Silent verification of dependence
  if (-not (Get-Command Get-LocationPathConfig -ErrorAction SilentlyContinue)) { return @() }

  $Config = Get-LocationPathConfig | Where-Object { $_.Name -eq "profile" }
  if ($null -eq $Config -or [string]::IsNullOrWhiteSpace($Config.Path)) { return @() }

  $TemplatePath = Join-Path $Config.Path "Templates"
  $TemplatePath = Join-Path $TemplatePath "GlobalGitIgnoreTemplate.txt"

  if (Test-Path $TemplatePath) {
    $RawContent = Get-Content -Path $TemplatePath -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($null -eq $RawContent) { return @() }

    return @($RawContent) | ForEach-Object { $_.TrimEnd("`r") }
  }

  return @()
}
