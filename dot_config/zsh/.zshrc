export PATH="$HOME/.ghcup/bin:$HOME/.cabal/bin:$PATH"
# Custom completions (must be in fpath before Zim initializes compinit)
fpath=("$HOME/.zsh/completions" $fpath)

[[ ! -f ~/.config/zsh/zim_config.zsh ]] || source ~/.config/zsh/zim_config.zsh

# Created by newuser for 5.9

. "$HOME/.local/bin/env"

[[ ! -f ~/.config/zsh/export.zsh ]] || source ~/.config/zsh/export.zsh
[[ ! -f ~/.config/zsh/fzf.zsh ]] || source ~/.config/zsh/fzf.zsh
[[ ! -f ~/.config/zsh/alias.zsh ]] || source ~/.config/zsh/alias.zsh
[[ ! -f ~/.config/zsh/others.zsh ]] || source ~/.config/zsh/others.zsh

eval "$(fnm env --use-on-cd --shell zsh)"

# zoxide
eval "$(zoxide init zsh)"

# yazi
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  local cwd="$(cat "$tmp" && rm -f -- "$tmp")"
  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ]; then
    builtin cd -- "$cwd"
  fi
}

# pnpm
export PNPM_HOME="/Users/sakura/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
export PATH="$HOME/.ghcup/bin:$HOME/.cabal/bin:$PATH"
eval "$(/Users/sakura/.local/bin/mise activate zsh)"

# try - fresh directories for experiments
eval "$(try init ~/Work/tries)"

# Do not expose Hermes' Xiaomi credential to child tools such as Pi.
unset XIAOMI_API_KEY

# Prompt
eval "$(starship init zsh)"
