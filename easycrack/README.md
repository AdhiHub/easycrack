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

## What You Can Do With Easycrack

| Feature | What it does |
|---------|-------------|
| **Auto WiFi Scan** | Scans all nearby WiFi networks and shows them as a simple numbered list |
| **One-Click Capture** | Select a network by number — it automatically captures the WPA handshake |
| **Deauth Attack** | Sends deauth packets to force clients to reconnect and reveal the handshake |
| **Auto Crack** | Runs aircrack-ng with your wordlist to crack the captured handshake |
| **Monitor Mode** | Enables/disables monitor mode automatically — no manual commands needed |
| **Interface Detection** | Auto-detects your wireless interface — no need to remember interface names |
| **Termux Support** | Works on Android Termux too (with root) |

## How To Use (Step by Step)

### Method 1: Full Auto (Recommended for beginners)

```bash
sudo easycrack
```

1. Select option **1 (Full auto)**
2. Pick your wireless interface from the list (type a number)
3. Wait 10 seconds for network scan
4. Pick a network from the numbered list
5. Wait up to 30 seconds for handshake capture
6. Enter path to your wordlist (or press Enter for default)
7. Sit back — aircrack-ng does the rest

### Method 2: Capture Only

```bash
sudo easycrack
```

- Select option **2 (Capture handshake only)**
- Same steps as above, but stops after saving the .cap file
- You can crack the handshake later with Method 3

### Method 3: Crack an Existing Capture

```bash
sudo easycrack
```

- Select option **3 (Crack an existing .cap file)**
- Enter the path to your .cap file
- Enter your wordlist path
- Let aircrack-ng crack it

### Method 4: Quick Crack (Command Line)

```bash
sudo easycrack --crack capture_file-01.cap
```

Skips the menu entirely. Just point to a .cap file and go.

### Method 5: Manual Install (No curl)

```bash
git clone https://github.com/mystry112000/AdhiHub.git
cd AdhiHub/easycrack
chmod +x easycrack.sh
sudo ./easycrack.sh
```

## What Happens Behind The Scenes

1. **Interface detection** — finds your wlan/wl interface
2. **Monitor mode** — runs `airmon-ng` or `iw` to enable monitoring
3. **Network scan** — runs `airodump-ng` for 10 seconds
4. **Handshake capture** — runs `airodump-ng` on the target + `aireplay-ng` deauth
5. **Crack** — runs `aircrack-ng` with your wordlist
6. **Cleanup** — removes temp files, disables monitor mode

## Requirements

- **Linux** or **Termux** (Android with root)
- aircrack-ng suite (`sudo apt install aircrack-ng` or `pkg install aircrack-ng`)
- sudo/root access (required for monitor mode)
- Wireless adapter that supports monitor mode

## Uninstall

```bash
sudo rm /usr/local/bin/easycrack
```

---

> **⚠️ DISCLAIMER: FOR EDUCATIONAL PURPOSES ONLY — USE AT YOUR OWN RISK.**
>
> This tool is for educational purposes to help understand WiFi security. By using this tool, you agree that:
> - You will only use it on networks you own or have explicit permission to test
> - The developer(s) of Easycrack and AdhiHub are NOT responsible for any misuse, damage, or legal issues caused by this tool
> - You use this tool AT YOUR OWN RISK
> - Unauthorized access to networks is illegal in most jurisdictions
>
> **The developer(s) assume NO liability for any actions or consequences resulting from the use of this tool. If you do not agree, do not use it.**
