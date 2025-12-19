function Get-LocationPathConfig {
  # IsRepo = $true   => Included in Update-GitRepositories() process AND accessible via go()
  # IsRepo = $false  => Accessible ONLY via go() function

  # IsOnlyMain = $true   => only pull main branch
  # IsOnlyMain = $false  => pull all branches

  # Get system context
  $Sys = Get-SystemContext

  # Definition of universal root folders
  # Join-Path automatically handles "/"" or "\"" depending on specific OS
  $DesktopPath   = Join-Path $HOME "Desktop"
  $ProjectsPath  = Join-Path $DesktopPath "Projects"
  $DocumentsPath = Join-Path $HOME "Documents"
  $PicturesPath  = Join-Path $HOME "Pictures"

  # For nvim, path changes depending on OS
  if ($Sys.IsMacOS -or $Sys.IsLinux) {
    $NvimPath = Join-Path $HOME ".config/nvim"
  }
  else {
    $NvimPath = Join-Path $env:LOCALAPPDATA "nvim"
  }

  return @(
    ##########---------- REPOSITORIES (Important order for Update-GitRepositories() function) ----------##########
    [PSCustomObject]@{ Name = "AngularTemplate";          Path = Join-Path $ProjectsPath   "AngularTemplate";         IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "ArtiWave";                 Path = Join-Path $ProjectsPath   "ArtiWave";                IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "Astrofall";                Path = Join-Path $ProjectsPath   "Astrofall";               IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "CotonShop";                Path = Join-Path $ProjectsPath   "CotonShop";               IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "Cours";                    Path = Join-Path $DesktopPath    "Cours";                   IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "DailyPush";                Path = Join-Path $DesktopPath    "DailyPush";               IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "DataScrub";                Path = Join-Path $ProjectsPath   "DataScrub";               IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "Documentations";           Path = Join-Path $DocumentsPath  "Documentations";          IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "Dotfiles";                 Path = Join-Path $DesktopPath    "Dotfiles";                IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "EasyGarden";               Path = Join-Path $ProjectsPath   "EasyGarden";              IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "ElexxionData";             Path = Join-Path $ProjectsPath   "ElexxionData";            IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "ElexxionMinio";            Path = Join-Path $ProjectsPath   "ElexxionMinio";           IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "EmmanuelLefevre";          Path = Join-Path $ProjectsPath   "EmmanuelLefevre";         IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "GestForm";                 Path = Join-Path $ProjectsPath   "GestForm";                IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "GitHubProfileIcons";       Path = Join-Path $PicturesPath   "GitHubProfileIcons";      IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "GoogleSheets";             Path = Join-Path $DesktopPath    "GoogleSheets";            IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "GPull";                    Path = Join-Path $ProjectsPath   "GPull";                   IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "LeCabinetDeCuriosites";    Path = Join-Path $ProjectsPath   "LeCabinetDeCuriosites";   IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "IAmEmmanuelLefevre";       Path = Join-Path $ProjectsPath   "IAmEmmanuelLefevre";      IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "MarkdownImg";              Path = Join-Path $DesktopPath    "MarkdownImg";             IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "Mflix";                    Path = Join-Path $ProjectsPath   "Mflix";                   IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "OmbreArcane";              Path = Join-Path $ProjectsPath   "OmbreArcane";             IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "OpenScraper";              Path = Join-Path $ProjectsPath   "OpenScraper";             IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "ParquetFlow";              Path = Join-Path $ProjectsPath   "ParquetFlow";             IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "ReplicaMySQL";             Path = Join-Path $ProjectsPath   "ReplicaMySQL";            IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "Schemas";                  Path = Join-Path $DesktopPath    "Schemas";                 IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "ScrapMate";                Path = Join-Path $ProjectsPath   "ScrapMate";               IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "Sortify";                  Path = Join-Path $ProjectsPath   "Sortify";                 IsRepo = $true;   IsOnlyMain = $false },
    [PSCustomObject]@{ Name = "Soutenances";              Path = Join-Path $DesktopPath    "Soutenances";             IsRepo = $true;   IsOnlyMain = $true  },
    [PSCustomObject]@{ Name = "Yam4";                     Path = Join-Path $ProjectsPath   "Yam4";                    IsRepo = $true;   IsOnlyMain = $false },

    ##########---------- NAVIGATION ONLY (go() function) ----------##########
    [PSCustomObject]@{ Name = "desktop";                  Path = $DesktopPath;                  IsRepo = $false },
    [PSCustomObject]@{ Name = "dwld";                     Path = Join-Path $HOME "Downloads";   IsRepo = $false },
    [PSCustomObject]@{ Name = "home";                     Path = $HOME;                         IsRepo = $false },
    [PSCustomObject]@{ Name = "nvim";                     Path = $NvimPath;                     IsRepo = $false },
    [PSCustomObject]@{ Name = "prof";                     Path = Split-Path $PROFILE -Parent;   IsRepo = $false },
    [PSCustomObject]@{ Name = "prj";                      Path = $ProjectsPath;                 IsRepo = $false }
  )
}
