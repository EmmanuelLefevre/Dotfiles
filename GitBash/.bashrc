# INTERACTIVE LOGIN SHELL

## Profil loaded in Powershell
eval "$(oh-my-posh init bash --config "$HOME\Documents\GitBash\gitbash_profile_darka.json")"

# ALIAS
## Open connection
alias o_ssh='ssh -T git@github.com'
## Close connection
alias c_ssh='exit'

# FUNCTIONS
BASE_PATH="C:/Users/Darka"

go() {
  # Dictionary definition of paths
  declare -A PATHS
  PATHS=(
    ["aw"]="$BASE_PATH/Desktop/Projets/ArtiWave"
    ["cours"]="$BASE_PATH/Desktop/Cours"
    ["docs"]="$BASE_PATH/Documents/Documentations"
    ["dwld"]="$BASE_PATH/Downloads"
    ["eg"]="$BASE_PATH/Desktop/Projets/EasyGarden"
    ["portfolio"]="$BASE_PATH/Desktop/Projets/IAmEmmanuelLefevre"
    ["profile"]="$BASE_PATH/Desktop/Projets/EmmanuelLefevre"
    ["projets"]="$BASE_PATH/Desktop/Projets"
    ["schemas"]="$BASE_PATH/Desktop/Schemas"
    ["settings"]="$BASE_PATH/Desktop/Settings"
    ["soutenances"]="$BASE_PATH/Desktop/Soutenances"
  )

  # Checks if the argument is a valid key
  if [[ -n "${PATHS[$1]}" ]]; then
    cd "${PATHS[$1]}" 2>/dev/null || echo "Error: Path '${PATHS[$1]}' doesn't exists!"
  else
    echo "Available paths :"
    for key in $(printf "%s\n" "${!PATHS[@]}" | sort); do
      echo " - $key -> ${PATHS[$key]}"
    done
  fi
}
