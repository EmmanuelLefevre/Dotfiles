##########---------- Dictionary of functions and their objectives ----------##########
function Get-GoalFunctionsDictionary {
  $goalFunctions = @{
    colors = "Display powershell colors in terminal"
    custom_alias = "Get custom aliases"
    custom_function  = "Get custom functions"
    dc = "Create containers and launch thems"
    gpull = "Update all your local repositories"
    gir = "Copy your .gitignore_global in the current repository"
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
    [string]$FileName   = $(Split-Path $PROFILE -Leaf),
    [string]$ScriptPath = $PROFILE
  )

  # Display script path
  Write-Host ""
  Write-Host -NoNewline "ScriptPath : " -ForegroundColor DarkGray
  Write-Host "$ScriptPath" -ForegroundColor DarkMagenta
  Write-Host ""

  return @{ Path = $ScriptPath; FileName = $FileName }
}

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
      Write-Host ("{0,-50}" -f " $($function.FileName)") -ForegroundColor Cyan
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host "⚠️ No custom functions found in script ⚠️" -ForegroundColor Red
  }
}

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
    Show-GracefulError -Message "⚠️ File already exists ⚠️" -NoCenter
  }
}

##########---------- Jump to a specific directory ----------##########
function go {
  param (
    [string]$location
  )

  ######## GUARD CLAUSE : MISSING ARGUMENT ########
  if (-not $location) {
    Show-GracefulError -Message "⚠️ Invalid option! Type 'go help'..." -NoCenter
    return
  }

  ######## LOAD CONFIG ########
  $allLocations = Get-LocationPathConfig

  ######## GUARD CLAUSE : CONFIGURATION ERROR ########
  if (-not $allLocations) {
    Show-GracefulError -Message "❌ Critical Error : Get-LocationPathConfig returned no data !" -NoCenter
    return
  }

  ######## HELP MODE ########
  if ($location -eq "help") {
    Write-Host ""
    Write-Host ("{0,-27} {1,-60}" -f "Alias", "Path") -ForegroundColor White -BackgroundColor DarkGray

    # Alphabetical sorting
    foreach ($option in ($allLocations | Sort-Object Name)) {
      # Icon to differentiate Repo vs Folder
      $icon = if($option.IsRepo){"󰊤"}else{""}

      if ($option.Name -ne "help") {
        Write-Host -NoNewline ("{0,-28}" -f "$($option.Name)") -ForegroundColor Magenta
        Write-Host ("{0,-60}" -f "$icon $($option.Path)") -ForegroundColor DarkCyan
      }
    }

    Write-Host ""
    return
  }

  ######## NAVIGATION MODE ########
  # Search (Case Insensitive by default in PowerShell)
  $target = $allLocations | Where-Object { $_.Name -eq $location } | Select-Object -First 1

  ######## GUARD CLAUSE : ALIAS NOT FOUND ########
  if (-not $target) {
    Write-Host -NoNewline "⚠️ Alias " -ForegroundColor Red
    Write-Host -NoNewline "`"$($location)`"" -ForegroundColor Magenta
    Write-Host " not found in configuration !" -ForegroundColor Red
    Write-Host "   └─> Type 'go help' to see available options..." -ForegroundColor DarkYellow
    return
  }

  if (Test-Path -Path $target.Path) {
    Set-Location -Path $target.Path
  }
  else {
    Write-Host -NoNewline "⚠️ Path defined for alias " -ForegroundColor Red
    Write-Host -NoNewline "'$location'" -ForegroundColor Magenta
    Write-Host " does not exist on disk !" -ForegroundColor Red
    Write-Host -NoNewline "   └─> Non-existent path : " -ForegroundColor DarkYellow
    Write-Host -NoNewline "`"$($target.Path)`"" -ForegroundColor DarkCyan
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
    [string]$hostname = "github.com",    # default host
    [int]$port        = 22               # default port for SSH
  )

  $msg = "🚀 Launch 󰣀 SSH connection with GPG keys 🚀"

  Write-Host ""
  Write-Host -NoNewline (Get-CenteredPadding -RawMessage $msg)
  Write-Host $msg -ForegroundColor Green

  # Test connection to SSH server
  $connection = Test-NetConnection -ComputerName $hostname -Port $port

  if ($connection.TcpTestSucceeded) {
    $msgPrefix = "󰣀 SSH connection to "
    $msgMiddle = " is open on port "
    $msgSuffix = " ✅"

    $fullMsg = $msgPrefix + $hostname + $msgMiddle + $port + $msgSuffix

    Write-Host -NoNewline (Get-CenteredPadding -RawMessage $fullMsg)
    Write-Host -NoNewline $msgPrefix -ForegroundColor Green
    Write-Host -NoNewline "`"$($hostname)`"" -ForegroundColor Magenta
    Write-Host -NoNewline $msgMiddle -ForegroundColor Green
    Write-Host -NoNewline $port -ForegroundColor Magenta
    Write-Host $msgSuffix -ForegroundColor Green
    Write-Host ""

    ########## CROSS-PLATFORM ##########
    # On Linux/Mac, simply call 'ssh'. On Windows, also prefer 'ssh' if it's in PATH
    if (Get-Command ssh -ErrorAction SilentlyContinue) {
      ssh -T git@github.com
    }
    else {
      # Fallback old Windows
      & "C:\Windows\System32\OpenSSH\ssh.exe" -T git@github.com
    }
  }
  else {
    $msgPrefix = "❌ Unable to connect to "
    $msgMiddle = " on port "
    $msgSuffix = " ❌"

    $fullMsg = $msgPrefix + $hostname + $msgMiddle + $port + $msgSuffix

    Write-Host -NoNewline $msgPrefix -ForegroundColor Red
    Write-Host -NoNewline "`"$($hostname)`"" -ForegroundColor Magenta
    Write-Host -NoNewline $msgMiddle -ForegroundColor Red
    Write-Host -NoNewline $port -ForegroundColor Magenta
    Write-Host $msgSuffix -ForegroundColor Red
    Write-Host ""
  }
}

##########---------- Display powershell colors in terminal ----------##########
function colors {
  $colors = [enum]::GetValues([System.ConsoleColor])

  foreach ($bgcolor in $colors) {
    foreach ($fgcolor in $colors) {
      Write-Host "$fgcolor|" -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine
    }

  Write-Host " on $bgcolor"
  }
}
