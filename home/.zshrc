# Alases
alias v=nvim
alias lg=lazygit
alias y=yazi
alias p=projman
alias j=just
alias cat=bat
alias ls=eza
alias cd=z

alias ta="tmux attach"


# Setting ENV Variabeles
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"

# Adding Go Installed Packages
export PATH="$HOME/go/bin/:$PATH"

# Adding emacs to path
export PATH="$HOME/.emacs.d/bin/:$PATH"

# Adding local bin to path
export PATH="$HOME/.local/bin/:$PATH"

# bun completions
[ -s "/Users/danielronalds/.bun/_bun" ] && source "/Users/danielronalds/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Cargo path
export PATH="$HOME/.cargo/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

 # fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# zoxide
eval "$(zoxide init zsh)"

# starship
eval "$(starship init zsh)"

# Added by `rbenv init` on Sun Aug  3 09:48:45 AM UTC 2025
eval "$(rbenv init - --no-rehash zsh)"
# Adding 3.4.2 ruby version to path
export PATH="$HOME/.rbenv/versions/3.4.2/bin:$PATH"
