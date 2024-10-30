# INTERACTIVE LOGIN SHELL

## Profil loaded in Powershell
eval "$(oh-my-posh init bash --config "$HOME\Documents\GitBash\gitbash_profile_darka.json")"

# ALIAS
## Open connection
alias o_ssh='ssh -T git@github.com'
## Close connection
alias c_ssh='exit'

#############################################################################################

# Base path
BASE_PATH="C:/Users/Darka"

# Default commit message
DEFAULT_COMMIT_MESSAGE="maj"

# ANSI colors
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

# Local repositories dictionary
declare -A LocalRepos
LocalRepos["cours"]="$BASE_PATH/Desktop/Cours"
LocalRepos["docs"]="$BASE_PATH/Documents/Documentations"
LocalRepos["portfolio"]="$BASE_PATH/Desktop/Projets/IAmEmmanuelLefevre"
LocalRepos["profile"]="$BASE_PATH/Desktop/Projets/EmmanuelLefevre"
LocalRepos["schemas"]="$BASE_PATH/Desktop/Schemas"
LocalRepos["settings"]="$BASE_PATH/Desktop/Settings"
LocalRepos["soutenances"]="$BASE_PATH/Desktop/Soutenances"

# FUNCTIONS
## Automatic commit message push with directory navigation
push() {
  local repo_name=$1
  # Use DEFAULT_COMMIT_MESSAGE if none is provided
  local commit_message=${2:-$DEFAULT_COMMIT_MESSAGE}

  if [ -n "${LocalRepos[$repo_name]}" ]; then
    cd "${LocalRepos[$repo_name]}"
    git add .
    git commit -m "$commit_message"
    git push
    echo -e "${MAGENTA}$repo_name${NC} has been successfully updated 🤙"
  else
    echo -e "⚠️ Error: local repository ${RED}$repo_name${NC} not found! ⚠️"
  fi
}

## Jump to a specific directory
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
