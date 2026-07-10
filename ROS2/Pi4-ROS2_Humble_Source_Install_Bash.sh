#!/bin/bash
# ============================================================================
# Pi4-ROS2_Humble_Deb_Install.sh
# ============================================================================
# Install ROS 2 Humble Hawksbill via Debian packages on Ubuntu 22.04 LTS
# Reference: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html
# ============================================================================
# Source: STEAM Clown - www.steamclown.org
# GitHub: https://github.com/jimTheSTEAMClown/Robots-Rovers-Project-Template
# Hacker: Jim Burnham - STEAM Clown, Engineer, Maker, Propmaster & Adrenologist
# This example code is licensed under the CC BY-NC-SA 4.0, GNU GPL and EUPL
# https://creativecommons.org/licenses/by-nc-sa/4.0/
# https://www.gnu.org/licenses/gpl-3.0.en.html
# https://eupl.eu/
#
# Program/Design Name:   Pi4-ROS2_Humble_Deb_Install.sh
# Description:           Installs ROS 2 Humble Hawksbill from Debian packages
#                        on Ubuntu 22.04 LTS (Jammy Jellyfish).
#                        Adapted from Pi5-ROS2_Jazzy_Source_Install_Bash.sh
#
# Target Hardware:       Raspberry Pi 4B or x86_64 laptop/desktop
# Target OS:             Ubuntu 22.04 LTS (Jammy Jellyfish, 64-bit)
#
# Key differences from the Jazzy script:
#
#   1. ROS repository setup method:
#      Jazzy uses the new ros2-apt-source .deb package method — noble ONLY.
#      Humble uses the classic GPG key + /etc/apt/sources.list.d/ros2.list
#      method, which resolves $UBUNTU_CODENAME to 'jammy' on Ubuntu 22.04.
#
#   2. Package name:
#      ros-jazzy-desktop  →  ros-humble-desktop
#
#   3. Setup path:
#      /opt/ros/jazzy/setup.bash  →  /opt/ros/humble/setup.bash
#
#   4. noble-updates / noble-backports check REMOVED:
#      That fix is specific to Ubuntu 24.04 (noble). Not applicable on 22.04.
#
#   Everything else (locale setup, Python3 packages, ros-dev-tools,
#   apt update/upgrade, talker/listener test) is identical to the Jazzy script.
#
# Revision:
#  Revision 0.01 - Initial Humble version adapted from Jazzy script
#
# Usage:
#   wget -O Pi4-ROS2_Humble_Deb_Install.sh https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/ROS2/Pi4-ROS2_Humble_Deb_Install.sh
#   chmod 755 Pi4-ROS2_Humble_Deb_Install.sh
#   ./Pi4-ROS2_Humble_Deb_Install.sh
#
# References:
#   https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html
#   https://www.ros.org/reps/rep-2000.html  (ROS 2 release schedule)
# ============================================================================

# ============================================================================
# STEP 1 - CHECK AND SET UTF-8 LOCALE
# ROS 2 requires a UTF-8 locale. Verify and set if needed.
# ============================================================================
read -s -p "Checking UTF-8 locale and updating packages - Press Enter to continue..."
echo ""

# -------------------------------------------------------------------------
# NOTE: On Ubuntu 22.04 (Jammy), $UBUNTU_CODENAME resolves to 'jammy'.
# Verify this before continuing:
#   . /etc/os-release && echo $UBUNTU_CODENAME
#   Expected output: jammy
#
# If this is Ubuntu 24.04 (noble) you are on the wrong script.
# Use Pi5-ROS2_Jazzy_Source_Install_Bash.sh for Ubuntu 24.04 / Jazzy.
# -------------------------------------------------------------------------

echo "Verifying Ubuntu version..."
UBUNTU_VER=$(lsb_release -rs 2>/dev/null || echo "unknown")
echo "  Detected Ubuntu version: $UBUNTU_VER"
if [[ "$UBUNTU_VER" != 22.* ]]; then
    echo "----------------------------------------------------"
    echo "WARNING: This script targets Ubuntu 22.04 (Jammy)."
    echo "  Detected: $UBUNTU_VER"
    echo "  For Ubuntu 24.04 use the Jazzy script instead."
    echo "----------------------------------------------------"
    read -p "  Do you wish to continue anyway? (yes/no): " CONFIRM
    [[ "$CONFIRM" != "yes" ]] && echo "Exiting." && exit 1
fi

echo ""
locale  # check for UTF-8

sudo apt update
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo ""
locale  # verify settings

# ============================================================================
# STEP 2 - ENABLE REQUIRED REPOSITORIES
# Add the Ubuntu Universe repository and the ROS 2 Humble apt repository.
#
# IMPORTANT — why this differs from the Jazzy script:
#   The Jazzy script uses the ros2-apt-source .deb package to configure the
#   ROS repository. That package only builds releases for Ubuntu 24.04 (noble)
#   and will fail on Ubuntu 22.04 (jammy).
#
#   For Humble on Ubuntu 22.04 we use the classic method:
#     1. Download the ROS GPG signing key
#     2. Write a sources.list entry that references the key
#   The $UBUNTU_CODENAME variable resolves to 'jammy' on Ubuntu 22.04,
#   pointing apt at the correct Humble package repository.
# ============================================================================
read -s -p "Installing software-properties-common and enabling Universe repo - Press Enter to continue..."
echo ""

sudo apt install -y software-properties-common
sudo add-apt-repository universe -y
sudo apt update && sudo apt install -y curl

# ============================================================================
# STEP 3 - ADD THE ROS 2 HUMBLE APT REPOSITORY
#
# Uses the classic GPG key + sources.list method (correct for Ubuntu 22.04).
# This replaces the ros2-apt-source .deb block used in the Jazzy script.
#
# After this runs, verify the repo line contains 'jammy' (not 'noble'):
#   cat /etc/apt/sources.list.d/ros2.list
#   Expected: deb [...] http://packages.ros.org/ros2/ubuntu jammy main
# ============================================================================
read -s -p "Adding ROS 2 Humble apt repository (GPG key + sources.list) - Press Enter to continue..."
echo ""

echo "Adding ROS 2 GPG signing key..."
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "Adding ROS 2 Humble apt repository..."
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu \
$(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo ""
echo "Verifying repository entry (should contain 'jammy'):"
cat /etc/apt/sources.list.d/ros2.list

sudo apt update

echo ""
echo "Verifying ros-humble-desktop is reachable in the repo:"
apt-cache policy ros-humble-desktop 2>/dev/null | head -5
if ! apt-cache show ros-humble-desktop &>/dev/null; then
    echo "----------------------------------------------------"
    echo "ERROR: ros-humble-desktop not found in apt cache."
    echo "  The repository may not have been added correctly."
    echo "  Check: cat /etc/apt/sources.list.d/ros2.list"
    echo "  Expected: deb [...] .../ros2/ubuntu jammy main"
    echo "----------------------------------------------------"
    exit 1
fi

# ============================================================================
# STEP 4 - INSTALL PYTHON3 DEVELOPMENT TOOLS
# Same as the Jazzy script — these package names are identical on 22.04.
# ============================================================================
read -s -p "Installing Python3 development and test tools - Press Enter to continue..."
echo ""

sudo apt update && sudo apt install -y \
    python3-flake8-blind-except \
    python3-flake8-class-newline \
    python3-flake8-deprecated \
    python3-mypy \
    python3-pip \
    python3-pytest \
    python3-pytest-cov \
    python3-pytest-mock \
    python3-pytest-repeat \
    python3-pytest-rerunfailures \
    python3-pytest-runner \
    python3-pytest-timeout \
    ros-dev-tools

# ============================================================================
# STEP 5 - INSTALL ROS DEV TOOLS
# Same as the Jazzy script.
# ============================================================================
read -s -p "Installing ros-dev-tools - Press Enter to continue..."
echo ""

sudo apt update && sudo apt install -y ros-dev-tools

# ============================================================================
# STEP 6 - INSTALL ROS 2 HUMBLE DESKTOP
#
# ros-humble-desktop installs:
#   - ROS 2 core libraries and tools
#   - RViz 2 (visualization)
#   - rqt (GUI tools)
#   - Demo nodes (talker, listener)
#   - rclpy and rclcpp client libraries
#
# Alternative (smaller, no GUI tools):
#   sudo apt install ros-humble-ros-base
#
# This step downloads ~800 MB and takes 10-20 min on Pi 4B,
# 3-5 min on a modern laptop with fast internet.
# ============================================================================
read -s -p "Installing ros-humble-desktop - Press Enter to continue..."
echo ""

sudo apt update
sudo apt upgrade -y
sudo apt install -y ros-humble-desktop

echo ""
echo "Verifying ROS 2 Humble install directory:"
ls /opt/ros/humble/setup.bash 2>/dev/null \
    && echo "  [PASS] /opt/ros/humble/setup.bash found" \
    || echo "  [FAIL] /opt/ros/humble/ not found — check install above"

# ============================================================================
# STEP 7 - SET UP ENVIRONMENT
# Source the Humble setup file and add it to ~/.bashrc for all future sessions.
# ============================================================================
read -s -p "Setting up ROS 2 Humble environment - Press Enter to continue..."
echo ""

source /opt/ros/humble/setup.bash

if ! grep -q '/opt/ros/humble/setup.bash' "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# ROS 2 Humble" >> "$HOME/.bashrc"
    echo "source /opt/ros/humble/setup.bash" >> "$HOME/.bashrc"
    echo "  Added 'source /opt/ros/humble/setup.bash' to ~/.bashrc"
else
    echo "  /opt/ros/humble/setup.bash already in ~/.bashrc — skipping"
fi

echo ""
echo "Verifying ROS 2 environment:"
ros2 --version 2>/dev/null && echo "  [PASS] ros2 command works" \
    || echo "  [FAIL] ros2 command not found — check install"
echo "  ROS_DISTRO: ${ROS_DISTRO:-not set}"

# ============================================================================
# DONE
# ============================================================================
echo ""
echo 'VICTORY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
read -s -p "ROS 2 Humble installed. Ready to test? - Press Enter to continue..."
echo ""

echo ""
echo "============================================================"
echo "  ROS 2 Humble — Quick Test"
echo "============================================================"
echo ""
echo "Test 1 — Talker / Listener (open TWO terminals):"
echo ""
echo "  Terminal 1 (C++ talker):"
echo "    source /opt/ros/humble/setup.bash"
echo "    ros2 run demo_nodes_cpp talker"
echo ""
echo "  Terminal 2 (Python listener):"
echo "    source /opt/ros/humble/setup.bash"
echo "    ros2 run demo_nodes_py listener"
echo ""
echo "  Terminal 2 should print: [INFO] I heard: 'Hello World: N'"
echo ""
echo "Test 2 — Version check:"
echo "    source /opt/ros/humble/setup.bash"
echo "    ros2 --version"
echo "    echo \$ROS_DISTRO   # Expected: humble"
echo ""
echo "Test 3 — List installed packages:"
echo "    ros2 pkg list | head -20"
echo ""
echo "============================================================"
echo "  Next steps:"
echo "    Create a workspace:  mkdir -p ~/colcon_ws/src"
echo "    Build workspace:     cd ~/colcon_ws && colcon build"
echo "    Source workspace:    source ~/colcon_ws/install/setup.bash"
echo "    Create a package:    cd ~/colcon_ws/src"
echo "      ros2 pkg create --build-type ament_python my_package"
echo "============================================================"
