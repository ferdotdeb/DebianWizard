#!/bin/bash

# ======================================================================
# DebianWizard
#
# An Debian and derivatives auto-installer script
#
# Improved version with Claude Sonnet 4
#
# Author: ferdotdeb
# Description: Automated setup script for Debian-based systems
# IMPORTANT: This script is designed for fresh Debian/Ubuntu or derivatives installations.
# ======================================================================

# Color codes for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global variables
git_username=""
git_email=""
ssh_password=""

# ======================================================================
# PRINT MESSAGES FUNCTIONS
# ======================================================================

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# The $1 parameter is the message sended to the print function to be showed with the color and symbol

# Function to print success messages
print_success() {
    print_message "$GREEN" "✓ $1"
}

# Function to print error messages
print_error() {
    print_message "$RED" "✗ ERROR: $1"
}

# Function to print warning messages
print_warning() {
    print_message "$YELLOW" "⚠ WARNING: $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# ======================================================================
# CHECK INTERNET FUNCTION
# ======================================================================

# Function to check internet connectivity
check_internet() {
    if ping -c 1 8.8.8.8 &> /dev/null || ping -c 1 google.com &> /dev/null; then
        return 0
    else
        return 1
    fi
}

show_welcome() {
    echo "=============================================="
    echo "Welcome to the Debian Wizard"
    echo "An Debian auto-installer script by @ferdotdeb"
    echo "=============================================="
 
    sleep 2
}

check_system() {
    echo "Checking OS version..."
    cat /etc/os-release
    sleep 2
    
    # Load variables of /etc/os-release file
    if ! source /etc/os-release; then
        print_error "Could not read system information from /etc/os-release"
        exit 1
    fi
    
    echo "$NAME system detected"
    
    # Validate if the system is Debian/Ubuntu based
    echo "Validating system compatibility..."
    sleep 2
    
    # Check if ID is debian or ubuntu directly
    if [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
        print_success "Compatible system detected: $NAME (ID: $ID)"
    # Check if ID_LIKE contains debian or ubuntu
    elif [[ "$ID_LIKE" =~ debian ]] || [[ "$ID_LIKE" =~ ubuntu ]]; then
        print_success "Compatible derivative system detected: $NAME (ID: $ID, based on: $ID_LIKE)"
    else
        print_error "Incompatible system detected!"
        echo "This script only works on Debian, Ubuntu, or their derivatives."
        echo "Current system: $NAME (ID: $ID, ID_LIKE: ${ID_LIKE:-not set})"
        echo "Exiting..."
        exit 1
    fi

    sleep 2
}

request_sudo_permission() {
    echo "Pre-requisites check..."
    echo "This will be the only non-automated part of the script"
    sleep 2
    
    echo "Please grant sudo permission to the script"
    if ! sudo -v; then
        print_error "Failed to obtain sudo permissions"
        exit 1
    fi
    
    print_success "Sudo permission granted!"
    sleep 2
}

validate_email() {
    local email=$1
    local regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    if [[ $email =~ $regex ]]; then
        return 0
    else
        return 1
    fi
}

collect_user_info() {
    echo "Please enter your personal information for Git configuration"
    
    # Get Git username
    echo -n "Enter your full name for Git installation: "
    read git_username
    while [ -z "$git_username" ]; do
        print_error "The name cannot be empty"
        echo -n "Enter your full name for Git installation: "
        read git_username
    done
    
    # Get Git email with validation
    echo -n "Enter your email for Git installation: "
    read git_email
    while ! validate_email "$git_email"; do
        print_error "Please enter a valid email address"
        echo -n "Enter your email for Git installation: "
        read git_email
    done
    
    # Get SSH password
    echo -n "Enter your password for SSH key generation: "
    read -s ssh_password # Flag -s for silent input
    echo # New line after silent input
    
    while [ -z "$ssh_password" ]; do
        print_error "Password cannot be empty"
        echo -n "Enter your password for SSH key generation: "
        read -s ssh_password
        echo
    done
    
    print_success "Pre-requisites check completed!"
}

# ======================================================================
# SYSTEM UPDATE FUNCTION
# ======================================================================

update_system() {
    echo "From this point on, the script will be fully automated."
    sleep 2

    echo "Checking internet connectivity..."
    if ! check_internet; then
        print_error "No internet connection detected"
        exit 1
    fi

    echo "Updating the system before installation..."
    sleep 2
    echo "Updating package list..."
    if ! sudo apt update; then
        print_error "Failed to update package list"
        exit 1
    fi
    
    echo "Upgrading installed packages..."
    # Usar modo no interactivo para evitar prompts de needrestart
    if ! sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt upgrade -y; then
        print_error "Failed to upgrade packages"
        exit 1
    fi
    
    print_success "System updated successfully"
}

install_repository_software() {
    echo "Continuing with the installation of repository software..."
    echo "Installing software from repositories..."
    
    # Check if required packages are already installed
    local packages="vim git fastfetch openssh-client solaar curl wget"
    local missing_packages=""
    
    for package in $packages; do
        if ! dpkg -l | grep -q "^ii.*$package "; then
            missing_packages="$missing_packages $package"
        fi
    done
    
    if [ -n "$missing_packages" ]; then
        echo "Installing missing packages:$missing_packages"
        if ! sudo apt install -y $missing_packages; then
            print_error "Failed to install repository software"
            exit 1
        fi
    else
        print_success "All required packages are already installed"
    fi
    
    print_success "Software from repositories installed successfully!"
    sleep 2
}

# ======================================================================
# EXTERNAL SOFTWARE INSTALLATION
# ======================================================================

install_google_chrome() {
    echo "Installing Google Chrome..."
    
    # Check if Chrome is already installed
    if command_exists google-chrome; then
        print_success "Google Chrome is already installed"
        return 0
    fi
    
    # Download Chrome
    if ! wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb; then
        print_error "Failed to download Google Chrome"
        return 1
    fi
    
    # Install Chrome
    if ! sudo dpkg -i /tmp/chrome.deb; then
        print_warning "dpkg installation failed, trying to fix dependencies"
        # Fix any dependency issues
        if ! sudo apt --fix-broken install -y; then
            print_error "Failed to fix Chrome dependencies"
            rm -f /tmp/chrome.deb
            return 1
        fi
    fi
    
    # Clean up
    rm -f /tmp/chrome.deb
    
    print_success "Google Chrome installed successfully!"
    return 0
}

install_vscode() {
    echo "Installing Visual Studio Code..."
    
    # Check if VS Code is already installed
    if command_exists code; then
        print_success "Visual Studio Code is already installed"
        return 0
    fi
    
    # Download VS Code
    if ! wget -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"; then
        print_error "Failed to download Visual Studio Code"
        return 1
    fi
    
    # Install VS Code
    if ! sudo dpkg -i /tmp/vscode.deb; then
        print_warning "dpkg installation failed, trying to fix dependencies"
        # Fix any dependency issues
        if ! sudo apt --fix-broken install -y; then
            print_error "Failed to fix VS Code dependencies"
            rm -f /tmp/vscode.deb
            return 1
        fi
    fi
    
    # Clean up
    rm -f /tmp/vscode.deb
    
    print_success "Visual Studio Code installed successfully!"
    return 0
}

install_uv() {
    echo "Installing UV for Python..."
    echo "Downloading UV setup script..."
    
    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
        print_error "Failed to install UV"
        return 1
    fi
    
    echo "Restarting shell..."
    if [ -f "$HOME/.local/bin/env" ]; then
        source "$HOME/.local/bin/env"
    else
        print_warning "UV environment file not found"
    fi
    
    print_success "UV installed successfully!"

    return 0
}

install_external_software() {
    echo "Continuing with the installation of external software..."
    echo "Installing external software..."
    
    local failed_installations=0
    
    if ! install_google_chrome; then
        ((failed_installations++))
        print_warning "Google Chrome installation failed but continuing"
    fi
    
    if ! install_vscode; then
        ((failed_installations++))
        print_warning "Visual Studio Code installation failed but continuing"
    fi
    
    if ! install_uv; then
        ((failed_installations++))
        print_warning "UV installation failed but continuing"
    fi
    
    if [ $failed_installations -eq 0 ]; then
        print_success "All external software installed successfully!"
    else
        print_warning "External software installation completed with $failed_installations failures"
    fi
}

# ======================================================================
# GIT AND SSH CONFIGURATION FUNCTIONS
# ======================================================================

configure_git() {
    echo "Continuing with Git configuration..."
    sleep 2
    echo "Starting Git configuration..."
    
    # Set default branch
    if ! git config --global init.defaultBranch main; then
        print_error "Failed to set default branch"
        return 1
    fi
    
    # Set user name
    if ! git config --global user.name "$git_username"; then
        print_error "Failed to set Git username"
        return 1
    fi
    
    # Set user email
    if ! git config --global user.email "$git_email"; then
        print_error "Failed to set Git email"
        return 1
    fi
    
    # Configure pull behavior (merge instead of rebase)
    if ! git config --global pull.rebase false; then
        print_error "Failed to set pull behavior"
        return 1
    fi
    
    # Configure push to automatically set up remote tracking
    if ! git config --global push.autoSetupRemote true; then
        print_error "Failed to set push auto setup remote"
        return 1
    fi
    
    print_success "Git configured successfully with:"
    echo "  Name: $git_username"
    echo "  Email: $git_email"
    echo "  Default branch: main"
    echo "  Pull strategy: merge (no rebase)"
    echo "  Push auto-setup: enabled"
    
    return 0
}

setup_ssh_key() {
    echo "Setting up SSH key..."
    
    # Create SSH directory if it doesn't exist
    if ! mkdir -p ~/.ssh; then
        print_error "Failed to create .ssh directory"
        return 1
    fi
    
    # Set proper permissions for .ssh directory
    if ! chmod 700 ~/.ssh; then
        print_error "Failed to set permissions for .ssh directory"
        return 1
    fi
    
    # Create SSH Key with the provided email, default location, and specific password
    if ! ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N "$ssh_password" -q; then
        print_error "Failed to create SSH key"
        return 1
    fi
    
    print_success "SSH key created successfully!"
    
    # Set proper permissions for SSH keys
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
    
    echo "Starting SSH agent..."
    eval "$(ssh-agent -s)"
    
    # Add the key to the agent
    if ! ssh-add ~/.ssh/id_ed25519; then
        print_error "Failed to add SSH key to agent"
        return 1
    fi
    
    print_success "SSH key added to agent successfully!"
    
    # Save the public key to a file
    if ! cat ~/.ssh/id_ed25519.pub > public_key.txt; then
        print_warning "Failed to save public key to file"
    else
        print_success "Public key saved to public_key.txt"
    fi
    
    echo "Your SSH public key (add this to GitHub/GitLab):"
    cat ~/.ssh/id_ed25519.pub
    
    return 0
}

# ======================================================================
# BASH CONFIGURATION
# ======================================================================

setup_bash_aliases() {
    echo "Continuing with the setup of bash aliases..."
    echo "You can see the list of all aliases documented in the README file"
    
    # Create .bash_aliases file
    cat > ~/.bash_aliases << 'EOL'
# Navigation
alias sls='ls -lavh'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System
alias upg='sudo apt update && sudo apt upgrade -y'
alias aptin='sudo apt install'
alias aptrm='sudo apt remove'
alias autorm='sudo apt autoremove'
alias cls='clear'
alias python='python3'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gsw='git switch'
alias glg='git log'

EOL

    # Asegurarse de que los cambios surtan efecto y evitar duplicados
    if ! grep -q "source ~/.bash_aliases" ~/.bashrc; then
        echo "source ~/.bash_aliases" >> ~/.bashrc
    fi

    print_success "Aliases configured successfully!"
    return 0
}

# ======================================================================
# MAIN FUNCTION
# ======================================================================

main() {
    # Welcome and initial checks
    show_welcome
    check_system
    request_sudo_permission
    collect_user_info
    
    # System updates and software installation
    update_system
    install_repository_software
    install_external_software
    
    # Git and SSH configuration
    local git_failed=0
    local ssh_failed=0
    
    if ! configure_git; then
        git_failed=1
        print_warning "Git configuration failed but continuing"
    fi
    
    if ! setup_ssh_key; then
        ssh_failed=1
        print_warning "SSH key setup failed but continuing"
    fi
    
    # Bash configuration
    if ! setup_bash_aliases; then
        print_warning "Bash aliases setup failed but continuing"
    fi
    
    echo "======================================================================================"
    if [ $git_failed -eq 0 ] && [ $ssh_failed -eq 0 ]; then
        print_success "Fully software installation and Git configuration completed successfully!"
    else
        print_warning "Installation completed with some configuration issues"
    fi
    echo "======================================================================================"
    echo "Next steps:"
    if [ $ssh_failed -eq 0 ]; then
        echo "1. Add your SSH public key to GitHub/GitLab (saved in public_key.txt)"
    else
        echo "1. SSH key setup failed - you may need to configure it manually"
    fi
    echo "2. Restart your terminal or run 'source ~/.bashrc' to load aliases"
    if [ $git_failed -eq 0 ]; then
        echo "3. Test your Git configuration with 'git config --list'"
    else
        echo "3. Git configuration failed - you may need to configure it manually"
    fi
    echo "======================================================================================"
}

# ======================================================================
# SCRIPT EXECUTION
# ======================================================================

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
