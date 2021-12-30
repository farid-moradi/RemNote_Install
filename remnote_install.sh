#!/usr/bin/env bash

set -e

#-----------------------------------------------------
# Variables
#-----------------------------------------------------
BLUE=`tput setaf 4`
COLOR_RESET=`tput sgr0`
PWD_START=`pwd`
DEST_DIR=~/.remnoteTest

showLogo() {
    echo -e "${BLUE}"
    echo -e ""
    echo -e "    ____                 _   __      __     "
    echo -e "   / __ \___  ____ ___  / | / /___  / /____ "
    echo -e "  / /_/ / _ \/ __ /__ \/  |/ / __ \/ __/ _ \ "
    echo -e " / _, _/  __/ / / / / / /|  / /_/ / /_/  __/"
    echo -e "/_/ |_|\___/_/ /_/ /_/_/ |_/\____/\__/\___/ "
    echo -e ""
    echo -e "Linux Installer"
    echo -e "${COLOR_RESET}"
}

# START
showLogo

# Download RemNote

VERSION=$(curl -vs https://www.remnote.com/desktop/linux 2>&1 | grep "^< location" | cut -d'/' -f 4 | sed 's/AppImage.*/AppImage/g')
echo "VERSION:"
echo $VERSION

FILENAME=$VERSION

TEMP_DIR=$(mktemp -d)
wget -O "${TEMP_DIR}/${FILENAME}" "https://www.remnote.com/desktop/linux"

# Installing RemNote

touch $TEMP_DIR
chmod +x $TEMP_DIR/$FILENAME

cd $TEMP_DIR
$TEMP_DIR/$FILENAME --appimage-extract "usr/share/icons/hicolor/0x0/apps/remnote.png"
$TEMP_DIR/$FILENAME --appimage-extract "*.desktop"
DESKTOP_FILE=$TEMP_DIR/squashfs-root/remnote.desktop
ICON_FILE_DIR=$TEMP_DIR/squashfs-root/usr/share/icons/hicolor/0x0/apps/remnote.png
ICON_FILE=$TEMP_DIR/squashfs-root/remnote.png
cp $ICON_FILE_DIR $ICON_FILE
cd $PWD_START

mkdir -p $DEST_DIR
rm -f $DEST_DIR/*
cp -R $TEMP_DIR/$FILENAME $DEST_DIR

# Installing Icon
rm -f ~/.local/share/icons/hicolor/512x512/apps/remnote.png
mkdir -p  ~/.local/share/icons/hicolor/512x512/apps
cp $ICON_FILE ~/.local/share/icons/hicolor/512x512/apps/remnote.png

# Installing Desktop file
rm -f ~/.local/share/applications/remnote.desktop
mkdir -p  ~/.local/share/applications/
sed -i "s@^Exec.*@Exec=$DEST_DIR/$VERSION --no-sandbox %U@1" $DESKTOP_FILE
cp $DESKTOP_FILE ~/.local/share/applications/


# Cleaning up
rm -rf "$TEMP_DIR"

# TODO: Check for other shells
# Add following lines to .bashrc in order to update the desktop file based on the version of remnote.
# Remnote auot-updates itself and we should take care of updating the desktop file
echo 'VERSION=`ls ~/.remnote`' >> ~/.bashrc
echo "sed -i \"s@^Exec.*@Exec=~/.local/share/applications/\$VERSION --no-sandbox %U@1\" ~/.local/share/applications/remnote.desktop" >> ~/.bashrc
source ~/.bashrc








