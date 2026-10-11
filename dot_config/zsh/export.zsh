export EDITOR=nvim

export PATH=$PATH:$HOME/.local/bin
export PATH="/usr/local/opt/node@16/bin:$PATH"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# GPG stuff
export GPG_TTY=$(tty)

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$HOME/Library/Android/sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"
export PATH=$HOME/.config/emacs/bin:$PATH
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$HOME/.cargo/bin/:$PATH"

export ELECTRON_OZONE_PLATFORM_HINT=wayland

# uv
[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"

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
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
