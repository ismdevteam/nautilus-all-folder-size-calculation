#!/bin/bash
set -e

# Configuration
PACKAGE_NAME="nautilus-all-folder-size-calculation"
VERSION="1.0"
MAINTAINER="ismdevteam <support@appism.ru>"
DESCRIPTION="Nautilus extension that displays accurate folder sizes with smart caching"
DEPENDS="python3, python3-gi, nautilus, gir1.2-nautilus-3.0"
ARCHITECTURE="all"
LICENSE="GPL-3.0"
SOURCE_URL="https://github.com/ismdevteam/nautilus-all-folder-size-calculation"

# Create build directory
BUILD_DIR="$(mktemp -d)/deb-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create proper Debian package structure
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/share/nautilus-python/extensions"
mkdir -p "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME"
mkdir -p "$BUILD_DIR/usr/share/lintian/overrides"

# Copy files
cp ../nautilus-all-folder-size-calculation.py "$BUILD_DIR/usr/share/nautilus-python/extensions/"
cp ../README.md "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/"

# Create proper copyright file
cat > "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/copyright" <<EOL
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: $PACKAGE_NAME
Source: $SOURCE_URL

Files: *
Copyright: $(date +%Y) $MAINTAINER
License: $LICENSE

License: $LICENSE
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 .
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 .
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
EOL

# Create control file with all required fields
cat > "$BUILD_DIR/DEBIAN/control" <<EOL
Package: $PACKAGE_NAME
Version: $VERSION
Section: gnome
Priority: optional
Architecture: $ARCHITECTURE
Depends: $DEPENDS
Maintainer: $MAINTAINER
Description: $DESCRIPTION
 This Nautilus extension adds accurate folder size calculation with smart caching.
 Features include:
  * Real-time size calculation
  * Automatic cache invalidation
  * Low memory footprint
  * Native integration with Nautilus file manager
Homepage: $SOURCE_URL
EOL

# Create postinst script with proper debhelper snippets
cat > "$BUILD_DIR/DEBIAN/postinst" <<'EOL'
#!/bin/sh
set -e

#DEBHELPER#

case "$1" in
    configure)
        # Restart nautilus to load the extension
        if [ -x "$(command -v nautilus)" ]; then
            nautilus -q || true
        fi

        # Update icon cache
        if [ -x "$(command -v gtk-update-icon-cache)" ]; then
            gtk-update-icon-cache -q -t /usr/share/icons/hicolor || true
        fi

        # Update desktop database
        if [ -x "$(command -v update-desktop-database)" ]; then
            update-desktop-database -q || true
        fi
        ;;
    abort-upgrade|abort-remove|abort-deconfigure)
        exit 0
        ;;
    *)
        echo "postinst called with unknown argument \`$1'" >&2
        exit 1
        ;;
esac

exit 0
EOL
chmod 755 "$BUILD_DIR/DEBIAN/postinst"

# Create prerm script with proper debhelper snippets
cat > "$BUILD_DIR/DEBIAN/prerm" <<'EOL'
#!/bin/sh
set -e

#DEBHELPER#

case "$1" in
    remove|deconfigure)
        # Restart nautilus to unload the extension
        if [ -x "$(command -v nautilus)" ]; then
            nautilus -q || true
        fi
        ;;
    upgrade|failed-upgrade)
        exit 0
        ;;
    *)
        echo "prerm called with unknown argument \`$1'" >&2
        exit 1
        ;;
esac

exit 0
EOL
chmod 755 "$BUILD_DIR/DEBIAN/prerm"

# Create proper Debian changelog
cat > "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/changelog.Debian" <<EOL
$PACKAGE_NAME ($VERSION) unstable; urgency=medium

  * Initial release
    - Features complete folder size calculation with smart caching
    - Proper integration with Nautilus file manager

 -- $MAINTAINER  $(date -R)
EOL
gzip -9n "$BUILD_DIR/usr/share/doc/$PACKAGE_NAME/changelog.Debian"

# Create proper lintian overrides
cat > "$BUILD_DIR/usr/share/lintian/overrides/$PACKAGE_NAME" <<EOL
# This package places files in /usr/share/nautilus-python/extensions
# which is the standard location for Nautilus Python extensions
$PACKAGE_NAME: extension-in-standard-directory
$PACKAGE_NAME: package-not-installed-by-upgrade
EOL

# Set proper permissions
find "$BUILD_DIR" -type d -exec chmod 755 {} \;
find "$BUILD_DIR" -type f -exec chmod 644 {} \;
chmod 755 "$BUILD_DIR/DEBIAN/"*

# Build the package
dpkg-deb --root-owner-group --build "$BUILD_DIR" "../releases/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"

# Check the package with lintian
if command -v lintian >/dev/null; then
    echo "Checking package with lintian..."
    lintian -i -I --show-overrides "${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
else
    echo "Lintian not installed, skipping package check"
    echo "Install with: sudo apt install lintian"
fi

echo ""
echo "Package built successfully: ${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
echo "To install: sudo apt install ./${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
