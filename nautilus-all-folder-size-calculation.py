# Nautilus All Folder Size Calculation - Extension for Nautilus to display accurate folder sizes
# Copyright (C) 2023 ismdevteam <support@appism.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import time
from gi.repository import Nautilus, GObject
from gettext import gettext, bindtextdomain, textdomain

try:
    # Python 3
    from gettext import locale
except ImportError:
    # Python 2
    import locale

class FolderSizeColumnProvider(GObject.GObject, Nautilus.ColumnProvider):
    """Provides the custom 'Size (MB)' column in Nautilus list view."""
    
    def __init__(self):
        GObject.Object.__init__(self)
    
    def get_columns(self):
        """Returns the column to be added to the Nautilus list view."""
        return [Nautilus.Column(
            name="FolderSize::size_column",
            attribute="folder_size",
            label=gettext("Size (MB)"),
            description=gettext("Calculates and displays folder sizes in MB"),
            xalign=1.0
        )]

class FolderSizeInfoProvider(GObject.GObject, Nautilus.InfoProvider):
    """Calculates and displays folder sizes with smart caching functionality."""
    
    def __init__(self):
        GObject.Object.__init__(self)
        self.calculating = set()
        self.size_cache = {}
        self.mod_time_cache = {}
        self._setup_gettext()
        
    def _setup_gettext(self):
        """Initializes gettext to localize strings."""
        try:
            locale.setlocale(locale.LC_ALL, "")
        except:
            pass
        bindtextdomain("nautilus-all-folder-size-calculation", "/usr/share/locale")
        textdomain("nautilus-all-folder-size-calculation")
        
    def get_folder_size_mb(self, path):
        """Calculates complete folder size in MB with caching."""
        total = 0
        try:
            with os.scandir(path) as it:
                for entry in it:
                    try:
                        if entry.is_file(follow_symlinks=False):
                            total += entry.stat(follow_symlinks=False).st_size
                        elif entry.is_dir(follow_symlinks=False):
                            if entry.path in self.size_cache:
                                total += self.size_cache[entry.path]
                            else:
                                total += self.get_folder_size_mb(entry.path)
                    except (PermissionError, FileNotFoundError):
                        continue
        except Exception:
            return 0
        
        size_mb = total / (1024 * 1024)
        self.size_cache[path] = size_mb
        self.mod_time_cache[path] = os.path.getmtime(path)
        return size_mb
    
    def get_file_size_mb(self, file):
        """Returns file size in MB."""
        try:
            path = file.get_location().get_path()
            if path:
                return os.stat(path).st_size / (1024 * 1024)
        except Exception:
            return 0

    def is_folder_modified(self, path):
        """Checks if folder has been modified since last calculation."""
        if path not in self.mod_time_cache:
            return True
        try:
            return os.path.getmtime(path) != self.mod_time_cache[path]
        except:
            return True

    def update_file_info(self, file):
        """Updates file information with size data."""
        if file.get_uri_scheme() != 'file':
            file.add_string_attribute('folder_size', gettext("N/A"))
            file.add_float_attribute('folder_size_raw', 0.0)
            return
        
        path = file.get_location().get_path()
        if not path:
            return
            
        if file.is_directory():
            if path in self.size_cache and not self.is_folder_modified(path):
                size_mb = self.size_cache[path]
                file.add_string_attribute('folder_size', f"{size_mb:.4f} MB")
                file.add_float_attribute('folder_size_raw', size_mb)
            elif path not in self.calculating:
                self.calculating.add(path)
                try:
                    size_mb = self.get_folder_size_mb(path)
                    file.add_string_attribute('folder_size', f"{size_mb:.4f} MB")
                    file.add_float_attribute('folder_size_raw', size_mb)
                finally:
                    self.calculating.remove(path)
        else:
            size_mb = self.get_file_size_mb(file)
            file.add_string_attribute('folder_size', f"{size_mb:.4f} MB")
            file.add_float_attribute('folder_size_raw', size_mb)

# Initialize gettext for translations
def initialize_gettext():
    try:
        locale.setlocale(locale.LC_ALL, "")
    except:
        pass
    bindtextdomain("nautilus-all-folder-size-calculation", "/usr/share/locale")
    textdomain("nautilus-all-folder-size-calculation")
