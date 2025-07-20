# Nautilus All Folder Size Calculation Extension

This extension adds complete folder size calculation to Nautilus file manager with smart caching functionality.

<img width="1437" height="817" alt="image" src="https://github.com/user-attachments/assets/51e72b87-3ba6-4772-ba63-7e711a0705a3" />

## Features

- Calculates and displays complete folder sizes in MB
- Smart caching system for better performance
- Only recalculates when folders are modified
- Works with local filesystems
- Lightweight and efficient

## Tested Platforms

- **Debian GNU/Linux 11 (bullseye)** with GNOME 3.38.5 and GNOME nautilus 3.38.2
- **Debian GNU/Linux 12 (bookworm)** with GNOME 43.9 and GNOME nautilus 43.2

## Requirements

- Nautilus file manager
- Python 3
- PyGObject
- Nautilus Python extensions support

## Installation

### Method 1: Using Install Script

```bash
# Clone the repository
git clone https://github.com/ismdevteam/nautilus-all-folder-size-calculation.git
cd nautilus-all-folder-size-calculation

# System-wide installation (requires sudo)
sudo ./install.sh install

# User installation (no sudo needed)
./install.sh install --user
```

### Method 2: Manual Installation

```bash
# For user installation
mkdir -p ~/.local/share/nautilus-python/extensions
cp nautilus-all-folder-size-calculation.py ~/.local/share/nautilus-python/extensions/

# For system-wide installation
sudo mkdir -p /usr/share/nautilus-python/extensions
sudo cp nautilus-all-folder-size-calculation.py /usr/share/nautilus-python/extensions/
```

After installation, restart Nautilus:
```bash
nautilus -q && nautilus &
```

## Uninstallation

### Using Install Script

```bash
# System-wide uninstallation
sudo ./install.sh uninstall

# User uninstallation
./install.sh uninstall --user
```

### Manual Uninstallation

```bash
# For user installation
rm -f ~/.local/share/nautilus-python/extensions/nautilus-all-folder-size-calculation.py

# For system-wide installation
sudo rm -f /usr/share/nautilus-python/extensions/nautilus-all-folder-size-calculation.py
```

Then restart Nautilus.

## Troubleshooting

1. If the extension doesn't appear:
   - Verify the files are in the correct location
   - Check Nautilus version compatibility
   - Restart Nautilus completely (`nautilus -q` then start again)

2. If you get permission errors:
   - For system-wide install, ensure you have sudo privileges
   - For user install, ensure the `.local` directory exists

3. If sizes don't update:
   - The extension caches sizes until folders are modified
   - Try navigating away and back to refresh

## Debian Package Installation

### Method 1: Install from Official Repository (Recommended)

1. **Add the repository**:
   ```bash
   echo "deb [trusted=yes arch=all] https://ismdevteam.github.io/deb stable main" | sudo tee /etc/apt/sources.list.d/nautilus-ext.list
   ```

2. **Update and install**:
   ```bash
   sudo apt update
   sudo apt install nautilus-all-folder-size-calculation
   ```

3. **Restart Nautilus**:
   ```bash
   nautilus -q && nautilus &
   ```

### Method 2: Manual .deb Installation (Alternative)

1. **Download the package** from the [Releases page](https://github.com/ismdevteam/nautilus-all-folder-size-calculation/releases) or build it yourself using the provided script.

2. **Install dependencies** (usually automatically handled but can be installed manually):
   ```bash
   sudo apt update
   sudo apt install python3 python3-gi nautilus gir1.2-nautilus-3.0
   ```

3. **Install the package**:
   ```bash
   sudo apt install ./nautilus-all-folder-size-calculation_1.0_all.deb
   ```
   or using dpkg:
   ```bash
   sudo dpkg -i nautilus-all-folder-size-calculation_1.0_all.deb
   sudo apt install -f  # To fix any missing dependencies
   ```

4. **Restart Nautilus** (if not done automatically):
   ```bash
   nautilus -q && nautilus &
   ```

### Uninstalling the .deb Package

1. **Remove the package**:
   ```bash
   sudo apt remove nautilus-all-folder-size-calculation
   ```

2. **For complete removal** (including configuration files):
   ```bash
   sudo apt purge nautilus-all-folder-size-calculation
   ```

3. **Restart Nautilus**:
   ```bash
   nautilus -q && nautilus &
   ```

## Building from Source

### Creating a Debian Package

1. **Install build dependencies**:
   ```bash
   sudo apt install devscripts debhelper dh-python
   ```

2. **Build the package**:
   ```bash
   ./build-deb-package.sh
   ```

3. **The resulting .deb file** will be created in the current directory.

## Verification

After installation, verify the extension is working:

1. Open Nautilus
2. Navigate to any folder
3. Enable the "Size (MB)" column in list view (Right-click column headers)

## Troubleshooting

If the extension doesn't appear:

1. Check installation location:
   ```bash
   ls /usr/share/nautilus-python/extensions/nautilus-all-folder-size-calculation.py
   ```

2. Check Nautilus Python support:
   ```bash
   nautilus --version | grep "python"
   ```

3. View extension errors:
   ```bash
   journalctl -f -o cat /usr/bin/nautilus
   ```

## Development

Project home: [https://github.com/ismdevteam/nautilus-all-folder-size-calculation](https://github.com/ismdevteam/nautilus-all-folder-size-calculation)

To report issues or contribute, please visit our GitHub repository.

## License

[GPL-3.0][LICENSE](https://github.com/ismdevteam/nautilus-all-folder-size-calculation/blob/main/LICENSE)
