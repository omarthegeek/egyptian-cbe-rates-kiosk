#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/YOUR_USERNAME/egypt-rates-kiosk/main"
KIOSK_DIR="$HOME/kiosk"
AUTOSTART_DIR="$HOME/.config/autostart"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   CBE Kiosk Installer                ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Dependencies
echo "▶ Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y chromium-browser unclutter curl

# 2. Download HTML
echo "▶ Downloading kiosk page..."
mkdir -p "$KIOSK_DIR"
curl -fsSL "$REPO/kiosk/egypt-rates-kiosk.html" -o "$KIOSK_DIR/egypt-rates-kiosk.html"

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
Exec=/bin/bash -c "sleep 8 && chromium-browser --kiosk --noerrdialogs --disable-infobars --no-first-run --disable-translate --check-for-update-interval=31536000 'file://$KIOSK_DIR/egypt-rates-kiosk.html'"
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

cat > "$AUTOSTART_DIR/unclutter.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Unclutter
Exec=unclutter -idle 1 -root
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

echo ""
echo "✅  Done! Reboot to launch the kiosk automatically."
echo ""
echo "    To test now:"
echo "    chromium-browser --kiosk 'file://$KIOSK_DIR/egypt-rates-kiosk.html'"
echo ""
echo "    To exit kiosk: Alt+F4"
echo ""