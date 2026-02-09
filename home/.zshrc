######################
# PATH Configuration #
######################

export PATH="$HOME/.emacs.d/bin/:$PATH"
export PATH="$HOME/.local/bin/:$PATH"

##################
# Shell Settings #
##################

HISTFILE="$HOME/.zsh_history"
SAVEHIST=10000
HISTSIZE=999
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Setting ENV Variabeles
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"

# Setup zoxide
eval "$(zoxide init zsh)"

# Setup Starship
eval "$(starship init zsh)"

# Setup Mise-en-place
eval "$(mise activate zsh)"

###########
# Aliases #
###########

alias v=nvim
alias lg=lazygit
alias y=yazi
alias p=projman
alias j=just
alias cat="bat --theme base16"
alias ls=eza
alias cd=z

alias ta="tmux attach"

###################
# Helpful Scripts #
###################

# Amazing easy ctrl+z? for toggling in and out of bg
if [[ $- == *i* ]]; then
  stty susp undef

  bindkey -s '^Z' 'fg\n'
fi

# Get the title of the PR associated with the current git branch
,pr-title() {
  gh pr view | head -n 1 | sed "s/title\\:\t//"
}

# Use FZF to switch git branches
,gb() {
  local branch=$(git branch | fzf --reverse --height "50%" --color "bw")

  local trimmed_branch=$(echo "$branch" | sed -e 's/^[[:space:]]*//')

  if [[ -z "$trimmed_branch" ]]; then
    return
  fi

  git checkout "$trimmed_branch"
}

# Make and then cd into a directory
,mkcd() {
    mkdir $1
    cd $1
}

# For analysing json responses. Opens a nvim buffer for json content to be pasted in, then opens jqp
,json() {
    local temp_file=$(mktemp)
    nvim $temp_file

    jqp --theme catppuccin-frappe < $temp_file

    rm $temp_file
}

# For quickly comparing files. Opens two buffers to paste content into, then diffs them
,cmpf() {
    local file_1=$(mktemp)
    nvim $file_1

    local file_2=$(mktemp)
    nvim $file_2

    diff $file_1 $file_2 | cat

    rm $file_1 $file_2
}
