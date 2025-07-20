#!/bin/bash

# Configuration variables
EXTENSION_NAME="all-folder-size-calculation"
AUTHOR_NAME="ismdevteam"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYTHON_FILE="nautilus-all-folder-size-calculation.py"

install_extension() {
    # Determine installation directory
    if [ "$1" == "--user" ]; then
        EXT_DIR="$HOME/.local/share/nautilus-python/extensions"
        SUDO=""
    else
        EXT_DIR="/usr/share/nautilus-python/extensions"
        SUDO="sudo"
    fi

    # Create directories if they don't exist
    $SUDO mkdir -p "$EXT_DIR"

    # Copy the Python file
    echo "Installing extension file..."
    if [ -f "$SCRIPT_DIR/$PYTHON_FILE" ]; then
        $SUDO cp "$SCRIPT_DIR/$PYTHON_FILE" "$EXT_DIR/"
        $SUDO chmod 644 "$EXT_DIR/$PYTHON_FILE"
        echo "Installation complete. Restart Nautilus to load the extension."
        echo "You can restart Nautilus with: nautilus -q && nautilus &"
    else
        echo "Error: Could not find $PYTHON_FILE in $SCRIPT_DIR"
        exit 1
    fi
}

uninstall_extension() {
    # Determine installation directory
    if [ "$1" == "--user" ]; then
        EXT_DIR="$HOME/.local/share/nautilus-python/extensions"
        SUDO=""
    else
        EXT_DIR="/usr/share/nautilus-python/extensions"
        SUDO="sudo"
    fi

    # Remove the Python file and pycache
    echo "Removing extension files..."
    $SUDO rm -f "$EXT_DIR/$PYTHON_FILE"
    $SUDO rm -rf "$EXT_DIR/__pycache__" 2>/dev/null
    echo "Uninstallation complete. Restart Nautilus to see changes."
    echo "You can restart Nautilus with: nautilus -q && nautilus &"
}

# Check if we need to restart with sudo
if [ "$1" == "install" ] && [ "$2" != "--user" ] && [ "$(id -u)" -ne 0 ]; then
    echo "Need root privileges for system-wide installation, restarting with sudo..."
    exec sudo "$0" "$@"
    exit $?
fi

if [ "$1" == "uninstall" ] && [ "$2" != "--user" ] && [ "$(id -u)" -ne 0 ]; then
    echo "Need root privileges for system-wide uninstallation, restarting with sudo..."
    exec sudo "$0" "$@"
    exit $?
fi

# Main script
case "$1" in
    install)
        install_extension "$2"
        ;;
    uninstall)
        uninstall_extension "$2"
        ;;
    *)
        echo "Usage: $0 {install|uninstall} [--user]"
        echo "Options:"
        echo "  install       Install the extension"
        echo "  uninstall     Remove the extension"
        echo ""
        echo "Flags:"
        echo "  --user        Install for current user only (default: system-wide)"
        exit 1
        ;;
esac
