# Debian Wizard

Debian Wizard is an automated setup script for fresh installations of Debian, Ubuntu, or their derivatives. It streamlines the post-installation process by updating the system, installing essential software from both official repositories and external sources, and configuring Git and SSH settings.

The purpose of this project is to provide users with a development environment that is ready to program, simply by running a script.

Taking advantage of the power of automation offered by Linux 🔥.

## Features ⚡

- **System Compatibility Check**: Ensures the script runs only on Debian-based systems (Debian or Ubuntu derivatives).
- **Automated System Update**: Update and upgrade all system packages for the installation, without the need to do it manually before running the script.
- **Software Installation**:
  - **From Repositories**: Install common utilities like `vim`, `git`, `curl`, `openssh-client` and more.
  - **External Software**: Install Google Chrome, Visual Studio Code, the `uv` Python package manager, and Docker with its official repository.
- **Git & GitHub Ready**:
  - **Git Configuration**: Configures your global Git username and email also establishes the default branch as main, using main aligns with modern Git hosting defaults (e.g., GitHub), avoids branch-name mismatches when pushing to remotes, and replaces the legacy master.
  - **SSH Configuration**: Generates a new `ed25519` SSH key, adds it to the `ssh-agent`, and after re-entering your passphrase manually, saves the public key for easy use on platforms like GitHub or GitLab.
- **Bash Aliases**: Sets up a collection of useful bash aliases to speed up common command-line tasks (Listed below).

## Prerequisites

- A fresh installation of a Debian-based operating system (e.g., Debian, Ubuntu, Linux Mint).
- Add user to the sudoers file.
- Super user privileges (sudo).
- Install wget (sudo apt install wget)
- Internet connectivity.

⚠️ Run the script on an operating system already configured at your own risk ⚠️

As it may modify system files and settings.

## How to Use

1. Download the script ⬇️:

    ```bash
    wget https://raw.githubusercontent.com/ferdotdeb/DebianWizard/main/debianWizard.sh
    ```

2. Make it executable ⚙️:

    ```bash
    chmod +x debianWizard.sh
    ```

3. Run the script 🚀:

    ```bash
    ./debianWizard.sh
    ```

The script will first ask for your name, email, and a password for the SSH key, this information will be used to configure Git and generate an SSH key.

After that, the rest of the process is fully automated.

## Function Documentation

This section provides a detailed breakdown of each function within the script.

### Main Function

`main()`: The entry point of the script. It calls all the other functions in the correct sequence to perform the complete setup process. It also provides a summary and next steps at the end of the execution.

### Print and Utility Functions

- `print_message(color, message)`: A core function to print messages to the console in different colors.
- `print_success(message)`: Prints a success message in green with a checkmark (✓).
- `print_error(message)`: Prints an error message in red with a cross (✗).
- `print_warning(message)`: Prints a warning message in yellow with a warning symbol (⚠).
- `command_exists(command)`: Checks if a specific command is available in the system's PATH.
- `check_internet()`: Verifies internet connectivity by pinging `8.8.8.8`.

### Initial Setup Function

- `show_welcome()`: Displays the initial welcome banner.
- `check_system()`: Reads the `/etc/os-release` file to verify that the operating system is Debian, Ubuntu, or a derivative. The script will exit if the system is not compatible.
- `request_sudo_permission()`: Prompts the user to grant `sudo` permissions, which are required for system-wide installations and updates.
- `validate_email(email)`: A helper function that uses a regular expression to check if the provided email address has a valid format.
- `collect_user_info()`: Interactively collects the user's full name and email for Git configuration, and a password for generating the SSH key.

### System and Software Installation Functions

- `update_system()`: Performs a full system update by running `sudo apt update` and `sudo apt upgrade -y`.
- `install_repository_software()`: Install a predefined list of essential packages from the default system repositories (`vim`, `git`, `fastfetch`, `openssh-client`, `solaar`, `curl`).
- `install_google_chrome()`: Downloads the `.deb` package for Google Chrome, install it using `dpkg`, and handles any potential dependency issues with `apt --fix-broken install`.
- `install_vscode()`: Downloads and install the latest stable version of Visual Studio Code for Debian-based systems.
- `install_uv()`: Install `uv`, a fast Python package manager from Astral, by executing its official installation script.
- `install_docker()`: Install Docker using the official Docker repository, for Debian and Ubuntu.
- `install_external_software()`: A wrapper function that calls the installers for Chrome, VS Code, `uv` and Docker. It is designed to continue even if one of the installations fails.

### Git Configuration Function

- `configure_git()`: Configures global Git settings, setting `init.defaultBranch` to `main` and using the name and email provided by the user.
- `setup_ssh_key()`:
    1. Creates an `ed25519` SSH key pair using the provided email.
    2. Sets the correct permissions (`700` for `~/.ssh` and `600` for the private key).
    3. Starts the `ssh-agent` and adds the new key.
    4. Saves the public key to `public_key.txt` in the current directory.
    5. Displays the public key.

### Setup Bash Aliases Function

This function creates a `~/.bash_aliases` file with a set of predefined aliases to enhance the user's command-line experience and is linked
in the `~/.bashrc` file.

The following list are all the aliases are created in the installation process:

| Alias  | Command                            | Description                                      |
| :----- | :--------------------------------- | :----------------------------------------------- |
| **Navigation** | | |
| `sls`  | `ls -lavh`                         | List files with details, in a human-readable format, i call this command super ls. |
| `ll`   | `ls -la`                           | List all files (including hidden) with details.  |
| `la`   | `ls -A`                            | List all files except `.` and `..`.              |
| `l`    | `ls -CF`                           | List files in columns, marking types.            |
| `..`   | `cd ..`                            | Go up one directory.                             |
| `...`  | `cd ../..`                         | Go up two directories.                           |
| `....` | `cd ../../..`                      | Go up three directories.                         |
| **System** | | |
| `upg`  | `sudo apt update && sudo apt upgrade -y` | Update and upgrade all system packages.    |
| `aptin`| `sudo apt install`                 | Shortcut for installing packages.              |
| `aptrm` | `sudo apt remove`                  | Shortcut for removing packages.                |
| `autorm`    | `sudo apt autoremove`               | Shortcut for removing unused packages.        |
| `cls`  | `clear`                            | Clear the terminal screen.                       |
| `python`| `python3`                          | Use `python3` when `python` is typed.           |
| `shutdown`| `systemctl poweroff`              | Shutdown the system.                             |
| `reboot`| `systemctl reboot`                 | Reboot the system.                               |
| **Git** | | |
| `gs`   | `git status`                       | Show the working tree status.                    |
| `ga`   | `git add`                          | Add file contents to the index.                  |
| `gc`   | `git commit -m`                    | Record changes to the repository with a message. |
| `gp`   | `git push`                         | Update remote refs along with associated objects.|
| `gpl`   | `git pull`                         | Fetch from and integrate with another repository.|
| `gsw`  | `git switch`                       | Switch branches.                                 |
| `glg`  | `git log`                          | Show commit logs.                                |

### Do you understand the code?

If you can read, and understand the code, great!
You can add or remove pieces of code, add or remove more software auto-installation functions, or modify existing ones.

Feel free to make a fork or submit a pull request.
