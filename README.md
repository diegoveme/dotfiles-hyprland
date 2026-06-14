# dotfiles

My desktop configuration for **Arch Linux + Hyprland** (Wayland).

Unified theme throughout: **Tokyo Night**.

> 📖 For the in-depth explanation of **every component and the reasoning behind
> it**, see **[`DOCUMENTATION.md`](DOCUMENTATION.md)**. This README is the quick
> overview.

## Contents

| Folder               | What it is                                                          |
|----------------------|--------------------------------------------------------------------|
| `.config/hypr`       | Hyprland (Lua), lock, idle, wallpaper, scripts and monitors        |
| `.config/waybar`     | Bar: 10 workspaces · CPU · RAM · temp · audio · Bluetooth · network · battery |
| `.config/btop`       | Full-screen system monitor                                         |
| `.config/rofi`       | App launcher and wallpaper picker                                  |
| `.config/wlogout`    | Graphical logout menu (Super+Esc)                                  |
| `.config/dunst`      | Notifications                                                      |
| `.config/kitty`      | Terminal                                                           |
| `.config/oh-my-posh` | Terminal prompt (0sadiPaper theme)                                |
| `.config/fastfetch`  | System info when opening the terminal (custom ASCII logo)          |
| `.config/wallpapers` | Wallpaper library (the active one is `hypr/current-wallpaper`)     |
| `bashrc`             | `.bashrc` (loads oh-my-posh + fastfetch)                          |
| `.local/bin/keybinds`| Command that shows all shortcuts (type `keybinds`)               |
| `.local/share/applications` | `NoDisplay` overrides that hide junk CLI/config entries from the launcher |
| `.config/gtk-3.0` `.config/gtk-4.0` | GTK dark theme settings (Tokyonight-Dark)         |
| `.config/Kvantum` `.config/qt5ct` `.config/qt6ct` | Qt dark theme (Kvantum)             |
| `etc/sddm.conf.d`    | SDDM config (Wayland greeter + theme)                            |
| `usr/share/sddm/themes/tokyo-lock` | Custom SDDM login theme (hyprlock-style)          |

## Shortcuts (Super key = Windows)

### Apps and system
| Shortcut               | Action                                   |
|------------------------|------------------------------------------|
| `Super + Space`        | App launcher (rofi)                      |
| `Super + Return`       | Terminal                                 |
| `Super + E`            | File manager                             |
| `Super + Esc`          | Graphical system menu (wlogout)          |
| `Super + Ctrl + Space` | Change wallpaper                         |
| `Super + L`            | Lock screen                              |
| `Super + ,`            | Dismiss notification                     |

### Screenshots, recording and OCR
| Shortcut               | Action                                   |
|------------------------|------------------------------------------|
| `Super + Shift + S`    | Capture a selected area → saved + clipboard |
| `Super + Shift + R`    | Capture full screen → saved + clipboard  |
| `Super + Alt + R`      | Record region (with audio) — repeat to stop |
| `Super + Alt + Shift + R` | Record full screen                    |
| `Super + Shift + O`    | OCR: extract text from a region          |

Screenshots are saved to `~/Pictures/Screenshots/` and also copied to the clipboard.

### Zoom (follows the cursor)
| Shortcut               | Action                                   |
|------------------------|------------------------------------------|
| `Super + =` / `Super + -` | Zoom in / out                         |
| `Super + Ctrl + scroll`| Zoom in / out with the mouse             |
| 2-finger pinch         | Zoom in / out on the touchpad (continuous) |
| `Super + Ctrl + 0`     | Reset zoom                               |

The touchpad also does **3-finger horizontal swipe → switch workspace**.

### Windows
| Shortcut               | Action                                   |
|------------------------|------------------------------------------|
| `Super + W`            | Close window                             |
| `Super + F`            | Fullscreen                               |
| `Super + T`            | Floating / tiling                        |
| `Super + G`            | Group windows                            |
| `Super + arrows`       | Move focus                               |
| `Super + Shift + arrows` | Swap window                            |
| `Alt + Tab`            | Cycle windows                            |
| `Super + Tab` / `Super + Shift + Tab` | Next / previous workspace |
| `Super + 1..0`         | Go to workspace                          |

### Monitors
| Shortcut               | Action                                   |
|------------------------|------------------------------------------|
| `Super + Ctrl + S`     | Cycle scaling (1 → 1.25 → 1.5 → 2)        |
| `Super + Ctrl + M`     | Mirror / extend the external monitor     |
| `Super + Ctrl + D`     | Turn the laptop panel off / on           |

- An external monitor **extends on its own** (as a separate screen) when plugged
  in. Use `Super + Ctrl + M` only if you want to **mirror** instead; press it
  again to go back to extending.
- The bar, wallpaper and notifications all show on **both** monitors; the app
  launcher and notifications appear on whichever screen you're using.
- **Tip:** plug the external in **extended** (the default). If you connect it
  while mirroring, the external can come up with no bar/wallpaper (it never gets
  its own output); unplug and replug the cable to fix it.
- On **closing the lid**: if there is an external, it keeps going on the external; if not, it locks and suspends.

**Volume and brightness** keys show an OSD (swayosd).

## Top bar (waybar)

- **Left:** 10 workspaces — current as a dot, in-use ones in a soft blue, empty
  ones dimmed. Next to them, a **focused-monitor indicator** (only with two
  screens): `󰌢 Laptop` (blue) or `󰍹 External` (green), showing where keyboard
  focus is. It updates instantly (driven by Hyprland events).
- **Right:** CPU · RAM · temp · volume · AirPods · Bluetooth · network · battery · tray.
  CPU/RAM/temp open `btop` on click; **clicking the network icon opens the
  Wi-Fi menu** (`impala`, for the `iwd` backend) and **clicking the Bluetooth
  icon opens the Bluetooth menu** (`bluetui`) — both in a terminal. The
  Bluetooth icon turns green when a device is connected.
- **AirPods battery** (🎧 icon) shows the real charge of connected AirPods —
  see [AirPods battery](#airpods-battery) below. The volume uses a speaker icon
  (🔊) so it isn't confused with it.

## AirPods battery

The bar shows the **real battery** of connected AirPods (lowest of the two buds,
with full L/R/Case breakdown in the tooltip; the icon turns red below 20% and
green while charging). AirPods don't report battery through standard BlueZ
(Apple uses a proprietary BLE broadcast), so a tiny scanner decodes it:

- `~/.local/share/airstatus/airpods.py` — scans Apple's BLE advertisement and
  writes `/tmp/airpods.json` (decoding adapted from
  [AirStatus](https://github.com/delphiki/AirStatus), rewritten for modern
  `bleak`). It runs as the user service **`airstatus.service`**.
- `~/.config/waybar/scripts/airpods.sh` — the waybar `custom/airpods` module
  reads that file and renders the icon (empty/hidden when no AirPods are near).

Setup (the `bleak` dependency lives in a venv, not committed):

```sh
cd ~/.local/share/airstatus
python3 -m venv venv && ./venv/bin/pip install bleak
systemctl --user enable --now airstatus.service
```

### AirPods audio in calls (hi-fi vs mic)

Classic Bluetooth can't send hi-fi audio **and** capture the mic at the same
time — A2DP (stereo, AAC) is output-only; the moment an app records, a headset
normally flips to HFP, which drops the whole call to mono "telephone" quality.
AirPods do hi-fi+mic together only through an Apple-proprietary path that isn't
exposed to Linux, so this setup **keeps the AirPods permanently in hi-fi A2DP**
and uses the **laptop mic** for calls:

- WirePlumber's auto-switch is disabled in
  `.config/wireplumber/wireplumber.conf.d/50-bluetooth-no-autoswitch.conf`
  (`bluetooth.autoswitch-to-headset-profile = false`).
- The laptop mic is the default input.

When you actually need the AirPods mic (e.g. away from the laptop), press
**`Super + Alt + M`** (`scripts/airpods-mic.sh`) to toggle into call mode
(HFP, AirPods mic on, audio mono for that call); press again to return to hi-fi.

## Wallpapers

- Change them with **`Super + Ctrl + Space`** (picker with thumbnails).
- The library is in `~/.config/wallpapers/`. Add images there and they show up automatically.
- The active wallpaper is the `~/.config/hypr/current-wallpaper` link.
- Rendered with **swaybg**, which covers every monitor (internal + external).

## Auto-lock

Lock after **5 min**, screen off after **6 min** (hypridle).

## Terminal

- **Prompt:** oh-my-posh with the `0sadiPaper` theme (folder, git, battery, time).
- **fastfetch** shows the system info (with a custom ASCII logo) when opening the terminal.
- Both are loaded from `bashrc`.

## Login screen (SDDM)

- Custom theme **`tokyo-lock`** — a hyprlock-style greeter: blurred wallpaper +
  big clock + minimal Tokyo Night login (password masked with `♡`).
- SDDM runs its greeter on **Wayland** (`weston`), not X11 — this avoids a black
  screen on the hybrid AMD+NVIDIA GPU. Config in `etc/sddm.conf.d/10-wayland.conf`.

> The theme's `background.jpg` is a blurred copy of the wallpaper (made with
> `ffmpeg`); regenerate it if you change the wallpaper.

## Dark theme (system-wide)

Everything renders dark/black, Tokyo Night:

- **GTK apps** use the `Tokyonight-Dark` theme (black tweak) + `prefer-dark`.
  Set in `gtk-3.0/settings.ini`, `gtk-4.0/settings.ini` and gsettings; the
  `GTK_THEME` env in Hyprland enforces it.
- **Qt apps** go dark through **Kvantum** (`KvArcDark`). `qt5ct`/`qt6ct` set the
  style; Hyprland exports `QT_QPA_PLATFORMTHEME=qt6ct` and `QT_STYLE_OVERRIDE=kvantum`.

The `Tokyonight-Dark` GTK theme is built from source (needs `sassc`) into
`~/.themes` — it is not committed here. Rebuild it with a Tokyo Night GTK theme
generator using the **dark** color variant and the **black** tweak, then the
configs in this repo pick it up.

## Notes / hardware

- Laptop: ASUS TUF A15 (AMD iGPU drives the panel, NVIDIA is offload).
- `asusctl` (from the asus-linux **g14** repo) handles fan curves, charge limit
  and keyboard backlight; `asusd` starts on its own via udev.
- Fn media keys may be unresponsive for the first few seconds after boot
  (asus-nb-wmi warms up).

## Dependencies

```sh
sudo pacman -S --needed \
    hyprland waybar btop kitty rofi-wayland \
    hyprlock hypridle swaybg dunst swayosd socat \
    grim slurp wl-clipboard libnotify brightnessctl playerctl impala \
    bluez bluez-utils \
    wf-recorder tesseract tesseract-data-eng tesseract-data-spa jq \
    fastfetch ttf-jetbrains-mono-nerd noto-fonts-emoji \
    sddm weston \
    qt5ct qt6ct kvantum kvantum-qt5 sassc
# AUR:
#   wlogout  oh-my-posh-bin
```

ASUS power profiles / fan / charge control use **asusctl**, installed from the
asus-linux **g14** repo (the AUR build is unsupported). Add the repo's GPG key,
append `[g14] Server = https://arch.asus-linux.org` to `/etc/pacman.conf`, then
`sudo pacman -Suy asusctl rog-control-center`. The `asusd` service starts on
its own via udev. **ROG Control Center** is the GUI for it (in the app launcher).

The Bluetooth menu uses **`bluetui`** (the TUI companion to `impala`). Install it
from its official release binary:

```sh
curl -sL -o bluetui \
  https://github.com/pythops/bluetui/releases/latest/download/bluetui-x86_64-linux-musl
chmod +x bluetui && sudo install -m 755 bluetui /usr/local/bin/bluetui
```

## Installation

```sh
cp -r .config/* ~/.config/
cp bashrc ~/.bashrc
mkdir -p ~/.local/bin && cp .local/bin/keybinds ~/.local/bin/

# Hide junk CLI/config entries from the app launcher (NoDisplay overrides):
mkdir -p ~/.local/share/applications && cp .local/share/applications/*.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications

# System files (need root):
sudo cp -r etc/sddm.conf.d/* /etc/sddm.conf.d/
sudo cp -r usr/share/sddm/themes/tokyo-lock /usr/share/sddm/themes/
# then add a background.jpg (blurred wallpaper) into the theme folder
```

> Type **`keybinds`** in any terminal to see the full list of shortcuts.

> The files use absolute paths to `/home/diegoveme`. Adjust them if your user
> is different (in `hypr/scripts/*`, `hyprlock.conf`, the autostart
> and `fastfetch/config.jsonc`).
