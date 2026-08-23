export EDITOR=nvim

# fnm
export PATH="$HOME/.local/share/fnm/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# uv
export UV_PYTHON_DOWNLOADS=latest

export PATH=$PATH:$HOME/.local/bin
export PATH="/usr/local/opt/node@16/bin:$PATH"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# pnpm
export PNPM_HOME="/home/sakura/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# zoxide
eval "$(zoxide init zsh)"

# GPG Agent for SSH Authentication in Zsh

# Erase the standard SSH_AGENT_PID to avoid conflicts
unset SSH_AGENT_PID

# Check if pinentry has already set the socket for us
if [[ -n "${gnupg_SSH_AUTH_SOCK_by_pinentry}" ]]; then
    export SSH_AUTH_SOCK="${gnupg_SSH_AUTH_SOCK_by_pinentry}"
else
    # If not, find the socket location using gpgconf
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

# Update the TTY for pinentry to work correctly in the current terminal
gpg-connect-agent updatestartuptty /bye >/dev/null


export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH=$HOME/.config/emacs/bin:$PATH
export TERM=xterm-256color
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$HOME/.cargo/bin/:$PATH"

export ELECTRON_OZONE_PLATFORM_HINT=wayland
