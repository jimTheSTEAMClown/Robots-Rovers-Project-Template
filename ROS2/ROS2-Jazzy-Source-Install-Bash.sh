#!/bin/bash
# ROS2 Jazzy Install Bash.sh
# https://docs.ros.org/en/jazzy/Installation/Alternatives/Ubuntu-Development-Setup.html

read -s -p "About to run apt update and upgrade -y - Press Enter to continue..."
sudo apt update
sudo apt upgrade -y

read -s -p "Checking locale settings - Press Enter to continue..."
locale  # check for UTF-8

read -s -p "setting locale settings, which are probably already set - Press Enter to continue..."
sudo apt update
sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings

# Enable required repositories - You will need to add the ROS 2 apt repository to your system.
# First ensure that the Ubuntu Universe repository is enabled.
read -s -p "install software-properties-common & universe stuff - Press Enter to continue..."
sudo apt install software-properties-common
sudo add-apt-repository universe

# The ros-apt-source packages provide keys and apt source configuration for the various ROS repositories.
# Installing the ros2-apt-source package will configure ROS 2 repositories for your system. Updates to 
# repository configuration will occur automatically when new versions of this package are released to the ROS repositories.
read -s -p "getting ROS source version - Press Enter to continue..."
sudo apt update
sudo apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb


# Install development tools (PYTHON) 
read -s -p "Installing a bunch of Python3 stuff (maybe a local version?) - Press Enter to continue..."
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


# Build ROS 2 - Get ROS 2 code - Create a workspace and clone all repos:
read -s -p "Build ROS 2 - Jazzy - Press Enter to continue..."
mkdir -p ~/ros2_jazzy/src
cd ~/ros2_jazzy
vcs import --input https://raw.githubusercontent.com/ros2/ros2/jazzy/ros2.repos src

# Install dependencies using rosdep
# ROS 2 packages are built on frequently updated Ubuntu systems. 
# It is always recommended that you ensure your system is up to date 
# before installing new packages.
read -s -p "setting up rosdep - Press Enter to continue..."

sudo apt update

sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

# Install additional RMW implementations (optional)
# The default middleware that ROS 2 uses is Fast DDS, but the middleware (RMW) 
# can be replaced at build or runtime. See the guide on how to work with multiple RMWs.

# Install colcon mixins
read -s -p "Install colcon mixins - Press Enter to continue..."
colcon mixin add default https://github.com/colcon/colcon-mixin-repository/raw/master/index.yaml
colcon mixin update default

# If you have already installed ROS 2 another way (either via debs or the binary distribution), 
# make sure that you run the below commands in a fresh environment that does not have those other 
# installations sourced. Also ensure that you do not have source /opt/ros/${ROS_DISTRO}/setup.bash in your .bashrc. 
# You can make sure that ROS 2 is not sourced with the command printenv | grep -i ROS. The output should be empty.
echo 'you should see something like'
echo 'add expected output here'
read -s -p "printenv | grep -i ROS - Press Enter to continue..."
printenv | grep -i ROS

read -s -p "next will make sure you aqre in ~/ros2_jazzy/ and build the mixin release - Press Enter to continue..."
cd ~/ros2_jazzy/
colcon build --symlink-install --mixin release

# Setup environment - Set up your environment by sourcing the following file.
read -s -p ". ~/ros2_jazzy/install/local_setup.bash - Press Enter to continue..."
. ~/ros2_jazzy/install/local_setup.bash

read -s -p "I think we are all setup.  Ready to test? - Press Enter to continue..."

echo 'Try some examples'
echo 'In one terminal, source the setup file and then run a C++ talker: '
echo '. ~/ros2_jazzy/install/local_setup.bash'
echo 'ros2 run demo_nodes_cpp talker'
echo ' '
echo 'In another terminal source the setup file and then run a Python listener: '
echo '. ~/ros2_jazzy/install/local_setup.bash'
echo 'ros2 run demo_nodes_py listener'
