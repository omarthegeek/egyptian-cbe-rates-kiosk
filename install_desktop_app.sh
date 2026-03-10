#!/bin/bash
set -e

WEBPAGE_URL="https://raw.githubusercontent.com/omarthegeek/cbe-rates-kiosk/refs/heads/main/docs/index.html"
KIOSK_DIR="$HOME/kiosk"
WEBPAGE_LOCALNAME="egypt-rates-kiosk.html"
AUTOSTART_DIR="$HOME/.config/autostart"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   CBE Kiosk Installer                ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Dependencies
echo "▶ Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y unclutter curl

## Check for Chromium package (name differs across distros)
if apt-cache show chromium &>/dev/null; then
    sudo apt-get install -y chromium
    CHROMIUM_BIN="chromium"
elif apt-cache show chromium-browser &>/dev/null; then
    sudo apt-get install -y chromium-browser
    CHROMIUM_BIN="chromium-browser"
else
    echo "❌ Could not find Chromium. Install it manually then re-run."
    exit 1
fi

# 2. Download HTML
echo "▶ Downloading kiosk page..."
mkdir -p "$KIOSK_DIR"
curl -fsSL "$WEBPAGE_URL" -o "$KIOSK_DIR/$WEBPAGE_LOCALNAME"

# 3. Disable screen blanking
echo "▶ Disabling screen blanking..."
mkdir -p "$HOME/.config/lxsession/LXDE-pi"
cat > "$HOME/.config/lxsession/LXDE-pi/autostart" << 'EOF'
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xset s off
@xset -dpms
@xset s noblank
EOF

# Disable via lightdm (system level)
sudo sed -i 's/#xserver-command=X/xserver-command=X -s 0 -dpms/' /etc/lightdm/lightdm.conf 2>/dev/null || true

# Chromium flags to prevent sleep (add to the kiosk Exec line)
# --disable-features=InfiniteSessionRestore prevents Chromium sleep tab throttling

# Disable Pi's built-in screen blanking (console level, catches edge cases)
sudo sed -i 's/^BLANK_TIME=.*/BLANK_TIME=0/' /etc/kbd/config 2>/dev/null || true
sudo sed -i 's/^POWERDOWN_TIME=.*/POWERDOWN_TIME=0/' /etc/kbd/config 2>/dev/null || true

# For Bookworm (uses labwc/wayfire compositor instead of X11)
if [ -f /etc/wayfire/wayfire.ini ] || [ -d "$HOME/.config/wayfire" ]; then
    mkdir -p "$HOME/.config/wayfire"
    cat >> "$HOME/.config/wayfire/wayfire.ini" << 'EOF'

[idle]
screensaver_timeout = 0
dpms_timeout = 0
EOF
fi

# 4. Autostart kiosk
echo "▶ Setting up autostart..."
mkdir -p "$AUTOSTART_DIR"

# Write launcher script (allows safe line breaks for Chromium flags)
cat > "$KIOSK_DIR/launch.sh" << EOF
#!/bin/bash
sleep 8
unclutter -idle 0 -root -noevents &
$CHROMIUM_BIN \\
  --kiosk \\
  --noerrdialogs \\
  --disable-infobars \\
  --no-first-run \\
  --disable-translate \\
  --check-for-update-interval=31536000 \\
  --disable-features=InfiniteSessionRestore \\
  --disable-background-timer-throttling \\
  --disable-renderer-backgrounding \\
  'file://$KIOSK_DIR/$WEBPAGE_LOCALNAME'
EOF
chmod +x "$KIOSK_DIR/launch.sh"

# .desktop simply calls the launcher
cat > "$AUTOSTART_DIR/cbe-kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Name=CBE Rates Kiosk
Exec=/bin/bash $KIOSK_DIR/launch.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

echo ""
echo "✅  Done! Reboot to launch the kiosk automatically."
echo ""
echo "    To test now:"
echo "    $CHROMIUM_BIN --kiosk 'file://$KIOSK_DIR/$WEBPAGE_LOCALNAME'"
echo ""
echo "    To exit kiosk: Alt+F4"
echo ""
