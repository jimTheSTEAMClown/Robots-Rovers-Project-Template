#! /bin/bash
# ============================================================================
# shell script to strip unwanted EXIF/GPS/device metadata from an image and
# write clean, web-safe copyright/rights tags in a single pass
# Source: STEAM Clown - www.steamclown.org
# GitHub: https://github.com/jimTheSTEAMClown/Linux
# Hacker: Jim Burnham - STEAM Clown, Engineer, Maker, Propmaster & Adrenologist
# This example code is licensed under the CC BY-NC-SA 4.0, GNU GPL and EUPL
# https://creativecommons.org/licenses/by-nc-sa/4.0/
# https://www.gnu.org/licenses/gpl-3.0.en.html
# https://eupl.eu/
# Program/Design Name:		image_exiftool_metatag_clean.sh
# Description:    shell script that takes an image file as a command-line
#                 argument, strips GPS coordinates, device/camera fingerprint
#                 tags, and other web-irrelevant EXIF data, then writes a
#                 clean Copyright and XMP-dc:Rights tag for publishing to
#                 steamclown.org / STEAM Clown's Resource Vault
# Dependencies:   exiftool (libimage-exiftool-perl)
# Revision:
#  Revision 0.01 - Created 07/25/2026 for STEAM Clown's Resource Vault
#  - Strips GPS, Make/Model, Motorola-specific tags, exposure settings,
#    sub-second timestamps, and filesystem dates
#  - Preserves Artist, DateTimeOriginal, CreateDate, Orientation,
#    ColorSpace, and full ICC color profile
#  - Writes Copyright and XMP-dc:Rights (CC BY-SA 4.0) in the same pass
# Additional Comments:
# see https://www.answers.com/Q/How_do_you_make_a_yes_no_command_in_cmd to add more features
# ============================================================================

# ----------------------------------------------------------------------
# Edit these two values before running
# ----------------------------------------------------------------------
COPYRIGHT_HOLDER="jim_The_STEAMClown - www.steamclown.org"
COPYRIGHT_SYMBOL=$(printf '\xc2\xa9')
LICENSE_TAG="CC BY-SA 4.0"

echo "----------------------------------------------------"
echo "Image EXIF Metadata Clean Script"
echo "----------------------------------------------------"
echo " "

# ----------------------------------------------------------------------
# Verify an image file was passed in on the command line
# ----------------------------------------------------------------------
if [ -z "$1" ]; then
    echo "----------------------------------------------------"
    echo "ERROR: No image file supplied."
    echo "Usage: ./image_exiftool_metatag_clean.sh <image-file>"
    echo "----------------------------------------------------"
    exit 1
fi

IMAGE_FILE="$1"

if [ ! -f "$IMAGE_FILE" ]; then
    echo "----------------------------------------------------"
    echo "ERROR: File not found: $IMAGE_FILE"
    echo "----------------------------------------------------"
    exit 1
fi

# ----------------------------------------------------------------------
# Verify exiftool is installed
# ----------------------------------------------------------------------
if ! command -v exiftool >/dev/null 2>&1; then
    echo "----------------------------------------------------"
    echo "ERROR: exiftool is not installed."
    echo "Install it with: sudo apt install libimage-exiftool-perl"
    echo "----------------------------------------------------"
    exit 1
fi

echo "Target file:        $IMAGE_FILE"
echo "Copyright holder:   $COPYRIGHT_HOLDER"
echo "License tag:        $LICENSE_TAG"
echo " "
echo "----------------------------------------------------"
echo "Current metadata (before clean):"
echo "----------------------------------------------------"
exiftool "$IMAGE_FILE"
echo " "

echo "----------------------------------------------------"
echo "Do you wish to strip metadata and write clean copyright/rights tags?"
echo "----------------------------------------------------"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
            echo "----------------------------------------------------"
            echo "Cleaning metadata on $IMAGE_FILE"
            echo "----------------------------------------------------"
            break;;
        No )
            echo "----------------------------------------------------"
            echo "Exiting Without Changes"
            echo "----------------------------------------------------"
            exit;;
    esac
done

# ----------------------------------------------------------------------
# Strip all tags, then restore only the keep-list, then write
# Copyright and XMP-dc:Rights fresh. -overwrite_original skips the
# "_original" backup copy exiftool normally leaves behind.
# ----------------------------------------------------------------------
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "[$TIMESTAMP] Running exiftool clean on $IMAGE_FILE"

exiftool -all= \
    -tagsFromFile @ \
    -Artist \
    -DateTimeOriginal \
    -CreateDate \
    -Orientation \
    -ColorSpace \
    -ICC_Profile:all \
    -Copyright="(c) $(date +%Y) $COPYRIGHT_HOLDER" \
    -XMP-dc:Rights="$LICENSE_TAG" \
    -XMP:Copyright="${COPYRIGHT_SYMBOL} $(date +%Y) $COPYRIGHT_HOLDER" \
    -overwrite_original \
    "$IMAGE_FILE"

if [ $? -eq 0 ]; then
    echo " "
    echo "----------------------------------------------------"
    echo "Metadata cleaned successfully."
    echo "----------------------------------------------------"
    echo "Remaining metadata (after clean):"
    echo "----------------------------------------------------"
    exiftool "$IMAGE_FILE"
    echo " "
    echo "============================================"
    echo "  ____   ___  _   _ _____ "
    echo " |  _ \ / _ \| \ | | ____|"
    echo " | | | | | | |  \| |  _|  "
    echo " | |_| | |_| | |\  | |___ "
    echo " |____/ \___/|_| \_|_____|"
    echo "============================================"
    echo " Image metadata clean complete: $IMAGE_FILE"
    echo "============================================"
else
    echo "----------------------------------------------------"
    echo "ERROR: exiftool reported a problem cleaning $IMAGE_FILE"
    echo "----------------------------------------------------"
    exit 1
fi
