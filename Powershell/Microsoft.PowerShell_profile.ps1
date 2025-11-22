#---------------#
# PROMPT THEMES #
#---------------#
oh-my-posh init pwsh --config "$env:USERPROFILE/Documents/PowerShell/powershell_profile_darka.json" | Invoke-Expression

#-------------------------------#
# USE SECURITY PROTOCOL TLS 1.2 #
#-------------------------------#
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#---------#
# ALIASES #
#---------#
Set-Alias ll ls
Set-Alias neo nvim
Set-Alias tt tree


#---------#
# MODULES #
#---------#

########## Terminal Icons ##########
Import-Module Terminal-Icons
########## PSReadLine ##########
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -PredictionViewStyle ListView


#---------#
# HELPERS #
#---------#

##########---------- Get help ----------##########
function help {
  $scriptInfo = Get-ScriptInfo
  $FileName = $scriptInfo.FileName

  # Dictionary of help alias with definition
  $aliasHelp = @{
    custom_alias = "List of custom aliases"
    custom_function = "List of custom functions"
  }

  # Convert dictionary to array of objects
  $aliasArray = @()
  foreach ($key in $aliasHelp.Keys) {
    $aliasArray += [PSCustomObject]@{
      Alias      = $key
      Definition = $aliasHelp[$key]
      FileName   = $FileName
    }
  }

  # Sort array by alias name
  $sortedAliasArray = $aliasArray | Sort-Object Alias

  # Check if any aliases were found and display them
  if ($sortedAliasArray.Count -gt 0) {
    # Display headers
    Write-Host ("{0,-20} {1,-30} {2,-34}" -f "Alias", "Definition", "File Name") -ForegroundColor White -BackgroundColor DarkGray

    # Display each alias informations
    foreach ($alias in $sortedAliasArray) {
      Write-Host -NoNewline ("{0,-21}" -f "$($alias.Alias)") -ForegroundColor DarkCyan
      Write-Host -NoNewline ("{0,-31}" -f "$($alias.Definition)") -ForegroundColor DarkMagenta
      Write-Host ("{0,-30}" -f " $($alias.FileName)") -ForegroundColor DarkYellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host "⚠️ No help aliases found in script ⚠️" -ForegroundColor Red
  }
}

##########---------- Get custom aliases ----------##########
function custom_alias {
  $scriptInfo = Get-ScriptInfo
  $ScriptPath = $scriptInfo.Path
  $FileName = $scriptInfo.FileName

  # Read file content
  $fileContent = Get-Content -Path $ScriptPath

  # Search aliases defined in file (Set-Alias)
  $aliasLines = $fileContent | Where-Object { $_ -match 'Set-Alias' }

  # Extract alias names and definitions
  $customAliases = $aliasLines | ForEach-Object {
    if ($_ -match 'Set-Alias\s+(\S+)\s+(\S+)') {
      [PSCustomObject]@{
        Name     = $matches[1]
        Alias    = $matches[2]
        FileName = $FileName
      }
    }
  }

  if ($customAliases) {
    # Display headers
    Write-Host ("{0,-10} {1,-14} {2,-34}" -f "Alias", "Command", "FileName") -ForegroundColor White -BackGroundColor DarkGray

    # Display each alias informations
    foreach ($alias in $customAliases) {
      Write-Host -NoNewline ("{0,-11}" -f "$($alias.Name)") -ForegroundColor DarkCyan
      Write-Host -NoNewline ("{0,-15}" -f "$($alias.Alias)") -ForegroundColor DarkMagenta
      Write-Host ("{0,-40}" -f " $($alias.FileName)") -ForegroundColor DarkYellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host "⚠️ No custom aliases found in script ⚠️" -ForegroundColor Red
  }
}

##########---------- Get custom functions ----------##########
function custom_function {
  $scriptInfo = Get-ScriptInfo
  $ScriptPath = $scriptInfo.Path
  $FileName = $scriptInfo.FileName

  # Read file content
  $fileContent = Get-Content -Path $ScriptPath

  # Search functions defined in file (function keyword)
  $functionLines = $fileContent | Where-Object { $_ -match 'function\s+\w+\s*\(?.*\)?' }

  # Extract function names and definitions
  $customFunctions = $functionLines | ForEach-Object {
    if ($_ -match 'function\s+(\w+)\s*\(?.*\)?') {
      [PSCustomObject]@{
        Alias    = $matches[1]
        FileName = $FileName
      }
    }
  }

  # List of names to exclude
  $excludedFunctions = @("Complete", "Get", "keyword", "names", "objective", "with", "in")

  # Filter custom functions to exclude those from the list
  $customFunctions = $customFunctions | Where-Object { -not ($excludedFunctions -contains $_.Alias) }

  # Sort functions alphabetically
  $sortedFunctions = $customFunctions | Sort-Object -Property Alias

  # Get function objective
  $goals = Get-GoalFunctionsDictionary

  if ($sortedFunctions) {
    # Display headers
    Write-Host ("{0,-18} {1,-50} {2,-34}" -f "Alias", "Definition", "FileName") -ForegroundColor White -BackGroundColor DarkGray

    # Display each function with informations
    foreach ($function in $sortedFunctions) {
      Write-Host -NoNewline ("{0,-19}" -f "$($function.Alias)") -ForegroundColor DarkCyan
      $goal = $goals[$function.Alias]
      Write-Host -NoNewline ("{0,-51}" -f "$goal") -ForegroundColor DarkMagenta
      Write-Host ("{0,-50}" -f " $($function.FileName)") -ForegroundColor DarkYellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host "⚠️ No custom functions found in script ⚠️" -ForegroundColor Red
  }
}


#-----------#
# FUNCTIONS #
#-----------#

##########---------- Clear ----------##########
function c {
  clear
}

##########----------Display current directory path ----------##########
function path {
  Write-Host ""
  $currentPath = Get-Location
  Write-Host $currentPath -ForegroundColor DarkMagenta
}

##########---------- Navigate to specified folder passed as a parameter ----------##########
##########---------- Or returns to parent directory if no paramater ----------##########
function z {
  param (
    [string]$folder
  )

  # If no parameter is specified, returns to parent directory
  if (!$folder) {
    Set-Location ..
    return
  }

  # Resolve relative or absolute folder path
  $path = Resolve-Path -Path $folder -ErrorAction SilentlyContinue

  if ($path) {
    Set-Location -Path $path
  }
  else {
    Write-Host -NoNewline "⚠️ Folder " -ForegroundColor Red
    Write-Host -NoNewline "$folder" -ForegroundColor Magenta
    Write-Host " not found ⚠️" -ForegroundColor Red
  }
}

##########---------- Docker ----------##########
function dc {
  docker-compose up --build
}

function dr {
  docker rm -f $(docker ps -aq)
  docker volume rm $(docker volume ls -q)
  docker network prune -f
  docker builder prune -af
  docker rmi -f $(docker images -q)
}

function dl {
  docker compose logs -f
}

##########---------- Create a file ----------##########
function touch {
  param (
    [string]$path
  )

  # If file does not exist, create it
  if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -ItemType File
  }
  # Display message if file already exists
  else {
    Write-Host "⚠️ File always exists ⚠️" -ForegroundColor Red
  }
}

##########---------- Jump to a specific directory ----------##########
function go {
  param (
    [string]$location
  )

  # Check if the argument is empty
  if (-not $location) {
    Write-Host "⚠️ Invalid option! Type 'go help' ⚠️" -ForegroundColor Red
    return
  }

  # List of valid options and their corresponding paths
  $validOptions = @(
    @{ Name = "aw";        Path = "$HOME\Desktop\Projets\ArtiWave" },
    @{ Name = "cours";     Path = "$HOME\Desktop\Cours" },
    @{ Name = "docs";      Path = "$HOME\Documents\Documentations" },
    @{ Name = "dotfiles";  Path = "$HOME\Desktop\Dotfiles" },
    @{ Name = "dwld";      Path = "$HOME\Downloads" },
    @{ Name = "eg";        Path = "$HOME\Desktop\Projets\EasyGarden" },
    @{ Name = "el";        Path = "$HOME\Desktop\Projets\EmmanuelLefevre" },
    @{ Name = "home";      Path = "$HOME" },
    @{ Name = "mdimg";     Path = "$HOME\Desktop\MarkdownImg" },
    @{ Name = "nvim";      Path = "$HOME\AppData\Local\nvim" },
    @{ Name = "profile";   Path = "$HOME\Documents\PowerShell" },
    @{ Name = "projets";   Path = "$HOME\Desktop\Projets" },
    @{ Name = "replica";   Path = "$HOME\Desktop\Projets\ReplicaMysql" },
    @{ Name = "help";      Path = "Available paths" }
  )

  # Check if the passed argument is valid
  if ($validOptions.Name -notcontains $location) {
    Write-Host "⚠️ Invalid argument! Type 'go help' ⚠️" -ForegroundColor Red
    return
  }

  Switch ($location) {
    "aw" {
      Set-Location -Path "$HOME\Desktop\Projets\ArtiWave"
    }
    "cours" {
      Set-Location -Path "$HOME\Desktop\Cours"
    }
    "docs" {
      Set-Location -Path "$HOME\Documents\Documentations"
    }
    "dotfiles" {
      Set-Location -Path "$HOME\Desktop\Dotfiles"
    }
    "dwld" {
      Set-Location -Path "$HOME\Downloads"
    }
    "eg" {
      Set-Location -Path "$HOME\Desktop\Projets\EasyGarden"
    }
    "el" {
      Set-Location -Path "$HOME\Desktop\Projets\EmmanuelLefevre"
    }
    "home" {
      Set-Location -Path "$HOME"
    }
    "mdimg" {
      Set-Location -Path "$HOME\Desktop\MarkdownImg"
    }
    "nvim" {
      Set-Location -Path "$HOME\AppData\Local\nvim"
    }
    "profile" {
      Set-Location -Path "$HOME\Documents\PowerShell"
    }
    "projets" {
      Set-Location -Path "$HOME\Desktop\Projets"
    }
    "replica" {
      Set-Location -Path "$HOME\Desktop\Projets\ReplicaMySQL"
    }
    "help" {
      # Create a table of valid options
      Write-Host ""
      Write-Host ("{0,-20} {1,-50}" -f "Alias", "Path Direction") -ForegroundColor White -BackgroundColor DarkGray

      foreach ($option in $validOptions) {
        if ($option.Name -ne "help") {
          Write-Host -NoNewline ("{0,-21}" -f "$($option.Name)") -ForegroundColor DarkCyan
          Write-Host ("{0,-50}" -f " $($option.Path)") -ForegroundColor DarkYellow
        }
      }
      Write-Host ""
    }
    default {
      Write-Host "⚠️ Error occurred! ⚠️" -ForegroundColor Red
    }
  }
}

##########---------- Find path of a specified command/executable ----------##########
function whereis ($comand) {
  Get-Command -Name $comand -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

##########---------- Test GitHub SSH connection with GPG keys ----------##########
function ssh_github {
  param (
    [string]$hostname = "github.com",  # default host
    [int]$port = 22                    # default port for SSH
  )
  Write-Host "🚀 Launch SSH connection with GPG keys 🚀" -ForegroundColor Green
  # Test connection to SSH server
  $connection = Test-NetConnection -ComputerName $hostname -Port $port
  if ($connection.TcpTestSucceeded) {
    Write-Host "The SSH connection to $hostname is open on $port!" -ForegroundColor Green
    & "C:\Windows\System32\OpenSSH\ssh.exe" -T git@github.com
  }
  else {
    Write-Host -NoNewline "⚠️ Unable to connect to " -ForegroundColor Red
    Write-Host -NoNewline "$hostname" -ForegroundColor Magenta
    Write-Host -NoNewline " on port " -ForegroundColor Red
    Write-Host -NoNewline "$port" -ForegroundColor Magenta
    Write-Host "! ⚠️" -ForegroundColor Red
  }
}

##########---------- Display powershell colors in terminal ----------##########
function colors {
  $colors = [enum]::GetValues([System.ConsoleColor])

  Foreach ($bgcolor in $colors) {
    Foreach ($fgcolor in $colors) {
      Write-Host "$fgcolor|" -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine
    }

  Write-Host " on $bgcolor"
  }
}

##########---------- Update your local repositories ----------##########
function gpull {
  [CmdletBinding()]
  param (
    # Force repository information reloading
    [switch]$RefreshCache
  )

  ######## CACHE MANAGEMENT ########
  # If cache doesn't exist or if a refresh is forced
  if (-not $Global:GPullCache -or $RefreshCache) {
    Write-Host "🔄 Updating repositories informations... 🔄" -ForegroundColor Cyan

    ######## DATA RETRIEVAL ########
    # Function is called only once
    $tempReposInfo = Get-RepositoriesInfo

    ######## GUARD CLAUSE : INVALID CONFIGURATION ########
    # Validate result before caching it
    $functionNameMessage = "in Get-RepositoriesInfo function"
    if ($tempReposInfo -eq $null) {
      Write-Host "⛔ Script stopped due to an invalid configuration $functionNameMessage ! ⛔" -ForegroundColor Red

      # Exit function
      return
    }

    # If everything is valid cache is created
    $Global:GPullCache = @{
      ReposInfo = $tempReposInfo
    }
  }

  ######## DATA RETRIEVAL ########
  # Retrieve repositories information from cache
  $reposInfo = $Global:GPullCache.ReposInfo

  $reposOrder = $reposInfo.Order
  $repos = $reposInfo.Paths
  $username = $reposInfo.Username
  $token = $reposInfo.Token

  # Tack if it's first tour
  $isFirstRepo = $true

  ######## REPOSITORY ITERATION ########
  # Iterate over each repository in the defined order
  foreach ($repoName in $reposOrder) {
    $repoPath = $repos[$repoName]

    ######## UI : SEPARATOR ########
    # Separator after each repository (except first)
    if (-not $isFirstRepo) {
      Write-Host ""
      Write-Host -NoNewline "     " -ForegroundColor DarkGray
      Show-Separator -NoNewline -Length 70 -ForegroundColor DarkGray -BackgroundColor Gray
      Write-Host "     " -ForegroundColor DarkGray
      Write-Host ""
    }
    $isFirstRepo = $false

    ######## GUARD CLAUSE : PATH EXISTS ########
    if (-not (Test-LocalRepoExists -Path $repoPath -Name $repoName)) {
      continue
    }

    ######## GUARD CLAUSE : NOT A GIT REPO ########
    if (-not (Test-IsGitRepository -Path $repoPath -Name $repoName)) {
      continue
    }

    # Change current directory to repository path
    Set-Location -Path $repoPath

    ######## GUARD CLAUSE : REMOTE MISMATCH ########
    # Check local remote matches GitHub info
    if (-not (Test-LocalRemoteMatch -UserName $username -RepoName $repoName)) {
      continue
    }

    ######## MAIN PROCESS ########
    # Show repository name being updated
    Write-Host -NoNewline "$repoName" -ForegroundColor white -BackgroundColor DarkBlue
    Write-Host " is on update process 🚀" -ForegroundColor Green

    try {
      ######## API CHECK & FETCH ########
      # Check for remote repository existence using GitHub API with authentication token
      $repoUrl = "https://api.github.com/repos/$username/$repoName"
      $response = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers @{ Authorization = "Bearer $token" } -ErrorAction Stop

      # Store original branch to return it later (Trim removes invisible blank spaces)
      $originalBranch = (git rev-parse --abbrev-ref HEAD).Trim()

      # Fetch latest remote changes
      git fetch --prune --quiet

      # Display date of last remote commit
      Show-LastCommitDate

      ######## GUARD CLAUSE : FETCH FAILED ########
      if (-not (Test-GitFetchSuccess -ExitCode $LASTEXITCODE)) {
        $repoIsInSafeState = $false

        continue
        # Move next repository
      }

      ######## DETECT NEW BRANCHES ########
      # Calculate which remote branches are missing locally
      $newBranchesToTrack = Get-NewRemoteBranches

      ######## USER PERMISSION TO PULL NEW BRANCHES ########
      Invoke-NewBranchTracking -NewBranches $newBranchesToTrack

      # Find all local branches that have a remote upstream
      $branchesToUpdate = git for-each-ref --format="%(refname:short) %(upstream:short)" refs/heads | ForEach-Object {
        $parts = $_ -split ' '
        if ($parts.Length -eq 2 -and $parts[1]) {
          [PSCustomObject]@{ Local = $parts[0]; Remote = $parts[1] }
        }
      }

      # If no branch has an upstream defined
      if (-not $branchesToUpdate) {
        Write-Host "ℹ️ No upstream defined ! Nothing to update or clean up for this repository ! ℹ️" -ForegroundColor DarkYellow

        # Move next repository
        continue
      }

      # Defines priority branches in specific order
      $mainBranchNames = @("main", "master")
      $devBranchNames = @("dev", "develop")

      # Create three lists to guarantee order (force an array)
      $mainBranches = @($branchesToUpdate | Where-Object { $mainBranchNames -icontains $_.Local })
      $devBranches = @($branchesToUpdate | Where-Object { $devBranchNames -icontains $_.Local })

      # Combines two priority lists into one for filtering
      $allPriorityNames = $mainBranchNames + $devBranchNames
      # Sort other branches in alphabetical order
      $otherBranches = $branchesToUpdate | Where-Object { -not ($allPriorityNames -icontains $_.Local) } | Sort-Object Local

      # Combine lists in the desired order
      $sortedBranchesToUpdate = $mainBranches + $devBranches + $otherBranches

      # Track repository state
      $repoIsInSafeState = $true

      # Track if any branch needed a pull
      $anyBranchNeededPull = $false

      # Iterate over each branch found to pull updates from remote
      foreach ($branch in $sortedBranchesToUpdate) {
        # Checkout to branch
        git checkout $branch.Local *> $null

        Write-Host -NoNewline "Inspecting branch " -ForegroundColor Cyan
        Write-Host "$($branch.Local)" -ForegroundColor Magenta

        # Check if checkout worked
        if ($LASTEXITCODE -ne 0) {
          Write-Host "⚠️ "
          Write-Host -NoNewline "Could not checkout " -ForegroundColor Magenta
          Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Red
          Write-Host " !!!" -ForegroundColor Magenta

          Write-Host -NoNewline "Blocked by local changes on " -ForegroundColor Magenta
          Write-Host -NoNewline "$originalBranch" -ForegroundColor Red
          Write-Host ". Halting updates for this repo" -ForegroundColor Magenta

          # Marks repository as an unstable state
          $repoIsInSafeState = $false

          # Exit loop, no need to continue processing this repository
          break
        }

        # Check for local (stagged/unstaged) changes
        $unstagedChanges = git diff --name-only --quiet
        $stagedChanges = git diff --cached --name-only --quiet

        # If local changes, skip pull
        if ($unstagedChanges -or $stagedChanges) {
          Write-Host -NoNewline "󰨈  Conflict detected on" -ForegroundColor Red
          Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Magenta
          Write-Host -NoNewline " , this branch has local changes. Pull avoided... 󰨈" -ForegroundColor Red
          Write-Host "Affected files =>" -ForegroundColor DarkCyan

          # List affected files
          if ($unstagedChanges) {
            Write-Host "Unstaged affected files =>" -ForegroundColor DarkCyan
            foreach ($file in $unstagedChanges) {
              Write-Host " $file" -ForegroundColor DarkCyan
            }
          }
          # List staged files
          if ($stagedChanges) {
            Write-Host "Staged affected files =>" -ForegroundColor DarkCyan
            foreach ($file in $stagedChanges) {
              Write-Host " $file" -ForegroundColor DarkCyan
            }
          }
          Show-Separator -Length 80 -ForegroundColor DarkGray

          # Skip to next branch
          continue
        }

        # Check if branch has local commits that doesn't exist on remote branch
        $unpushedCommits = git log "@{u}..HEAD" --oneline -q 2>$null
        if ($unpushedCommits) {
          Write-Host -NoNewline "⚠️ Branch ahead => " -ForegroundColor Red
          Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Magenta
          Write-Host " has unpushed commits. Pull avoided to prevent a merge ⚠️" -ForegroundColor Red
          Show-Separator -Length 80 -ForegroundColor DarkGray

          # Skip to next branch
          continue
        }

        # Compare local and remote commits
        $localCommit = git rev-parse $branch.Local
        $remoteCommit = (git rev-parse $branch.Remote -q 2>$null)
        # If remote commit doesn't exist, skip branch
        if (-not $remoteCommit) {
          # Skip to next branch
          continue
        }

        # If commits are the same, branch is up to date
        if ($localCommit -eq $remoteCommit) {
          Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Red
          Write-Host " is already updated ✅" -ForegroundColor Green
          Show-Separator -Length 80 -ForegroundColor DarkGray

          # Skip to next branch
          continue
        }

        # If we get here, a branch needs a pull
        $anyBranchNeededPull = $true

        # Update branchs
        $pullSuccess = $false

        # If main/master automatically pull it
        if ($branch.Local -eq "main" -or $branch.Local -eq "master") {
          Write-Host "⏳ Updating main branch..." -ForegroundColor Magenta

          Show-LatestCommitMessage -LocalBranch $branch.Local -RemoteBranch $branch.Remote -HideHashes

          git pull

          # Check if pull worked
          if ($LASTEXITCODE -eq 0) {
            # Mark pull as successful
            $pullSuccess = $true
          }
        }
        # If dev/develop automatically pull it
        elseif ($branch.Local -eq "dev" -or $branch.Local -eq "develop") {
          Write-Host "⏳ Updating develop branch..." -ForegroundColor Magenta

          Show-LatestCommitMessage -LocalBranch $branch.Local -RemoteBranch $branch.Remote -HideHashes

          git pull

          # Check if pull worked
          if ($LASTEXITCODE -eq 0) {
            # Mark pull as successful
            $pullSuccess = $true
          }
        }
        # Ask user for other branches
        else {
          Write-Host -NoNewline "Branch " -ForegroundColor Magenta
          Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Red
          Write-Host " has updates" -ForegroundColor Magenta

          Show-LatestCommitMessage -LocalBranch $branch.Local -RemoteBranch $branch.Remote -HideHashes

          Write-Host -NoNewline "Pull ? (Y/n): " -ForegroundColor Magenta

          $choice = Read-Host
          if ($choice -match '^(Y|y|yes|^)$') {
            Write-Host -NoNewline "⏳ Updating " -ForegroundColor Magenta
            Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Red
            Write-Host "..." -ForegroundColor Magenta

            git pull

            # Check if pull worked
            if ($LASTEXITCODE -eq 0) {
              # Mark pull as successful
              $pullSuccess = $true
            }
          }
          # If user refuses pull
          else {
            Write-Host -NoNewline "Skipping pull for " -ForegroundColor Magenta
            Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Red
            Write-Host "..." -ForegroundColor Magenta

            Show-Separator -Length 80 -ForegroundColor DarkGray

            # Reset pull success
            $pullSuccess = $null
          }
        }

        # Check pull status for each updated branch
        if ($pullSuccess -eq $true) {
          Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Red
          Write-Host " successfully updated ✅" -ForegroundColor Green
          Show-Separator -Length 80 -ForegroundColor DarkGray
        }
        # Check pull status for each not updated branch
        elseif ($pullSuccess -eq $false) {
          Write-Host "⚠️ "
          Write-Host -NoNewline "Error updating " -ForegroundColor Red
          Write-Host -NoNewline "$($branch.Local)" -ForegroundColor Magenta
          Write-Host -NoNewline " in " -ForegroundColor Red
          Write-Host -NoNewline "$repoName" -ForegroundColor white -BackgroundColor DarkBlue
          Write-Host " ⚠️" -ForegroundColor Red

          # Mark repository as not in a safe state
          $repoIsInSafeState = $false

          # Exit branch loop
          break
        }
      }

      # If no branch needed pull
      if ($anyBranchNeededPull -eq $false) {
        Write-Host "All branches already updated 🤙" -ForegroundColor Green
      }

      # Track whether user's branch has been deleted
      [bool]$originalBranchWasDeleted = $false

      # Define protected branches
      $protectedBranches = @("dev", "develop", "main", "master")

      # Interactive prune
      $orphanedBranches = git branch -vv | Select-String -Pattern '\[.*: gone\]' | ForEach-Object {
        $line = $_.Line.Trim()
        if ($line -match '^\*?\s*([\S]+)') {
          $Matches[1]
        }
      }

      # Filter protected branches
      $orphanedBranchesToClean = $orphanedBranches | Where-Object { -not ($protectedBranches -icontains $_) }

      # Cleaning up orphaned branches
      if ($orphanedBranchesToClean.Count -gt 0) {
        Write-Host "🧹 Cleaning up orphaned local branches..." -ForegroundColor DarkYellow

        foreach ($orphaned in $orphanedBranchesToClean) {
          # Ask user
          Write-Host -NoNewline "Do you want to delete the orphaned local branch " -ForegroundColor Magenta
          Write-Host -NoNewline "$orphaned" -ForegroundColor Red
          Write-Host -NoNewline " ? (Y/n): " -ForegroundColor Magenta

          $choice = Read-Host
          if ($choice -match '^(Y|y|yes|^)$') {
            Write-Host -NoNewline "👉 Removal of " -ForegroundColor Magenta
            Write-Host -NoNewline "$orphaned" -ForegroundColor Red
            Write-Host " branch..." -ForegroundColor Magenta

            # Secure removal
            git branch -d $orphaned *> $null

            # Check if deletion worked
            if ($LASTEXITCODE -eq 0) {
              Write-Host -NoNewline "$orphaned" -ForegroundColor Red
              Write-Host " successfully deleted ✅" -ForegroundColor Green

              if ($orphaned -eq $originalBranch) { $originalBranchWasDeleted = $true }
            }
            # If deletion failed (probably unmerged changes)
            else {
              Write-Host -NoNewline "⚠️ Branch " -ForegroundColor Red
              Write-Host -NoNewline "$orphaned" -ForegroundColor Magenta
              Write-Host " contains unmerged changes ! ⚠️" -ForegroundColor Red

              Write-Host -NoNewline "Force the deletion of " -ForegroundColor Magenta
              Write-Host -NoNewline "$orphaned" -ForegroundColor Red
              Write-Host -NoNewline " ? (Y/n): " -ForegroundColor Magenta

              $forceChoice = Read-Host
              if ($forceChoice -match '^(Y|y|yes|^)$') {
                # Forced removal
                git branch -D $orphaned *> $null

                # Check if forced deletion worked
                if ($LASTEXITCODE -eq 0) {
                  Write-Host -NoNewline "$orphaned" -ForegroundColor Red
                  Write-Host " successfully deleted ✅" -ForegroundColor Green

                  # Mark original branch as deleted
                  if ($orphaned -eq $originalBranch) {
                    $originalBranchWasDeleted = $true
                  }

                  # Move to next orphaned branch
                  continue
                }
                # If forced deletion failed
                else {
                  Write-Host -NoNewline "⚠️ Unexpected error. Failure to remove " -ForegroundColor Red
                  Write-Host "$orphaned ⚠️" -ForegroundColor Magenta
                }
              }
              # User refuses forced deletion
              else {
                Write-Host -NoNewline "👍 Local branch  " -ForegroundColor Green
                Write-Host -NoNewline "$orphaned" -ForegroundColor Magenta
                Write-Host " kept 👍" -ForegroundColor Green
              }
            }
          }
        }
      }

      # Integration branches to check
      $integrationBranches = @("main", "master", "develop", "dev")

      # Use hash table to collect merged branches (avoids duplicates)
      $allMergedBranches = @{}

      foreach ($intBranch in $integrationBranches) {
        # Check if integration branch exists locally
        if (git branch --list $intBranch) {
          # Get merged branches into this branch
          $branchesMergedIntoThisOne = git branch --merged $intBranch | ForEach-Object { $_.Trim() }

          # Add them to list
          foreach ($branch in $branchesMergedIntoThisOne) {
            $allMergedBranches[$branch] = $true
          }
        }
      }

      # Filter list to keep only branches that can be cleaned
      $mergedBranchesToClean = $allMergedBranches.Keys | Where-Object {
        ( $_ -ne $originalBranch ) -and ( -not ($protectedBranches -icontains $_) )
      }

      # Remove integration branches from list
      if ($mergedBranchesToClean.Count -gt 0) {
        # Cleaning up merged branches
        Write-Host "🧹 Cleaning up branches that have already being merged..." -ForegroundColor DarkYellow

        foreach ($merged in $mergedBranchesToClean.Keys) {
          # Ask user
          Write-Host -NoNewline "Branch " -ForegroundColor Magenta
          Write-Host -NoNewline "$merged" -ForegroundColor Red
          Write-Host -NoNewline " is already merged. Delete ? (Y/n): " -ForegroundColor Magenta

          $choice = Read-Host
          if ($choice -match '^(Y|y|yes|^)$') {
            Write-Host -NoNewline "👉 Removal of " -ForegroundColor Magenta
            Write-Host -NoNewline "$merged" -ForegroundColor Red
            Write-Host " branch..." -ForegroundColor Magenta

            # Secure removal (guaranteed to work because --merged)
            git branch -d $merged *> $null

            # Check if deletion worked
            if ($LASTEXITCODE -eq 0) {
              Write-Host -NoNewline "$merged" -ForegroundColor Red
              Write-Host " successfully deleted ✅" -ForegroundColor Green

              # Check if original branch has been deleted
              if ($merged -eq $originalBranch) {
                # Mark original branch as deleted
                $originalBranchWasDeleted = $true
              }
            }
            # If deletion failed
            else {
              Write-Host -NoNewline "⚠️ Unexpected error. Failure to remove " -ForegroundColor Red
              Write-Host "$orphaned ⚠️" -ForegroundColor Magenta
            }
          }
        }
      }

      ######## WORKFLOW INFO ########
      Show-MergeAdvice

      ######## RETURN STRATEGY ########
      Restore-UserLocation -OriginalBranch $originalBranch -RepoIsSafe $repoIsInSafeState -OriginalWasDeleted $originalBranchWasDeleted
    }
    catch {
      ######## ERROR CONTEXT ANALYSIS ########
      # Get HTTP response if exists (regardless of the error type)
      $responseError = $null

      # Response property exists on exception, so we take it
      if ($_.Exception.PSObject.Properties.Match('Response').Count) {
        $responseError = $_.Exception.Response
      }

      ######## ERROR HANDLER : HTTP ########
      # If we have a server response
      if ($null -ne $responseError) {
        Show-GitHubHttpError -StatusCode $responseError.StatusCode `
                            -RepoName $repoName `
                            -ErrorMessage $_.Exception.Message
      }

      ######## ERROR HANDLER : NETWORK / SYSTEM ########
      # No HTTP response
      else {
        Show-NetworkOrSystemError -RepoName $repoName `
                                    -Message $_.Exception.Message
      }
    }

    # Return to home directory
    Set-Location -Path $HOME
  }
}


#------------------------------#
# GIT PULL UTILITIES FUNCTIONS #
#------------------------------#
##########---------- Get local repositories information ----------##########
function Get-RepositoriesInfo {
  ######## DATA DEFINITION ########
  # GitHub username
  $gitHubUsername = $env:GITHUB_USERNAME

  # GitHub token
  $gitHubToken = $env:GITHUB_TOKEN

  # Array to define the order of repositories
  $reposOrder = @(
    "ArtiWave",
    "Cours",
    "DailyPush",
    "DataScrub",
    "Documentations",
    "Dotfiles",
    "EmmanuelLefevre",
    "GitHubProfileIcons",
    "GoogleSheets",
    "IAmEmmanuelLefevre",
    "MarkdownImg",
    "OpenScraper",
    "ParquetFlow",
    "ReplicaMySQL",
    "Schemas",
    "ScrapMate",
    "Soutenances"
  )

  # Dictionary containing local repositories path
  $repos = @{
    "ArtiWave"               = "$env:USERPROFILE\Desktop\Projets\ArtiWave"
    "Cours"                  = "$env:USERPROFILE\Desktop\Cours"
    "DailyPush"              = "$env:USERPROFILE\Desktop\DailyPush"
    "DataScrub"              = "$env:USERPROFILE\Desktop\Projets\DataScrub"
    "Documentations"         = "$env:USERPROFILE\Documents\Documentations"
    "Dotfiles"               = "$env:USERPROFILE\Desktop\Dotfiles"
    "EmmanuelLefevre"        = "$env:USERPROFILE\Desktop\Projets\EmmanuelLefevre"
    "GitHubProfileIcons"     = "$env:USERPROFILE\Pictures\GitHubProfileIcons"
    "GoogleSheets"           = "$env:USERPROFILE\Desktop\GoogleSheets"
    "IAmEmmanuelLefevre"     = "$env:USERPROFILE\Desktop\Projets\IAmEmmanuelLefevre"
    "MarkdownImg"            = "$env:USERPROFILE\Desktop\MarkdownImg"
    "OpenScraper"            = "$env:USERPROFILE\Desktop\Projets\OpenScraper"
    "ParquetFlow"            = "$env:USERPROFILE\Desktop\Projets\ParquetFlow"
    "ReplicaMySQL"           = "$env:USERPROFILE\Desktop\Projets\ReplicaMySQL"
    "Schemas"                = "$env:USERPROFILE\Desktop\Schemas"
    "ScrapMate"              = "$env:USERPROFILE\Desktop\Projets\ScrapMate"
    "Soutenances"            = "$env:USERPROFILE\Desktop\Soutenances"
  }

  # Error message templates
  $envVarMessageTemplate = "Check/add {0} and its value in your Windows Environment Variables..."
  $functionNameMessage = "in Get-RepositoriesInfo function !"

  ######## GUARD CLAUSE : MISSING USERNAME ########
  if ([string]::IsNullOrWhiteSpace($gitHubUsername)) {
    Write-Host "❌ GitHub username is missing or invalid ! ❌" -ForegroundColor Red

    $msg = $envVarMessageTemplate -f "'GITHUB_USERNAME'"
    Write-Host "ℹ️ $msg" -ForegroundColor DarkYellow
    return $null
  }

  ######## GUARD CLAUSE : MISSING TOKEN ########
  if ([string]::IsNullOrWhiteSpace($gitHubToken)) {
    Write-Host "❌ GitHub token is missing or invalid ! ❌" -ForegroundColor Red

    $msg = $envVarMessageTemplate -f "'GITHUB_TOKEN'"
    Write-Host "ℹ️ $msg" -ForegroundColor DarkYellow
    return $null
  }

  ######## GUARD CLAUSE : EMPTY ORDER LIST ########
  if (-not $reposOrder -or $reposOrder.Count -eq 0) {
    Write-Host "❌ Local array repo order is empty ! ❌" -ForegroundColor Red
    Write-Host "ℹ️ Define at least one repository in the repository order array $functionNameMessage" -ForegroundColor Yellow
    return $null
  }

  ######## GUARD CLAUSE : EMPTY PATH DICTIONARY ########
  if (-not $repos -or $repos.Keys.Count -eq 0) {
    Write-Host "❌ Local repository dictionary is empty ! ❌" -ForegroundColor Red
    Write-Host "ℹ️ Ensure repository dictionary contains at least one reference with a valid path $functionNameMessage" -ForegroundColor Yellow
    return $null
  }

  ######## RETURN SUCCESS ########
  # All is fine
  Write-Host "✔️ GitHub configuration and projects are ok ✔️" -ForegroundColor Green
  Show-Separator -Length 80 -ForegroundColor DarkBlue
  Write-Host ""

  return @{
    Username = $gitHubUsername
    Token = $gitHubToken
    Order = $reposOrder
    Paths = $repos
  }
}

##########---------- Display a separator line with custom length and colors ----------##########
function Show-Separator {
  param (
    [Parameter(Mandatory=$true)]
    [int]$Length,

    [Parameter(Mandatory=$true)]
    [System.ConsoleColor]$ForegroundColor,

    [Parameter(Mandatory=$false)]
    [System.ConsoleColor]$BackgroundColor,

    [Parameter(Mandatory=$false)]
    [switch]$NoNewline
  )

  ######## DATA PREPARATION ########
  # Create line string based on requested length
  $line = "─" * $Length

  ######## GUARD CLAUSE : WITH BACKGROUND COLOR ########
  # If a background color is specified, handle it specific way and exit
  if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
    Write-Host -NoNewline:$NoNewline $line -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    return
  }

  ######## STANDARD DISPLAY ########
  # Otherwise (default behavior), display with foreground color only
  Write-Host -NoNewline:$NoNewline $line -ForegroundColor $ForegroundColor
}

##########---------- Check if folder is a valid git repository ----------##########
function Test-IsGitRepository {
  param (
    [string]$Name,
    [string]$Path
  )

  ######## GUARD CLAUSE : MISSING .GIT FOLDER ########
  # Check if the .git hidden folder exists inside the target path
  if (-not (Test-Path -Path "$Path\.git")) {
    Write-Host -NoNewline "⛔ Local folder " -ForegroundColor Red
    Write-Host -NoNewline "$Name" -ForegroundColor White -BackgroundColor Magenta
    Write-Host " found but it's NOT a git repository ⛔" -ForegroundColor Red
    Write-Host "Missing .git folder inside 👉 " -ForegroundColor DarkYellow
    Write-Host "$Path" -ForegroundColor Red

    return $false
  }

  ######## RETURN SUCCESS ########
  return $true
}

##########---------- Check if local repository path exists ----------##########
function Test-LocalRepoExists {
  param (
    [string]$Name,
    [string]$Path
  )

  ######## GUARD CLAUSE : PATH NOT FOUND ########
  # Check if the path variable is defined AND if the folder exists on disk
  if (-not ($Path -and (Test-Path -Path $Path))) {
    Write-Host -NoNewline "⚠️ Local repository path for " -ForegroundColor Red
    Write-Host -NoNewline "$Name" -ForegroundColor White -BackgroundColor Magenta
    Write-Host " doesn't exist ⚠️" -ForegroundColor Red
    Write-Host "Path searched 👉 " -ForegroundColor DarkYellow
    Write-Host "$Path" -ForegroundColor Red

    return $false
  }

  ######## RETURN SUCCESS ########
  return $true
}

##########---------- Check if local remote matches expected GitHub URL ----------##########
function Test-LocalRemoteMatch {
  param (
    [string]$RepoName,
    [string]$UserName
  )

  ######## DATA RETRIEVAL ########
  # Retrieve the fetch URL for 'origin'
  $localRemoteUrl = (git remote get-url origin 2>$null)

  ######## GUARD CLAUSE : URL MISMATCH ########
  # Check if the local remote URL corresponds to the expected GitHub project
  if (-not ($localRemoteUrl -match "$UserName/$RepoName")) {
    Write-Host -NoNewline "⚠️ Original local remote " -ForegroundColor Red
    Write-Host -NoNewline "$localRemoteUrl" -ForegroundColor Magenta
    Write-Host -NoNewline " doesn't match (" -ForegroundColor Red
    Write-Host -NoNewline "$UserName" -ForegroundColor Magenta
    Write-Host -NoNewline "/" -ForegroundColor Red
    Write-Host -NoNewline "$RepoName" -ForegroundColor Magenta
    Write-Host "). Repository ignored ! ⚠️" -ForegroundColor Red

    return $false
  }

  ######## RETURN SUCCESS ########
  return $true
}

##########---------- Check if git fetch succeeded ----------##########
function Test-GitFetchSuccess {
  param ([int]$ExitCode)

  ######## GUARD CLAUSE : FETCH FAILED ########
  # Check if the exit code indicates an error (non-zero)
  if ($ExitCode -ne 0) {
    Write-Host -NoNewline "⚠️ "
    Write-Host -NoNewline "'Git fetch' failed ! Check your Git access credentials (SSH keys/Credential Manager)... ⚠️" -ForegroundColor Red

    return $false
  }

  ######## RETURN SUCCESS ########
  return $true
}

##########---------- Calculate new remote branches to track ----------##########
function Get-NewRemoteBranches {
  ######## DATA RETRIEVAL ########
  # Get all remote branches (excluding HEAD) and local branches
  $allRemoteRefs = git for-each-ref --format="%(refname:short)" refs/remotes | Where-Object { $_ -notmatch '/HEAD$' }
  $allLocalBranches = git for-each-ref --format="%(refname:short)" refs/heads

  # List to store new branches to track
  $branchesFound = @()

  ######## PROCESSING LOOP ########
  # Iterate through remote branches to find those not tracked locally
  foreach ($remoteRef in $allRemoteRefs) {

    # Extract local name from remote ref (ex: "origin/feature/x" -> "feature/x")
    if ($remoteRef -match '^[^/]+/(.+)$') {
      $localEquivalent = $Matches[1]

      ######## GUARD CLAUSE : IGNORED PREFIXES ########
      # Define prefixes to exclude (Hotfix and Release)
      $prefixesToIgnore = @('hotfix/', 'release/')
      $shouldIgnore = $false

      # Check each prefix to ignore
      foreach ($prefix in $prefixesToIgnore) {
        # Check if branch name begins with a prefix to ignore
        if ($localEquivalent.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
          $shouldIgnore = $true

          # No point in continuing to search, exit loop
          break
        }
      }

      # If branch matches an ignored prefix, skip to next iteration
      if ($isIgnored) {
        continue
      }

      ######## GUARD CLAUSE : ALREADY TRACKED ########
      # If the branch already exists locally, skip it
      if ($localEquivalent -in $allLocalBranches) {
        continue
      }

      ######## ADD TO SELECTION ########
      # If we are here, strictly valid (Not ignored AND Not already local)
      $branchesFound += $remoteRef
    }
  }

  return $branchesFound
}

##########---------- Interactive process to track new branches ----------##########
function Invoke-NewBranchTracking {
  param (
    [array]$NewBranches
  )

  ######## GUARD CLAUSE : NO NEW BRANCHES ########
  # If the list is empty or null, nothing to do
  if (-not $NewBranches -or $NewBranches.Count -eq 0) {
    return
  }

  ######## USER INTERACTION LOOP ########
  foreach ($newBranchRef in $NewBranches) {
    # Extract local name (ex: origin/feature/x -> feature/x)
    $null = $newBranchRef -match '^[^/]+/(.+)$'
    $localBranchName = $Matches[1]

    # Display Branch Found
    Write-Host -NoNewline "❤️ New remote branches found ❤️ =>" -ForegroundColor Blue
    Write-Host "🦄 $localBranchName 🦄" -ForegroundColor DarkCyan

    # Get and show latest commit message
    $latestCommitMsg = git log -1 --format="%s" $newBranchRef 2>$null
    if ($latestCommitMsg) {
      Write-Host -NoNewline "Commit message : " -ForegroundColor Magenta
      Write-Host "$latestCommitMsg" -ForegroundColor Cyan
    }

    # Ask user permission
    Write-Host -NoNewline "Pull " -ForegroundColor Magenta
    Write-Host -NoNewline "$localBranchName" -ForegroundColor Red
    Write-Host -NoNewline " ? (Y/n): " -ForegroundColor Magenta

    $choice = Read-Host
    if ($choice -match '^(Y|y|yes|^)$') {
      Write-Host -NoNewline "⏳ Creating local branch " -ForegroundColor Magenta
      Write-Host "$localBranchName" -ForegroundColor Red

      # Create local branch tracking remote branch
      git branch --track --quiet $localBranchName $newBranchRef 2>$null

      # Check if branch creation worked
      if ($LASTEXITCODE -eq 0) {
        Write-Host -NoNewline "$localBranchName" -ForegroundColor Red
        Write-Host " successfully pulled ✅" -ForegroundColor Green
      }
      # If branch creation failed
      else {
        Write-Host -NoNewline "$localBranchName" -ForegroundColor Red
        Write-Host "⚠️ New creation branch has failed ! ⚠️" -ForegroundColor Red
      }
    }
  }

  ######## UI : END SEPARATOR ########
  Show-Separator -Length 80 -ForegroundColor DarkGray
}

##########---------- Show last commit date regardless of branch ----------##########
function Show-LastCommitDate {
  ######## DATA RETRIEVAL ########
  # Retrieve all remote branches sorted by date
  $allRefs = git for-each-ref --sort=-committerdate refs/remotes --format="%(refname:short) %(committerdate:iso-strict)" 2>$null

  ######## GUARD CLAUSE : NO REFS RETRIEVED ########
  # Check if we got a result
  if ([string]::IsNullOrWhiteSpace($allRefs)) {
    return
  }

  ######## FILTERING ########
  # Exclude "HEAD" references (ex: origin/HEAD) and select most recent
  $lastCommitInfo = $allRefs | Where-Object {
    ($_ -notmatch '/HEAD\s') -and ($_ -match '/')
  } | Select-Object -First 1

  ######## GUARD CLAUSE : NO MATCHING BRANCH ########
  if ([string]::IsNullOrWhiteSpace($lastCommitInfo)) {
    return
  }

  # Separate the chain into two
  $parts = $lastCommitInfo -split ' ', 2

  ######## GUARD CLAUSE : DATA INTEGRITY FAIL ########
  # Check data integrity (must have Branch + Date)
  if ($parts.Length -ne 2) {
    return
  }

  ######## PROCESSING / DISPLAY ########
  # Clean up branch name (Remove "origin/")
  $branchName = $parts[0] -replace '^.*?/', ''
  $dateString = $parts[1]

  try {
    # Convert ISO string into [datetime] object
    [datetime]$commitDate = $dateString

    # Define culture on "en-US"
    $culture = [System.Globalization.CultureInfo]'en-US'

    # Format date (ex: Monday 13 September 2025)
    $formattedDate = $commitDate.ToString('dddd dd MMMM yyyy', $culture)

    # Display formatted message
    Write-Host -NoNewline "📈 Last repository commit : " -ForegroundColor DarkYellow
    Write-Host -NoNewline "$formattedDate" -ForegroundColor Cyan
    Write-Host -NoNewline " on " -ForegroundColor DarkYellow
    Write-Host "$branchName" -ForegroundColor Magenta
    Show-Separator -Length 80 -ForegroundColor DarkGray
  }
  catch {
    # If date parsing fails, exit silently
    return
  }
}

##########---------- Get and show latest commit message ----------##########
function Show-LatestCommitMessage {
  param (
    [string]$LocalBranch,
    [string]$RemoteBranch,
    [switch]$HideHashes
  )

  ######## DATA RETRIEVAL ########
  # Get HASH HEAD
  $localHash  = git rev-parse $LocalBranch 2>$null
  $remoteHash = git rev-parse $RemoteBranch 2>$null

  ######## GUARD CLAUSE : INVALID REFERENCES ########
  if (-not $localHash -or -not $remoteHash) {
    Write-Host "⚠️ Unable to read local/remote references ! ⚠️" -ForegroundColor Red

    return
  }

  ######## DATA ANALYSIS : ANCESTRY ########
  $isLocalBehind  = git merge-base --is-ancestor $localHash $remoteHash 2>$null
  $isRemoteBehind = git merge-base --is-ancestor $remoteHash $localHash 2>$null

  # Divergence detection (detect rebase/push --force)
  if (-not $isLocalBehind -and -not $isRemoteBehind) {
    Write-Host "⚠️ History rewritten or divergence detected... A pull can trigger a rebase or a reset ! ⚠️" -ForegroundColor Red
  }

  # Get new commits
  $raw = git log --oneline --no-merges "$LocalBranch..$RemoteBranch" 2>$null

  # Normalisation : string → array
  $newCommits = @()
  if ($raw) {
    if ($raw -is [string]) {
      $newCommits = @($raw)
    }
    else {
      $newCommits = $raw
    }
  }

  ######## GUARD CLAUSE : NO COMMITS VISIBLE ########
  # If no commits
  if ($newCommits.Count -eq 0) {
    if ($isLocalBehind) {
      Write-Host "ℹ️ Fast-forward possible (no visible commits) ℹ️" -ForegroundColor DarkYellow
    }
    else {
      Write-Host "ℹ️ No commit visible, but a pull may be needed... ℹ️" -ForegroundColor DarkYellow
    }
    return
  }

  # Cleanup if HideHashes option is enabled → removes hash in front of message
  if ($HideHashes) {
    $newCommits = $newCommits | ForEach-Object {
      ($_ -replace '^[0-9a-f]+\s+', '')
    }
  }

  ######## GUARD CLAUSE : SINGLE COMMIT ########
  # One commit
  if ($newCommits.Count -eq 1) {
    Write-Host -NoNewline "Commit message : " -ForegroundColor Magenta
    Write-Host "`"$($newCommits[0])`"" -ForegroundColor Cyan
    return
  }

  ######## DISPLAY MULTIPLE COMMITS ########
  # Several commits
  Write-Host "New commits received :" -ForegroundColor Magenta
  foreach ($commit in $newCommits) {
    Write-Host "- `"$commit`"" -ForegroundColor Cyan
  }
}

##########---------- Check for unmerged commits in main from dev ----------##########
function Show-MergeAdvice {
  ######## DATA RETRIEVAL ########
  # Identify main branch (main or master)
  $mainBranch = if (git branch --list "main") { "main" }
                elseif (git branch --list "master") { "master" }
                else { $null }

  ######## GUARD CLAUSE : MAIN BRANCH NOT FOUND ########
  if (-not $mainBranch) { return }

  ######## DATA RETRIEVAL ########
  # Identify dev branch (develop or dev)
  $devBranch = if (git branch --list "develop") { "develop" }
              elseif (git branch --list "dev") { "dev" }
              else { $null }

  ######## GUARD CLAUSE : DEV BRANCH NOT FOUND ########
  if (-not $devBranch) { return }

  ######## DATA RETRIEVAL ########
  # Check for commits in Dev that are not in Main
  $unmergedCommits = git log "$mainBranch..$devBranch" --oneline -q 2>$null

  ######## GUARD CLAUSE : ALREADY MERGED ########
  # If result is empty, everything is merged, so we exit
  if (-not $unmergedCommits) { return }

  ######## SHOW ADVICE ########
  Write-Host -NoNewline "ℹ️ $devBranch" -ForegroundColor Magenta
  Write-Host -NoNewline " has commits that are not in " -ForegroundColor DarkYellow
  Write-Host -NoNewline "$mainBranch" -ForegroundColor Magenta
  Write-Host ". Think about merging ! ℹ️" -ForegroundColor DarkYellow
}

##########---------- Restore user to original branch ----------##########
function Restore-UserLocation {
  param (
    [bool]$RepoIsSafe,
    [string]$OriginalBranch,
    [bool]$OriginalWasDeleted
  )

  ######## GUARD CLAUSE : UNSAFE REPO STATE ########
  # Repository isn't in a safe mode, cannot switch branches safely
  if (-not $RepoIsSafe) {
    Write-Host "⚠️ Repo is in an unstable state. Can't return to the branch where you were ! ⚠️" -ForegroundColor Red
    return
  }

  ######## GUARD CLAUSE : ORIGINAL BRANCH DELETED ########
  # Original branch was removed during cleaning, switch to a fallback branch
  if ($OriginalWasDeleted) {
    Write-Host -NoNewline "⚡ Original branch " -ForegroundColor Magenta
    Write-Host -NoNewline "$OriginalBranch" -ForegroundColor Red
    Write-Host " has been deleted..." -ForegroundColor Magenta

    # Determine fallback branch priority
    $fallbackBranch = if (git branch --list "develop") { "develop" }
                      elseif (git branch --list "dev") { "dev" }
                      elseif (git branch --list "main") { "main" }
                      else { "master" }

    Write-Host -NoNewline "😍 You have been moved to " -ForegroundColor DarkYellow
    Write-Host -NoNewline "$fallbackBranch" -ForegroundColor Magenta
    Write-Host " branch 😍" -ForegroundColor DarkYellow

    git checkout $fallbackBranch *> $null
    return
  }

  ######## DATA RETRIEVAL ########
  # Retrieves branch on which script finished its work
  $currentBranch = git rev-parse --abbrev-ref HEAD

  ######## GUARD CLAUSE : ALREADY ON TARGET ########
  # If we are already on original branch, we do nothing and we say nothing
  if ($currentBranch -eq $OriginalBranch) {
    return
  }

  ######## STANDARD RETURN ########
  # Otherwise, we go there and display it
  git checkout $OriginalBranch *> $null

  Write-Host -NoNewline "👌 Place it back on the branch where you were => " -ForegroundColor Magenta
  Write-Host "$OriginalBranch" -ForegroundColor Red
}

##########---------- Display HTTP errors ----------##########
function Show-GitHubHttpError {
  param (
    [Parameter(Mandatory=$true)]
    [int]$StatusCode,

    [Parameter(Mandatory=$true)]
    [string]$RepoName,

    [Parameter(Mandatory=$false)]
    [string]$ErrorMessage
  )

  ######## ERROR DISPATCHING ########
  switch ($StatusCode) {
    # Server Errors (all 500+ code)
    { $_ -ge 500 } {
      Write-Host -NoNewline "🔥 "
      Write-Host -NoNewline "GitHub server error (" -ForegroundColor Red
      Write-Host -NoNewline "$StatusCode" -ForegroundColor Magenta
      Write-Host "). GitHub's fault, not yours ! Try later... 🔥" -ForegroundColor Red
      return
    }

    # Not Found
    404 {
      Write-Host -NoNewline "⚠️ "
      Write-Host -NoNewline "Remote repository " -ForegroundColor Red
      Write-Host -NoNewline "$RepoName" -ForegroundColor white -BackgroundColor DarkBlue
      Write-Host " doesn't exists ⚠️" -ForegroundColor Red
      return
    }

    # Rate Limit
    403 {
      Write-Host "󰊤 GitHub API rate limit exceeded! Try again later or authenticate to increase your rate limit. 󰊤" -ForegroundColor Red
      return
    }

    # Unauthorized
    401 {
      Write-Host "󰊤 Check your personal token defined in your settings 󰊤" -ForegroundColor Red
      return
    }

    # Default/Other HTTP errors
    Default {
      Write-Host "⚠️ HTTP Error $StatusCode : $ErrorMessage" -ForegroundColor Red
    }
  }
}

##########---------- Display Network/System errors ----------##########
function Show-NetworkOrSystemError {
  param (
    [Parameter(Mandatory=$true)]
    [string]$RepoName,

    [Parameter(Mandatory=$true)]
    [string]$Message
  )

  ######## ERROR TYPE : NETWORK ########
  # Network problem (DNS, unplugged cable, firewall, no internet ...)
  if ($Message -match "remote name could not be resolved" -or $Message -match "connect" -or $Message -match "timed out") {
    Write-Host -NoNewline "💀 "
    Write-Host -NoNewline "Network error for " -ForegroundColor Red
    Write-Host -NoNewline "$RepoName" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host ". Unable to connect to GitHub, maybe check your connection or your firewall ! 💀" -ForegroundColor Red
  }

  ######## ERROR TYPE : INTERNAL/SCRIPT ########
  # Script or Git processing error (fallback)
  else {
    Write-Host -NoNewline "💥 Internal Script/Git processing error 💥" -ForegroundColor Red

    # Display technical message for debugging
    Write-Host "Details 👉 " -ForegroundColor Magenta
    Write-Host -NoNewline "$Message" -ForegroundColor Red
  }
}


#---------------------#
# UTILITIES FUNCTIONS #
#---------------------#
##########---------- Dictionary of functions and their objectives ----------##########
function Get-GoalFunctionsDictionary {
  $goalFunctions = @{
    colors = "Display powershell colors in terminal"
    custom_alias = "Get custom aliases"
    custom_function  = "Get custom functions"
    dc = "Create containers and launch thems"
    gpull = "Update all your local repositories"
    go = "Jump to a specific directory"
    help = "Get help"
    path = "Display the current directory path"
    ssh_github = "Test GitHub SSH connection with GPG keys"
    touch = "Create a file"
    whereis = "Find path of a specified command/executable"
    z = "Go specified folder / returns parent directory"
  }
  return $goalFunctions
}

##########---------- Get script path and name ----------##########
function Get-ScriptInfo {
  param (
    [string]$FileName = "Microsoft.PowerShell_profile.ps1",
    [string]$ScriptPath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  )

  # Display script path
  Write-Host ""
  Write-Host "ScriptPath: " -ForegroundColor DarkGray -NoNewline
  Write-Host "$ScriptPath" -ForegroundColor DarkMagenta
  Write-Host ""

  return @{ Path = $ScriptPath; FileName = $FileName }
}
