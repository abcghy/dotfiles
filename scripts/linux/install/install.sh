#!/bin/bash

# Arch Linux Interactive Installation Script
# Main entry point that checks environment, installs Go if needed,
# compiles and runs the TUI wizard, then executes the installation.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="/tmp/arch-install-$$"
FAILED_LOG="$HOME/.config/arch-install/failed-packages.log"

# Show usage information
show_help() {
    cat << 'EOF'
Arch Linux Interactive Installation Script

Usage: ./install.sh [OPTIONS]

Options:
  --test-config    Test if configuration files are valid
  --help, -h       Show this help message
  --recompile, -r  Force recompilation of wizard
  --no-compile     Skip compilation check (use existing wizard)

Examples:
  ./install.sh                    # Run the interactive installer
  ./install.sh --test-config      # Test configuration without installing
  ./install.sh --recompile        # Force recompile and run

The wizard will be automatically recompiled when:
  - Go source files are modified
  - Configuration files are modified
  - go.mod or go.sum changes

EOF
}

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This script is designed for Arch Linux only!"
        exit 1
    fi
}

# Check and install Go
check_go() {
    if command -v go &> /dev/null; then
        GO_VERSION=$(go version | awk '{print $3}')
        print_success "Go is already installed ($GO_VERSION)"
        return 0
    fi

    print_warning "Go is not installed."
    echo ""
    echo "This installation wizard uses a Go-based TUI (Terminal User Interface)"
    echo "built with charmbracelet/bubbles to provide an interactive experience."
    echo ""
    echo "Go is required to compile and run this wizard. It will be installed"
    echo "using pacman and can be removed afterward if desired."
    echo ""
    read -p "Proceed with Go installation? [Y/n] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        print_error "Installation cancelled. Go is required to run this wizard."
        exit 1
    fi

    print_info "Installing Go..."
    if sudo pacman -S --needed --noconfirm go; then
        print_success "Go installed successfully"
    else
        print_error "Failed to install Go. Please install it manually:"
        print_error "  sudo pacman -S go"
        exit 1
    fi
}

# Check if wizard needs recompilation
needs_compile() {
    local wizard_path="$SCRIPT_DIR/wizard"
    
    # If wizard doesn't exist, needs compile
    if [[ ! -f "$wizard_path" ]]; then
        return 0
    fi
    
    # Check if any Go file is newer than the wizard
    local go_files=($(find "$SCRIPT_DIR" -name "*.go" -type f))
    for go_file in "${go_files[@]}"; do
        if [[ "$go_file" -nt "$wizard_path" ]]; then
            return 0
        fi
    done
    
    # Check if go.mod or go.sum is newer
    if [[ "$SCRIPT_DIR/go.mod" -nt "$wizard_path" ]] || [[ "$SCRIPT_DIR/go.sum" -nt "$wizard_path" ]]; then
        return 0
    fi
    
    # Check if config/packages.toml is newer
    if [[ "$SCRIPT_DIR/config/packages.toml" -nt "$wizard_path" ]]; then
        return 0
    fi
    
    return 1
}

# Compile the Go wizard
compile_wizard() {
    if ! needs_compile; then
        print_success "Wizard is up to date, skipping compilation"
        return 0
    fi
    
    print_info "Compiling installation wizard..."
    
    cd "$SCRIPT_DIR"
    
    # Initialize Go module if needed
    if [[ ! -f go.mod ]]; then
        print_error "Go module not found. Please ensure you're running this from the correct directory."
        exit 1
    fi
    
    # Download dependencies
    go mod download 2>/dev/null || true
    
    # Build the wizard
    if go build -o wizard .; then
        print_success "Wizard compiled successfully"
    else
        print_error "Failed to compile wizard"
        exit 1
    fi
}

# Run the wizard and get user selections
run_wizard() {
    print_info "Starting installation wizard..."
    echo ""
    
    cd "$SCRIPT_DIR"
    
# Run the wizard and capture output
    # The wizard will save its output to a file
    echo "Note: Running wizard interactively..."
    echo "The wizard will save its output to $TEMP_DIR/manifest.json"
    
    # Export TEMP_DIR for wizard to use
    export TEMP_DIR
    
    # Run wizard with explicit terminal access
    # Use script command to ensure proper terminal environment
    if script -qc "./wizard" /dev/null 2>/dev/null || ./wizard; then
        # Check if wizard created manifest file
        if [[ -f "$TEMP_DIR/manifest.json" && -s "$TEMP_DIR/manifest.json" ]]; then
            print_success "Wizard completed successfully"
            return 0
        else
            print_warning "Installation cancelled by user"
            exit 0
        fi
    else
        print_error "Wizard encountered an error"
        exit 1
    fi
}

# Install yay in temporary directory
install_yay() {
    if command -v yay &> /dev/null; then
        YAY_VERSION=$(yay --version | head -n1 | awk '{print $2}')
        print_success "yay is already installed ($YAY_VERSION)"
        return 0
    fi

    print_info "Installing yay (AUR helper)..."
    
    YAY_TEMP="/tmp/yay-install-$$"
    mkdir -p "$YAY_TEMP"
    cd "$YAY_TEMP"
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm git base-devel
    
    # Clone and build yay-bin (pre-compiled binary for speed)
    if git clone https://aur.archlinux.org/yay-bin.git; then
        cd yay-bin
        if makepkg -si --noconfirm; then
            print_success "yay installed successfully"
            cd "$SCRIPT_DIR"
            rm -rf "$YAY_TEMP"
            return 0
        else
            print_error "Failed to build yay"
            cd "$SCRIPT_DIR"
            rm -rf "$YAY_TEMP"
            print_error "yay installation failed. To retry, run:"
            print_error "  $0"
            exit 1
        fi
    else
        print_error "Failed to clone yay repository"
        cd "$SCRIPT_DIR"
        rm -rf "$YAY_TEMP"
        print_error "yay installation failed. To retry, run:"
        print_error "  $0"
        exit 1
    fi
}

# Enable multilib repository if needed
enable_multilib() {
    local need_multilib=$1
    
    if [[ "$need_multilib" != "true" ]]; then
        return 0
    fi

    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        if grep -A1 "^\[multilib\]" /etc/pacman.conf | grep -q "^Include"; then
            print_success "multilib repository is already enabled"
            return 0
        fi
    fi

    print_info "Enabling multilib repository for Steam..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/{s/^#//}' /etc/pacman.conf
    
    print_info "Updating package database..."
    sudo pacman -Sy
    
    print_success "multilib repository enabled"
}

# Install packages from pacman
install_pacman_packages() {
    local manifest_file=$1
    local packages=($(jq -r '.pacman_packages[]' "$manifest_file" 2>/dev/null))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        print_info "No official packages to install"
        return 0
    fi

    print_info "Installing ${#packages[@]} packages from official repositories..."
    
    # Install all packages at once for better performance
    if sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        print_success "All official packages installed successfully"
    else
        print_warning "Some packages failed to install, trying individually..."
        
        for pkg in "${packages[@]}"; do
            if sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
                print_success "Installed: $pkg"
            else
                print_error "Failed to install: $pkg"
                echo "$(date '+%Y-%m-%d %H:%M:%S') - pacman - $pkg" >> "$FAILED_LOG"
            fi
        done
    fi
}

# Install packages from AUR using yay
install_aur_packages() {
    local manifest_file=$1
    local packages=($(jq -r '.aur_packages[]' "$manifest_file" 2>/dev/null))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        print_info "No AUR packages to install"
        return 0
    fi

    print_info "Installing ${#packages[@]} packages from AUR..."
    
    # Install all packages at once
    if yay -S --needed --noconfirm "${packages[@]}"; then
        print_success "All AUR packages installed successfully"
    else
        print_warning "Some AUR packages failed to install, trying individually..."
        
        for pkg in "${packages[@]}"; do
            if yay -S --needed --noconfirm "$pkg" 2>/dev/null; then
                print_success "Installed: $pkg"
            else
                print_error "Failed to install: $pkg"
                echo "$(date '+%Y-%m-%d %H:%M:%S') - AUR - $pkg" >> "$FAILED_LOG"
            fi
        done
    fi
}

# Install development environment
install_dev_env() {
    local env=$1
    
    case "$env" in
        python)
            if command -v python &> /dev/null || command -v python3 &> /dev/null; then
                print_success "Python is already installed"
                return 0
            fi
            print_info "Installing Python..."
            sudo pacman -S --needed --noconfirm python python-pip
            ;;
        nodejs)
            if command -v node &> /dev/null; then
                print_success "Node.js is already installed"
                return 0
            fi
            print_info "Installing fnm (Fast Node Manager)..."
            if ! command -v fnm &> /dev/null; then
                # Install fnm
                curl -fsSL https://fnm.vercel.app/install | bash
                export PATH="$HOME/.local/share/fnm:$PATH"
                eval "$(fnm env 2>/dev/null || true)"
            fi
            print_info "Installing Node.js LTS..."
            fnm install --lts
            fnm use lts-latest
            ;;
        rust)
            if command -v rustc &> /dev/null; then
                print_success "Rust is already installed"
                return 0
            fi
            print_info "Installing Rust via rustup..."
            if ! command -v rustup &> /dev/null; then
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source "$HOME/.cargo/env"
            fi
            rustup default stable
            ;;
        go)
            print_info "Go is already installed (required for this wizard)"
            ;;
        *)
            print_warning "Unknown development environment: $env"
            ;;
    esac
}

# Install TPM for tmux if tmux is selected
install_tpm() {
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_success "TPM (Tmux Plugin Manager) is already installed"
        return 0
    fi
    
    print_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    print_success "TPM installed. Remember to press prefix + I in tmux to install plugins."
}

# Main installation logic
perform_installation() {
    local manifest_file=$1
    
    # Initialize failed log
    mkdir -p "$(dirname "$FAILED_LOG")"
    echo "# Installation Log - $(date)" > "$FAILED_LOG"
    echo "" >> "$FAILED_LOG"
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        print_info "Installing jq for JSON parsing..."
        sudo pacman -S --needed --noconfirm jq
    fi
    
    # Parse manifest
    local enable_multilib=$(jq -r '.enable_multilib' "$manifest_file")
    local dev_envs=($(jq -r '.dev_envs[]' "$manifest_file" 2>/dev/null))
    local summary=$(jq -r '.summary' "$manifest_file")
    
    # Enable multilib if needed
    enable_multilib "$enable_multilib"
    
    # Show summary
    echo ""
    print_info "Installation Summary:"
    echo "$summary" | jq -r '
        "Categories: \(.categories | join(", "))",
        "Fonts: \(.fonts | join(", "))",
        "Optional Tools: \(.optional_tools | join(", "))",
        "Extra Packages: \(.extra_packages | join(", "))"
    ' 2>/dev/null || true
    echo ""
    
    # Install packages
    install_pacman_packages "$manifest_file"
    install_aur_packages "$manifest_file"
    
    # Install development environments
    for env in "${dev_envs[@]}"; do
        install_dev_env "$env"
    done
    
    # Install TPM if tmux was selected
    local categories=($(jq -r '.summary.categories[]' "$manifest_file" 2>/dev/null))
    for cat in "${categories[@]}"; do
        if [[ "$cat" == "terminal" ]] || [[ "$cat" == "dev" ]]; then
            install_tpm
            break
        fi
    done
    
    # Print final summary
    echo ""
    print_success "========================================"
    print_success "  Installation completed!"
    print_success "========================================"
    
    if [[ -s "$FAILED_LOG" ]] && [[ $(wc -l < "$FAILED_LOG") -gt 2 ]]; then
        echo ""
        print_warning "Some packages failed to install. See: $FAILED_LOG"
        echo ""
        echo "Failed packages:"
        tail -n +3 "$FAILED_LOG"
    else
        print_success "All packages installed successfully!"
    fi
}

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Check for required dependencies
check_dependencies() {
    local deps=("git" "base-devel")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! pacman -Qi "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_info "Installing required dependencies: ${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
}

# Main execution
main() {
    # Parse command line arguments
    local force_compile=false
    local skip_compile=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --test-config)
                check_go
                if [[ "$force_compile" == true ]]; then
                    rm -f "$SCRIPT_DIR/wizard"
                fi
                compile_wizard
                "$SCRIPT_DIR/wizard" --test-config
                exit $?
                ;;
            --recompile|-r)
                force_compile=true
                shift
                ;;
            --no-compile)
                skip_compile=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    print_info "Arch Linux Interactive Installation Script"
    print_info "=========================================="
    echo ""
    
    # Check prerequisites
    check_arch
    check_dependencies
    check_go
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    # Handle compile options
    if [[ "$force_compile" == true ]]; then
        print_info "Force recompilation requested..."
        rm -f "$SCRIPT_DIR/wizard"
        compile_wizard
    elif [[ "$skip_compile" == true ]]; then
        if [[ -f "$SCRIPT_DIR/wizard" ]]; then
            print_success "Using existing wizard (skipping compilation check)"
        else
            print_warning "No existing wizard found, compiling..."
            compile_wizard
        fi
    else
        # Normal mode - check if recompilation is needed
        compile_wizard
    fi
    
    if run_wizard; then
        # Install yay
        install_yay
        
        # Perform installation based on wizard output
        perform_installation "$TEMP_DIR/manifest.json"
    fi
    
    echo ""
    print_success "All done! Enjoy your Arch Linux system! 🎉"
}

# Run main function
main "$@"
