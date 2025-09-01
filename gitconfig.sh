#!/bin/bash

echo "Welcome to the ferdotdeb Debian auto-installer"
sleep 2

echo "Checking OS version..."
sleep 2

# Load variables of /etc/os-release file
cat /etc/os-release
source /etc/os-release

echo "$NAME system detected"

echo "Remember this script only works on Debian or Debian-based systems"
sleep 2

echo "Pre-requisites check..."
echo "This will be the only non-automated part of the script"
sleep 1

echo "Please grant sudo permission to the script"
sudo -v

echo "Sudo permission granted!"
sleep 2

echo "Please enter your personal information for Git configuration"
echo -n "Enter your full name for Git installation:"
read git_username
while [ -z "$git_username" ]; do
    echo "The name cannot be empty"
    echo -n "Enter your full name for Git installation: "
    read git_username
done

echo -n "Enter your email for Git installation:"
read git_email
while [ -z "$git_email" ] || ! echo "$git_email" | grep -q '@'; do
    echo "Please enter a valid email address"
    echo -n "Enter your email for Git installation: "
    read git_email
done

echo -n "Enter your password for SSH key generation:"
read -s ssh_password # Flag -s for silent input

echo "Pre-requisites check completed!"

echo "Updating package list..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt upgrade -y

echo "Installing software from repositories..."
sudo apt install -y vim git fastfetch openssh-client solaar xclip curl wget
echo "Software from repositories installed successfully!"
sleep 2

echo "Installing external software..."

# Install Google Chrome
echo "Installing Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo dpkg -i /tmp/chrome.deb
# Fix any dependency issues
sudo apt --fix-broken install -y
# Clean up
rm /tmp/chrome.deb
echo "Google Chrome installed successfully!"

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
wget -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo dpkg -i /tmp/vscode.deb
# Fix any dependency issues
sudo apt --fix-broken install -y
# Clean up
rm /tmp/vscode.deb
echo "Visual Studio Code installed successfully!"

# Install UV for python
echo "Downloading UV setup script..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# Check if the installation was successful
if [ $? -ne 0 ]; then
    echo "Error installing UV"
    exit 1
fi

echo "Restarting shell..."
if [ -f "$HOME/.local/bin/env" ]; then
    source $HOME/.local/bin/env
else
    echo "Warning: UV environment file not found"
fi

echo "Git autoconfiguration started"

git config --global init.defaultBranch main
git config --global user.name "$git_username"
git config --global user.email "$git_email"

echo "Git configured successfully with:"
echo "Name: $git_username"
echo "Email: $git_email"

# Create SSH Key automatically
echo "Creating SSH key..."

# Create SSH Key with the provided email, default location, and specific password
ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N "$ssh_password" -q
echo "SSH key created successfully!"

echo "Starting SSH agent..."
eval "$(ssh-agent -s)"

# Add the key to the agent
ssh-add ~/.ssh/id_ed25519

# Show the public key
echo "Your SSH public key (add this to GitHub/GitLab):"
cat ~/.ssh/id_ed25519.pub > public_key.txt

# Optionally, copy the key to the clipboard if xclip is installed
if command -v xclip &> /dev/null; then
    cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
    echo "Public key copied to clipboard"
fi

echo "Finished setting up Git and SSH!"



# Configure Bash aliases
echo "Setting up useful aliases..."

# Create .bash_aliases file or append to it if it exists
cat > ~/.bash_aliases << 'EOL'
# Navigation
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'# Configure Bash aliases
echo "Setting up useful aliases..."

# Create .bash_aliases file or append to it if it exists
cat > ~/.bash_aliases << 'EOL'
# Navigation
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'# Configure Bash aliases
echo "Setting up useful aliases..."

# Create .bash_aliases file or append to it if it exists
cat > ~/.bash_aliases << 'EOL'
# Navigation
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System
alias update='sudo apt update && sudo apt upgrade -y'
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
EOL

# Asegurarse de que los cambios surtan efecto
echo "source ~/.bash_aliases" >> ~/.bashrc

echo "Aliases configured successfully!"
alias remove='sudo apt remove'
alias cls='clear'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'# Configure Bash aliases
echo "Setting up useful aliases..."

# Create .bash_aliases file or append to it if it exists
cat > ~/.bash_aliases << 'EOL'
# Navigation
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System
alias update='sudo apt update && sudo apt upgrade -y'
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
EOL

# Asegurarse de que los cambios surtan efecto
echo "source ~/.bash_aliases" >> ~/.bashrc

echo "Aliases configured successfully!"
alias gp='git push'
alias gl='git pull'

# Custom paths
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'
EOL

# Asegurarse de que los cambios surtan efecto
echo "source ~/.bash_aliases" >> ~/.bashrc

echo "Aliases configured successfully!"
alias ...='cd ../..'
alias ....='cd ../../..'

# System
alias update='sudo apt update && sudo apt upgrade -y'
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
EOL

# Asegurarse de que los cambios surtan efecto
echo "source ~/.bash_aliases" >> ~/.bashrc

echo "Aliases configured successfully!"