#! /bin/bash
# ============================================================================
# Shell script to fix Desktop-Portal-Gnome on Raspberry Pi 5 Ubuntu 24.04
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

    sudo apt purge xdg-desktop-portal-gnome
    sudo apt install xdg-desktop-portal-gtk
    systemctl --user daemon-reexec
    systemctl --user restart xdg-desktop-portal

    ls *.sh

    echo " "
    echo "----------------------------------------------------"
    echo "Done: Copying Setup Shell scripts"
    echo "----------------------------------------------------"
else
    echo "Skipping locale setup"
fi

echo "Rebooting in 7 seconds to reset xdg-desktop-portal..."
echo "Press Ctrl+C to cancel"
sleep 7
sudo reboot

