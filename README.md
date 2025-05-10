# Harry's Dot Files Repo

``` bash
.
├── scripts
│   └── mac
├── softwares
│   └── mac
└── .config
````


We get three main directories here.
- .config a place stores all my config files for apps
- softwares stores all my installed apps list
- scripts are some scripts that easy to manipulate my computers

## Mac
1. First we need to install homebrew by ...
2. Second we need to install my apps by scripts/mac/brew-restore.sh
3. Then we can use `stow .` to put all my config into the right spot

## Linux
1. First we need to install yay by ...
2. second we need to install all the apps by scripts/linux/pacman-restore.sh
3. Then we can use `stow .` ...

Theoratically, all the things can be operated by one single script.

## TODO
- [ ] Need to config private files in the future (some private key stuffs)
