# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.config/zsh/zim_config.zsh ]] || source ~/.config/zsh/zim_config.zsh

# Created by newuser for 5.9

[ -f "/Users/sakura/.ghcup/env" ] && source "/Users/sakura/.ghcup/env" # ghcup-env

# . "$HOME/.local/bin/env"

[[ ! -f ~/.config/zsh/export.zsh ]] || source ~/.config/zsh/export.zsh
[[ ! -f ~/.config/zsh/fzf.zsh ]] || source ~/.config/zsh/fzf.zsh
[[ ! -f ~/.config/zsh/alias.zsh ]] || source ~/.config/zsh/alias.zsh
[[ ! -f ~/.config/zsh/others.zsh ]] || source ~/.config/zsh/others.zsh

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

