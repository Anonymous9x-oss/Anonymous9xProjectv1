--[[
    ╔══════════════════════════════════════════════════════════╗
    ║   X-Ray  //  Anonymous9x                                 ║
    ║   Universal Map See-Through                              ║
    ║   Delta Mobile / iOS / PC — All Executors               ║
    ╠══════════════════════════════════════════════════════════╣
    ║   LOGIC LEARNED + UPGRADED FROM SOURCE:                  ║
    ║                                                          ║
    ║   Source used obj.Transparency = 0.6 flat.               ║
    ║   We improve:                                            ║
    ║   [1] Save original transparency per-part (same)         ║
    ║   [2] Skip player characters entirely                    ║
    ║   [3] Skip parts that are already fully transparent      ║
    ║       (invisible kill parts, triggers, etc.)             ║
    ║   [4] DescendantAdded watcher — parts added mid-game     ║
    ║       (e.g. spawned rooms, dynamic builds) also get      ║
    ║       X-rayed automatically.                             ║
    ║   [5] LocalPlayer.CharacterAdded — auto re-apply on      ║
    ║       respawn so X-ray never drops after death.          ║
    ║   [6] Clean memory wipe on OFF (same as source).         ║
    ║                                                          ║
    ║   USAGE:                                                  ║
    ║   Execute once   → X-Ray ON                              ║
    ║   Execute again  → X-Ray OFF (restores everything)       ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  TOGGLE GATE
-- ══════════════════════════════════════════════════════════════
if _G.XrayActive == nil then _G.XrayActive = false end
_G.XrayActive = not _G.XrayActive
local ENTERING = _G.XrayActive

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM  (God Mode style — lightning glitch)
-- ══════════════════════════════════════════════════════════════
local function buildNotif(guiName, mainText, subText, colorMode, displaySecs)
    pcall(function()
        local old = game.CoreGui:FindFirstChild(guiName)
        if old then old:Destroy() end
    end)

    -- colorMode: "on" = white/bright, "off" = grey/dim, "respawn" = white/muted
    local PAL = colorMode == "on" and {
        panel  = Color3.fromRGB(8,   8,  10),
        stroke = Color3.fromRGB(220, 220, 228),
        strokeB= Color3.fromRGB(80,  80,  95),
        main   = Color3.new(1, 1, 1),
        sub    = Color3.fromRGB(165, 165, 178),
        aberR  = Color3.fromRGB(200, 200, 218),
        aberB  = Color3.fromRGB(120, 120, 140),
        bolt   = Color3.fromRGB(255, 255, 255),
        bar    = Color3.fromRGB(200, 200, 215),
        sep    = Color3.fromRGB(180, 180, 200),
        cred   = Color3.fromRGB(90,  90, 110),
    } or colorMode == "off" and {
        panel  = Color3.fromRGB(8,   8,  10),
        stroke = Color3.fromRGB(65,  65,  80),
        strokeB= Color3.fromRGB(30,  30,  40),
        main   = Color3.fromRGB(140, 140, 155),
        sub    = Color3.fromRGB(80,  80,  95),
        aberR  = Color3.fromRGB(70,  70,  85),
        aberB  = Color3.fromRGB(55,  55,  70),
        bolt   = Color3.fromRGB(90,  90, 110),
        bar    = Color3.fromRGB(60,  60,  78),
        sep    = Color3.fromRGB(55,  55,  72),
        cred   = Color3.fromRGB(55,  55,  70),
    } or {  -- respawn
        panel  = Color3.fromRGB(8,   8,  10),
        stroke = Color3.fromRGB(170, 170, 185),
        strokeB= Color3.fromRGB(60,  60,  78),
        main   = Color3.fromRGB(200, 200, 212),
        sub    = Color3.fromRGB(120, 120, 138),
        aberR  = Color3.fromRGB(155, 155, 172),
        aberB  = Color3.fromRGB(100, 100, 118),
        bolt   = Color3.fromRGB(200, 200, 215),
        bar    = Color3.fromRGB(140, 140, 158),
        sep    = Color3.fromRGB(130, 130, 148),
        cred   = Color3.fromRGB(70,  70,  90),
    }

    local gui = Instance.new("ScreenGui")
    gui.Name           = guiName
    gui.ResetOnSpawn   = false
    gui.DisplayOrder   = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = game.CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

    local PANEL_H = 88
    local wrap = Instance.new("Frame")
    wrap.Name                   = "Wrap"
    wrap.Size                   = UDim2.new(0, 292, 0, PANEL_H)
    wrap.Position               = UDim2.new(0.5, 0, 0, 18)
    wrap.AnchorPoint            = Vector2.new(0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.ClipsDescendants       = false
    wrap.ZIndex                 = 10
    wrap.Parent                 = gui

    local panel = Instance.new("Frame")
    panel.Size                   = UDim2.new(1, 0, 1, 0)
    panel.BackgroundColor3       = PAL.panel
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel        = 0
    panel.ZIndex                 = 10
    panel.Parent                 = wrap
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 7)

    local borderStroke = Instance.new("UIStroke")
    borderStroke.Color       = PAL.stroke
    borderStroke.Thickness   = 1.6
    borderStroke.Transparency = 1
    borderStroke.Parent      = panel

    local topLine = Instance.new("Frame")
    topLine.Size             = UDim2.new(0.84, 0, 0, 2)
    topLine.Position         = UDim2.new(0.08, 0, 0, 0)
    topLine.BackgroundColor3 = PAL.stroke
    topLine.BackgroundTransparency = 1
    topLine.BorderSizePixel  = 0
    topLine.ZIndex           = 14
    topLine.Parent           = wrap
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(1, 0)

    local botLine = Instance.new("Frame")
    botLine.Size             = UDim2.new(0.48, 0, 0, 1)
    botLine.Position         = UDim2.new(0.26, 0, 1, -1)
    botLine.BackgroundColor3 = PAL.sub
    botLine.BackgroundTransparency = 1
    botLine.BorderSizePixel  = 0
    botLine.ZIndex           = 14
    botLine.Parent           = wrap
    Instance.new("UICorner", botLine).CornerRadius = UDim.new(1, 0)

    local leftBar = Instance.new("Frame")
    leftBar.Size             = UDim2.new(0, 3, 0.6, 0)
    leftBar.Position         = UDim2.new(0, 0, 0.20, 0)
    leftBar.BackgroundColor3 = PAL.bar
    leftBar.BackgroundTransparency = 1
    leftBar.BorderSizePixel  = 0
    leftBar.ZIndex           = 15
    leftBar.Parent           = wrap
    Instance.new("UICorner", leftBar).CornerRadius = UDim.new(1, 0)

    local rightBar = leftBar:Clone()
    rightBar.Position = UDim2.new(1, -3, 0.20, 0)
    rightBar.Parent   = wrap

    local tickFrames = {}
    local function tick(ax, ay)
        local hw = Instance.new("Frame")
        hw.Size             = UDim2.new(0, 8, 0, 2)
        hw.Position         = UDim2.new(ax, ax==0 and 1 or -9, ay, ay==0 and 1 or -3)
        hw.BackgroundColor3 = PAL.stroke
        hw.BackgroundTransparency = 1
        hw.BorderSizePixel  = 0; hw.ZIndex = 17; hw.Parent = wrap
        local vw = Instance.new("Frame")
        vw.Size             = UDim2.new(0, 2, 0, 8)
        vw.Position         = UDim2.new(ax, ax==0 and 1 or -3, ay, ay==0 and 1 or -9)
        vw.BackgroundColor3 = PAL.stroke
        vw.BackgroundTransparency = 1
        vw.BorderSizePixel  = 0; vw.ZIndex = 17; vw.Parent = wrap
        table.insert(tickFrames, hw)
        table.insert(tickFrames, vw)
    end
    tick(0,0) tick(1,0) tick(0,1) tick(1,1)

    local boltSegments = {}
    local function makeBolt(ox, oy)
        local segs = {
            {dx=4, dy=0,  r= 52, w=10, h=2},
            {dx=2, dy=5,  r=-48, w= 8, h=2},
            {dx=5, dy=11, r= 55, w=11, h=2},
            {dx=1, dy=17, r=-42, w= 7, h=2},
        }
        for _, s in ipairs(segs) do
            local seg = Instance.new("Frame")
            seg.Size             = UDim2.new(0, s.w, 0, s.h)
            seg.Position         = UDim2.new(0, ox+s.dx, 0, oy+s.dy)
            seg.Rotation         = s.r
            seg.BackgroundColor3 = PAL.bolt
            seg.BackgroundTransparency = 1
            seg.BorderSizePixel  = 0
            seg.ZIndex           = 16
            seg.Parent           = wrap
            table.insert(boltSegments, seg)
        end
    end
    makeBolt(6,  10) makeBolt(15,  6)
    makeBolt(262, 10) makeBolt(271, 6)

    local aberR = Instance.new("TextLabel")
    aberR.Size               = UDim2.new(1,0,0,26)
    aberR.Position           = UDim2.new(0,2.5,0,9)
    aberR.BackgroundTransparency = 1
    aberR.Text               = mainText
    aberR.Font               = Enum.Font.GothamBlack
    aberR.TextSize            = 14
    aberR.TextColor3          = PAL.aberR
    aberR.TextTransparency    = 1
    aberR.TextXAlignment      = Enum.TextXAlignment.Center
    aberR.ZIndex              = 11; aberR.Parent = wrap

    local aberB = Instance.new("TextLabel")
    aberB.Size               = UDim2.new(1,0,0,26)
    aberB.Position           = UDim2.new(0,-2.5,0,7)
    aberB.BackgroundTransparency = 1
    aberB.Text               = mainText
    aberB.Font               = Enum.Font.GothamBlack
    aberB.TextSize            = 14
    aberB.TextColor3          = PAL.aberB
    aberB.TextTransparency    = 1
    aberB.TextXAlignment      = Enum.TextXAlignment.Center
    aberB.ZIndex              = 11; aberB.Parent = wrap

    local mainLbl = Instance.new("TextLabel")
    mainLbl.Size               = UDim2.new(1,0,0,26)
    mainLbl.Position           = UDim2.new(0,0,0,8)
    mainLbl.BackgroundTransparency = 1
    mainLbl.Text               = mainText
    mainLbl.Font               = Enum.Font.GothamBlack
    mainLbl.TextSize            = 14
    mainLbl.TextColor3          = PAL.main
    mainLbl.TextStrokeColor3    = PAL.strokeB
    mainLbl.TextStrokeTransparency = 1
    mainLbl.TextTransparency    = 1
    mainLbl.TextXAlignment      = Enum.TextXAlignment.Center
    mainLbl.ZIndex              = 18; mainLbl.Parent = wrap
    local lStroke = Instance.new("UIStroke")
    lStroke.Color = PAL.stroke; lStroke.Thickness = 1.0; lStroke.Transparency = 1
    lStroke.Parent = mainLbl

    local subLbl = Instance.new("TextLabel")
    subLbl.Size               = UDim2.new(1,-18,0,16)
    subLbl.Position           = UDim2.new(0,9,0,38)
    subLbl.BackgroundTransparency = 1
    subLbl.Text               = subText
    subLbl.Font               = Enum.Font.GothamSemibold
    subLbl.TextSize            = 9
    subLbl.TextColor3          = PAL.sub
    subLbl.TextTransparency    = 1
    subLbl.TextXAlignment      = Enum.TextXAlignment.Center
    subLbl.ZIndex              = 18; subLbl.Parent = wrap

    local sepLine = Instance.new("Frame")
    sepLine.Size             = UDim2.new(0.65, 0, 0, 1)
    sepLine.Position         = UDim2.new(0.175, 0, 1, -17)
    sepLine.BackgroundColor3 = PAL.sep
    sepLine.BackgroundTransparency = 1
    sepLine.BorderSizePixel  = 0; sepLine.ZIndex = 17; sepLine.Parent = wrap
    Instance.new("UICorner", sepLine).CornerRadius = UDim.new(1, 0)

    local cred = Instance.new("TextLabel")
    cred.Size               = UDim2.new(1,-14,0,13)
    cred.Position           = UDim2.new(0,7,1,-15)
    cred.BackgroundTransparency = 1
    cred.Text               = "By  Anonymous9x"
    cred.Font               = Enum.Font.Gotham
    cred.TextSize            = 7
    cred.TextColor3          = PAL.cred
    cred.TextTransparency    = 1
    cred.TextXAlignment      = Enum.TextXAlignment.Center
    cred.ZIndex              = 18; cred.Parent = wrap

    -- ── REVEAL ALL (solid, no more blink after this) ──────────
    local function revealAll()
        panel.BackgroundTransparency = 0.08
        borderStroke.Transparency   = 0.05
        topLine.BackgroundTransparency  = 0.0
        botLine.BackgroundTransparency  = 0.38
        leftBar.BackgroundTransparency  = 0.0
        rightBar.BackgroundTransparency = 0.0
        for _, f in ipairs(tickFrames)   do f.BackgroundTransparency = 0.15 end
        for _, s in ipairs(boltSegments) do s.BackgroundTransparency = 0.15 end
        sepLine.BackgroundTransparency = 0.55
        mainLbl.TextTransparency      = 0.0
        mainLbl.TextStrokeTransparency = 0.0
        subLbl.TextTransparency       = 0.08
        cred.TextTransparency         = 0.22
        aberR.TextTransparency        = 0.68
        aberB.TextTransparency        = 0.68
        lStroke.Transparency          = 0.20
    end

    local function hideAll()
        panel.BackgroundTransparency = 1; borderStroke.Transparency = 1
        topLine.BackgroundTransparency = 1; botLine.BackgroundTransparency = 1
        leftBar.BackgroundTransparency = 1; rightBar.BackgroundTransparency = 1
        for _, f in ipairs(tickFrames)   do f.BackgroundTransparency = 1 end
        for _, s in ipairs(boltSegments) do s.BackgroundTransparency = 1 end
        sepLine.BackgroundTransparency = 1
        mainLbl.TextTransparency = 1; mainLbl.TextStrokeTransparency = 1
        subLbl.TextTransparency = 1; cred.TextTransparency = 1
        aberR.TextTransparency = 1; aberB.TextTransparency = 1
        lStroke.Transparency = 1
    end

    local function snapX(px) wrap.Position = UDim2.new(0.5, px, 0, 18) end

    -- ── ENTRY: lightning strike glitch ───────────────────────
    task.delay(0.00, function() snapX(-10); borderStroke.Transparency=0.1
        for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.0 end
        for _,f in ipairs(tickFrames)   do f.BackgroundTransparency=0.0 end end)
    task.delay(0.05, function() hideAll(); snapX(7) end)
    task.delay(0.09, function()
        panel.BackgroundTransparency=0.38; borderStroke.Transparency=0.0
        topLine.BackgroundTransparency=0.0
        for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.05 end
        mainLbl.TextTransparency=0.5; mainLbl.TextStrokeTransparency=0.5
        aberR.TextTransparency=0.5; aberB.TextTransparency=0.5 end)
    task.delay(0.14, function() hideAll(); snapX(-4) end)
    task.delay(0.17, function()
        panel.BackgroundTransparency=0.18; borderStroke.Transparency=0.05
        topLine.BackgroundTransparency=0.0; botLine.BackgroundTransparency=0.38
        for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.1 end
        for _,f in ipairs(tickFrames)   do f.BackgroundTransparency=0.2 end
        mainLbl.TextTransparency=0.2; mainLbl.TextStrokeTransparency=0.2
        subLbl.TextTransparency=0.4; aberR.TextTransparency=0.6; aberB.TextTransparency=0.6
        lStroke.Transparency=0.3 end)
    task.delay(0.21, function() wrap.Position = UDim2.new(0.5,0,0,18); revealAll() end)

    -- ── IDLE EFFECTS (text + internal elements only) ──────────
    local t, gTimer, glitching = 0, 0, false
    local origText = mainText
    local GCHARS   = {"#","X","/","_","!","I","1","\\","|","0","T","V","Z","N"}
    local function scramble(s)
        local chars = {}; for c in s:gmatch(".") do table.insert(chars,c) end
        local n = math.random(2,3)
        for _ = 1, n do
            local i = math.random(1, #chars)
            if chars[i] ~= " " then chars[i] = GCHARS[math.random(1,#GCHARS)] end
        end
        return table.concat(chars)
    end

    local effectConn
    effectConn = RunService.Heartbeat:Connect(function(dt)
        t += dt; gTimer += dt
        local fast = (math.sin(t*6)+1)/2
        local slow = (math.sin(t*1.6)+1)/2
        borderStroke.Transparency = 0.05 + fast*0.52
        lStroke.Transparency      = 0.10 + fast*0.56
        leftBar.BackgroundTransparency  = fast*0.60
        rightBar.BackgroundTransparency = fast*0.60
        topLine.BackgroundTransparency  = slow*0.42
        botLine.BackgroundTransparency  = 0.32 + fast*0.46
        for _,f in ipairs(tickFrames)   do f.BackgroundTransparency = 0.10+fast*0.56 end
        for _,s in ipairs(boltSegments) do s.BackgroundTransparency = 0.08+fast*0.70 end
        sepLine.BackgroundTransparency  = 0.45+slow*0.36
        cred.TextTransparency           = 0.15+slow*0.28
        local jitter = fast*2.4
        aberR.Position = UDim2.new(0,  jitter, 0, 9)
        aberB.Position = UDim2.new(0, -jitter, 0, 7)
        aberR.TextTransparency = 0.60+slow*0.20
        aberB.TextTransparency = 0.60+slow*0.20
        subLbl.TextTransparency = 0.06+slow*0.30
        if gTimer > 0.88 then
            gTimer = 0; glitching = true
            task.delay(0.060, function()
                glitching = false
                mainLbl.Text = origText; aberR.Text = origText; aberB.Text = origText
            end)
        end
        if glitching then
            local g = scramble(origText)
            mainLbl.Text = g; aberR.Text = g; aberB.Text = g
        end
    end)

    -- ── EXIT: glitch dissolve in place ────────────────────────
    task.delay(displaySecs, function()
        effectConn:Disconnect()
        mainLbl.Text = origText; aberR.Text = origText; aberB.Text = origText
        local steps = {
            {0.00,  5, 0.35, 0.35},
            {0.05, -7, 0.65, 0.55},
            {0.09,  3, 0.25, 0.20},
            {0.13, -4, 0.80, 0.70},
            {0.17,  0, 1.00, 1.00},
        }
        for _, s in ipairs(steps) do
            task.delay(s[1], function()
                if not gui or not gui.Parent then return end
                snapX(s[2])
                panel.BackgroundTransparency = s[3]; borderStroke.Transparency = s[3]
                mainLbl.TextTransparency = s[4]; mainLbl.TextStrokeTransparency = s[4]
                subLbl.TextTransparency  = s[4]
                aberR.TextTransparency   = math.min(1, s[4]+0.15)
                aberB.TextTransparency   = math.min(1, s[4]+0.15)
                cred.TextTransparency    = s[4]
                topLine.BackgroundTransparency = s[3]; botLine.BackgroundTransparency = s[3]
                leftBar.BackgroundTransparency = s[3]; rightBar.BackgroundTransparency = s[3]
                sepLine.BackgroundTransparency = s[3]; lStroke.Transparency = s[4]
                for _,f in ipairs(tickFrames)   do f.BackgroundTransparency = s[3] end
                for _,s2 in ipairs(boltSegments) do s2.BackgroundTransparency = s[3] end
                if s[4] < 0.9 and s[4] > 0 then
                    mainLbl.Text = scramble(origText)
                    aberR.Text = mainLbl.Text; aberB.Text = mainLbl.Text
                end
            end)
        end
        task.delay(0.22, function() pcall(function() gui:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  X-RAY ENGINE
-- ══════════════════════════════════════════════════════════════
local XRAY_TRANSPARENCY = 0.65   -- how see-through walls become
local _savedT    = _G._XrayOrigT     or {}   -- {[part] = originalTransparency}
local _xrayConns = _G._XrayConns     or {}   -- connections to disconnect on OFF
_G._XrayOrigT  = _savedT
_G._XrayConns  = _xrayConns

-- Build a set of all player character parts for fast lookup
local function playerPartSet()
    local s = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, d in ipairs(p.Character:GetDescendants()) do
                s[d] = true
            end
            s[p.Character] = true
        end
    end
    return s
end

local function shouldSkip(part, plrSet)
    -- Skip player character parts
    if plrSet[part] then return true end
    -- Skip already fully invisible parts (triggers, kill parts, etc.)
    if part.Transparency >= 0.98 then return true end
    -- Skip terrain
    if part:IsA("Terrain") then return true end
    return false
end

local function applyXray()
    local plrSet = playerPartSet()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not shouldSkip(obj, plrSet) then
            if _savedT[obj] == nil then
                _savedT[obj] = obj.Transparency
            end
            pcall(function() obj.Transparency = XRAY_TRANSPARENCY end)
        end
    end
end

local function restoreXray()
    for part, origT in pairs(_savedT) do
        pcall(function() part.Transparency = origT end)
    end
    table.clear(_savedT)
end

local function disconnectXrayConns()
    for _, c in ipairs(_xrayConns) do pcall(function() c:Disconnect() end) end
    table.clear(_xrayConns)
end

local function addXConn(c) table.insert(_xrayConns, c) end

-- ══════════════════════════════════════════════════════════════
--  ENABLE
-- ══════════════════════════════════════════════════════════════
local function enableXray()
    -- Initial scan of all existing parts
    applyXray()

    -- Watch for new parts added mid-game (dynamic rooms, spawned objects)
    addXConn(workspace.DescendantAdded:Connect(function(obj)
        if not _G.XrayActive then return end
        if obj:IsA("BasePart") then
            task.wait(0.05)   -- wait for part to settle into workspace hierarchy
            if not shouldSkip(obj, playerPartSet()) then
                if _savedT[obj] == nil then
                    _savedT[obj] = obj.Transparency
                end
                pcall(function() obj.Transparency = XRAY_TRANSPARENCY end)
            end
        end
    end))

    -- Auto re-apply after respawn
    addXConn(LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.25)
        if _G.XrayActive then
            -- Remove old char parts from savedT so they reset cleanly
            local c = LocalPlayer.Character
            if c then
                for _, d in ipairs(c:GetDescendants()) do
                    _savedT[d] = nil
                end
            end
            applyXray()
            buildNotif(
                "__XrayRespawnNotif",
                "X-RAY  RE-APPLIED",
                "AUTO REACTIVATED  ON RESPAWN",
                "respawn",
                2.8
            )
        end
    end))
end

-- ══════════════════════════════════════════════════════════════
--  DISABLE
-- ══════════════════════════════════════════════════════════════
local function disableXray()
    disconnectXrayConns()
    restoreXray()
end

-- ══════════════════════════════════════════════════════════════
--  RUN
-- ══════════════════════════════════════════════════════════════
if ENTERING then
    enableXray()
    buildNotif(
        "__XrayMainNotif",
        "X-RAY  ACTIVATED",
        "WALLS  TRANSPARENT  —  SEE THROUGH",
        "on",
        3.2
    )
else
    disableXray()
    buildNotif(
        "__XrayMainNotif",
        "X-RAY  DEACTIVATED",
        "ALL PARTS  RESTORED  —  NORMAL VIEW",
        "off",
        3.0
    )
end
