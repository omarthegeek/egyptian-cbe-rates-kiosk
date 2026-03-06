#!/bin/bash
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   CBE Kiosk Uninstaller              ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Remove kiosk files
echo "▶ Removing kiosk files..."
rm -rf "$HOME/kiosk"

# 2. Remove autostart entries
echo "▶ Removing autostart entries..."
rm -f "$HOME/.config/autostart/cbe-kiosk.desktop"
rm -f "$HOME/.config/autostart/unclutter.desktop"

# 3. Remove openbox config
echo "▶ Removing Openbox config..."
rm -f "$HOME/.config/openbox/autostart"
rm -f "$HOME/.xinitrc"

# 4. Remove startx from bash_profile
echo "▶ Removing auto-startx from bash_profile..."
sed -i '/# Launch kiosk on boot/,/fi/d' "$HOME/.bash_profile"

# 5. Restore normal desktop boot
echo "▶ Restoring desktop boot..."
sudo raspi-config nonint do_boot_behaviour B4

echo ""
echo "✅  Uninstalled. Reboot to return to normal desktop."
echo ""
echo "    sudo reboot"
echo ""