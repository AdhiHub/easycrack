#!/usr/bin/env bash
#
# easycrack installer (part of AdhiHub)
# Run: curl -fsSL https://raw.githubusercontent.com/mystry112000/AdhiHub/main/easycrack/install.sh | bash
#

set -e

REPO="https://raw.githubusercontent.com/mystry112000/AdhiHub/main/easycrack"
BIN="${DESTDIR:-/usr/local/bin}"

GREEN='\033[1;32m'; CYAN='\033[1;36m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; RESET='\033[0m'

echo -e "${CYAN}
  ╔══════════════════════════════╗
  ║   EASYCRACK INSTALLER v1.0   ║
  ╚══════════════════════════════╝${RESET}"

# Detect Termux
if [ -n "$PREFIX" ] && [ -d "$PREFIX" ]; then
  echo -e "${YELLOW}[*] Detected Termux${RESET}"
  BIN="$PREFIX/bin"
fi

# Install dependencies
echo -e "${YELLOW}[*] Installing dependencies...${RESET}"
if command -v apt &>/dev/null; then
  sudo apt update -qq && sudo apt install -y -qq aircrack-ng curl 2>/dev/null || true
elif command -v pkg &>/dev/null; then
  pkg update -y && pkg install -y aircrack-ng curl
elif command -v pacman &>/dev/null; then
  sudo pacman -Sy --noconfirm aircrack-ng curl 2>/dev/null || true
else
  echo -e "${YELLOW}⚠ Could not auto-install. Make sure aircrack-ng is installed.${RESET}"
fi

# Download easycrack
echo -e "${YELLOW}[*] Downloading easycrack...${RESET}"
if command -v curl &>/dev/null; then
  sudo curl -fsSL "$REPO/easycrack.sh" -o "$BIN/easycrack" 2>/dev/null || curl -fsSL "$REPO/easycrack.sh" -o "$BIN/easycrack"
else
  sudo wget -q "$REPO/easycrack.sh" -O "$BIN/easycrack" 2>/dev/null || wget -q "$REPO/easycrack.sh" -O "$BIN/easycrack"
fi

sudo chmod +x "$BIN/easycrack"

echo -e "${GREEN}✓ Installed to $BIN/easycrack${RESET}"
echo -e ""
echo -e "${CYAN}Usage:${RESET}"
echo -e "  sudo easycrack          # Full interactive menu"
echo -e "  sudo easycrack --crack <file>  # Crack existing capture"
echo -e ""
echo -e "${YELLOW}First time? Just run: sudo easycrack${RESET}"
