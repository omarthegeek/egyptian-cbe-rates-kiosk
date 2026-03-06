#!/bin/bash
set -e

WEBPAGE_URL="https://raw.githubusercontent.com/omarthegeek/egyptian-cbe-rates-kiosk/refs/heads/main/docs/index.html"
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

# 4. Autostart kiosk
echo "▶ Setting up autostart..."
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/cbe-kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Name=CBE Rates Kiosk
Exec=/bin/bash -c "sleep 8 && $CHROMIUM_BIN --kiosk --noerrdialogs --disable-infobars --no-first-run --disable-translate --check-for-update-interval=31536000 'file://$KIOSK_DIR/$WEBPAGE_LOCALNAME'"
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

cat > "$AUTOSTART_DIR/unclutter.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Unclutter
Exec=unclutter -idle 0 -root -noevents
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
