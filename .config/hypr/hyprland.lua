
-- Hyprland config (Lua format) — Tokyo Night desktop.
-- Full rationale for every block lives in the dotfiles' DOCUMENTATION.md.


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
})

-- Any external monitor (HDMI/USB-C): activates on its own at its preferred
-- resolution and extends automatically when plugged in.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun"


-------------------
---- AUTOSTART ----
-------------------

-- Desktop services
hl.on("hyprland.start", function ()
  hl.exec_cmd("sleep 2 && waybar") -- status bar (delayed: if it starts too early, it crashes)
  hl.exec_cmd("hypridle")          -- auto-lock / screen off on inactivity
  hl.exec_cmd("swayosd-server")    -- volume / brightness OSD
  hl.exec_cmd("/home/diegoveme/.config/hypr/scripts/wallpaper.sh")  -- wallpaper (swaybg, all monitors)
  -- notifications: dunst (managed by systemd, dunst.service)
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Dark theme everywhere (Tokyo Night). GTK apps follow Tokyonight-Dark;
-- Qt apps go dark via Kvantum (qt5ct/qt6ct).
hl.env("GTK_THEME", "Tokyonight-Dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

-- More responsive scroll (helps with touchpad zoom)
hl.config({ binds = { scroll_event_delay = 0 } })

-- Touchpad zoom: 2-finger pinch → zoom in/out, continuous and anchored to the
-- cursor (Hyprland's native live cursorZoom). Pinch out = in, pinch in = out.
hl.gesture({ fingers = 2, direction = "pinchout", action = "cursorZoom", mode = "live" })
hl.gesture({ fingers = 2, direction = "pinchin",  action = "cursorZoom", mode = "live" })

-- Blur (frosted glass) on the launcher and the bar
hl.layer_rule({ match = { namespace = "rofi" },   blur = true })
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 0.92,
        inactive_opacity = 0.84,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- dwindle is the active layout (set above)
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,    -- 0 = no built-in anime wallpaper underneath (we use swaybg)
        disable_hyprland_logo   = true, -- no Hyprland logo / default background showing through
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Touchpad gesture: 3-finger horizontal swipe → switch workspace.
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Base binds (the standard ones are further down)
-- Note: terminal=Super+Return, close=Super+W, rofi=Super+Space, float=Super+T
-- (Super+M removed: it closed the Hyprland session; now Super+Esc → wlogout)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))   -- lock screen
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- ===== Standard shortcuts =====
-- Apps / system
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd(menu))                         -- app launcher
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))                     -- terminal
hl.bind(mainMod .. " + W",      hl.dsp.window.close())                         -- close window
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- fullscreen
hl.bind(mainMod .. " + T",      hl.dsp.window.float({ action = "toggle" }))    -- floating/tiling
hl.bind(mainMod .. " + G",      hl.dsp.group.toggle())                         -- group windows
hl.bind(mainMod .. " + H",      hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/toggle-floaters.sh")) -- hide/show floaters
hl.bind(mainMod .. " + ESCAPE",        hl.dsp.exec_cmd("pkill -x wlogout || wlogout -p layer-shell"))                -- system menu (wlogout, toggle: avoids opening several)
hl.bind(mainMod .. " + CTRL + SPACE",  hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/wallpaper-picker.sh")) -- change wallpaper

-- Navigation between workspaces and windows
hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "e+1" }), { repeating = true })  -- next workspace (hold to spam)
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })  -- previous workspace (hold to spam)
hl.bind("ALT + TAB",                 hl.dsp.window.cycle_next())               -- cycle windows

-- Move (swap) the active window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }))

-- Resize the active window with the keyboard (useful for floaters)
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 40,  y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.resize({ x = 0, y = -40, relative = true }))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.resize({ x = 0, y = 40,  relative = true }))

-- Screenshots. Saves to ~/Pictures/Screenshots, copies to clipboard, notifies.
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/screenshot.sh region"))  -- select area
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/screenshot.sh full"))    -- whole screen

-- Notifications
hl.bind(mainMod .. " + COMMA",         hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mainMod .. " + SHIFT + COMMA", hl.dsp.exec_cmd("dunstctl close-all"))

-- Screen recording (toggle region + system audio) and full capture
hl.bind(mainMod .. " + ALT + R",         hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/screenrecord.sh region"))
hl.bind(mainMod .. " + ALT + SHIFT + R", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/screenrecord.sh full"))

-- OCR: extract text from a region to the clipboard
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/ocr.sh"))

-- Screen zoom (follows the cursor)
hl.bind(mainMod .. " + EQUAL",             hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/zoom.sh in"))
hl.bind(mainMod .. " + MINUS",             hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/zoom.sh out"))
hl.bind(mainMod .. " + CTRL + 0",          hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/zoom.sh reset"))
hl.bind(mainMod .. " + CTRL + mouse_up",   hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/zoom.sh in"))
hl.bind(mainMod .. " + CTRL + mouse_down", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/zoom.sh out"))

-- AirPods mic toggle: music (A2DP hi-fi) <-> call (HFP, AirPods mic on)
hl.bind(mainMod .. " + ALT + M", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/airpods-mic.sh"))

-- Monitor management
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/monitor-scale.sh"))     -- cycle scaling
hl.bind(mainMod .. " + CTRL + M", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/monitor-mirror.sh"))    -- mirror/extend
hl.bind(mainMod .. " + CTRL + D", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/monitor-internal.sh"))  -- turn internal panel off/on

-- Laptop lid
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/lid.sh close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("/home/diegoveme/.config/hypr/scripts/lid.sh open"),  { locked = true })
-- ===== end standard shortcuts =====

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad). Move-to-scratchpad is on Super+Alt+S
-- because Super+Shift+S is now the area screenshot.
hl.bind(mainMod .. " + S",       hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("swayosd-client --brightness raise"),          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("swayosd-client --brightness lower"),          { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Ignore maximize requests from all apps (nicer tiling behavior).
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Transparency for "system companion" apps (file manager, utilities).
-- With the global blur, they look like frosted glass. Add more classes here if you want.
local systemApps = {
    "dolphin", "org.kde.dolphin",
    "nautilus", "org.gnome.Nautilus",
    "thunar", "pcmanfm", "pcmanfm-qt", "nemo",
    "pavucontrol", "org.pulseaudio.pavucontrol",
    "nm-connection-editor", "blueman-manager",
    "org.kde.ark", "file-roller",
    "org.kde.gwenview", "imv", "org.kde.kcalc", "gnome-calculator",
    "org.kde.systemsettings", "xdg-desktop-portal-gtk",
}
for _, cls in ipairs(systemApps) do
    hl.window_rule({ match = { class = cls }, opacity = 0.85 })
end
