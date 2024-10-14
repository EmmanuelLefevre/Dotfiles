#---------------#
# PROMPT THEMES #
#---------------#
oh-my-posh init pwsh --config 'C:/Users/darka/Documents/PowerShell/myprofile.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.omp.json' | Invoke-Expression
#oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/atomic.omp.json' | Invoke-Expression


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
########## SSH ##########
Import-Module Posh-SSH
########## PSReadLine ##########
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -PredictionViewStyle ListView


#---------#
# HELPERS #
#---------#

########## Help alias ##########
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
    Write-Host ("{0,-20} {1,-30} {2,-40}" -f "Alias", "Definition", "FileName") -ForegroundColor White -BackgroundColor DarkGray

    # Display each alias informations
    foreach ($alias in $sortedAliasArray) {
      Write-Host -NoNewline ("{0,-21}" -f "$($alias.Alias)") -ForegroundColor DarkCyan
      Write-Host -NoNewline ("{0,-31}" -f "$($alias.Definition)") -ForegroundColor Magenta
      Write-Host ("{0,-30}" -f "$($alias.FileName)") -ForegroundColor Yellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host " No help aliases found in script !!! " -ForegroundColor DarkRed -BackgroundColor DarkYellow
  }
}

########## List of custom aliases ##########
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
    Write-Host ("{0,-10} {1,-20} {2,-40}" -f "Alias", "Command", "FileName") -ForegroundColor White -BackGroundColor DarkGray

    # Display each alias informations
    foreach ($alias in $customAliases) {
      Write-Host -NoNewline ("{0,-11}" -f "$($alias.Name)") -ForegroundColor DarkCyan
      Write-Host -NoNewline ("{0,-21}" -f "$($alias.Alias)") -ForegroundColor Magenta
      Write-Host ("{0,-40}" -f "$($alias.FileName)") -ForegroundColor Yellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host " No custom aliases found in script !!! " -ForegroundColor DarkRed -BackGroundColor DarkYellow
  }
}

########## List of custom functions ##########
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
    Write-Host ("{0,-18} {1,-50} {2,-50}" -f "Alias", "Definition", "FileName") -ForegroundColor White -BackGroundColor DarkGray

    # Display each function with informations
    foreach ($function in $sortedFunctions) {
      Write-Host -NoNewline ("{0,-19}" -f "$($function.Alias)") -ForegroundColor DarkCyan

      $goal = $goals[$function.Alias]
      Write-Host -NoNewline ("{0,-51}" -f "$goal") -ForegroundColor Magenta

      Write-Host ("{0,-50}" -f "$($function.FileName)") -ForegroundColor Yellow
    }
    Write-Host ""
  }
  else {
    Write-Host ""
    Write-Host " No custom functions found in script !!! " -ForegroundColor DarkRed -BackGroundColor DarkYellow
  }
}

########## Display all powershell colors in terminal ##########
function colors {
  $colors = [enum]::GetValues([System.ConsoleColor])

  Foreach ($bgcolor in $colors) {
    Foreach ($fgcolor in $colors) {
      Write-Host "$fgcolor|" -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine
    }

  Write-Host " on $bgcolor"
  }
}


#-----------#
# FUNCTIONS #
#-----------#

########## Goto ##########
function go {
  param (
    [string]$location
  )

  # Check if the argument is empty
  if (-not $location) {
    Write-Host ""
    Write-Host "Invalid option !!! Type 'go help'" -ForegroundColor DarkRed -BackgroundColor DarkYellow
    return
  }

  # List of valid options and their corresponding paths
  $validOptions = @(
    @{ Name = "dwld"; Path = "$HOME\Downloads" },
    @{ Name = "home"; Path = "$HOME" },
    @{ Name = "nvim"; Path = "$HOME\AppData\Local\nvim" },
    @{ Name = "profile"; Path = "$HOME\Documents\PowerShell" },
    @{ Name = "projets"; Path = "$HOME\Desktop\Projets" },
    @{ Name = "help"; Path = "Available paths" }
  )

  # Check if the passed argument is valid
  if ($validOptions.Name -notcontains $location) {
    Write-Host ""
    Write-Host " Invalid argument !!! Type 'go help' " -ForegroundColor DarkRed -BackgroundColor DarkYellow
    return
  }

  Switch ($location) {
    "dwld" {
      Set-Location -Path "$HOME\Downloads"
    }
    "home" {
      Set-Location -Path "$HOME"
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
    "help" {
      # Create a table of valid options
      Write-Host ""
      Write-Host ("{0,-20} {1,-50}" -f "Alias", "PathDirection") -ForegroundColor White -BackgroundColor DarkGray

      foreach ($option in $validOptions) {
        if ($option.Name -ne "help") {
          Write-Host -NoNewline ("{0,-21}" -f "$($option.Name)") -ForegroundColor DarkCyan
          Write-Host ("{0,-50}" -f "$($option.Path)") -ForegroundColor Yellow
        }
      }
      Write-Host ""
    }
    default {
      Write-Host ""
      Write-Host " Error occurred !!! " -ForegroundColor DarkRed -BackgroundColor DarkYellow
    }
  }
}

########## Whereis ##########
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
  Write-Host "Launch SSH connection with GPG keys..." -ForegroundColor Green
  # Test connection to SSH server
  $connection = Test-NetConnection -ComputerName $hostname -Port $port
  if ($connection.TcpTestSucceeded) {
    Write-Host "The SSH connection to $hostname is open on $port!" -ForegroundColor Green
    & "C:\Windows\System32\OpenSSH\ssh.exe" -T git@github.com
  }
  else {
    Write-Host "Unable to connect to $hostname on port $port!" -ForegroundColor Red
  }
}


#-------------------#
# UTILITY FUNCTIONS #
#-------------------#

########## Dictionary of functions and their objectives ##########
function Get-GoalFunctionsDictionary {
  $goalFunctions = @{
    colors = "Display all powershell colors in terminal"
    custom_alias = "Get all custom aliases"
    custom_function  = "Get objective function"
    go = "Go directly to a specific directory"
    help = "Get help aliases"
    ssh_github = "Test GitHub SSH connection with GPG keys"
    whereis = "Find path of a specified command/executable"
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
  Write-Host "$ScriptPath" -ForegroundColor DarkYellow
  Write-Host ""

  return @{ Path = $ScriptPath; FileName = $FileName }
}
