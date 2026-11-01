-- ============================================================================
-- HYPRLAND KONFIGURATION (Minimalistisch · Instant · Matte Sage/Slate Theme)
-- Dokumentation aller Tastenkombinationen: ~/.config/hypr/README.md
-- ============================================================================

local home        = assert(os.getenv("HOME"), "HOME must be set")
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")

------------------
---- MONITORS ----
------------------
-- Interner Laptop-Bildschirm auf nativer Skalierung (1.0 = volle 1920x1080 statt 1.5x Zoom)
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto-right",
    scale    = 1.0,
})

-- Weitere Bildschirme automatisch rechts neben den vorhandenen anordnen.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto-right",
    scale    = 1.0,
})

-- Optionale, Git-ignorierte Monitor-Regeln pro Rechner (siehe monitors.example.lua).
-- Nach den Standardregeln laden, damit lokale Einstellungen Vorrang haben.
local monitor_config = config_home .. "/hypr/monitors.local.lua"
local monitor_file = io.open(monitor_config, "r")
if monitor_file then
    monitor_file:close()
    dofile(monitor_config)
end


---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local menu        = "pkill -x fuzzel || fuzzel"
local browser     = "firefox"
local fileManager = "pcmanfm"
local tuiFiles    = "kitty -e yazi"
local lock           = "hyprlock"
local powermenu      = home .. "/.config/hypr/powermenu.sh"
local windowswitcher = home .. "/.config/hypr/windowswitcher.sh"
local wallpaper      = home .. "/.config/wallpaper/wallpaper.sh"
local screenshot     = string.format("%q", config_home .. "/hypr/screenshot.sh")


-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    -- Gespeicherten Default bzw. Monitor-Overrides anwenden (startet hyprpaper bei Bedarf)
    hl.exec_cmd(wallpaper .. " apply --quiet")
end)

-- Neu angeschlossene Monitore erhalten die gespeicherte Belegung (sonst Default)
hl.on("monitor.added", function()
    hl.exec_cmd("sleep 0.6 && " .. wallpaper .. " apply --quiet")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")


-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Minimalistisch: Keine Animationen, keine Ränder/Abstände am Rand, keine Rundungen/Schatten/Blur
-- Catppuccin Mocha Pastellfarben: Base (#1e1e2e), Surface0 (#313244), Pastel Blue (#89b4fa) & Teal (#94e2d5)
hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 1,

        col = {
            active_border   = "rgba(89b4faff)",
            inactive_border = "rgba(313244ff)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = false,
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
    },

    master = {
        new_status = "master",
    },

    misc = {
        -- Hintergrundbilder bleiben wie gewünscht unverändert
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        background_color        = "0x1e1e2e",
        animate_manual_resizes  = false,
        animate_mouse_windowdragging = false,
        disable_splash_rendering = true,
    },

    binds = {
        allow_workspace_cycles            = true,
        workspace_back_and_forth          = false,
        workspace_center_on               = 1,
        window_direction_monitor_fallback = true,
        movefocus_cycles_fullscreen       = true,
    },

    cursor = {
        warp_on_change_workspace = 1,
    },
})


---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "de",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------
-- Siehe ~/.config/hypr/README.md für die vollständige Übersicht
local mainMod = "SUPER"

-- Programme starten & System
hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",              hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("kitty -e tmux new-session -A -s main"))
hl.bind(mainMod .. " + space",          hl.dsp.exec_cmd(menu))
hl.bind("ALT + space",             hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B",              hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Y",              hl.dsp.exec_cmd(tuiFiles))
hl.bind(mainMod .. " + L",              hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd(powermenu))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("killall -SIGUSR2 waybar || (pkill waybar; waybar &)"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(wallpaper .. " tui"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + M",         hl.dsp.exit())

-- Fenster-Aktionen
hl.bind(mainMod .. " + C",         hl.dsp.window.close())
hl.bind(mainMod .. " + W",         hl.dsp.window.close())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + C",  hl.dsp.window.center())
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T",         hl.dsp.layout("togglesplit"))


-- ============================================================================
-- SCHNELLER FENSTERWECHSEL, LETZTES FENSTER & SPRUNG-POSITIONEN (SLOTS 1-10)
-- Funktioniert nahtlos über alle Workspaces und Bildschirme (Monitore) hinweg
-- ============================================================================
local current_active_addr = nil
local last_active_addr    = nil
local window_slots        = {}

hl.on("window.active", function(win)
    if win and win.address and win.address ~= current_active_addr then
        last_active_addr    = current_active_addr
        current_active_addr = win.address
    end
end)

-- Fokussiert ein Zielfenster zuverlässig (auch auf anderem Monitor, Workspace oder im Scratchpad)
local function focus_window_smart(win)
    if not win then
        return false
    end
    if type(win) == "string" then
        win = hl.get_window("address:" .. win) or hl.get_window(win)
    end
    if not win then
        return false
    end

    if win.workspace and win.workspace.special and not win.workspace.visible then
        local sp_name = (win.workspace.name or "magic"):gsub("^special:", "")
        hl.dispatch(hl.dsp.workspace.toggle_special(sp_name))
    end

    hl.dispatch(hl.dsp.focus({ window = win }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = win }))
    return true
end

-- Alle gemappten Fenster räumlich sortiert (Monitor links->rechts, Workspace, Position oben->unten)
local function get_sorted_windows()
    local wins = hl.get_windows({ mapped = true }) or {}
    table.sort(wins, function(a, b)
        local ma = (a.monitor and a.monitor.x) or 0
        local mb = (b.monitor and b.monitor.x) or 0
        if ma ~= mb then
            return ma < mb
        end
        local wa = (a.workspace and a.workspace.id) or 0
        local wb = (b.workspace and b.workspace.id) or 0
        if wa ~= wb then
            return wa < wb
        end
        local ya = (a.at and (a.at.y or a.at[2])) or 0
        local yb = (b.at and (b.at.y or b.at[2])) or 0
        if ya ~= yb then
            return ya < yb
        end
        local xa = (a.at and (a.at.x or a.at[1])) or 0
        local xb = (b.at and (b.at.x or b.at[1])) or 0
        if xa ~= xb then
            return xa < xb
        end
        return (a.address or "") < (b.address or "")
    end)
    return wins
end

-- Springt sofort zum zuletzt aktiven Fenster/Programm (auch über Bildschirme & Workspaces hinweg)
local function focus_last_window()
    local active      = hl.get_active_window()
    local active_addr = active and active.address or nil

    -- 1. Hyprlands direktes last_window prüfen
    local last = hl.get_last_window()
    if last and last.mapped and last.address ~= active_addr then
        if focus_window_smart(last) then
            return
        end
    end

    -- 2. Eigenes Event-Tracking prüfen (funktioniert auch von leeren Workspaces aus)
    if last_active_addr and last_active_addr ~= active_addr then
        for _, w in ipairs(hl.get_windows({ mapped = true }) or {}) do
            if w.address == last_active_addr then
                if focus_window_smart(w) then
                    return
                end
            end
        end
    end

    -- 3. Fallback über focus_history_id aller offenen Fenster (Monitor- & Workspace-übergreifend)
    local candidates = hl.get_windows({ mapped = true }) or {}
    table.sort(candidates, function(a, b)
        return (a.focus_history_id or 9999) < (b.focus_history_id or 9999)
    end)
    for _, w in ipairs(candidates) do
        if w.address ~= active_addr then
            if focus_window_smart(w) then
                return
            end
        end
    end
end

-- Schaltet durch alle offenen Fenster über alle Bildschirme & Workspaces hinweg (step = +1 oder -1)
local function cycle_all_windows(step)
    local wins = get_sorted_windows()
    local n    = #wins
    if n == 0 then
        return
    end
    local active      = hl.get_active_window()
    local active_addr = active and active.address or nil
    local cur_idx     = 1
    for i, w in ipairs(wins) do
        if w.address == active_addr then
            cur_idx = i
            break
        end
    end
    local next_idx = ((cur_idx - 1 + (step or 1)) % n) + 1
    focus_window_smart(wins[next_idx])
end

-- Schaltet durch alle Fenster desselben Programms (gleiche class) über alle Bildschirme hinweg
local function cycle_same_class()
    local active = hl.get_active_window()
    if not active or not active.class or active.class == "" then
        focus_last_window()
        return
    end
    local all_wins = get_sorted_windows()
    local same     = {}
    local cur_idx  = 1
    for _, w in ipairs(all_wins) do
        if w.class == active.class then
            table.insert(same, w)
            if w.address == active.address then
                cur_idx = #same
            end
        end
    end
    if #same <= 1 then
        focus_last_window()
        return
    end
    local next_idx = (cur_idx % #same) + 1
    focus_window_smart(same[next_idx])
end

-- Speichert das aktuelle Fenster fest auf Sprung-Position (Slot) <slot> (1-10)
local function save_window_slot(slot)
    local win = hl.get_active_window()
    if not win or not win.address then
        return
    end
    local tag_name = "slot_" .. tostring(slot)
    for _, w in ipairs(hl.get_windows() or {}) do
        hl.dispatch(hl.dsp.window.tag({ tag = "-" .. tag_name, window = w }))
    end
    window_slots[slot] = win.address
    hl.dispatch(hl.dsp.window.tag({ tag = "+" .. tag_name, window = win }))

    local app = (win.class or "Fenster"):gsub("^.*%.", "")
    local mon = (win.monitor and win.monitor.name) or ""
    hl.notification.create({
        text     = string.format("Position [%d] gespeichert: %s (%s)", slot, app, mon),
        duration = 1600,
        color    = "rgba(89b4faff)",
    })
end

-- Springt direkt zu Fenster-Position (Slot) <slot> (1-10) über alle Bildschirme hinweg:
--   1. Falls Position manuell gespeichert wurde: Springt zu diesem gespeicherten Fenster
--      (Erneutes Drücken auf derselben Position springt wieder zurück zum vorherigen Fenster!)
--   2. Falls Position noch nicht manuell belegt wurde: Springt automatisch zum <slot>-ten offenen Fenster!
local function jump_window_slot(slot)
    local target   = nil
    local tag_name = "slot_" .. tostring(slot)

    if window_slots[slot] then
        for _, w in ipairs(hl.get_windows({ mapped = true }) or {}) do
            if w.address == window_slots[slot] then
                target = w
                break
            end
        end
    end

    if not target then
        local tagged = hl.get_windows({ tag = tag_name, mapped = true }) or {}
        if #tagged > 0 then
            target             = tagged[1]
            window_slots[slot] = target.address
        end
    end

    if not target then
        local wins = get_sorted_windows()
        target = wins[slot]
    end

    if not target then
        return
    end

    local active = hl.get_active_window()
    if active and active.address == target.address then
        focus_last_window()
    else
        focus_window_smart(target)
    end
end

-- Monitore sortiert von links nach rechts holen
local function get_sorted_monitors()
    local mons = hl.get_monitors() or {}
    table.sort(mons, function(a, b)
        if (a.x or 0) ~= (b.x or 0) then
            return (a.x or 0) < (b.x or 0)
        end
        return (a.id or 0) < (b.id or 0)
    end)
    return mons
end

-- Springt direkt zum nächsten / anderen Bildschirm (Monitor)
local function focus_next_monitor(step)
    local mons = get_sorted_monitors()
    if #mons <= 1 then
        return
    end
    local active_mon = hl.get_active_monitor()
    local cur_idx    = 1
    for i, m in ipairs(mons) do
        if active_mon and m.name == active_mon.name then
            cur_idx = i
            break
        end
    end
    local next_idx = ((cur_idx - 1 + (step or 1)) % #mons) + 1
    local target_m = mons[next_idx]
    if target_m.active_workspace and target_m.active_workspace.last_window then
        focus_window_smart(target_m.active_workspace.last_window)
    else
        hl.dispatch(hl.dsp.focus({ monitor = target_m.name }))
    end
end

-- Verschiebt das aktive Fenster auf den anderen / nächsten Bildschirm und fokussiert es dort
local function move_window_to_next_monitor()
    local mons = get_sorted_monitors()
    if #mons <= 1 then
        return
    end
    local win        = hl.get_active_window()
    local active_mon = hl.get_active_monitor()
    if not win or not active_mon then
        return
    end
    local cur_idx = 1
    for i, m in ipairs(mons) do
        if m.name == active_mon.name then
            cur_idx = i
            break
        end
    end
    local target_m  = mons[(cur_idx % #mons) + 1]
    local target_ws = target_m.active_workspace and target_m.active_workspace.id
    if target_ws then
        hl.dispatch(hl.dsp.window.move({ workspace = target_ws }))
        focus_window_smart(win)
    end
end

-- Tauscht die aktiven Workspaces zwischen den beiden Bildschirmen
local function swap_monitors_workspaces()
    local mons = get_sorted_monitors()
    if #mons <= 1 then
        return
    end
    local active_mon = hl.get_active_monitor()
    local cur_idx    = 1
    for i, m in ipairs(mons) do
        if active_mon and m.name == active_mon.name then
            cur_idx = i
            break
        end
    end
    local other_m = mons[(cur_idx % #mons) + 1]
    if active_mon and other_m then
        hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = active_mon.name, monitor2 = other_m.name }))
    end
end

-- Tastenkombinationen: Letztes Fenster / Alle Fenster / Gleiches Programm / Interaktiver Switcher
hl.bind("ALT + Tab",                         focus_last_window)
hl.bind(mainMod .. " + Tab",                 focus_last_window)
hl.bind(mainMod .. " + BackSpace",           focus_last_window)
hl.bind("ALT + SHIFT + Tab",                 function() cycle_all_windows(1) end)
hl.bind(mainMod .. " + SHIFT + Tab",         function() cycle_all_windows(1) end)
hl.bind(mainMod .. " + dead_circumflex",     cycle_same_class)
hl.bind(mainMod .. " + grave",               cycle_same_class)
hl.bind(mainMod .. " + G",                   hl.dsp.exec_cmd(windowswitcher))
hl.bind(mainMod .. " + numbersign",          hl.dsp.exec_cmd(windowswitcher))

-- Tastenkombinationen: Direkt zwischen Bildschirmen (Monitoren) springen & Fenster mitnehmen
hl.bind(mainMod .. " + O",                   function() focus_next_monitor(1) end)
hl.bind(mainMod .. " + less",                function() focus_next_monitor(1) end)
hl.bind(mainMod .. " + SHIFT + O",           move_window_to_next_monitor)
hl.bind(mainMod .. " + SHIFT + less",        move_window_to_next_monitor)
hl.bind(mainMod .. " + CTRL + O",            swap_monitors_workspaces)

-- Tastenkombinationen: Schnell-Positionen F1..F4 (Anspringen mit SUPER + F1..F4, Speichern mit SUPER + CTRL + F1..F4)
for slot = 1, 4 do
    hl.bind(mainMod .. " + F" .. slot,         function() jump_window_slot(slot) end)
    hl.bind(mainMod .. " + CTRL + F" .. slot,  function() save_window_slot(slot) end)
    hl.bind(mainMod .. " + SHIFT + F" .. slot, function() save_window_slot(slot) end)
end

-- Fokus zwischen Fenstern wechseln (SUPER + Pfeiltasten)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Fenster verschieben / tauschen (SUPER + SHIFT + Pfeiltasten)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Fenstergröße anpassen (SUPER + CTRL + Pfeiltasten)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,  y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,  y = 40,  relative = true }), { repeating = true })

-- Bildschirme / Workspaces wechseln mit STRG + ALT + Pfeiltasten (Links / Rechts)
hl.bind("CTRL + ALT + left",          hl.dsp.focus({ workspace = "r-1" }))
hl.bind("CTRL + ALT + right",         hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + ALT + SHIFT + left",  hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("CTRL + ALT + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))

-- Hilfsfunktion: Wechselt nur dann zu Bildschirm / Workspace <num>, wenn dieser tatsächlich existiert ("sofern da")
local function focus_existing_screen(num)
    for _, ws in ipairs(hl.get_workspaces()) do
        if ws.id == num or ws.name == tostring(num) then
            hl.dispatch(hl.dsp.focus({ workspace = num }))
            return
        end
    end
    local monitors = hl.get_monitors()
    if monitors and monitors[num] then
        hl.dispatch(hl.dsp.focus({ monitor = monitors[num].name }))
    end
end

-- Workspaces / Bildschirme & Fenster-Positionen über Zahlen (1-10)
for i = 1, 10 do
    local key = i % 10
    -- STRG + ALT + <num>: Wechselt zu Bildschirm/Workspace <num>, sofern dieser bereits vorhanden ist
    hl.bind("CTRL + ALT + " .. key, function()
        focus_existing_screen(i)
    end)
    -- SUPER + ALT + <num>: Springt direkt zu Fenster-Position (Slot) <num> (über alle Bildschirme hinweg!)
    hl.bind(mainMod .. " + ALT + " .. key, function()
        jump_window_slot(i)
    end)
    -- SUPER + CTRL + <num>: Speichert das aktuelle Fenster fest auf Position (Slot) <num>
    hl.bind(mainMod .. " + CTRL + " .. key, function()
        save_window_slot(i)
    end)
    -- SUPER + <num>: Wechselt direkt zu Workspace <num> (oder legt ihn neu an)
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Unbegrenzte / Dynamische Workspaces (Infinity Workspaces)
hl.bind(mainMod .. " + period",         hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + comma",          hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + Next",           hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + Prior",          hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + N",              hl.dsp.focus({ workspace = "empty" }))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + SHIFT + N",      hl.dsp.window.move({ workspace = "empty" }))

-- Mausrad durch Workspaces (unbegrenzt)
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "r-1" }))

-- Scratchpad (Special Workspace)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Fenster mit Maus verschieben / skalieren (SUPER + Linksklick / Rechtsklick)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Snipping Tool: Bereich auswählen, speichern/kopieren und mit Satty bearbeiten.
hl.bind("Print",                   hl.dsp.exec_cmd(screenshot .. " region"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(screenshot .. " region"))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd(screenshot .. " full"))
hl.bind("ALT + Print",             hl.dsp.exec_cmd(screenshot .. " window"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd(screenshot .. " monitor"))

-- Multimedia & Helligkeit (Laptop-Funktionstasten)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    name  = "screenshot-editor",
    match = { class = "^(com\\.gabm\\.satty|org\\.satty\\.satty)$" },
    float = true,
    center = true,
})

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
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
