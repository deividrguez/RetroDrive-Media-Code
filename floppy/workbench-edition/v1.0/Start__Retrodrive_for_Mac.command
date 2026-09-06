#!/bin/bash

cd "$(dirname "$0")"

# =========================
# CONFIG
# =========================

ROOT="$(pwd)"
EMU_APP="$ROOT/EMULATOR/MACOSX/FS-UAE.app"
EMU="$EMU_APP/Contents/MacOS/fs-uae"

# =========================
# FIX SEGURIDAD macOS
# =========================

if [ -d "$EMU_APP" ]; then
    xattr -rd com.apple.quarantine "$EMU_APP" 2>/dev/null
fi
ROM="$ROOT/ROMS/kick.rom"
CONFIG="$ROOT/CONFIG/config.uae"
GAMES="$ROOT/GAMES"

LANG=""

# =========================
# LOGO
# =========================

logo() {
clear
cat << 'EOF'
                      |    |                     |                           |       |
\ \  \   / _ \   __| |  / __ \   _ \ __ \   __| __ \    _ \ __ `__ \  |   | |  _` | __|  _ \   __|
 \ \  \ / (   | |      <  |   |  __/ |   | (    | | |   __/ |   |   | |   | | (   | |   (   | |
  \_/\_/ \___/ _|   _|\_\_.__/ \___|_|  _|\___|_| |_| \___|_|  _|  _|\__,_|_|\__,_|\__|\___/ _|

   _   _     _   _   _   _   _   _   _   _   _   _
  / \ / \   / \ / \ / \ / \ / \ / \ / \ / \ / \ / \
 ( b | y ) ( r | e | t | r | o | d | r | i | v | e )
  \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/
EOF
echo
}

# =========================
# LANGUAGE
# =========================

lang_menu() {
logo
echo "1. English"
echo "2. Espanol"
echo "3. Francais"
echo "4. Deutsch"
echo
read -p "> " opt

case $opt in
    1) LANG="en" ;;
    2) LANG="es" ;;
    3) LANG="fr" ;;
    4) LANG="de" ;;
    *) lang_menu ;;
esac
}

# =========================
# TEXTS
# =========================

load_texts() {

if [ "$LANG" == "es" ]; then
    TITLE="MENU PRINCIPAL"
    LOAD="Cargar juego"
    SET="Configuracion"
    HELP="Ayuda"
    EXIT="Salir"
    SELECT="Selecciona opcion:"
fi

if [ "$LANG" == "en" ]; then
    TITLE="MAIN MENU"
    LOAD="Load Game"
    SET="Settings"
    HELP="Help"
    EXIT="Exit"
    SELECT="Select option:"
fi

if [ "$LANG" == "fr" ]; then
    TITLE="MENU"
    LOAD="Charger jeu"
    SET="Configuration"
    HELP="Aide"
    EXIT="Quitter"
    SELECT="Choisir:"
fi

if [ "$LANG" == "de" ]; then
    TITLE="MENU"
    LOAD="Spiel laden"
    SET="Einstellungen"
    HELP="Hilfe"
    EXIT="Beenden"
    SELECT="Waehlen:"
fi
}

# =========================
# MAIN MENU
# =========================

main_menu() {
load_texts
logo

echo "$TITLE"
echo
echo "1. $LOAD"
echo "2. $SET"
echo "3. $HELP"
echo "4. $EXIT"
echo

read -p "$SELECT " opt

case $opt in
    1) load_games ;;
    2) settings ;;
    3) help_menu ;;
    4) exit ;;
    *) main_menu ;;
esac
}

# =========================
# SETTINGS
# =========================

settings() {
logo

echo "1. Check ROM"
echo "2. Where to get it"
echo "3. Back"
echo

read -p "> " opt

case $opt in
    1) check_rom ;;
    2) rom_info ;;
    3) main_menu ;;
    *) settings ;;
esac
}

check_rom() {
logo

if [ -f "$ROM" ]; then
    echo "ROM OK"
else
    echo "ROM NOT FOUND"
fi

read -p "Press enter..."
settings
}

rom_info() {
logo
echo "Use Amiga Forever or internet"
echo "Place file as: ROMS/kick.rom"
read -p "Press enter..."
settings
}

# =========================
# LOAD GAMES
# =========================

load_games() {

while true; do
    logo
    echo "=== GAMES ==="
    echo

    i=1
    declare -a list

    for dir in "$GAMES"/*; do
        if [ -d "$dir" ]; then
            name=$(basename "$dir")
            echo "$i . - $name"
            list[$i]="$dir"
            ((i++))
        fi
    done

    echo
    echo "B - Back"
    echo

    read -p "$SELECT " sel

    if [[ "$sel" == "B" || "$sel" == "b" ]]; then
        main_menu
        return
    fi

    if ! [[ "$sel" =~ ^[0-9]+$ ]]; then
        continue
    fi

    GAMEPATH="${list[$sel]}"

    if [ -z "$GAMEPATH" ]; then
        continue
    fi

    run_game "$GAMEPATH"
done
}

# =========================
# RUN GAME (ADF SIMPLE)
# =========================

run_game() {

GAMEPATH="$1"

logo
echo "Loading $(basename "$GAMEPATH")..."
echo

ADF=$(find "$GAMEPATH" -name "*.adf" | head -n 1)

if [ ! -z "$ADF" ]; then
    echo "Found ADF:"
    echo "$ADF"
    echo
    read -p "Press enter to launch..."

    "$EMU" -f "$CONFIG" -0 "$ADF"

    echo
    read -p "Press enter to return..."
    return
fi

echo "No ADF found"
read -p "Press enter..."
}

# =========================
# HELP
# =========================

help_menu() {
logo
echo "RetroDrive Help"
read -p "Press enter..."
main_menu
}

# =========================

lang_menu
main_menu

read -p "Press enter to exit..."