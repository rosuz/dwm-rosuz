#!/bin/bash

DWM_PATH="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="$DWM_PATH/themes"

if [[ -n "$SUDO_USER" ]]; then
  REAL_HOME="$(eval echo ~$SUDO_USER)"
else
  REAL_HOME="$HOME"
fi

echo "=== dwm 6.8 Installer ==="

# Check dependencies
missing=()
for cmd in make gcc xorg-server xorg-xinit libx11 libxft libxinerama feh polybar dunst i3lock-color maim xclip ffmpeg xautolock imagemagick xdotool upower; do
  if ! command -v "$cmd" &>/dev/null && ! pacman -Qi "$cmd" &>/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

# For pkg-config libs
for lib in x11 xft xinerama; do
  if ! pkg-config --exists "$lib" 2>/dev/null; then
    lib_pkg="lib${lib}"
    [[ "$lib" == "xinerama" ]] && lib_pkg="libxinerama"
    missing+=("$lib_pkg")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Missing dependencies: ${missing[*]}"
  echo "Install them first:"
  echo "  sudo pacman -S ${missing[*]}"
  exit 1
fi

# Theme selection
themes=()
while IFS= read -r d; do
  name=$(basename "$d")
  [[ "$name" == "current" ]] && continue
  themes+=("$name")
done < <(find "$THEME_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

echo ""
echo "Available themes:"
for i in "${!themes[@]}"; do
  echo "  $((i+1)). ${themes[$i]}"
done
echo ""
read -rp "Select theme [1, default=nord]: " choice

if [[ -z "$choice" ]]; then
  theme="nord"
elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#themes[@]} )); then
  theme="${themes[$((choice-1))]}"
else
  theme="$choice"
fi

if [[ ! -d "$THEME_DIR/$theme" ]]; then
  echo "Theme '$theme' not found, falling back to nord"
  theme="nord"
fi

echo "Selected theme: $theme"

# Generate theme
"$DWM_PATH/scripts/dwm-theme-switch" "$theme"

# Add dwm scripts to PATH
path_line="export PATH=\"\$PATH:$REAL_HOME/.local/share/dwm/scripts\""
grep -qxF "$path_line" "$REAL_HOME/.bashrc" 2>/dev/null || echo "$path_line" >> "$REAL_HOME/.bashrc"

# Install config files
echo ""
read -rp "Copy config files from dwm/config/ to ~/.config/? [Y/n] " ans
if [[ ! "$ans" =~ ^[nN] ]]; then
    cp -r "$DWM_PATH/config/." "$REAL_HOME/.config/"
    echo "Config files installed."
fi

# Deploy runtime files to ~/.local/share/dwm
echo "Deploying runtime files to ~/.local/share/dwm..."
rm -rf "$REAL_HOME/.local/share/dwm"
mkdir -p "$REAL_HOME/.local/share/dwm"
cp -r "$DWM_PATH/scripts" "$REAL_HOME/.local/share/dwm/"
cp -r "$DWM_PATH/themes" "$REAL_HOME/.local/share/dwm/"
cp -r "$DWM_PATH/templates" "$REAL_HOME/.local/share/dwm/"
echo "Runtime files deployed."

# Install Alacritty desktop entry for xdg-terminal-exec
mkdir -p "$REAL_HOME/.local/share/applications"
if [[ -f "$DWM_PATH/applications/Alacritty.desktop" ]]; then
    cp "$DWM_PATH/applications/Alacritty.desktop" "$REAL_HOME/.local/share/applications/"
    echo "Alacritty desktop entry installed."
fi

# Install browser desktop entry
if [[ -f "$DWM_PATH/applications/org.dwm.browser.desktop" ]]; then
    cp "$DWM_PATH/applications/org.dwm.browser.desktop" "$REAL_HOME/.local/share/applications/"
    echo "Browser desktop entry installed."
fi

update-desktop-database "$REAL_HOME/.local/share/applications" 2>/dev/null || true

# Install xdg-terminal-exec config
if [[ -f "$DWM_PATH/config/xdg-terminals.list" ]]; then
    cp "$DWM_PATH/config/xdg-terminals.list" "$REAL_HOME/.config/xdg-terminals.list"
    echo "xdg-terminals.list installed."
fi

# Install .xinitrc
echo ""
read -rp "Copy .xinitrc to $REAL_HOME/? [Y/n] " ans
if [[ ! "$ans" =~ ^[nN] ]]; then
    cp "$DWM_PATH/scripts/.xinitrc" "$REAL_HOME/.xinitrc"
    echo ".xinitrc installed."
fi

# Input configuration
echo ""
read -rp "Configure keyboard and touchpad now? [Y/n] " ans
if [[ ! "$ans" =~ ^[nN] ]]; then
    "$DWM_PATH/scripts/dwm-input-config"
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Start dwm:"
echo "  startx  (if using .xinitrc)"
echo "  or select dwm in your display manager (SDDM/LightDM)"
echo ""
echo "Keybinds:"
echo "  Mod+Space    → dwm-launch-menu drun"
echo "  Mod+Return   → zoom"
echo "  Mod+Shift+b  → browser"
echo "  Mod+Print    → screenshot (region)"
echo "  Mod+Shift+Print → screenrecord toggle"
echo "  Mod+Ctrl+l   → lock screen"
echo "  Mod+Shift+q  → quit dwm"
