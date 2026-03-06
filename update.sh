#!/bin/bash
echo "▶ Updating CBE kiosk..."
rm -rf "$HOME/kiosk"
rm -f "$HOME/.config/autostart/cbe-kiosk.desktop"
rm -f "$HOME/.config/autostart/unclutter.desktop"
echo "✅  Uninstalled. Reboot to apply."