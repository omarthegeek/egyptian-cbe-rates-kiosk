#!/bin/bash
set -e

WEBPAGE_URL="https://raw.githubusercontent.com/omarthegeek/egyptian-cbe-rates-kiosk/refs/heads/main/docs/index.html"
KIOSK_DIR="$HOME/kiosk"
WEBPAGE_LOCALNAME="egypt-rates-kiosk.html"
AUTOSTART_DIR="$HOME/.config/autostart"

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

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   CBE Kiosk Installer                ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Dependencies
echo "▶ Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends xorg openbox

# 2. Download HTML
echo "▶ Downloading kiosk page..."
mkdir -p "$KIOSK_DIR"
curl -fsSL "$WEBPAGE_URL" -o "$KIOSK_DIR/$WEBPAGE_LOCALNAME"

# Write the openbox autostart (runs inside the minimal X session)
mkdir -p "$HOME/.config/openbox"
cat > "$HOME/.config/openbox/autostart" << EOF
# Disable screen blanking
xset s off &
xset -dpms &
xset s noblank &

# Hide cursor
unclutter -idle 0 -root -noevents &

# Launch Chromium
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
  'file://$KIOSK_DIR/$WEBPAGE_LOCALNAME' &
EOF

# Write a minimal .xinitrc that launches openbox
cat > "$HOME/.xinitrc" << 'EOF'
exec openbox-session
EOF

# Auto-login to console (no desktop login screen)
sudo raspi-config nonint do_boot_behaviour B2

# Start X automatically on login
if ! grep -q "startx" "$HOME/.bash_profile" 2>/dev/null; then
  cat >> "$HOME/.bash_profile" << 'EOF'

# Launch kiosk on boot
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  startx
fi
EOF
fi