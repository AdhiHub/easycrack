# EASYCRACK

Automated aircrack-ng wrapper — one command to scan, capture handshakes, and crack WiFi passwords.

Part of the **AdhiHub** tool collection.

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/mystry112000/AdhiHub/main/easycrack/install.sh | bash
```

That's it. One command. Then run:

```bash
sudo easycrack
```

## Usage

| Command | What it does |
|---------|-------------|
| `sudo easycrack` | Interactive menu — pick a mode, pick a network, it does the rest |
| `sudo easycrack --crack capture.cap` | Skip scanning, just crack an existing handshake |
| `sudo easycrack --help` | Show help |

### Interactive Modes

1. **Full auto** — scan networks → select one → capture handshake → crack with wordlist
2. **Capture only** — scan → capture → save .cap file (don't crack)
3. **Crack existing** — point to a .cap file and crack it

## What It Does For You

- Detects your wireless interface automatically
- Enables/disables monitor mode (no manual airmon-ng)
- Scans networks and shows them as a simple numbered list
- Captures WPA handshake with deauth attack
- Cracks with aircrack-ng

No need to remember complex aircrack-ng syntax. Just type numbers and press Enter.

## Install Manually

```bash
git clone https://github.com/mystry112000/AdhiHub.git
cd AdhiHub/easycrack
chmod +x easycrack.sh
sudo ./easycrack.sh
```

## Requirements

- **Linux** or **Termux** (Android)
- aircrack-ng suite (`sudo apt install aircrack-ng` or `pkg install aircrack-ng`)
- sudo access (for monitor mode)
- Wireless adapter that supports monitor mode

## Uninstall

```bash
sudo rm /usr/local/bin/easycrack
```
