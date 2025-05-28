sudo pacman -S --noconfirm --needed neovim tmux tmuxp
sudo pacman -S --noconfirm --needed tldr fd ripgrep fzf
sudo pacman -S --noconfirm --needed git lazygit
# lazygit httpie sttr lnav bat

yay -S --needed visual-studio-code-bin

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "already installed tpm"
else
    echo "tpm not installed yet. clone it for now."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "don't forget to type C-a and I after you are into tmux"
fi
