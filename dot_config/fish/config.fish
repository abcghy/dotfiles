if status is-interactive
    # Commands to run in interactive sessions can go here
end

# GPG Agent for SSH Authentication in Fish Shell

# Erase the standard SSH_AGENT_PID to avoid conflicts
set -e SSH_AGENT_PID

# Check if pinentry has already set the socket for us
if set -q gnupg_SSH_AUTH_SOCK_by_pinentry
    set -gx SSH_AUTH_SOCK "$gnupg_SSH_AUTH_SOCK_by_pinentry"
else
    # If not, find the socket location using gpgconf
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end

# Update the TTY for pinentry to work correctly in the current terminal
gpg-connect-agent updatestartuptty /bye >/dev/null

zoxide init fish | source
