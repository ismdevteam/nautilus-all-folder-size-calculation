#!/bin/bash
set -e

# Configuration
REPO_OWNER="ismdevteam"
REPO_NAME="nautilus-all-folder-size-calculation"
PACKAGE_NAME="nautilus-all-folder-size-calculation"
VERSION="1.0"
ARCHITECTURE="all"
DIST_CODENAME="stable"
COMPONENT="main"
MAINTAINER="ismdevteam <support@appism.ru>"
DEPENDS="python3, python3-gi, nautilus, gir1.2-nautilus-3.0"
HOMEPAGE="https://github.com/$REPO_OWNER/$REPO_NAME"
SECTION="gnome"
PRIORITY="optional"

# Create temporary directory structure
TEMP_DIR=$(mktemp -d)
REPO_DIR="$TEMP_DIR/docs/deb"
echo "Creating repository structure in $TEMP_DIR..."
mkdir -p "$REPO_DIR"/{dists/$DIST_CODENAME/main/binary-all,pool/main/n/$PACKAGE_NAME}

# Try to get .deb file from different sources
DEB_FOUND=false
DEB_FILE=""

# 1. First try local releases directory
LOCAL_DEB="$(dirname "$0")/../releases/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
if [ -f "$LOCAL_DEB" ]; then
    DEB_FILE="$LOCAL_DEB"
    DEB_FOUND=true
    echo "Found local .deb file: $DEB_FILE"
else
    echo "No local .deb file found in releases directory"
fi

# 2. Try to download from GitHub releases if local not found
if [ "$DEB_FOUND" = false ]; then
    echo "Attempting to download .deb file from GitHub releases..."
    RELEASE_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
    DEB_URL=$(curl -s "$RELEASE_URL" | grep -o "https://.*${PACKAGE_NAME}.*${ARCHITECTURE}\.deb" | head -n 1)
    
    if [ -n "$DEB_URL" ]; then
        echo "Downloading .deb file from: $DEB_URL"
        DEB_FILE="$TEMP_DIR/$(basename "$DEB_URL")"
        if ! wget -q "$DEB_URL" -O "$DEB_FILE"; then
            echo "Failed to download .deb file from GitHub"
            DEB_FILE=""
        else
            DEB_FOUND=true
            echo "Successfully downloaded .deb file"
        fi
    else
        echo "No .deb file found in GitHub releases"
    fi
fi

# 3. Fall back to manual input if automatic methods failed
if [ "$DEB_FOUND" = false ]; then
    read -p "Enter path to your .deb file: " DEB_FILE
    while [ ! -f "$DEB_FILE" ]; do
        echo "Error: File not found!"
        read -p "Enter valid path to your .deb file: " DEB_FILE
    done
fi

# Verify .deb file name matches expected pattern
DEB_BASENAME=$(basename "$DEB_FILE")
if [[ ! "$DEB_BASENAME" =~ ${PACKAGE_NAME}_[0-9]+\.[0-9]+_${ARCHITECTURE}\.deb ]]; then
    echo "Warning: .deb filename doesn't match expected pattern: ${PACKAGE_NAME}_X.X_${ARCHITECTURE}.deb"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Copy .deb file to correct location
cp "$DEB_FILE" "$REPO_DIR/pool/main/n/$PACKAGE_NAME/"
echo "Using .deb file: $DEB_FILE"

# Generate Packages file
echo "Generating package indexes..."
cd "$REPO_DIR"
dpkg-scanpackages --multiversion pool/ > dists/$DIST_CODENAME/main/binary-all/Packages
gzip -9c dists/$DIST_CODENAME/main/binary-all/Packages > dists/$DIST_CODENAME/main/binary-all/Packages.gz

# Generate Release file
cd dists/$DIST_CODENAME
cat > Release <<EOF
Origin: $REPO_OWNER.github.io
Label: $REPO_OWNER.github.io
Suite: $DIST_CODENAME
Codename: $DIST_CODENAME
Version: $VERSION
Architectures: $ARCHITECTURE
Components: $COMPONENT
Description: Custom repository for $PACKAGE_NAME
Date: $(date -Ru)
MD5Sum:
 $(md5sum main/binary-all/Packages | cut -d' ' -f1) $(stat -c %s main/binary-all/Packages) main/binary-all/Packages
 $(md5sum main/binary-all/Packages.gz | cut -d' ' -f1) $(stat -c %s main/binary-all/Packages.gz) main/binary-all/Packages.gz
SHA256:
 $(sha256sum main/binary-all/Packages | cut -d' ' -f1) $(stat -c %s main/binary-all/Packages) main/binary-all/Packages
 $(sha256sum main/binary-all/Packages.gz | cut -d' ' -f1) $(stat -c %s main/binary-all/Packages.gz) main/binary-all/Packages.gz
EOF

# Create empty InRelease file
touch InRelease

# Summary
echo -e "\n\033[1mRepository created successfully!\033[0m"
echo -e "Directory structure:"
tree -L 5 "$TEMP_DIR"

echo -e "\nTo deploy to GitHub Pages:"
echo -e "\033[1m"
echo "rm -rf /path/to/your/repo/docs/deb"
echo "cp -r $TEMP_DIR/docs/deb /path/to/your/repo/docs/"
echo "cd /path/to/your/repo"
echo "git add docs/deb"
echo "git commit -m 'Update deb repository'"
echo "git push origin main"
echo -e "\033[0m"

echo -e "\nUsers can install with:"
echo -e "\033[1m"
echo "echo \"deb [trusted=yes] https://$REPO_OWNER.github.io/deb $DIST_CODENAME $COMPONENT\" | sudo tee /etc/apt/sources.list.d/$REPO_NAME.list"
echo "sudo apt update && sudo apt install $PACKAGE_NAME"
echo -e "\033[0m"

echo -e "\nTemporary files kept at: $TEMP_DIR"
