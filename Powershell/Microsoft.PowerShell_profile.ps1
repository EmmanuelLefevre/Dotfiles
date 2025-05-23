#---------------#
# PROMPT THEMES #
#---------------#
oh-my-posh init pwsh --config "$env:USERPROFILE/Documents/PowerShell/powershell_profile_darka.json" | Invoke-Expression

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

########## Get help ##########
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
      Write-Host ("{0,-30}" -f " $($alias.FileName)") -ForegroundColor Yellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host "⚠️ No help aliases found in script ⚠️" -ForegroundColor Red
  }
}

########## Get custom aliases ##########
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
      Write-Host ("{0,-40}" -f " $($alias.FileName)") -ForegroundColor Yellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host "⚠️ No custom aliases found in script ⚠️" -ForegroundColor Red
  }
}

########## Get custom functions ##########
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
      Write-Host ("{0,-50}" -f " $($function.FileName)") -ForegroundColor Yellow
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

########## Display the current directory path ##########
function path {
  Write-Host ""
  $currentPath = Get-Location
  Write-Host $currentPath -ForegroundColor DarkMagenta
}

########## Navigate to the specified folder passed as a parameter ##########
########## Or returns to parent directory if no paramater is specified ##########
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

# Docker
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

########## Create a file ##########
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

########## Jump to a specific directory ##########
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
          Write-Host ("{0,-50}" -f " $($option.Path)") -ForegroundColor Yellow
        }
      }
      Write-Host ""
    }
    default {
      Write-Host "⚠️ Error occurred! ⚠️" -ForegroundColor Red
    }
  }
}

########## Find path of a specified command/executable ##########
function whereis ($comand) {
  Get-Command -Name $comand -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

########## Test GitHub SSH connection with GPG keys ##########
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

########## Display powershell colors in terminal ##########
function colors {
  $colors = [enum]::GetValues([System.ConsoleColor])

  Foreach ($bgcolor in $colors) {
    Foreach ($fgcolor in $colors) {
      Write-Host "$fgcolor|" -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine
    }

  Write-Host " on $bgcolor"
  }
}

########## Update your local repositories ##########
function git_pull {
  # Get local repositories information and their order
  $reposInfo = Get-RepositoriesInfo
  $reposOrder = $reposInfo.Order
  $repos = $reposInfo.Paths
  # Get GitHub username and token
  $username = $reposInfo.Username
  $token = $reposInfo.Token

  # Iterate over each repository in the defined order
  foreach ($repoName in $reposOrder) {
    $repoPath = $repos[$repoName]
    if (Test-Path -Path $repoPath) {
      # Change current directory to repository path
      Set-Location -Path $repoPath

      # Show the name of the repository being updated
      Write-Host -NoNewline "$repoName" -ForegroundColor Magenta
      Write-Host " is on update process 🚀"

      try {
        # Check for remote repository existence using GitHub API with authentication token
        $repoUrl = "https://api.github.com/repos/$username/$repoName"
        $response = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers @{ Authorization = "Bearer $token" } -ErrorAction Stop

        # Check current branch
        $currentBranch = git rev-parse --abbrev-ref HEAD
        # If branch isn't "master" or "main"
        if ($currentBranch -ne "main" -and $currentBranch -ne "master") {
          Write-Host -NoNewline "⚠️ "
          Write-Host -NoNewline "$repoName" -ForegroundColor Magenta
          Write-Host -NoNewline " is on " -ForegroundColor Red
          Write-Host -NoNewline "$currentBranch" -ForegroundColor Magenta
          Write-Host " not 'main' or 'master'! Cancelling update ⚠️" -ForegroundColor Red
          Write-Host "--------------------------------------------------------------------"

          # Next repository
          continue
        }

        # Check if local changes exist before pull
        $diffOutput = git diff --name-only
        if ($diffOutput) {
          Write-Host "󰨈  Conflict detected! Pull avoided... 󰨈" -ForegroundColor Red
          Write-Host "Affected files =>"
          foreach ($file in $diffOutput) {
            Write-Host " $file" -ForegroundColor DarkCyan
          }
          Write-Host "--------------------------------------------------------------------"

          # Next repository
          continue
        }

        # Check if repository is already updated
        git fetch
        $localCommit = git rev-parse HEAD
        $remoteCommit = git rev-parse "origin/$currentBranch"

        if ($localCommit -eq $remoteCommit) {
          Write-Host "Already updated 🤙" -ForegroundColor Green
          Write-Host "--------------------------------------------------------------------"

          # Next repository
          continue
        }

        # Execute the git pull command if everything is correct
        git pull

        # Check if the command was successful
        if ($LASTEXITCODE -eq 0) {
          Write-Host "Successfully updated ✅" -ForegroundColor Green
        }
        else {
          Write-Host -NoNewline "⚠️ "
          Write-Host -NoNewline "Error updating " -ForegroundColor Red
          Write-Host -NoNewline "$repoName" -ForegroundColor Magenta
          Write-Host " ⚠️" -ForegroundColor Red
        }
      }
      catch {
        # Check if the error is related to the remote repository not existing
        if ($_.Exception.Response.StatusCode -eq 404) {
          Write-Host -NoNewline "⚠️ "
          Write-Host -NoNewline "Remote repository " -ForegroundColor Red
          Write-Host -NoNewline "$repoName" -ForegroundColor Magenta
          Write-Host " doesn't exists ⚠️" -ForegroundColor Red
        }
        # elseif ($responseBody.message -match "API rate limit exceeded") {
        elseif ($_.Exception.Response.StatusCode -eq 403) {
          Write-Host "󰊤 GitHub API rate limit exceeded! Try again later or authenticate to increase your rate limit. 󰊤" -ForegroundColor Red
        }
        elseif ($_.Exception.Response.StatusCode -eq 401) {
          Write-Host "󰊤 Bad credentials! Check your personal token 󰊤" -ForegroundColor Red
        }
        else {
          Write-Host -NoNewline "⚠️ An error occurred while updating "
          Write-Host -NoNewline "$repoName" -ForegroundColor Magenta
          Write-Host ": ${_} ⚠️" -ForegroundColor Red
        }
      }

      # Line separator after each repository processing
      Write-Host "--------------------------------------------------------------------"

      # Return to home directory
      Set-Location -Path $HOME
    }
    else {
      Write-Host -NoNewline "⚠️ Local repository " -ForegroundColor Red
      Write-Host -NoNewline "$repoName" -ForegroundColor Magenta
      Write-Host " doesn't exists ⚠️" -ForegroundColor Red
      Write-Host "--------------------------------------------------------------------"
    }
  }
}



#-------------------#
# UTILITY FUNCTIONS #
#-------------------#

########## Dictionary of functions and their objectives ##########
function Get-GoalFunctionsDictionary {
  $goalFunctions = @{
    colors = "Display powershell colors in terminal"
    custom_alias = "Get custom aliases"
    custom_function  = "Get custom functions"
    dc = "Create containers and launch thems"
    git_pull = "Update your local repositories"
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

########## Get script path and name ##########
function Get-ScriptInfo {
  param (
    [string]$ScriptPath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    [string]$FileName = "Microsoft.PowerShell_profile.ps1"
  )

  # Display script path
  Write-Host ""
  Write-Host "ScriptPath: " -ForegroundColor DarkGray -NoNewline
  Write-Host "$ScriptPath" -ForegroundColor DarkMagenta
  Write-Host ""

  return @{ Path = $ScriptPath; FileName = $FileName }
}

########## Get local repositories information ##########
function Get-RepositoriesInfo {
  # GitHub username
  $gitHubUsername = "<YOUR GITUB USERNAME>"

  # GitHub token
  $gitHubToken = "<YOUR PERSONAL TOKEN>"

  # Array to define the order of repositories
  $reposOrder = @("ArtiWave", "Cours", "DailyPush", "DataScrub", "Documentations", "Dotfiles", "EmmanuelLefevre", "GitHubProfileIcons", "GoogleSheets", "IAmEmmanuelLefevre", "MarkdownImg", "OpenScraper", "ParquetFlow", "ReplicaMySQL", "Schemas", "ScrapMate", "Soutenances")

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

  return @{
    Username = $gitHubUsername
    Token = $gitHubToken
    Order = $reposOrder
    Paths = $repos
  }
}