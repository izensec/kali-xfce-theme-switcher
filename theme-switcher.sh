#!/bin/bash

# -----------------------------------------------
# Edit the DEFAULT_COLOR constant if needed
# Available colors as of Kali 2025.04:
# Blue, Green, Orange, Pink, Purple, Red, Slate,
# Teal, and Yellow
# -----------------------------------------------
DEFAULT_COLOR="Blue"

help() {
  cat << EOF
Usage: $(basename "$0") [-c COLOR]

Options:
  -c COLOR   (Optional) Set the color. Supported values:
             Blue, Green, Orange, Pink, Purple,
             Red, Slate, Teal, Yellow
  -h         Show this help message and exit

Notes:
  - The -c option is optional.
  - If -c is not provided, the default color "$DEFAULT_COLOR" is used.
  - If an unsupported color is entered, the default color is used.

Examples:
  $(basename "$0")
  $(basename "$0") -c Blue
  $(basename "$0") -c Red
EOF
}

OPTSTRING=":c:h"
shopt -s nocasematch
while getopts $OPTSTRING opt; do
  case $opt in
    c)
      # to all lowercase
      color="${OPTARG,,}"
      # capitalize first letter
      color="${color^}"
      case $color in
        Blue|Green|Orange|Pink|Purple|Red|Slate|Teal|Yellow)
            COLOR=$color
            ;;
        *)
            echo "Unsupported color entered, defaulting to $DEFAULT_COLOR."
            COLOR="$DEFAULT_COLOR"
            ;;
    esac
      ;;
    h)
      help
      exit 0
      ;;
    :)
      echo "Option -c was specified but no color entered, defaulting to $DEFAULT_COLOR."
      COLOR="$DEFAULT_COLOR"
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      help
      exit 1
      ;;
  esac
done
shopt -u nocasematch

# Set default Color if no option in entered
if [[ -z "$COLOR" ]]; then
    echo "No color option was entered, defaulting to $DEFAULT_COLOR"
    COLOR="$DEFAULT_COLOR"
fi

# if the color is different from Blue include it in theme name
if [[ "$COLOR" != "Blue" ]]; then
    DARK_THEME="Kali-$COLOR-Dark"
    LIGHT_THEME="Kali-$COLOR-Light"
else
    DARK_THEME="Kali-Dark"
    LIGHT_THEME="Kali-Light"
fi

DARK_ICONS="Flat-Remix-$COLOR-Dark"
LIGHT_ICONS="Flat-Remix-$COLOR-Light"
DARK_MOUSEPAD="Kali-Dark"
LIGHT_MOUSEPAD="Kali-Light"

# Get current GTK theme name
THEME=$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null)

# Exit if Theme is empty
if [[ -z "$THEME" ]]; then
    echo "Could not determine current theme."
    exit 1
fi

echo "Current theme: $THEME"

if [[ "$THEME" == *Dark* ]]; then
    echo "Dark theme detected, switching to $LIGHT_THEME"
    # Theme Style
    xfconf-query -c xsettings -p /Net/ThemeName -s "$LIGHT_THEME"
    # Icons
    xfconf-query -c xsettings -p /Net/IconThemeName -s "$LIGHT_ICONS"
    # Window Manager
    xfconf-query -c xfwm4 -p /general/theme -s "$LIGHT_THEME"
    # MousePad Text Editor
    gsettings set org.xfce.mousepad.preferences.view color-scheme "$LIGHT_MOUSEPAD"
    # QT5 config
    sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/qt5ct/colors/$LIGHT_THEME.conf|" ~/.config/qt5ct/qt5ct.conf
    sed -i "s|^icon_theme=.*|icon_theme=$LIGHT_ICONS|" ~/.config/qt5ct/qt5ct.conf
    # QT6 config
    sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/$LIGHT_THEME.conf|" ~/.config/qt6ct/qt6ct.conf
    sed -i "s|^icon_theme=.*|icon_theme=$LIGHT_ICONS|" ~/.config/qt6ct/qt6ct.conf
    # QTerminal
    sed -i "s|^colorScheme=.*|colorScheme=$LIGHT_MOUSEPAD|" ~/.config/qterminal.org/qterminal.ini
    echo "Light theme applied."
elif [[ "$THEME" == *Light* ]]; then
    echo "Light theme detected, switching to $DARK_THEME"
    # Theme Style
    xfconf-query -c xsettings -p /Net/ThemeName -s "$DARK_THEME"
    # Icons
    xfconf-query -c xsettings -p /Net/IconThemeName -s "$DARK_ICONS"
    # Window Manager
    xfconf-query -c xfwm4 -p /general/theme -s "$DARK_THEME"
    # MousePad Text Editor
    gsettings set org.xfce.mousepad.preferences.view color-scheme "$DARK_MOUSEPAD"
    # QT5 config
    sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/qt5ct/colors/$DARK_THEME.conf|" ~/.config/qt5ct/qt5ct.conf
    sed -i "s|^icon_theme=.*|icon_theme=$DARK_ICONS|" ~/.config/qt5ct/qt5ct.conf
    # QT6 config
    sed -i "s|^color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/$DARK_THEME.conf|" ~/.config/qt6ct/qt6ct.conf
    sed -i "s|^icon_theme=.*|icon_theme=$DARK_ICONS|" ~/.config/qt6ct/qt6ct.conf
    # QTerminal
    sed -i "s|^colorScheme=.*|colorScheme=$DARK_MOUSEPAD|" ~/.config/qterminal.org/qterminal.ini
    echo "Dark theme applied."
else
    echo "Theme is neither Dark nor Light. No action taken."
fi