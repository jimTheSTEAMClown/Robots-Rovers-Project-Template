#! /bin/bash
# ============================================================================
# Shell script to pull the bash shell scripts for Desktop on Raspberry Pi 5 Ubuntu 24.04
# ============================================================================
cd 
pwd

echo "============================================================"
echo "want to run update & upgrade?"
echo "============================================================"
echo "Do you wish to update and upgrade? Enter y/Y or n/N"
read -p "Set locale?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    echo "----------------------------------------------------"
  echo "getting home with cd ~"
  echo "----------------------------------------------------"
  echo " "
  cd ~
  pwd
  echo "----------------------------------------------------"
  echo "Running $ update"
  echo "----------------------------------------------------"
  echo " "
  sudo apt update
  echo " "
  echo "----------------------------------------------------"
  echo "Done running Update"
  echo "----------------------------------------------------"
  echo "----------------------------------------------------"
  echo "Running $ upgrade with -y"
  echo "----------------------------------------------------"
  echo " "
  sudo apt upgrade -y
  echo " "
  echo "----------------------------------------------------"
  echo "Done running Upgrade"
  echo "----------------------------------------------------"
else
    echo "Skipping locale setup"
fi

echo "============================================================"
echo "Ready to copy setup shell scripts?"
echo "============================================================"
echo "Do you wish to copy setup shell scripts? Enter y/Y or n/N"
read -p "Set locale?: " yesInstall

if [ "$yesInstall" == "y" ] || [ "$yesInstall" == "Y" ]; then

    sudo wget -O Pi5-Ubuntu-Desk-24.04-Run-First.sh https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/Raspberry/imageSetup/Pi5-Ubuntu-Desk-24.04-Run-First.sh 
    sudo chmod 755 Pi5-Ubuntu-Desk-24.04-Run-First.sh
    sudo wget -O Pi5-Ubuntu-Desk-24.04-Tools-Apps-Install.sh https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/Raspberry/imageSetup/Pi5-Ubuntu-Desk-24.04-Tools-Apps-Install.sh 
    sudo chmod 755 Pi5-Ubuntu-Desk-24.04-Tools-Apps-Install.sh
    sudo wget -O Pi5-Ubuntu-24.04-ROS2-Jazzy-Install.sh https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-LVR/refs/heads/main/ROS2/Pi5-Ubuntu-24.04-ROS2-Jazzy-Install.sh 
    sudo chmod 755 Pi5-Ubuntu-24.04-ROS2-Jazzy-Install.sh

    ls *.sh

    echo " "
    echo "----------------------------------------------------"
    echo "Done: Copying Setup Shell scripts"
    echo "----------------------------------------------------"
else
    echo "Skipping locale setup"
fi

