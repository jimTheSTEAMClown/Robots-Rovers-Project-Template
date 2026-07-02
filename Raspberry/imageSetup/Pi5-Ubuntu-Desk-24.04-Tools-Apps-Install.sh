#! /bin/bash
# ============================================================================
# Shell script to set up a Raspberry Pi 5 Ubuntu 24.04 image for STEAM robotics
# Source: STEAM Clown - www.steamclown.org
# GitHub: https://github.com/jimTheSTEAMClown/Linux
# Hacker: Jim Burnham - STEAM Clown, Engineer, Maker, Propmaster & Adrenologist
# This example code is licensed under the CC BY-NC-SA 4.0, GNU GPL and EUPL
# https://creativecommons.org/licenses/by-nc-sa/4.0/
# https://www.gnu.org/licenses/gpl-3.0.en.html
# https://eupl.eu/
#
# Program/Design Name:   Pi5-Ubuntu-24.04-New-Clean-Install.sh
# Description:           Shell script to configure a fresh Ubuntu 24.04 install
#                        on a Raspberry Pi 5 for STEAM/Robotics/Mechatronics use.
#                        Installs dev tools, Python libraries, GPIO support,
#                        I2C/serial tools, Docker, nmap, Chromium, VS Code,
#                        Thonny, VNC, Arduino IDE 2.x, PlatformIO, and more.
#                        All output is logged to ~/pi5-install-<timestamp>.log
#                        while also displaying in the terminal (tee).
#
# Target Hardware:       Raspberry Pi 5 (ARM64 / aarch64)
# Target OS:             Ubuntu 24.04.x LTS (64-bit)
#
# Dependencies:          Run as a normal user with sudo privileges
#                        Must have internet access
#
# Revision:
#  Revision 0.01 - Initial Pi 5 STEAM Clown robotics setup
#  Revision 0.02 - Added Docker, nmap, VNC (TigerVNC), Arduino IDE 2.x,
#                  PlatformIO, esptool, minicom, neofetch, cheese,
#                  git global config, and full verify step
#  Revision 0.03 - Dependency audit fixes for fresh Ubuntu 24.04 Desktop:
#                  Added pre-flight bootstrap (curl, wget, gnupg, snapd,
#                  python3-distutils, lsb-release, xdg-desktop-portal-gnome)
#                  Added ufw enable before allow ssh
#                  Added snapd readiness wait before VS Code snap install
#
# Steps:
#  STEP  1 - Update and Upgrade
#  STEP  2 - Core System and Networking Tools
#  STEP  3 - Python Tools
#  STEP  4 - Hardware, GPIO, I2C, Serial, and ESP Tools
#  STEP  5 - Text Editors and IDEs
#  STEP  6 - Web Browser (Chromium ARM64)
#  STEP  7 - Docker and Docker Compose
#  STEP  8 - GNOME Desktop Tweaks + neofetch
#  STEP  9 - VNC Remote Desktop (gnome-remote-desktop + TigerVNC Viewer)
#  STEP 10 - Arduino IDE 2.x (ARM64 AppImage)
#  STEP 11 - PlatformIO (VS Code extension + CLI + udev rules)
#  STEP 12 - Git Global Config (interactive name/email setup)
#  STEP 13 - Verify All Installs
#
# Usage:
#   chmod +x Pi5-Ubuntu-24.04-New-Clean-Install.sh
#   ./Pi5-Ubuntu-24.04-New-Clean-Install.sh
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
# Log file:  ~/pi5-install-YYYYMMDD-HHMMSS.log
# ============================================================================
LOG_FILE="$HOME/pi5-install-$(date +%Y%m%d-%H%M%S).log"

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
    curl \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    snapd \
    python3-distutils \
    xdg-desktop-portal-gnome
echo "  Pre-flight bootstrap complete"
echo " "

# Ensure snapd is fully initialized before any snap commands run later
echo "  Waiting for snapd to be ready..."
sudo systemctl enable snapd
sudo systemctl start snapd
sudo snap wait system seed.loaded
echo "  snapd is ready"
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
echo "  Raspberry Pi 5 Ubuntu 24.04 - STEAM Clown Setup Script"
echo "  Revision 0.03"
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
echo "Do you wish to run the Pi 5 Ubuntu Setup Script?"
echo "----------------------------------------------------"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
            echo "----------------------------------------------------"
            echo "Running Pi 5 Ubuntu Setup Script"
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
# STEP 2 - CORE SYSTEM AND NETWORKING TOOLS
# Foundational tools used by virtually every other install step and for
# day-to-day SSH, file transfer, network diagnostics, and navigation.
#
#   curl           - Command-line URL tool; downloads files and calls APIs
#   git            - Version control; clones repos and manages curriculum files
#   openssh-server - Enables SSH access to the Pi from laptops/desktops
#   net-tools      - Provides 'ifconfig' for checking IP addresses
#   htop           - Interactive process/resource viewer; better than 'ps aux'
#   tree           - Displays directory structure as a visual tree
#   wget           - Downloads files from the web via command line
#   nmap           - Network scanner; finds Pi/Arduino/ESP IPs on local network
#                    Use: nmap -sn 192.168.1.0/24  to scan your subnet
#   minicom        - Serial terminal for debugging Arduino/ESP over USB UART
#                    Use: minicom -D /dev/ttyUSB0 -b 115200
#   neofetch       - Prints system info banner (distro, CPU, RAM, etc.)
#                    Fun for students to see Pi 5 specs; great for screenshots
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 2 - CORE SYSTEM AND NETWORKING TOOLS"
echo "  Installing:"
echo "    - curl"
echo "    - git"
echo "    - openssh-server (with ufw allow ssh)"
echo "    - net-tools (ifconfig)"
echo "    - htop"
echo "    - tree"
echo "    - wget"
echo "    - nmap  (network scanner)"
echo "    - minicom (serial terminal for Arduino/ESP debugging)"
echo "    - neofetch (system info banner)"
echo "============================================================"
echo "Do you wish to install core tools? Enter y/Y or n/N"
read -p "Install core tools?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Installing curl - command-line URL and download tool"
    echo "Running: sudo apt install curl -y"
    echo "----------------------------------------------------"
    sudo apt install curl -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing git - version control system"
    echo "Running: sudo apt install git -y"
    echo "----------------------------------------------------"
    sudo apt install git -y

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
    echo "Installing htop - interactive process and resource viewer"
    echo "Running: sudo apt install htop -y"
    echo "----------------------------------------------------"
    sudo apt install htop -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing tree - visual directory structure display"
    echo "Running: sudo apt install tree -y"
    echo "----------------------------------------------------"
    sudo apt install tree -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing wget - command-line file downloader"
    echo "Running: sudo apt install wget -y"
    echo "----------------------------------------------------"
    sudo apt install wget -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing nmap - network scanner"
    echo "  Scan local network: nmap -sn 192.168.1.0/24"
    echo "  Find Pi/Arduino/ESP device IPs on the lab network"
    echo "Running: sudo apt install nmap -y"
    echo "----------------------------------------------------"
    sudo apt install nmap -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing minicom - serial terminal emulator"
    echo "  Debug Arduino/ESP serial output over USB"
    echo "  Usage: minicom -D /dev/ttyUSB0 -b 115200"
    echo "  Exit minicom: Ctrl+A then X"
    echo "Running: sudo apt install minicom -y"
    echo "----------------------------------------------------"
    sudo apt install minicom -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing neofetch - system info banner"
    echo "  Displays distro, CPU, RAM, and Pi 5 specs"
    echo "  Run: neofetch"
    echo "Running: sudo apt install neofetch -y"
    echo "----------------------------------------------------"
    sudo apt install neofetch -y

    echo " "
    echo "----------------------------------------------------"
    echo "Done: CORE SYSTEM AND NETWORKING TOOLS"
    echo "----------------------------------------------------"
else
    echo "Skipping core tools install"
fi

# ============================================================================
# STEP 3 - PYTHON TOOLS
# Python is the primary language for Pi robotics and student curriculum.
#
#   python3-pip    - Python package manager
#                    NOTE: Ubuntu 24.04 uses PEP 668 externally-managed env.
#                    Use '--break-system-packages' when running pip directly,
#                    or prefer apt-installed python3-* packages where available.
#   python3-venv   - Virtual environment support; best practice for pip installs
#   python3-dev    - Python C headers; required by some native pip packages
#   build-essential - gcc/g++/make; required for compiling native Python modules
#                     and by PlatformIO toolchain (installed in Step 11)
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 3 - PYTHON TOOLS"
echo "  Installing:"
echo "    - python3-pip    (pip package manager)"
echo "    - python3-venv   (virtual environment support)"
echo "    - python3-dev    (Python C headers for native packages)"
echo "    - build-essential (gcc/make toolchain)"
echo "  NOTE: Ubuntu 24.04 PEP 668 - prefer apt python3-* packages"
echo "        or use venv / '--break-system-packages' with pip"
echo "============================================================"
echo "Do you wish to install Python tools? Enter y/Y or n/N"
read -p "Install Python tools?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Installing python3-pip - Python 3 package manager"
    echo "Running: sudo apt install python3-pip -y"
    echo "----------------------------------------------------"
    sudo apt install python3-pip -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing python3-venv - Python virtual environments"
    echo "Running: sudo apt install python3-venv -y"
    echo "----------------------------------------------------"
    sudo apt install python3-venv -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing python3-dev - Python C headers"
    echo "  Required by some pip packages that compile native code"
    echo "Running: sudo apt install python3-dev -y"
    echo "----------------------------------------------------"
    sudo apt install python3-dev -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing build-essential - gcc/g++/make toolchain"
    echo "  Required for compiling native Python modules"
    echo "  Also required by PlatformIO firmware toolchain (Step 11)"
    echo "Running: sudo apt install build-essential -y"
    echo "----------------------------------------------------"
    sudo apt install build-essential -y

    echo " "
    echo "----------------------------------------------------"
    echo "Done: PYTHON TOOLS"
    echo "----------------------------------------------------"
    python3 -V
    pip3 -V
else
    echo "Skipping Python tools install"
fi

# ============================================================================
# STEP 4 - HARDWARE, GPIO, I2C, SERIAL, AND ESP TOOLS
# Enables Python control of GPIO pins, I2C bus, SPI, UART serial ports,
# and flashing of ESP32/ESP8266 devices — all essential for rover projects.
#
#   python3-gpiozero  - High-level GPIO library; preferred for student code
#                       Simple safe API: LED("GPIO17"), Motor(4,14), etc.
#                       Docs: https://gpiozero.readthedocs.io
#   pigpio            - Low-level GPIO daemon; provides precise hardware PWM
#                       Required as the gpiozero PWM backend on Pi 5
#                       Docs: https://abyz.me.uk/rpi/pigpio/
#   python3-pigpio    - Python bindings for the pigpio daemon
#   python3-serial    - PySerial; UART/serial comms with Arduino, GPS, BT, etc.
#                       Docs: https://pyserial.readthedocs.io
#   python3-smbus     - I2C bus access for sensors (IMU, OLED, ADC, etc.)
#   i2c-tools         - CLI I2C utilities: i2cdetect, i2cdump, i2cget, i2cset
#                       Use: i2cdetect -y 1  to scan for connected I2C devices
#   esptool           - Flashes firmware to ESP32/ESP8266 boards from Pi
#                       Use: esptool.py --port /dev/ttyUSB0 flash_id
#                       Docs: https://docs.espressif.com/projects/esptool
#   cheese            - Webcam viewer; useful for rover camera testing
#                       Docs: https://wiki.gnome.org/Apps/Cheese
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 4 - HARDWARE, GPIO, I2C, SERIAL, AND ESP TOOLS"
echo "  Installing:"
echo "    - python3-gpiozero (high-level GPIO; preferred for students)"
echo "    - pigpio + python3-pigpio (GPIO daemon + precise PWM)"
echo "    - python3-serial (PySerial; UART/serial comms)"
echo "    - python3-smbus  (I2C sensor access)"
echo "    - i2c-tools      (i2cdetect and I2C CLI utilities)"
echo "    - esptool        (flash ESP32/ESP8266 from Pi)"
echo "    - cheese         (webcam viewer for rover cameras)"
echo "  Also: adds user to gpio, i2c, and dialout groups"
echo "============================================================"
echo "Do you wish to install hardware/GPIO/serial tools? Enter y/Y or n/N"
read -p "Install hardware tools?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Installing python3-gpiozero"
    echo "  High-level GPIO library; great for student rover code"
    echo "  Example: from gpiozero import Motor, LED, Button"
    echo "  Docs: https://gpiozero.readthedocs.io"
    echo "Running: sudo apt install python3-gpiozero -y"
    echo "----------------------------------------------------"
    sudo apt install python3-gpiozero -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing pigpio and python3-pigpio"
    echo "  Low-level GPIO daemon providing precise hardware PWM"
    echo "  Required as the gpiozero PWM backend on Pi 5"
    echo "  Docs: https://abyz.me.uk/rpi/pigpio/"
    echo "Running: sudo apt install pigpio python3-pigpio -y"
    echo "----------------------------------------------------"
    sudo apt install pigpio python3-pigpio -y

    echo "  Enabling pigpiod to start automatically at boot..."
    sudo systemctl enable pigpiod
    sudo systemctl start pigpiod
    echo "  pigpiod service enabled and started"

    echo " "
    echo "----------------------------------------------------"
    echo "Installing python3-serial (PySerial)"
    echo "  UART/serial comms with Arduino, GPS, Bluetooth modules"
    echo "  Example: ser = serial.Serial('/dev/ttyUSB0', 115200)"
    echo "  Docs: https://pyserial.readthedocs.io"
    echo "Running: sudo apt install python3-serial -y"
    echo "----------------------------------------------------"
    sudo apt install python3-serial -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing python3-smbus - I2C bus access library"
    echo "  Communicates with I2C sensors: IMU, OLED display, ADC, etc."
    echo "Running: sudo apt install python3-smbus -y"
    echo "----------------------------------------------------"
    sudo apt install python3-smbus -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing i2c-tools - command-line I2C scan utilities"
    echo "  Scan I2C bus: i2cdetect -y 1"
    echo "  Read register: i2cget -y 1 0x68 0x00"
    echo "Running: sudo apt install i2c-tools -y"
    echo "----------------------------------------------------"
    sudo apt install i2c-tools -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing esptool - ESP32/ESP8266 firmware flash tool"
    echo "  Flash firmware: esptool.py --port /dev/ttyUSB0 write_flash ..."
    echo "  Check chip:     esptool.py --port /dev/ttyUSB0 flash_id"
    echo "  Docs: https://docs.espressif.com/projects/esptool"
    echo "Running: sudo apt install esptool -y"
    echo "----------------------------------------------------"
    sudo apt install esptool -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing cheese - webcam viewer"
    echo "  Test and view USB or CSI cameras attached to rover"
    echo "  Docs: https://wiki.gnome.org/Apps/Cheese"
    echo "Running: sudo apt install cheese -y"
    echo "----------------------------------------------------"
    sudo apt install cheese -y

    echo " "
    echo "----------------------------------------------------"
    echo "Adding $USER to hardware access groups"
    echo "  gpio    - GPIO pin access"
    echo "  i2c     - I2C bus access"
    echo "  dialout - serial/USB port write access for uploads"
    echo "  plugdev - USB device access"
    echo "  NOTE: Log out and back in for group changes to take effect"
    echo "----------------------------------------------------"
    sudo usermod -aG gpio "$USER"
    sudo usermod -aG i2c "$USER"
    sudo usermod -aG dialout "$USER"
    sudo usermod -aG plugdev "$USER"
    echo "  User $USER added to gpio, i2c, dialout, plugdev groups"

    echo " "
    echo "----------------------------------------------------"
    echo "Done: HARDWARE, GPIO, I2C, SERIAL, AND ESP TOOLS"
    echo "----------------------------------------------------"
else
    echo "Skipping hardware/GPIO/serial tools install"
fi

# ============================================================================
# STEP 5 - TEXT EDITORS AND IDEs
# A range of editors from beginner-friendly to professional.
#
#   vim      - Classic terminal text editor; essential for SSH config editing
#   thonny   - Beginner Python IDE with built-in debugger and variable
#              inspector; ideal for student first steps with Pi GPIO
#              Docs: https://thonny.org
#   code     - Visual Studio Code via snap; professional cross-platform IDE
#              Used for Python, C++, ROS2, web dev, and curriculum authoring
#              ARM64 snap works natively on Pi 5
#              Docs: https://code.visualstudio.com
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 5 - TEXT EDITORS AND IDEs"
echo "  Installing:"
echo "    - vim    (terminal text editor)"
echo "    - thonny (beginner Python IDE for students)"
echo "    - VS Code via snap (professional IDE)"
echo "============================================================"
echo "Do you wish to install editors and IDEs? Enter y/Y or n/N"
read -p "Install editors/IDEs?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Installing vim - terminal-based text editor"
    echo "  Essential for editing config files over SSH"
    echo "Running: sudo apt install vim -y"
    echo "----------------------------------------------------"
    sudo apt install vim -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing Thonny - beginner Python IDE"
    echo "  Simple UI, built-in step debugger, variable inspector"
    echo "  Supports MicroPython for microcontrollers"
    echo "  Docs: https://thonny.org"
    echo "Running: sudo apt install thonny -y"
    echo "----------------------------------------------------"
    sudo apt install thonny -y

    echo " "
    echo "----------------------------------------------------"
    echo "Installing Visual Studio Code via snap"
    echo "  Professional IDE for Python, C++, ROS2, web dev"
    echo "  PlatformIO and other extensions install in Step 11"
    echo "  ARM64 snap version runs natively on Pi 5"
    echo "  snapd was initialized in pre-flight bootstrap"
    echo "  Docs: https://code.visualstudio.com"
    echo "Running: sudo snap install --classic code"
    echo "----------------------------------------------------"
    sudo snap install --classic code

    echo " "
    echo "----------------------------------------------------"
    echo "Done: TEXT EDITORS AND IDEs"
    echo "----------------------------------------------------"
else
    echo "Skipping editors/IDEs install"
fi

# ============================================================================
# STEP 6 - WEB BROWSER (CHROMIUM - ARM64)
# Google Chrome does NOT have an ARM64 Linux build.
# Chromium is the correct open-source ARM64 browser for Ubuntu on Pi 5.
# It is functionally identical to Chrome for student browsing and web-based
# curriculum tools.
#
#   chromium-browser - Open-source Chromium browser; ARM64 native
#                      Replaces Google Chrome on Pi 5
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 6 - WEB BROWSER (CHROMIUM - ARM64)"
echo "  Installing:"
echo "    - chromium-browser (ARM64 native; replaces Google Chrome)"
echo "  NOTE: Google Chrome amd64 .deb will NOT install on Pi 5 ARM64"
echo "============================================================"
echo "Do you wish to install Chromium? Enter y/Y or n/N"
read -p "Install Chromium?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Installing chromium-browser"
    echo "  ARM64 native open-source browser; Chrome equivalent for Pi"
    echo "  Google Chrome amd64 .deb does not work on ARM64"
    echo "Running: sudo apt install chromium-browser -y"
    echo "----------------------------------------------------"
    sudo apt install chromium-browser -y

    echo " "
    echo "----------------------------------------------------"
    echo "Done: WEB BROWSER"
    echo "----------------------------------------------------"
else
    echo "Skipping Chromium install"
fi

# ============================================================================
# STEP 7 - DOCKER AND DOCKER COMPOSE
# Docker runs containerized applications without affecting the base OS.
# Useful for running ROS2 nodes, isolated student dev environments,
# web servers, databases, and other services in clean containers.
#
# IMPORTANT: The Ubuntu apt package 'docker.io' is outdated.
# This step installs Docker CE (Community Edition) from the official
# Docker apt repository — the correct production-grade install for ARM64.
#
#   docker-ce            - Docker Community Edition engine
#   docker-ce-cli        - Docker command-line interface
#   containerd.io        - Container runtime used by Docker
#   docker-buildx-plugin - Multi-platform image build support
#   docker-compose-plugin- 'docker compose' command (v2 plugin)
#
# References:
#   https://docs.docker.com/engine/install/ubuntu/
#   https://docs.docker.com/compose/
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 7 - DOCKER AND DOCKER COMPOSE"
echo "  Installing Docker CE from official Docker apt repository"
echo "  (NOT docker.io from Ubuntu repos - that version is outdated)"
echo "  Installing:"
echo "    - docker-ce + docker-ce-cli + containerd.io"
echo "    - docker-buildx-plugin"
echo "    - docker-compose-plugin (docker compose v2)"
echo "  Also: adds user to docker group (run docker without sudo)"
echo "  Docs: https://docs.docker.com/engine/install/ubuntu/"
echo "============================================================"
echo "Do you wish to install Docker? Enter y/Y or n/N"
read -p "Install Docker?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Removing any old/conflicting Docker packages"
    echo "----------------------------------------------------"
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 \
                podman-docker containerd runc; do
        sudo apt remove "$pkg" -y 2>/dev/null || true
    done

    echo " "
    echo "----------------------------------------------------"
    echo "Installing Docker apt repo prerequisites"
    echo "Running: sudo apt install ca-certificates curl -y"
    echo "----------------------------------------------------"
    sudo apt install ca-certificates curl -y

    echo " "
    echo "----------------------------------------------------"
    echo "Adding Docker official GPG key"
    echo "----------------------------------------------------"
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo " "
    echo "----------------------------------------------------"
    echo "Adding Docker apt repository for ARM64"
    echo "----------------------------------------------------"
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update

    echo " "
    echo "----------------------------------------------------"
    echo "Installing Docker CE and Docker Compose plugin"
    echo "Running: sudo apt install docker-ce docker-ce-cli containerd.io"
    echo "                         docker-buildx-plugin docker-compose-plugin -y"
    echo "----------------------------------------------------"
    sudo apt install docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin -y

    echo " "
    echo "----------------------------------------------------"
    echo "Adding $USER to docker group"
    echo "  Allows running 'docker' commands without sudo"
    echo "  NOTE: Log out and back in for group change to take effect"
    echo "----------------------------------------------------"
    sudo usermod -aG docker "$USER"
    echo "  User $USER added to docker group"

    echo " "
    echo "----------------------------------------------------"
    echo "Enabling Docker service to start at boot"
    echo "----------------------------------------------------"
    sudo systemctl enable docker
    sudo systemctl start docker

    echo " "
    echo "----------------------------------------------------"
    echo "Verifying Docker install"
    echo "----------------------------------------------------"
    docker --version
    docker compose version

    echo " "
    echo "----------------------------------------------------"
    echo "Done: DOCKER AND DOCKER COMPOSE"
    echo "----------------------------------------------------"
else
    echo "Skipping Docker install"
fi

# ============================================================================
# STEP 8 - GNOME DESKTOP TWEAKS AND NEOFETCH
# Quality-of-life GNOME settings for a classroom or lab Pi.
# Prevents the screen from locking during student demos or long compiles.
# neofetch auto-runs at terminal open to show Pi 5 specs to students.
#
#   idle-delay   - Seconds before screensaver activates (0 = never)
#   lock-delay   - Seconds after screensaver before screen locks
#   neofetch     - System info banner; added to ~/.bashrc for auto-display
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 8 - GNOME DESKTOP TWEAKS AND NEOFETCH"
echo "  Applying:"
echo "    - Extend idle/screensaver delay (classroom demo friendly)"
echo "    - Extend screen lock delay"
echo "    - Add neofetch to ~/.bashrc (auto-shows Pi 5 specs on terminal open)"
echo "============================================================"
echo "Do you wish to apply GNOME tweaks and neofetch? Enter y/Y or n/N"
read -p "Apply GNOME tweaks?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Setting GNOME idle delay to 800 seconds (~13 min)"
    echo "Running: gsettings set org.gnome.desktop.session idle-delay 800"
    echo "----------------------------------------------------"
    gsettings set org.gnome.desktop.session idle-delay 800

    echo " "
    echo "----------------------------------------------------"
    echo "Setting GNOME screen lock delay to 900 seconds (15 min)"
    echo "Running: gsettings set org.gnome.desktop.screensaver lock-delay 900"
    echo "----------------------------------------------------"
    gsettings set org.gnome.desktop.screensaver lock-delay 900

    echo " "
    echo "----------------------------------------------------"
    echo "Adding neofetch to ~/.bashrc"
    echo "  Displays Pi 5 system specs each time a terminal opens"
    echo "  Remove later by deleting the neofetch line from ~/.bashrc"
    echo "----------------------------------------------------"
    if ! grep -q 'neofetch' "$HOME/.bashrc"; then
        echo '' >> "$HOME/.bashrc"
        echo '# Show system info on terminal open' >> "$HOME/.bashrc"
        echo 'neofetch' >> "$HOME/.bashrc"
        echo "  neofetch added to ~/.bashrc"
    else
        echo "  neofetch already in ~/.bashrc, skipping"
    fi

    echo " "
    echo "----------------------------------------------------"
    echo "Done: GNOME DESKTOP TWEAKS AND NEOFETCH"
    echo "----------------------------------------------------"
else
    echo "Skipping GNOME tweaks"
fi

# ============================================================================
# STEP 9 - VNC REMOTE DESKTOP
# Enables viewing and controlling the Pi desktop from Windows or Linux
# laptops over the network.
#
# SERVER (on the Pi):
#   gnome-remote-desktop - Built-in Ubuntu 24.04 VNC/RDP server.
#                          Shows your actual logged-in GNOME desktop
#                          (not a separate virtual session like TigerVNC server).
#                          Enable after install via:
#                          Settings > Sharing > Remote Desktop
#                          Set a VNC password in the same settings panel.
#
# CLIENT (on your Windows/Linux laptop - install separately):
#   TigerVNC Viewer      - Fully open-source VNC client; lightweight,
#                          fast, works on Windows and Linux.
#                          Download: https://tigervnc.org/
#   RealVNC Viewer       - Free (not open source) VNC client; most
#                          polished UI for Windows users.
#                          Download: https://www.realvnc.com/en/connect/download/viewer/
#
# CONNECT: After enabling on Pi, connect from laptop using:
#   vnc://<pi-ip-address>:5900
#   Find Pi IP with: ip addr   or   nmap -sn 192.168.x.0/24
#
# References:
#   https://ubuntu.com/tutorials/access-remote-desktop
#   https://tigervnc.org/
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 9 - VNC REMOTE DESKTOP"
echo "  Installing on Pi (server):"
echo "    - gnome-remote-desktop (built-in Ubuntu VNC/RDP server)"
echo "      Shows your actual GNOME desktop to remote clients"
echo " "
echo "  VNC CLIENT (install on your Windows/Linux laptop separately):"
echo "    - TigerVNC Viewer (open source): https://tigervnc.org/"
echo "    - RealVNC Viewer  (free):        https://www.realvnc.com/en/connect/download/viewer/"
echo " "
echo "  After install: Settings > Sharing > Remote Desktop > Enable"
echo "  Connect from laptop: vnc://<pi-ip-address>:5900"
echo "============================================================"
echo "Do you wish to install gnome-remote-desktop? Enter y/Y or n/N"
read -p "Install VNC Remote Desktop?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Installing gnome-remote-desktop"
    echo "  Enables VNC and RDP access to Pi desktop"
    echo "  Shows the actual logged-in GNOME session to remote clients"
    echo "  xdg-desktop-portal-gnome was installed in pre-flight bootstrap"
    echo "  (required for the VNC sharing toggle to work in Settings)"
    echo "  Docs: https://ubuntu.com/tutorials/access-remote-desktop"
    echo "Running: sudo apt install gnome-remote-desktop -y"
    echo "----------------------------------------------------"
    sudo apt install gnome-remote-desktop -y

    echo " "
    echo "----------------------------------------------------"
    echo "Done: VNC REMOTE DESKTOP"
    echo " "
    echo "  IMPORTANT - Manual steps required after this script:"
    echo "  1. Open Settings > Sharing > Remote Desktop"
    echo "  2. Toggle 'Remote Desktop' ON"
    echo "  3. Toggle 'Remote Control' ON (allows mouse/keyboard)"
    echo "  4. Set a VNC password under Authentication"
    echo "  5. Note your Pi IP: ip addr | grep 'inet '"
    echo "  6. On your laptop, open TigerVNC or RealVNC Viewer"
    echo "     and connect to: <pi-ip-address>:5900"
    echo "----------------------------------------------------"
else
    echo "Skipping VNC Remote Desktop install"
fi

# ============================================================================
# STEP 10 - ARDUINO IDE 2.x (ARM64 APPIMAGE)
# The Ubuntu apt package 'arduino' installs the outdated 1.x IDE.
# Arduino IDE 2.x must be downloaded as an ARM64 AppImage for Pi 5.
#
#   arduino-ide AppImage - Modern Arduino IDE 2.x with boards manager,
#                          library manager, serial plotter, and debugger
#                          AppImage format runs without a traditional install;
#                          the file is self-contained and just needs to be
#                          made executable.
#   libfuse2             - FUSE library required for AppImage to mount itself
#                          at runtime; without this the AppImage will not launch
#
# Check for latest version at:
#   https://github.com/arduino/arduino-ide/releases
# Update ARDUINO_VER below when a new version is released.
#
# Reference: https://www.arduino.cc/en/software
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 10 - ARDUINO IDE 2.x (ARM64 APPIMAGE)"
echo "  Downloading Arduino IDE 2.x for ARM64 (aarch64)"
echo "  Installing to: ~/Arduino/arduino-ide/"
echo "  Creating desktop launcher shortcut"
echo "  NOTE: Update ARDUINO_VER in script if newer version available"
echo "  Check: https://github.com/arduino/arduino-ide/releases"
echo "============================================================"
echo "Do you wish to install Arduino IDE 2.x? Enter y/Y or n/N"
read -p "Install Arduino IDE 2.x?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    # --------------------------------------------------------
    # VERSION - update this when a new release is available
    # Check: https://github.com/arduino/arduino-ide/releases
    # --------------------------------------------------------
    ARDUINO_VER="2.3.4"
    ARDUINO_URL="https://github.com/arduino/arduino-ide/releases/download/${ARDUINO_VER}/arduino-ide_${ARDUINO_VER}_Linux_aarch64.AppImage"
    ARDUINO_DIR="$HOME/Arduino/arduino-ide"
    ARDUINO_BIN="$ARDUINO_DIR/arduino-ide.AppImage"

    echo " "
    echo "----------------------------------------------------"
    echo "Creating install directory: $ARDUINO_DIR"
    echo "----------------------------------------------------"
    mkdir -p "$ARDUINO_DIR"

    echo " "
    echo "----------------------------------------------------"
    echo "Downloading Arduino IDE $ARDUINO_VER for ARM64"
    echo "From: $ARDUINO_URL"
    echo "To:   $ARDUINO_BIN"
    echo "----------------------------------------------------"
    wget -O "$ARDUINO_BIN" "$ARDUINO_URL"

    echo " "
    echo "----------------------------------------------------"
    echo "Making AppImage executable"
    echo "Running: chmod +x $ARDUINO_BIN"
    echo "----------------------------------------------------"
    chmod +x "$ARDUINO_BIN"

    echo " "
    echo "----------------------------------------------------"
    echo "Installing libfuse2 - required for AppImage to run"
    echo "  AppImages use FUSE to mount themselves at launch"
    echo "  Without libfuse2 the AppImage will silently fail to start"
    echo "Running: sudo apt install libfuse2 -y"
    echo "----------------------------------------------------"
    sudo apt install libfuse2 -y

    echo " "
    echo "----------------------------------------------------"
    echo "Creating GNOME desktop launcher shortcut"
    echo "  Shortcut: ~/Desktop/Arduino IDE.desktop"
    echo "----------------------------------------------------"
    mkdir -p "$HOME/Desktop"
    cat > "$HOME/Desktop/Arduino IDE.desktop" << EOF
[Desktop Entry]
Name=Arduino IDE
Comment=Arduino IDE 2.x for Pi 5
Exec=$ARDUINO_BIN
Icon=arduino
Terminal=false
Type=Application
Categories=Development;
EOF
    chmod +x "$HOME/Desktop/Arduino IDE.desktop"
    echo "  Desktop shortcut created"

    echo " "
    echo "----------------------------------------------------"
    echo "Done: ARDUINO IDE 2.x"
    echo " "
    echo "  Launch from terminal: $ARDUINO_BIN"
    echo "  Or double-click the desktop shortcut"
    echo "  First launch downloads board toolchains automatically"
    echo "----------------------------------------------------"
else
    echo "Skipping Arduino IDE 2.x install"
fi

# ============================================================================
# STEP 11 - PLATFORMIO (VS CODE EXTENSION + CLI)
# PlatformIO is a professional embedded development platform that extends
# VS Code for serious multi-file C++ rover and robotics projects.
# It replaces the Arduino IDE workflow with a proper dependency-managed,
# Git-friendly build system supporting hundreds of boards.
#
#   platformio.platformio-ide - VS Code extension; project wizard, board
#                               manager, serial monitor, and build toolbar
#   PlatformIO Core CLI       - 'pio' command for terminal build/upload
#                               Installs to ~/.local/bin/pio
#   99-platformio-udev.rules  - udev rules so Pi recognizes Arduino/ESP
#                               boards over USB without needing sudo
#
# Reference: https://docs.platformio.org/en/latest/core/installation/index.html
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 11 - PLATFORMIO (VS Code Extension + CLI)"
echo "  Installing:"
echo "    - PlatformIO Core CLI via official installer"
echo "    - PlatformIO IDE extension into VS Code"
echo "    - PlatformIO udev rules for USB board detection"
echo "  Requires VS Code installed (Step 5)"
echo "  Docs: https://platformio.org"
echo "============================================================"
echo "Do you wish to install PlatformIO? Enter y/Y or n/N"
read -p "Install PlatformIO?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Installing PlatformIO Core CLI via official installer"
    echo "  Downloads and installs 'pio' to ~/.local/bin/pio"
    echo "  python3-distutils was installed in pre-flight bootstrap"
    echo "  (required by get-platformio.py on Python 3.12+ / Ubuntu 24.04)"
    echo "  Docs: https://docs.platformio.org/en/latest/core/installation"
    echo "----------------------------------------------------"
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py \
        -o /tmp/get-platformio.py
    python3 /tmp/get-platformio.py
    rm /tmp/get-platformio.py

    echo " "
    echo "----------------------------------------------------"
    echo "Adding PlatformIO CLI to PATH in ~/.bashrc"
    echo "  Enables 'pio' command from any terminal session"
    echo "----------------------------------------------------"
    if ! grep -q 'platformio\|\.local/bin' "$HOME/.bashrc"; then
        echo '' >> "$HOME/.bashrc"
        echo '# PlatformIO CLI' >> "$HOME/.bashrc"
        echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$HOME/.bashrc"
        echo "  PATH entry added to ~/.bashrc"
    else
        echo "  PATH entry already exists in ~/.bashrc, skipping"
    fi
    export PATH="$PATH:$HOME/.local/bin"

    echo " "
    echo "----------------------------------------------------"
    echo "Installing PlatformIO IDE extension into VS Code"
    echo "  Provides: project wizard, board manager, serial monitor"
    echo "Running: code --install-extension platformio.platformio-ide"
    echo "----------------------------------------------------"
    code --install-extension platformio.platformio-ide

    echo " "
    echo "----------------------------------------------------"
    echo "Installing PlatformIO udev rules"
    echo "  Allows Pi to detect Arduino/ESP boards over USB"
    echo "  without needing sudo for uploads"
    echo "  Rule: /etc/udev/rules.d/99-platformio-udev.rules"
    echo "----------------------------------------------------"
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules \
        | sudo tee /etc/udev/rules.d/99-platformio-udev.rules > /dev/null
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "  udev rules installed and reloaded"

    echo " "
    echo "----------------------------------------------------"
    echo "Verifying PlatformIO CLI"
    echo "----------------------------------------------------"
    if command -v pio &>/dev/null; then
        echo "  pio: $(pio --version)"
    else
        echo "  pio: not yet in PATH for this session"
        echo "       Open a new terminal and run: pio --version"
    fi

    echo " "
    echo "----------------------------------------------------"
    echo "Done: PLATFORMIO"
    echo " "
    echo "  NEXT STEPS for PlatformIO:"
    echo "  1. Log out and back in (PATH change takes effect)"
    echo "  2. Open VS Code -> click the PlatformIO alien-head icon"
    echo "  3. New Project -> search your board:"
    echo "       'Arduino UNO R4 WiFi' or 'Arduino Mega 2560'"
    echo "  4. PlatformIO downloads the toolchain automatically on first build"
    echo "----------------------------------------------------"
else
    echo "Skipping PlatformIO install"
fi

# ============================================================================
# STEP 12 - GIT GLOBAL CONFIG
# Sets the global git user name and email used for all commits on this Pi.
# These appear in every git commit log and are required before committing
# to any repo. Stored in ~/.gitconfig
#
# Also sets VS Code as the default git editor (optional but recommended
# since VS Code is already installed in Step 5).
# ============================================================================
echo " "
echo "============================================================"
echo "STEP 12 - GIT GLOBAL CONFIG"
echo "  Configures git global user name, email, and default editor"
echo "  Stored in: ~/.gitconfig"
echo "============================================================"
echo "Do you wish to configure git global settings? Enter y/Y or n/N"
read -p "Configure git global?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo " "
    echo "----------------------------------------------------"
    echo "Enter your git user name (e.g. Jim Burnham)"
    read -p "Git user name: " GIT_NAME

    echo "Enter your git email (e.g. jburnham@metroed.net)"
    read -p "Git email: " GIT_EMAIL
    echo "----------------------------------------------------"

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global core.editor "code --wait"
    git config --global init.defaultBranch main

    echo " "
    echo "  Git global config set:"
    echo "    user.name  = $GIT_NAME"
    echo "    user.email = $GIT_EMAIL"
    echo "    core.editor = code --wait"
    echo "    init.defaultBranch = main"
    echo " "
    echo "  Stored in: ~/.gitconfig"
    echo "  View anytime with: git config --list --global"

    echo " "
    echo "----------------------------------------------------"
    echo "Done: GIT GLOBAL CONFIG"
    echo "----------------------------------------------------"
else
    echo "Skipping git global config"
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
check_tool curl
check_tool git
check_tool ssh -V
check_tool wget
check_tool nmap
check_tool minicom
check_tool neofetch
check_tool htop
check_tool tree
check_tool ifconfig

echo " "
echo "--- Python ---"
check_tool python3
check_tool pip3

echo " "
echo "--- Hardware Tools ---"
check_tool i2cdetect
check_tool pigpiod
check_tool esptool

echo " "
echo "--- IDEs and Editors ---"
check_tool vim
check_tool thonny
check_tool code

echo " "
echo "--- Browser ---"
check_tool chromium-browser

echo " "
echo "--- Docker ---"
check_tool docker
check_tool "docker compose" version

echo " "
echo "--- PlatformIO ---"
check_tool pio

echo " "
echo "--- Services ---"
printf "  %-22s " "pigpiod:"
sudo systemctl is-active pigpiod 2>/dev/null || echo "NOT RUNNING"

printf "  %-22s " "docker:"
sudo systemctl is-active docker 2>/dev/null || echo "NOT RUNNING"

echo " "
echo "--- Git Config ---"
echo "  user.name  = $(git config --global user.name 2>/dev/null || echo 'not set')"
echo "  user.email = $(git config --global user.email 2>/dev/null || echo 'not set')"

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
echo "  Done: Pi 5 Ubuntu 24.04 STEAM Clown Setup - Rev 0.03"
echo " "
echo "  Log file saved to:"
echo "  $LOG_FILE"
echo " "
echo "  REQUIRED MANUAL STEPS AFTER REBOOT:"
echo "  1. LOG OUT AND BACK IN"
echo "     (gpio, i2c, dialout, plugdev, docker group changes)"
echo " "
echo "  2. ENABLE VNC REMOTE DESKTOP"
echo "     Settings > Sharing > Remote Desktop > Toggle ON"
echo "     Set a VNC password, note your Pi IP: ip addr"
echo "     Connect from laptop with TigerVNC or RealVNC Viewer"
echo "     TigerVNC: https://tigervnc.org/"
echo " "
echo "  3. ARDUINO IDE"
echo "     Launch: ~/Arduino/arduino-ide/arduino-ide.AppImage"
echo "     Or double-click the desktop shortcut"
echo " "
echo "  4. PLATFORMIO"
echo "     Open VS Code > click alien-head icon > New Project"
echo "     Toolchain downloads automatically on first build"
echo " "
echo "  5. ROS2 JAZZY (install separately)"
echo "     https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html"
echo "============================================================"
