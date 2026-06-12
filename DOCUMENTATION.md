# Full documentation

Deep reference for this setup — **what** each piece is, **why** it exists, and
**how** it works. For a quick overview and the shortcut list, see
[`README.md`](README.md).

> Everything is **Arch Linux + Hyprland (Wayland)**, themed **Tokyo Night**.
> The guiding principle: a tiling desktop that still lets windows float freely,
> every action reachable from the keyboard, one coherent dark theme end to end,
> and no surprises (no black screens, no half-broken keys).

## Table of contents

1. [Hardware & boot](#1-hardware--boot)
2. [Hyprland (`hyprland.lua`)](#2-hyprland-hyprlandlua)
3. [Keybindings](#3-keybindings)
4. [Scripts](#4-scripts)
5. [Top bar (waybar)](#5-top-bar-waybar)
6. [Lock & idle (hyprlock + hypridle)](#6-lock--idle-hyprlock--hypridle)
7. [Wallpaper](#7-wallpaper)
8. [Notifications (dunst)](#8-notifications-dunst)
9. [Theming (Tokyo Night everywhere)](#9-theming-tokyo-night-everywhere)
10. [Terminal (kitty + bash + prompt)](#10-terminal-kitty--bash--prompt)
11. [Login screen (SDDM)](#11-login-screen-sddm)
12. [App launcher (rofi)](#12-app-launcher-rofi)
13. [Network (iwd + impala)](#13-network-iwd--impala)
14. [ASUS power (asusctl)](#14-asus-power-asusctl)
15. [System menu (wlogout)](#15-system-menu-wlogout)
16. [Known issues & pending](#16-known-issues--pending)
17. [Maintenance & gotchas](#17-maintenance--gotchas)
18. [System-level changes (outside this repo)](#18-system-level-changes-outside-this-repo)

---

## 1. Hardware & boot

**Laptop:** ASUS TUF Gaming A15 (FA506NF). **Hybrid GPU:** AMD Radeon 680M
(integrated, drives the internal `eDP-1` panel) + NVIDIA RTX 2050 (offload /
external outputs). Single system disk `nvme1n1` (`p1` = EFI `/boot`, `p2` = `/`
ext4). The second disk `nvme0n1` is empty.

**Boot chain:** `GRUB → UKI → systemd-stub → kernel`.

- The install is a **Unified Kernel Image** (`/boot/EFI/Linux/arch-linux.efi`):
  kernel + initramfs + cmdline bundled into one signed EFI binary. GRUB simply
  boots that image. There is no loose `initramfs-linux.img` — it lives inside
  the UKI. This is normal and healthy.
- **Why this matters:** to change the kernel command line or rebuild the
  initramfs you regenerate the UKI with `sudo mkinitcpio -p linux`. The file's
  **modification date stays fixed (a deterministic/reproducible-build stamp)** —
  don't read that as "it didn't rebuild"; the contents (sha256) do change.

**Why brightness works (`acpi_backlight=native`):** the kernel cmdline carries
`acpi_backlight=native`. Without it the only backlight interface exposed is
`nvidia_wmi_ec_backlight`, which doesn't drive the real panel. The flag exposes
`amdgpu_bl1` (the AMD panel backlight), so `Fn+F7/F8` (via swayosd) actually
change the brightness.

**Why the greeter runs on Wayland:** see [§11](#11-login-screen-sddm). Short
version: the X11 SDDM greeter crashed on the hybrid GPU and produced a black
screen at boot; switching SDDM to a Wayland greeter (weston) fixed it.

---

## 2. Hyprland (`hyprland.lua`)

`~/.config/hypr/hyprland.lua` — the compositor config. This Hyprland build uses
the **Lua config format** (`hl.bind`, `hl.config`, `hl.monitor`, `hl.env`,
`hl.window_rule`, `hl.gesture`, dispatchers like `hl.dsp.*`).

> **Critical gotcha:** in Lua mode the classic `hyprctl keyword ...` is **not**
> accepted. To poke settings at runtime use `hyprctl eval 'hl.config({...})'`,
> and dispatchers use Lua syntax, e.g.
> `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'`. All the scripts
> follow this.

### Monitors

- `eDP-1` is pinned to **1920x1080@144, scale = 1** (native, no fractional
  scaling — the panel is 1080p and 1× looks correct).
- A catch-all `output = ""` rule makes **any external monitor** light up at its
  preferred mode and **extend automatically** when plugged in.

### Environment variables (`hl.env`)

- `XCURSOR_SIZE` / `HYPRCURSOR_SIZE = 24` — cursor size.
- `GTK_THEME = Tokyonight-Dark`, `QT_QPA_PLATFORMTHEME = qt6ct`,
  `QT_STYLE_OVERRIDE = kvantum` — force the **dark theme** on GTK and Qt apps
  (see [§9](#9-theming-tokyo-night-everywhere)).
- `scroll_event_delay = 0` — snappier scroll (also helps cursor-zoom by mouse).

### Look & feel

- `gaps_in = 4`, `gaps_out = 8`, `border_size = 2`, gradient active border.
- `rounding = 10`, **`active_opacity = 0.92` / `inactive_opacity = 0.84`**, blur
  enabled (frosted glass), drop shadows. Layer-rule blur is also applied to
  `rofi` and `waybar` so the launcher and bar look like frosted glass.
- `layout = "dwindle"`, `resize_on_border = true` (drag any border/gap to
  resize — handy for floating windows).
- **`misc.force_default_wallpaper = 0` + `disable_hyprland_logo = true`** — this
  is important: by default Hyprland paints its own random anime/mascot wallpaper
  *underneath*. With hyprpaper on top, any gap/transition let the built-in one
  show through ("a wallpaper behind the wallpaper"). Setting these to 0/true
  removes the built-in background entirely.

### Animations

A full set of bezier/spring curves and per-leaf animations (windows, layers,
workspaces, fades, zoomFactor). Tuned for quick-but-smooth motion.

### Gestures

Two working touchpad gestures (native Hyprland gesture engine):

- **2-finger pinch → zoom** in/out, continuous and anchored to the cursor
  (live `cursorZoom`).
- **3-finger horizontal swipe → switch workspace.**

Note on what's *not* possible: a **2-finger swipe** can't be a gesture — libinput
treats 2 fingers as scroll, so only pinch (2 fingers) and 3+-finger swipes are
real gestures. And `cursorZoom`'s continuous mode needs a pinch scale, so a
swipe can only do stepped zoom. Hence pinch is the native, fluid touchpad zoom.

### Window rules

- Suppress maximize events from all apps (nicer tiling behavior).
- An XWayland drag fix.
- `hyprland-run` floats bottom-left.
- (TUIs opened from the bar — btop, impala — intentionally open **tiled**, not
  floating; the user prefers them in the tiling layout.)

### Autostart (`hyprland.start`)

- `sleep 2 && waybar` — the bar, **delayed 2s** (it crashes if it starts before
  the compositor is fully up).
- `hypridle` — idle lock / screen-off daemon.
- `swayosd-server` — the volume/brightness OSD daemon.
- `wallpaper.sh` — starts hyprpaper and applies the wallpaper.
- dunst is **not** autostarted here — it's D-Bus activated on the first
  notification (and runs as `dunst.service`).

---

## 3. Keybindings

`Super` = Windows key. A clean, conventional Hyprland layout
(Return/Space/W/T/etc.) so the muscle memory is intuitive.
Type **`keybinds`** in any terminal for the live, colored cheat sheet
(`~/.local/bin/keybinds`).

| Shortcut | Action | Why / notes |
|---|---|---|
| `Super + Space` | App launcher (rofi) | |
| `Super + Return` | Terminal | |
| `Super + E` | File manager (Dolphin) | |
| `Super + Esc` | System menu (wlogout) | graphical power menu |
| `Super + L` | Lock (hyprlock) | |
| `Super + Ctrl + Space` | Change wallpaper | rofi picker with thumbnails |
| `Super + ,` / `Super + Shift + ,` | Dismiss one / all notifications | |
| `Super + W` | Close window | |
| `Super + T` | Float / back to tiling | "window freedom" |
| `Super + H` | Hide / show all floaters | stash & restore |
| `Super + F` | Fullscreen | |
| `Super + G` | Group windows | |
| `Super + arrows` | Move focus | |
| `Super + Shift + arrows` | Swap window | |
| `Super + Alt + arrows` | Resize window | |
| `Super + 1..0` | Go to workspace 1..10 | |
| `Super + Shift + 1..0` | Move window to workspace | |
| `Super + Tab` / `Super + Shift + Tab` | Next / previous workspace | **hold to spam** (`repeating = true`) — like Ctrl+Tab in a browser |
| `Super + S` | Scratchpad (show/hide) | special "magic" workspace |
| `Super + Alt + S` | Send window to scratchpad | moved off `Shift+S` (now a screenshot) |
| `Super + Shift + S` | Screenshot a selected **area** | |
| `Super + Shift + R` | Screenshot **full screen** | |
| `Super + Alt + R` | Record region (with audio) — repeat to stop | |
| `Super + Alt + Shift + R` | Record full screen | |
| `Super + Shift + O` | OCR a region → clipboard | |
| `Super + =` / `Super + -` | Zoom in / out (follows cursor) | |
| `Super + Ctrl + scroll` | Zoom with the mouse | |
| `Super + Ctrl + 0` | Reset zoom | |
| `Super + Ctrl + S` | Cycle monitor scaling (1 → 1.25 → 1.5 → 2) | |
| `Super + Ctrl + M` | Mirror / extend external | |
| `Super + Ctrl + D` | Laptop panel off / on | refuses if it's the only screen |
| `Fn` volume/brightness/media | OSD via swayosd | `{ locked = true, repeating = true }` so they work on the lock screen and auto-repeat |

> **No `Fn+F6` and no `Super+Shift+L`.** `Fn+F6` (XF86ScreenSaver) isn't
> bindable on this ASUS firmware, and the old "lock + blank" combo on
> `Super+Shift+L` was removed as redundant with wlogout's lock button.

---

## 4. Scripts

All in `~/.config/hypr/scripts/`. They lean on `hyprctl ... -j | jq` to read
state and `hyprctl eval 'hl.…'` to act (Lua syntax). All notify via
`notify-send` (needs **libnotify** — see [§8](#8-notifications-dunst)).

| Script | What it does | Why / how |
|---|---|---|
| `screenshot.sh region\|full` | Capture → save to `~/Pictures/Screenshots` + copy to clipboard + notify | one helper for both `Super+Shift+S/R`; `slurp` cancel exits cleanly |
| `screenrecord.sh region\|full` | Toggle screen recording with **system audio** (`wf-recorder`, sink `.monitor`) → `~/Videos` | second press sends `SIGINT` to stop & finalize the mp4 |
| `ocr.sh` | Select a region → `tesseract` (spa+eng) → clipboard | uses a temp PNG cleaned on exit |
| `zoom.sh in\|out\|reset` | Cursor-following screen zoom in 0.5 steps | sets `cursor.zoom_factor` via `hl.config` |
| `toggle-app.sh <class> '<cmd>'` | Open the window if closed, **close it if open** | used by waybar; **race-safe** (see [§5](#5-top-bar-waybar)) |
| `toggle-floaters.sh` | Hide/show **all floaters** on the current workspace | stashes them to `special:stash` and back — for `Super+H` |
| `wallpaper.sh` | Start hyprpaper + apply the active wallpaper via IPC | run at login; falls back to the first image in the library |
| `wallpaper-picker.sh` | rofi grid of thumbnails → set & persist the choice | updates the `current-wallpaper` symlink |
| `monitor-scale.sh` | Cycle the focused monitor's scale 1→1.25→1.5→2 | picks the closest current step, advances one |
| `monitor-mirror.sh` | Toggle mirror ↔ extend on the external | stateful via `~/.config/hypr/.mirror-state` |
| `monitor-internal.sh` | Turn the laptop panel off/on | **refuses to turn off the only screen** |
| `lid.sh close\|open` | Lid logic | external present → only blank the internal; else lock + suspend |

---

## 5. Top bar (waybar)

`~/.config/waybar/{config.jsonc,style.css}`.

**Left — workspaces (`hyprland/workspaces`):**

- **All 10** are shown (`persistent-workspaces` 1–10) — on purpose.
- Style: each workspace shows its **number** (1–9, `0` for 10); the **active**
  one shows a dot `󱓻`.
- Colors (`style.css`): **empty** workspaces are muted/dim (opacity 0.5),
  **in-use** ones (have windows) are a soft blue, the **active** one is bright
  accent. This is the "tenuous color so you can tell which are in use".
- **Note:** changing `persistent-workspaces` needs a **full waybar restart**
  (`reload_style_on_change` only reloads the CSS).

**Right:** `cpu · memory · temperature · pulseaudio · network · battery · tray`.

- CPU/RAM/temp **click → toggle btop** (class `sysmon`).
- Network **click → toggle the wifi menu** (`impala`, class `wifi-menu`) — see
  [§13](#13-network-iwd--impala). Hover shows ESSID + IP.
- Both open **tiled** (no float rule), by preference.

**The toggle (`toggle-app.sh`) and its race fix — important:**

A naive `on-click: "kitty -e btop"` opens a *new* window every click. The toggle
script instead closes the window if it's already open. The tricky part is doing
that without a race when you **spam clicks**:

- A **per-class non-blocking `flock`** (`/tmp/toggle-app-<class>.lock`)
  debounces: while one toggle is mid-flight, extra clicks are **dropped**, not
  queued (a *blocking* lock queued dozens and felt stuck).
- The launch uses `setsid bash -c "$launch" 9>&-`. The **`9>&-` is essential**:
  it closes the lock file descriptor in the launched app. Without it, btop
  inherits fd 9 and holds the flock for its whole lifetime, so no later click
  could ever close it.
- Each branch waits only until the window actually appears/disappears before
  releasing the lock, so the next click sees the correct state.

Net result: spam freely — it toggles open/close cleanly and **never opens two**.

---

## 6. Lock & idle (hyprlock + hypridle)

**`hyprlock.conf`** — the lock screen: blurred current wallpaper + a large
clock + a minimal password field. The password character is a **heart `♡`**
(`dots_text_format = ♡`), matching the user's aesthetic (same glyph used in
fastfetch and the prompt). `Super+L` locks.

**`hypridle.conf`** — idle behavior:

- After **5 min** → lock (`loginctl lock-session`).
- After **6 min** → screen off (`dpms disable`), back on when you return.
- `lock_cmd` guards with `pidof hyprlock || hyprlock` so it never stacks
  multiple lockers; locks before sleep and re-enables the display after wake.

---

## 7. Wallpaper

**`hyprpaper`** is the daemon. `hyprpaper.conf` preloads
`~/.config/hypr/current-wallpaper` (a **symlink** to the active image).

- `wallpaper.sh` (autostart) launches hyprpaper and applies the wallpaper via
  IPC (`hyprctl hyprpaper wallpaper ...`).
- `wallpaper-picker.sh` (`Super+Ctrl+Space`) shows a rofi thumbnail grid, points
  the symlink at your choice and applies it.
- The library is `~/.config/wallpapers/`; drop images there and they appear.
  Personal wallpapers are **git-ignored** (only the Tokyo Night gradient is
  committed) to keep the repo light.
- See [§2](#2-hyprland-hyprlandlua) for why `force_default_wallpaper = 0` matters
  here.

---

## 8. Notifications (dunst)

**`dunst`** is the notification daemon, Tokyo Night styled (rounded, frame color
per urgency: muted / blue / red). Left-click does the default action + closes,
right-click clears all.

> **Dependency that's easy to miss:** the *client* `notify-send` comes from
> **`libnotify`**, not from dunst. Without it, every script's notification
> fails silently. It is installed and listed in the dependencies.

---

## 9. Theming (Tokyo Night everywhere)

The whole system is dark, one palette. Background `#1a1b26`, foreground
`#c0caf5`, accent `#7aa2f7`, plus the usual Tokyo Night red/green/yellow.

- **GTK apps:** theme **`Tokyonight-Dark`** (dark variant, "black" tweak),
  built from source with `sassc` into `~/.themes` (not committed — rebuild it).
  Applied via `gsettings` (`gtk-theme` + `color-scheme: prefer-dark`) and
  `gtk-3.0/`+`gtk-4.0/settings.ini`; `GTK_THEME` env enforces it.
- **Qt apps:** **Kvantum** with a dark theme (`KvArcDark`). Packages
  `qt5ct qt6ct kvantum kvantum-qt5`; configs in `Kvantum/`, `qt5ct/`, `qt6ct/`.
  Env `QT_QPA_PLATFORMTHEME=qt6ct` + `QT_STYLE_OVERRIDE=kvantum`. **Qt apps pick
  up the theme after a re-login** (the env must be in the session).
- **Fonts:** `JetBrainsMono Nerd Font` everywhere (glyphs/icons). `noto-fonts-emoji`
  provides **color emoji** in the terminal (without it, emoji render as mono
  tofu).

---

## 10. Terminal (kitty + bash + prompt)

- **kitty** — Tokyo Night colors, JetBrainsMono Nerd Font 11, 88% background
  opacity (frosted with the global blur), powerline tabs, no audio bell.
- **bash** — `.bashrc` adds `~/.local/bin` to `PATH`, then loads the prompt and
  fastfetch.
- **Prompt: oh-my-posh** with the user's own **`0sadiPaper`** theme
  (`~/.config/oh-my-posh/0sadipaper.omp.json`).
- **fastfetch** runs on terminal open: custom magenta ASCII logo, `♡` separators
  (same heart motif), system info.

---

## 11. Login screen (SDDM)

A custom theme **`tokyo-lock`** that looks like hyprlock: blurred wallpaper + big
clock + minimal Tokyo Night login, with the password masked by **`♡`** (and
centered like hyprlock).

- Files in `usr/share/sddm/themes/tokyo-lock/` (also installed to
  `/usr/share/sddm/themes/`). `background.jpg` is a blurred copy of the wallpaper
  made with `ffmpeg` — **regenerate it if you change the wallpaper** (it's not
  committed).
- **`Main.qml` must use `import QtQuick 2.15`** — a versionless import renders in
  test mode but **breaks the real greeter**.
- **Greeter runs on Wayland** (`weston`), set in `etc/sddm.conf.d/10-wayland.conf`
  (`DisplayServer=wayland`). **Why:** the X11 greeter grabbed the NVIDIA GPU with
  no display ("Cannot find any crtc"), the Qt platform plugin core-dumped, and
  you got a **black screen at boot**. weston uses the AMD panel natively, like
  Hyprland. Do **not** set `QT_WAYLAND_SHELL_INTEGRATION=layer-shell` in the
  greeter env — it crashes it.

---

## 12. App launcher (rofi)

`rofi -show drun` (`Super+Space`), Tokyo Night `.rasi` theme, icons on.

To keep the launcher showing only **real apps**, junk entries (CLI tools, config
utilities, stray daemons) are hidden with **`NoDisplay=true` override files** in
`~/.local/share/applications/` — same basename as the system `.desktop`, which
overrides it. Nothing is uninstalled; the entries are just hidden. Hidden:
`htop, vim, bssh, bvnc, avahi-discover, kvantummanager, rofi, rofi-theme-selector,
qt5ct, qt6ct, xgps, xgpsspeed, uuctl, qvidcap, qv4l2`. Newly installed apps still
appear automatically. To hide another, drop a matching override; to restore one,
delete its override.

---

## 13. Network (iwd + impala)

The Wi-Fi backend is **`iwd`** (not NetworkManager). The bar's network module
`on-click` runs `rfkill unblock wifi; ` then opens **`impala`** — a TUI for iwd
(`extra/impala`) — in a kitty window (class `wifi-menu`), via the toggle script
so it doesn't duplicate. Hover shows the current ESSID/IP; click to pick a
network.

---

## 14. ASUS power (asusctl)

**`asusctl`** + **ROG Control Center** (GUI), installed from the official
asus-linux **g14** repo (`Server = https://arch.asus-linux.org`) — the AUR build
is unsupported.

- `asusd` starts itself via udev (don't enable it manually).
- Profiles: `asusctl profile list|get|set|next` → **Quiet / Balanced /
  Performance** (auto: Performance on AC, Quiet on battery).
- Battery charge limit: `/sys/class/power_supply/BAT*/charge_control_end_threshold`.
- `asusctl` does **not** fix the slow-at-boot Fn keys (that's the `asus-nb-wmi`
  module load timing — see [§16](#16-known-issues--pending)).

---

## 15. System menu (wlogout)

**`wlogout`** (`Super+Esc`) — a graphical power menu: lock, logout, suspend,
hibernate, reboot, shutdown (each with a keybind letter). Tokyo Night styled
with custom icons in `~/.config/wlogout/icons/`.

---

## 16. Known issues & pending

- **Fn keys slow for the first seconds after boot:** the `asus-nb-wmi` module
  loads a bit late. Mitigated by `/etc/modules-load.d/asus-nb-wmi.conf` (loads it
  early via systemd). The improvement is marginal because the keys also need
  Hyprland + swayosd to be up; it's largely firmware timing.

---

## 17. Maintenance & gotchas

- **Lua Hyprland:** `hyprctl keyword` does **not** work. Use
  `hyprctl eval 'hl.config({...})'` and `hyprctl dispatch 'hl.dsp.…'`.
- **UKI date is deterministic:** a fixed timestamp on `arch-linux.efi` is normal;
  the contents do change on `mkinitcpio -p linux` (verify by sha256, not mtime).
- **Absolute paths:** several files hardcode `/home/diegoveme`
  (`hypr/scripts/*`, `hyprpaper.conf`, `hyprlock.conf`, the autostart,
  `fastfetch/config.jsonc`). Adjust them for a different user.
- **SDDM background:** `tokyo-lock/background.jpg` is a blurred copy of the
  wallpaper; regenerate it with ffmpeg if you change the wallpaper.
- **GTK theme + personal wallpapers are not committed** (built/heavy); rebuild
  the theme with `sassc`, and drop wallpapers into `~/.config/wallpapers/`.
- **Debugging the toggle script:** never `pkill -f "toggle-app.sh"` — the pattern
  matches the killing shell itself (it self-terminates, exit 144). Kill by PID
  via `hyprctl clients`/`ps` instead.

---

## 18. System-level changes (outside this repo)

These live in `/etc`, `/usr`, the UEFI NVRAM or installed packages — **not** in
the dotfiles. Recorded here as a redo checklist for a reinstall. (Files under
`etc/` and `usr/` in this repo are *copies* of some of them for reference.)

### Kernel command line — `/etc/kernel/cmdline`

```
root=PARTUUID=… zswap.enabled=0 rw rootfstype=ext4 acpi_backlight=native
```

- **`acpi_backlight=native`** is the brightness fix ([§1](#1-hardware--boot)):
  it exposes `amdgpu_bl1` (the real AMD panel backlight) instead of the
  non-working `nvidia_wmi_ec_backlight`.
- This cmdline is **embedded into the UKI** when you run `sudo mkinitcpio -p linux`
  (the UKI is what GRUB boots). Edit this file, then regenerate the UKI.

### Fn media keys early-load — `/etc/modules-load.d/asus-nb-wmi.conf`

```
asus_nb_wmi
```

- Loads the ASUS hotkey driver early (via `systemd-modules-load`) so the Fn
  volume/brightness keys respond a bit sooner after boot. Safe; touches nothing
  in the boot image. See [§16](#16-known-issues--pending) for the caveat (it's a
  marginal improvement — the keys also need Hyprland/swayosd up).
- The mkinitcpio `MODULES=()` array was intentionally **left empty** — putting
  the module in the initramfs was tested and reverted (no real benefit, and it
  rebuilds the boot image for nothing).

### UEFI boot entries — phantom cleanup

The firmware boot menu had **three phantom entries** left over from earlier
installs — all `VenHw(...)` device paths pointing at nothing real. They were
removed with:

```sh
sudo efibootmgr -b <id> -B   # done for the 3 phantom ids
```

- What remains: **`Boot0005 GRUB`** (the only real loader →
  `\EFI\GRUB\grubx64.efi`) plus the firmware's own network/CD/USB entries
  (`0002,0003,0006,0007,0008`).
- ⚠️ **Never delete the GRUB entry.** There is no other OS installed (those were
  just stale NVRAM variables); the second disk `nvme0n1` is empty.

### SDDM (display manager)

- `/etc/sddm.conf.d/10-wayland.conf` → Wayland greeter + `Current=tokyo-lock`
  (tracked here under `etc/`). Fixes the black-screen-at-boot ([§11](#11-login-screen-sddm)).
- Theme installed to `/usr/share/sddm/themes/tokyo-lock/` (tracked here under
  `usr/`). Add a blurred `background.jpg` after installing.

### asusctl / ROG Control Center — g14 repo

Added to `/etc/pacman.conf`:

```
[g14]
Server = https://arch.asus-linux.org
```

…with the repo's GPG key imported and locally signed
(`pacman-key --recv-keys 8F65…FA35 && pacman-key --lsign-key …`), then
`sudo pacman -Suy asusctl rog-control-center`. See [§14](#14-asus-power-asusctl).

### GTK theme build

`Tokyonight-Dark` is **not** committed (it's a build artifact in `~/.themes`).
Rebuild it with `sassc` from a Tokyo Night GTK theme generator using the **dark**
variant + **black** tweak; the `gtk-3.0/4.0`, `Kvantum`, `qt5ct`, `qt6ct` configs
in this repo then pick it up. See [§9](#9-theming-tokyo-night-everywhere).
