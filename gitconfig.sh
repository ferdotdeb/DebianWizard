#!/bin/bash

# ======================================================================
# Debian Auto-installer Script - Refactored Version by Claude Sonnet
# Author: ferdotdeb
# Description: Automated setup script for Debian-based systems
# ======================================================================

# Global variables
git_username=""
git_email=""
ssh_password=""

# ======================================================================
# UTILITY FUNCTIONS
# ======================================================================

show_welcome() {
    echo "Welcome to the ferdotdeb Debian auto-installer"
    sleep 2
}

check_system() {
    echo "Checking OS version..."
    sleep 2
    
    # Load variables of /etc/os-release file
    cat /etc/os-release
    source /etc/os-release
    
    echo "$NAME system detected"
    
    # Validate if the system is Debian/Ubuntu based
    echo "Validating system compatibility..."
    
    # Check if ID is debian or ubuntu directly
    if [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
        echo "✓ Compatible system detected: $NAME (ID: $ID)"
    # Check if ID_LIKE contains debian or ubuntu
    elif [[ "$ID_LIKE" =~ debian ]] || [[ "$ID_LIKE" =~ ubuntu ]]; then
        echo "✓ Compatible derivative system detected: $NAME (ID: $ID, based on: $ID_LIKE)"
    else
        echo "✗ ERROR: Incompatible system detected!"
        echo "This script only works on Debian, Ubuntu, or their derivatives."
        echo "Current system: $NAME (ID: $ID, ID_LIKE: $ID_LIKE)"
        echo "Exiting..."
        exit 1
    fi
    
    sleep 2
}

request_sudo_permission() {
    echo "Pre-requisites check..."
    echo "This will be the only non-automated part of the script"
    sleep 1
    
    echo "Please grant sudo permission to the script"
    sudo -v
    
    echo "Sudo permission granted!"
    sleep 2
}

validate_email() {
    local email=$1
    if [[ -z "$email" ]] || ! echo "$email" | grep -q '@'; then
        return 1
    fi
    return 0
}

collect_user_info() {
    echo "Please enter your personal information for Git configuration"
    
    # Get Git username
    echo -n "Enter your full name for Git installation: "
    read git_username
    while [ -z "$git_username" ]; do
        echo "The name cannot be empty"
        echo -n "Enter your full name for Git installation: "
        read git_username
    done
    
    # Get Git email with validation
    echo -n "Enter your email for Git installation: "
    read git_email
    while ! validate_email "$git_email"; do
        echo "Please enter a valid email address"
        echo -n "Enter your email for Git installation: "
        read git_email
    done
    
    # Get SSH password
    echo -n "Enter your password for SSH key generation: "
    read -s ssh_password # Flag -s for silent input
    echo # New line after silent input
    
    echo "Pre-requisites check completed!"
}

# ======================================================================
# SYSTEM UPDATE FUNCTIONS
# ======================================================================

update_system() {
    echo "Updating package list..."
    sudo apt update
    
    echo "Upgrading installed packages..."
    sudo apt upgrade -y
}

install_repository_software() {
    echo "Installing software from repositories..."
    sudo apt install -y vim git fastfetch openssh-client solaar xclip curl wget
    
    if [ $? -eq 0 ]; then
        echo "Software from repositories installed successfully!"
    else
        echo "Error installing repository software"
        exit 1
    fi
    sleep 2
}

# ======================================================================
# EXTERNAL SOFTWARE INSTALLATION FUNCTIONS
# ======================================================================

install_google_chrome() {
    echo "Installing Google Chrome..."
    
    # Download Chrome
    if ! wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb; then
        echo "Error downloading Google Chrome"
        return 1
    fi
    
    # Install Chrome
    sudo dpkg -i /tmp/chrome.deb
    
    # Fix any dependency issues
    sudo apt --fix-broken install -y
    
    # Clean up
    rm /tmp/chrome.deb
    
    echo "Google Chrome installed successfully!"
}

install_vscode() {
    echo "Installing Visual Studio Code..."
    
    # Download VS Code
    if ! wget -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"; then
        echo "Error downloading Visual Studio Code"
        return 1
    fi
    
    # Install VS Code
    sudo dpkg -i /tmp/vscode.deb
    
    # Fix any dependency issues
    sudo apt --fix-broken install -y
    
    # Clean up
    rm /tmp/vscode.deb
    
    echo "Visual Studio Code installed successfully!"
}

install_uv() {
    echo "Installing UV for Python..."
    echo "Downloading UV setup script..."
    
    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
        echo "Error installing UV"
        return 1
    fi
    
    echo "Restarting shell..."
    if [ -f "$HOME/.local/bin/env" ]; then
        source "$HOME/.local/bin/env"
    else
        echo "Warning: UV environment file not found"
    fi
    
    echo "UV installed successfully!"
}

install_external_software() {
    echo "Installing external software..."
    
    install_google_chrome
    install_vscode
    install_uv
    
    echo "External software installation completed!"
}

# ======================================================================
# GIT AND SSH CONFIGURATION FUNCTIONS
# ======================================================================

configure_git() {
    echo "Git autoconfiguration started"
    
    git config --global init.defaultBranch main
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    
    echo "Git configured successfully with:"
    echo "Name: $git_username"
    echo "Email: $git_email"
}

setup_ssh_key() {
    echo "Creating SSH key..."
    
    # Create SSH directory if it doesn't exist
    mkdir -p ~/.ssh
    
    # Create SSH Key with the provided email, default location, and specific password
    if ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N "$ssh_password" -q; then
        echo "SSH key created successfully!"
    else
        echo "Error creating SSH key"
        return 1
    fi
    
    echo "Starting SSH agent..."
    eval "$(ssh-agent -s)"
    
    # Add the key to the agent
    if ssh-add ~/.ssh/id_ed25519; then
        echo "SSH key added to agent successfully!"
    else
        echo "Error adding SSH key to agent"
        return 1
    fi
    
    # Show the public key
    echo "Your SSH public key (add this to GitHub/GitLab):"
    cat ~/.ssh/id_ed25519.pub > public_key.txt
    
    # Copy the key to the clipboard if xclip is installed
    if command -v xclip &> /dev/null; then
        cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
        echo "Public key copied to clipboard"
    fi
    
    echo "Finished setting up Git and SSH!"
}

# ======================================================================
# BASH CONFIGURATION FUNCTIONS
# ======================================================================

setup_bash_aliases() {
    echo "Setting up useful aliases..."
    
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
    alias install='sudo apt install'
    alias remove='sudo apt remove'
    alias cls='clear'

    # Git shortcuts
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit -m'
    alias gp='git push'
    alias gl='git pull'

    # Custom paths
    alias downloads='cd ~/Downloads'
    alias documents='cd ~/Documents'

    alias python='python3'
EOL
    
    # Add source command to .bashrc if not already present
    if ! grep -q "source ~/.bash_aliases" ~/.bashrc; then
        echo "source ~/.bash_aliases" >> ~/.bashrc
    fi
    
    echo "Aliases configured successfully!"
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
    configure_git
    setup_ssh_key
    
    # Bash configuration
    setup_bash_aliases
    
    echo "======================================================================"
    echo "Installation and configuration completed successfully!"
    echo "======================================================================"
    echo "Next steps:"
    echo "1. Add your SSH public key to GitHub/GitLab (saved in public_key.txt)"
    echo "2. Restart your terminal or run 'source ~/.bashrc' to load aliases"
    echo "3. Test your Git configuration with 'git config --list'"
    echo "======================================================================"
}

# ======================================================================
# SCRIPT EXECUTION
# ======================================================================

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
