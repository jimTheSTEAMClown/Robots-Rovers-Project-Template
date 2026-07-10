#!/bin/bash
# -----------------------------------------------------------------------------------------
# ROS2 Jazzy Source Install Bash.sh
# https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
# -----------------------------------------------------------------------------------------


read -s -p "checking UTF and updating - Press Enter to continue..."
# -----------------------------------------------------------------------------------------
locale  # check for UTF-8
sudo apt update
sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
locale  # verify settings
# -----------------------------------------------------------------------------------------
# Enable required repositories - You will need to add the ROS 2 apt repository to your system.
# First ensure that the Ubuntu Universe repository is enabled.
# -----------------------------------------------------------------------------------------
read -s -p "install software-properties-common & universe stuff - Press Enter to continue..."
# -----------------------------------------------------------------------------------------
sudo apt install software-properties-common
sudo add-apt-repository universe

# -----------------------------------------------------------------------------------------
# The ros-apt-source packages provide keys and apt source configuration for the various ROS repositories.
# Installing the ros2-apt-source package will configure ROS 2 repositories for your system. Updates to 
# repository configuration will occur automatically when new versions of this package are released to the ROS repositories.
read -s -p "getting ROS source version - Press Enter to continue..."
sudo apt update
sudo apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

# -----------------------------------------------------------------------------------------
# Install development tools (PYTHON) 
read -s -p "Installing a bunch of Python3 stuff (maybe a local version?) - Press Enter to continue..."
# -----------------------------------------------------------------------------------------
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

# Install development tools (optional)
# If you are going to build ROS packages or otherwise do development, you can also install the development tools:
# Check /etc/apt/sources.list.d/ubuntu.sources and ensure the Suites: line includes noble-updates and noble-backports:
# read -s -p "Checking Sources for ROS2 - Press Enter to continue..."
# grep Suites /etc/apt/sources.list.d/ubuntu.sources

# If noble-updates or noble-backports are missing then edit the file and update the line to:
# Suites: noble noble-updates noble-backports
# Then run:

# sudo apt clean && sudo apt update && sudo apt full-upgrade -y

# -----------------------------------------------------------------------------------------
# Dev Tools ROS 2 - install ros-dev-tools:
read -s -p "install ros-dev-tools - Press Enter to continue..."
sudo apt update && sudo apt install ros-dev-tools

# -----------------------------------------------------------------------------------------
# Install ROS 2 - install ROS2:
read -s -p "install ros2 - Press Enter to continue..."
sudo apt update
sudo apt upgrade -y
sudo apt install ros-jazzy-desktop

# -----------------------------------------------------------------------------------------
# Setup environment
# Set up your environment by sourcing the following file.
read -s -p "Setup environment - Press Enter to continue..."
source /opt/ros/jazzy/setup.bash




echo 'VICTORY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
read -s -p "I think we are all setup.  Ready to test? - Press Enter to continue..."

echo 'Try some examples'
echo 'In one terminal, source the setup file and then run a C++ talker: '
echo 'source /opt/ros/jazzy/setup.bash'
echo 'ros2 run demo_nodes_cpp talker'
echo ' '
echo 'In another terminal source the setup file and then run a Python listener: '
echo 'source /opt/ros/jazzy/setup.bash'
echo 'ros2 run demo_nodes_py listener'

