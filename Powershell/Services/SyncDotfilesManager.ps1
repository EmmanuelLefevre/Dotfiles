##########---------- Synchronize your dotfiles ----------##########
function Sync-Dotfiles {
  [CmdletBinding()]
  param()

  Write-Host "--- Début de la synchronisation des Dotfiles ---" -ForegroundColor Cyan

  # 1. Récupérer les chemins via ta config
  $Config = Get-LocationPathConfig
  $DotfilesRepo = $Config | Where-Object { $_.Name -eq "Dotfiles" }
  $NvimDest = $Config | Where-Object { $_.Name -eq "nvim" }
  $PwshDest = $Config | Where-Object { $_.Name -eq "pwsh" }

  if (-not (Test-Path $DotfilesRepo.Path)) {
      Write-Error "Le dossier Dotfiles est introuvable à l'adresse : $($DotfilesRepo.Path)"
      return
  }

  # 2. Définir les paires Source (dans le repo) -> Destination (sur le système)
  # Adapte les noms de dossiers source selon la structure de ton repo Git
  $SyncMap = @(
    @{ Source = Join-Path $DotfilesRepo.Path "nvim"; Destination = $NvimDest.Path },
    @{ Source = Join-Path $DotfilesRepo.Path "PowerShell"; Destination = $PwshDest.Path }
    # Tu peux ajouter ici gitconfig, tmux, etc.
  )

  foreach ($Item in $SyncMap) {
    if (Test-Path $Item.Source) {
      Write-Host "Synchronisation de : $($Item.Source) -> $($Item.Destination)" -ForegroundColor Gray

      # Créer le dossier parent si inexistant
      if (-not (Test-Path $Item.Destination)) {
        New-Item -ItemType Directory -Path $Item.Destination -Force | Out-Null
      }

      # Copie récursive et forcée
      Copy-Item -Path "$($Item.Source)\*" -Destination $Item.Destination -Recurse -Force
    }
    else {
      Write-Warning "Source introuvable, skip : $($Item.Source)"
    }
  }

  Write-Host "Synchronisation terminée avec succès !" -ForegroundColor Green
}
