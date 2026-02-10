# Arch Linux Installation Script Project

## Project Goals
Create a unified, interactive Arch Linux software installation script with the following features:
- Single entry point (install.sh)
- Interactive TUI interface (using charmbracelet/bubbles)
- Highly customizable
- Intelligent detection of installed software

## Core Requirements

### 1. Yay Installation Optimization
- Download and install yay-bin (pre-compiled binary) in a temporary directory (/tmp/yay-install)
- Detect if yay is already installed to avoid reinstallation
- Automatically clean up temporary files after installation
- Terminate script immediately if yay installation fails, with clear retry instructions

### 2. Unified Entry Point
- Create install.sh as the main entry point
- Check environment and install Go (if not installed), explaining why to the user
- Compile and run the Go TUI program
- Execute actual installation based on program output

### 3. Configuration File Driven
- Use TOML files to manage package lists
- Package definitions in `config/packages.toml`
- Users can directly modify the TOML to add software
- No hardcoded package lists in the program

### 4. Categories and Presets

#### Software Categories (defined in TOML):
- **Base System**: man, fcitx5, wl-clipboard, keyd, bluez-utils, blueman, 7zip
- **Terminal Environment**: zsh, kitty, yazi, tmux, cmatrix, fastfetch, btop, fzf, rsync
- **Development Tools**: neovim, tmuxp, tldr, fd, ripgrep, git, lazygit, pastel, vscode
- **Window Management**: niri, mako, waybar, fuzzel, swww, swayosd, brightnessctl, hyprlock, hypridle
- **Fonts**: noto-fonts-sc, maplemono-nf-cn, nerd-fonts, font-awesome, times-new-roman, lora
- **Entertainment**: mpv, telegram-desktop, swayimg, yt-dlp
- **Productivity**: neomutt, isync, w3m, cherry-studio

#### Non-Universal Tools (optional, not selected by default):
- sbcl (Lisp compiler)
- quicklisp (Lisp package manager)
- tsukimi-bin (anime client)
- ncspot (Spotify TUI client)

#### Development Environments (optional, with version detection):
- Python (pacman)
- Node.js (installed via fnm)
- Rust (rustup)

#### Preset Combinations:
- **Minimal Install**: Base system + Terminal environment
- **Developer Workstation**: Minimal + Development tools + Fonts + Window management
- **Gaming**: Minimal + Window management + Fonts + Entertainment + Steam

### 5. Interactive Wizard Flow

1. **Welcome Page** → Explain script functionality
2. **Preset Selection** → Choose preset or custom installation
3. **Category Selection** (if custom) → Multi-select desired categories
4. **Font Selection** → Multi-select fonts with usage descriptions
5. **Development Environment Selection** → Multi-select environments, show installed versions
6. **Optional Tools Selection** → Select non-universal tools
7. **Confirmation Page** → Display list of packages to be installed
8. **Execute Installation** → Show progress and results

### 6. Intelligent Detection

- Detect already installed packages, display as installed status (grayed out)
- Detect installed development environments, display version numbers
- Allow users to skip already installed software

### 7. Error Handling

- Yay installation failure → Stop immediately, show retry command
- Regular package failure → Log to `~/.config/arch-install/failed-packages.log`, continue with other packages
- Finally display installation summary with list of failed packages

### 8. Special Handling

- **multilib**: Automatically enable to install Steam
- **Font Descriptions**:
  - noto-fonts-sc: Chinese font display (required)
  - maplemono-nf-cn: Programming font with Nerd Font icons
  - nerd-fonts-sarasa-term: Terminal-specific font
  - otf-font-awesome: Icon font for waybar and others
  - ttf-times-new-roman: Web/document display
  - otf-lora-cyrillic: Reading font for foliate

## Technical Architecture

### File Structure
```
install/
├── install.sh              # Bash main entry
├── config/
│   └── packages.toml       # Package configuration file
├── internal/
│   ├── models/             # Data models
│   ├── config/             # Configuration parsing
│   ├── tui/                # TUI components
│   │   ├── wizard.go       # Wizard controller
│   │   ├── views/          # Step views
│   │   └── styles.go       # Style definitions
│   └── installer/          # Installation logic
├── pkg/
│   └── detector/           # Installed software detection
├── go.mod / go.sum         # Go modules
└── main.go                 # Program entry
```

### Workflow
1. install.sh checks environment
2. If needed, install Go with explanation to user
3. Compile and run Go program
4. Go program parses TOML configuration file
5. Detect installed software (pacman + which + version)
6. Display interactive wizard
7. Output selection results (JSON)
8. install.sh executes based on results:
   - Install yay (temporary directory)
   - Enable multilib (if Steam needed)
   - Install all selected packages
   - Log failed packages
   - Display installation summary

## Configuration Format (TOML)

```toml
[categories]
[categories.base]
name = "Base System"
description = "System base tools and input methods"
packages = ["man", "fcitx5", "wl-clipboard", "keyd", "bluez-utils", "blueman", "7zip"]

[categories.terminal]
name = "Terminal Environment"
description = "Terminal emulators and common tools"
packages = ["zsh", "kitty", "yazi", "tmux", "cmatrix", "fastfetch", "btop", "fzf", "rsync"]

[categories.fonts]
name = "Fonts"
description = "System and programming fonts"

[[categories.fonts.packages]]
name = "noto-fonts-sc"
description = "Chinese font display (required)"
recommended = true
aur = true

[[categories.fonts.packages]]
name = "maplemono-nf-cn"
description = "Programming font with Nerd Font icons"
recommended = true
aur = true

[[categories.fonts.packages]]
name = "nerd-fonts-sarasa-term"
description = "Terminal-specific font"
recommended = false
aur = true

[optional]
[optional.tools]
name = "Optional Tools"
items = [
    { name = "sbcl", description = "Common Lisp compiler", aur = false },
    { name = "quicklisp", description = "Lisp package manager", aur = false },
    { name = "tsukimi-bin", description = "Anime client", aur = true },
    { name = "ncspot", description = "Spotify TUI client", aur = false }
]

[optional.dev-env]
name = "Development Environments"
items = [
    { name = "python", description = "Python programming environment", installer = "pacman" },
    { name = "nodejs", description = "Node.js (installed via fnm)", installer = "fnm" },
    { name = "rust", description = "Rust programming environment", installer = "rustup" }
]

[presets]
[presets.minimal]
name = "Minimal Install"
description = "Base system + Terminal environment"
categories = ["base", "terminal"]

[presets.developer]
name = "Developer Workstation"
description = "Suitable for programming development"
categories = ["base", "terminal", "dev", "fonts", "wm"]
fonts = ["noto-fonts-sc", "maplemono-nf-cn"]

[presets.gaming]
name = "Gaming & Entertainment"
description = "Suitable for gaming and entertainment"
categories = ["base", "terminal", "wm", "fonts", "entertainment"]
fonts = ["noto-fonts-sc"]
packages = ["steam"]
```

## Version Detection Strategy

For development environments, detection methods:

```bash
# Python
python --version  # Python 3.11.6

# Node.js
node --version    # v20.10.0

# Rust
rustc --version   # rustc 1.75.0
```

Display in TUI:
- Not installed: □ Node.js - JavaScript runtime (fnm install)
- Installed: ☑ Node.js v20.10.0 - JavaScript runtime (already installed)

## Iteration Plan

### Phase 1 (Current)
- Basic architecture implementation
- TOML configuration file parsing
- Basic TUI interface
- Basic installation functionality
- Installed software detection

### Phase 2 (Future)
- More development environment support (pyenv, nvm, etc.)
- Post-installation configuration script support
- Installation history records
- Configuration file validation
- Support for user custom script directories

## Notes

1. All non-universal tools are unchecked by default
2. Fonts need detailed usage descriptions to help users decide
3. When detecting installed software, handle version differences
4. If yay installation fails, must clearly instruct user how to retry
5. Must explain to user before installing Go
6. Configuration files use TOML format, easy to read and modify

## Related Links

- charmbracelet/bubbles: https://github.com/charmbracelet/bubbles
- charmbracelet/lipgloss: https://github.com/charmbracelet/lipgloss
- yay-bin AUR: https://aur.archlinux.org/packages/yay-bin
- fnm (Fast Node Manager): https://github.com/Schniz/fnm
- TOML Specification: https://toml.io/
