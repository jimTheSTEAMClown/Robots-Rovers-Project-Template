#! /bin/bash
# ============================================================================
# Shell script to run first before installing apps on a Raspberry Pi 5 Ubuntu 24.04 image for STEAM robotics
# Source: STEAM Clown - www.steamclown.org
# GitHub: https://github.com/jimTheSTEAMClown/Linux
# Hacker: Jim Burnham - STEAM Clown, Engineer, Maker, Propmaster & Adrenologist
# This example code is licensed under the CC BY-NC-SA 4.0, GNU GPL and EUPL
# https://creativecommons.org/licenses/by-nc-sa/4.0/
# https://www.gnu.org/licenses/gpl-3.0.en.html
# https://eupl.eu/
#
# Program/Design Name:   Pi5-Ubuntu-24.04-Run-First.sh
# Description:           Shell script to let you do thinkgs like ifconfig, and stuff to be able to run the setup script
#
# Target Hardware:       Raspberry Pi 5 (ARM64 / aarch64)
# Target OS:             Ubuntu 24.04.x LTS (64-bit)
#
# Dependencies:          Run as a normal user with sudo privileges
#                        Must have internet access
#
# Revision:
#  Revision 0.01 - Initial Pi 5 STEAM Clown robotics setup
#  
# Steps:
#  STEP  1 - Update and Upgrade
#  STEP  2 - sudo apt install net-tools -y
#  STEP  3 - sudo apt install openssh-server -y
#  STEP  4 - make sure ssh is running
#  STEP  5 - 
#  STEP  6 - 
#  STEP  7 - 

#
# Usage:
#   chmod +x Pi5-Ubuntu-24.04-Run-First.sh
#   ./Pi5-Ubuntu-24.04-Run-First.sh
#
# References:
#   https://ubuntu.com/tutorials/how-to-install-ubuntu-on-raspberry-pi
#   https://gpiozero.readthedocs.io/en/stable/
#   https://docs.docker.com/engine/install/ubuntu/
#   https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
#   https://www.arduino.cc/en/software
#   https://docs.platformio.org/en/latest/core/installation/index.html
#   https://tigervnc.org/
# ============================================================================

# ============================================================================
# LOGGING SETUP
# All output goes to terminal AND to a timestamped log file in home directory.
# Uses 'tee' so you see everything live in the terminal while it is captured.
# Log file:  ~/pi5-Run-First-YYYYMMDD-HHMMSS.log
# ============================================================================
LOG_FILE="$HOME/pi5-Run-First-$(date +%Y%m%d-%H%M%S).log"

# Redirect all stdout and stderr through tee to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo "============================================================"
echo "  LOGGING ENABLED"
echo "  Log file: $LOG_FILE"
echo "  All terminal output is being saved to that file."
echo "============================================================"
echo " "

# ============================================================================
# PRE-FLIGHT BOOTSTRAP
# Install the bare minimum tools needed by this script itself BEFORE any
# prompted steps run. These are not guaranteed on a brand new Ubuntu 24.04
# Desktop image and are required for later steps to succeed.
#
#   curl             - Used in Steps 7, 11 to download keys and installers
#   wget             - Used in Step 10 to download Arduino IDE AppImage
#   gnupg            - Required by apt to verify the Docker GPG signing key
#   lsb-release      - Used by Docker repo setup to detect Ubuntu codename
#   ca-certificates  - Required for HTTPS apt repo connections
#   snapd            - Snap package manager; required for VS Code (Step 5)
#   python3-distutils - Required by PlatformIO get-platformio.py installer
#                       Removed from Python 3.12+ stdlib; must be installed
#                       separately on Ubuntu 24.04
#   xdg-desktop-portal-gnome - Required by gnome-remote-desktop for VNC
#                       sharing toggle to work in Settings > Sharing
# ============================================================================
echo " "
echo "============================================================"
echo "PRE-FLIGHT BOOTSTRAP"
echo "  Installing script dependencies on fresh Ubuntu 24.04..."
echo "  curl, wget, gnupg, lsb-release, ca-certificates,"
echo "  snapd, python3-distutils, xdg-desktop-portal-gnome"
echo "============================================================"
sudo apt update -qq
sudo apt install -y \
    net-tools \
    openssh-server
echo "  Pre-flight bootstrap complete"
echo " "

# ============================================================================
# ARCHITECTURE CHECK
# Confirms we are running on ARM64 (aarch64) as required for Pi 5.
# Warns and offers a bail-out if run on an x86 machine by mistake.
# ============================================================================
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
if [ "$ARCH" != "aarch64" ]; then
    echo "----------------------------------------------------"
    echo "WARNING: This script is designed for ARM64 (aarch64)"
    echo "You appear to be running on: $ARCH"
    echo "Some packages (Chromium, Arduino AppImage) may not work."
    echo "----------------------------------------------------"
    echo "Do you wish to continue anyway?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No  ) echo "Exiting."; exit 1;;
        esac
    done
fi

# ============================================================================
# HEADER BANNER
# ============================================================================
echo " "
echo "  ____  _  ____    ____  "
echo " (  _ \(_)( ___)  ( ___)  "
echo "  )___/ _  )__)    )__)   "
echo " (__) (_)(____)  (____)   "
echo "  ____  ____  ____   __   __  __  ____  ____  "
echo " (  _ \(  _ \(  _ \ / _) /  \(  )(_  _)/ ___) "
echo "  )   / ) _ ( ) _ (( (/\( () ))(__  )(  \___ \ "
echo " (__\_)(____/(____/ \__/ \__/(____)(__)  (____/ "
echo " "
echo "============================================================"
echo "  Raspberry Pi 5 Ubuntu 24.04 - STEAM Clown Run First Script"
echo "  Revision 0.01"
echo "  Target: Pi 5 / ARM64 / Ubuntu 24.04 LTS"
echo "  For: Fire Breathing Robots / Mechatronics Curriculum"
echo "  Log: $LOG_FILE"
echo "============================================================"
echo " "
pwd
ls
echo " "

# ============================================================================
# CONFIRM RUN
# ============================================================================
echo "----------------------------------------------------"
echo "Do you wish to run the Pi 5 Ubuntu Run First Script?"
echo "----------------------------------------------------"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
            echo "----------------------------------------------------"
            echo "Running Pi 5 Ubuntu Run First Script"
            echo "----------------------------------------------------"
            break;;
        No )
            echo "----------------------------------------------------"
            echo "Exiting Without Changes"
            echo "----------------------------------------------------"
            exit;;
    esac
done

# ============================================================================
# STEP 1 - UPDATE AND UPGRADE
# Always run this first on a fresh install to pull the latest package lists
# and apply all security patches before installing anything else.
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 1 - UPDATE AND UPGRADE"
echo "  Running: sudo apt update"
echo "  Running: sudo apt upgrade -y"
echo "============================================================"
echo "Do you wish to run UPDATE and UPGRADE? Enter y/Y or n/N"
read -p "Update and upgrade?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then
    echo " "
    cd ~
    pwd
    echo "----------------------------------------------------"
    echo "Running: sudo apt update"
    echo "----------------------------------------------------"
    sudo apt update

    echo " "
    echo "----------------------------------------------------"
    echo "Running: sudo apt upgrade -y"
    echo "----------------------------------------------------"
    sudo apt upgrade -y

    echo " "
    echo "----------------------------------------------------"
    echo "Done: UPDATE AND UPGRADE"
    echo "----------------------------------------------------"
else
    echo "Skipping UPDATE AND UPGRADE"
fi

# ============================================================================
# STEP 2 - NETWORKING TOOLS & SSh
# Foundational tools used by virtually every other install step SSH, file transfer, 
# network diagnostics, and navigation.
#
#   net-tools      - Provides 'ifconfig' for checking IP addresses
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 2 - CORE SYSTEM AND NETWORKING TOOLS"
echo "  Installing:"
echo "    - openssh-server (with ufw allow ssh)"
echo "    - net-tools (ifconfig)"
echo "============================================================"
echo "Do you wish to install these Run First tools? Enter y/Y or n/N"
read -p "Install core tools?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    
    echo " "
    echo "----------------------------------------------------"
    echo "Installing openssh-server - enables SSH into this Pi"
    echo "Running: sudo apt install openssh-server -y"
    echo "----------------------------------------------------"
    sudo apt install openssh-server -y
    sudo ufw --force enable
    sudo ufw allow ssh
    echo "  ufw enabled and SSH firewall rule added"

    echo " "
    echo "----------------------------------------------------"
    echo "Installing net-tools - provides ifconfig command"
    echo "Running: sudo apt install net-tools -y"
    echo "----------------------------------------------------"
    sudo apt install net-tools -y

    echo " "
    echo "----------------------------------------------------"
    echo "Done: SSH AND NETWORKING TOOLS"
    echo "----------------------------------------------------"
else
    echo "Skipping core tools install"
fi



# ============================================================================
# STEP 13 - VERIFY ALL INSTALLS
# Quick version check on all installed tools.
# Flags anything that is NOT FOUND so you know what to investigate.
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 13 - VERIFY ALL INSTALLS"
echo "============================================================"
echo " "

check_tool() {
    local tool=$1
    local version_flag=${2:---version}
    printf "  %-22s " "$tool:"
    if command -v "$tool" &>/dev/null; then
        echo "$($tool $version_flag 2>&1 | head -1)"
    else
        echo "NOT FOUND"
    fi
}

echo "--- Core Tools ---"
check_tool ssh -V
check_tool wget
check_tool ifconfig



echo " "
echo "--- Groups for $USER ---"
groups "$USER"

# ============================================================================
# DONE BANNER
# ============================================================================
echo " "
echo "  ____    __  _  _  ____  "
echo " (  _ \  /  \( \( )( ___) "
echo "  )(_) )( () ))  (  )__)  "
echo " (____/  \__/(_)\_)(____)  "
echo " "
echo "============================================================"
echo "  Done: Pi 5 Ubuntu 24.04 STEAM Clown Run First - Rev 0.01"
echo " "
echo "  Log file saved to:"
echo "  $LOG_FILE"
echo " "
echo "  REQUIRED MANUAL STEPS AFTER REBOOT:"
echo "  1. LOG OUT AND BACK IN"
echo " "
echo "  2. Run the Pi5-Tools script"
echo "  
echo "============================================================"
