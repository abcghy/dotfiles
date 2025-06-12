alias vim=nvim
alias ra=ranger
alias lg=lazygit
alias ff=fastfetch
alias zz='cd $(z | awk '\''{print $NF}'\'' | fzf +s --tac --preview "tree -L1 {}")'
