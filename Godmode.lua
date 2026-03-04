--[[
    ╔══════════════════════════════════════════╗
    ║      GOD MODE  //  UNIVERSAL ENGINE      ║
    ║      By Anonymous9x                      ║
    ║      Delta Mobile / iOS ONLY             ║
    ║      Execute again to toggle OFF         ║
    ╚══════════════════════════════════════════╝

    ENGINE COVERAGE:
    [1] Health Loop      — Heartbeat: Health locked at MAX
    [2] ForceField       — Invisible FF, blocks projectile/explosion
    [3] Kill Part Scan   — Disable CanTouch on kill/lava/acid/spike/etc
    [4] Part Watcher     — Auto-disable new kill parts added mid-game
    [5] Anti-Void        — Teleport up if Y < -500
    [6] State Hijack     — Force GettingUp on ragdoll/downed state
    [7] MaxHealth Clamp  — Prevent games overriding MaxHealth to 0
    [8] Auto Re-apply    — Reapply engine on respawn + respawn notif
]]

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer  = Players.LocalPlayer

-- Toggle Gate
if _G.GodModeActive == nil then _G.GodModeActive = false end
_G.GodModeActive = not _G.GodModeActive
local ENTERING = _G.GodModeActive

-- ================================================================================
--  SHARED NOTIF BUILDER — reused by main notif AND respawn notif
--  height: total px height of the panel (pass 90 for main, 68 for respawn)
-- ================================================================================
local function buildNotif(guiName, mainText, subText, entering, panelH, displaySecs)

    pcall(function()
        local old = game.CoreGui:FindFirstChild(guiName)
        if old then old:Destroy() end
    end)

    -- Palette
    local PAL = entering and {
        panel  = Color3.fromRGB(10,  6,   0),
        stroke = Color3.fromRGB(255, 200,  40),
        strokeB= Color3.fromRGB(220,  80,   0),
        main   = Color3.fromRGB(255, 230, 120),
        sub    = Color3.fromRGB(255, 155,  25),
        aberR  = Color3.fromRGB(255,  30,   0),
        aberB  = Color3.fromRGB(  0, 200, 255),
        bolt   = Color3.fromRGB(255, 255, 200),
        scan   = Color3.fromRGB(255, 190,  10),
        bar    = Color3.fromRGB(255, 180,   0),
    } or {
        panel  = Color3.fromRGB(  3,   6,  18),
        stroke = Color3.fromRGB( 70, 155, 255),
        strokeB= Color3.fromRGB( 20,  55, 200),
        main   = Color3.fromRGB(155, 210, 255),
        sub    = Color3.fromRGB( 70, 135, 230),
        aberR  = Color3.fromRGB(190,  30, 255),
        aberB  = Color3.fromRGB(  0, 220, 255),
        bolt   = Color3.fromRGB(200, 228, 255),
        scan   = Color3.fromRGB( 50, 115, 255),
        bar    = Color3.fromRGB( 60, 140, 255),
    }

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name           = guiName
    gui.ResetOnSpawn   = false
    gui.DisplayOrder   = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = game.CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

    -- Wrapper (slide target) — panelH is the full height
    local wrap = Instance.new("Frame")
    wrap.Name                   = "Wrap"
    wrap.Size                   = UDim2.new(0, 298, 0, panelH)
    wrap.Position               = UDim2.new(0.5, 0, 0, -(panelH + 30))
    wrap.AnchorPoint            = Vector2.new(0.5, 0)
    wrap.BackgroundTransparency = 1
    wrap.ClipsDescendants       = false
    wrap.ZIndex                 = 10
    wrap.Parent                 = gui

    -- Panel BG — fills the full wrap
    local panel = Instance.new("Frame")
    panel.Size                  = UDim2.new(1, 0, 1, 0)
    panel.BackgroundColor3      = PAL.panel
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel       = 0
    panel.ZIndex                = 10
    panel.Parent                = wrap
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 7)

    local borderStroke = Instance.new("UIStroke")
    borderStroke.Color       = PAL.stroke
    borderStroke.Thickness   = 1.8
    borderStroke.Transparency = 0.04
    borderStroke.Parent      = panel

    -- Top accent line
    local topLine = Instance.new("Frame")
    topLine.Size             = UDim2.new(0.86, 0, 0, 2)
    topLine.Position         = UDim2.new(0.07, 0, 0, 0)
    topLine.BackgroundColor3 = PAL.stroke
    topLine.BorderSizePixel  = 0
    topLine.ZIndex           = 14
    topLine.Parent           = wrap
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(1,0)

    -- Bottom dim line
    local botLine = Instance.new("Frame")
    botLine.Size             = UDim2.new(0.50, 0, 0, 1)
    botLine.Position         = UDim2.new(0.25, 0, 1, -1)
    botLine.BackgroundColor3 = PAL.sub
    botLine.BackgroundTransparency = 0.35
    botLine.BorderSizePixel  = 0
    botLine.ZIndex           = 14
    botLine.Parent           = wrap
    Instance.new("UICorner", botLine).CornerRadius = UDim.new(1,0)

    -- Left / Right power bars
    local leftBar = Instance.new("Frame")
    leftBar.Size             = UDim2.new(0, 3, 0.65, 0)
    leftBar.Position         = UDim2.new(0, 0, 0.175, 0)
    leftBar.BackgroundColor3 = PAL.bar
    leftBar.BorderSizePixel  = 0
    leftBar.ZIndex           = 15
    leftBar.Parent           = wrap
    Instance.new("UICorner", leftBar).CornerRadius = UDim.new(1,0)

    local rightBar = leftBar:Clone()
    rightBar.Position = UDim2.new(1, -3, 0.175, 0)
    rightBar.Parent   = wrap

    -- Corner tick marks (HUD)
    local function tick(parent, ax, ay)
        local hw = Instance.new("Frame")
        hw.Size             = UDim2.new(0, 9, 0, 2)
        hw.Position         = UDim2.new(ax, ax==0 and 1 or -10, ay, ay==0 and 1 or -3)
        hw.BackgroundColor3 = PAL.stroke
        hw.BackgroundTransparency = 0.15
        hw.BorderSizePixel  = 0
        hw.ZIndex           = 17
        hw.Parent           = parent
        local vw = Instance.new("Frame")
        vw.Size             = UDim2.new(0, 2, 0, 9)
        vw.Position         = UDim2.new(ax, ax==0 and 1 or -3, ay, ay==0 and 1 or -10)
        vw.BackgroundColor3 = PAL.stroke
        vw.BackgroundTransparency = 0.15
        vw.BorderSizePixel  = 0
        vw.ZIndex           = 17
        vw.Parent           = parent
    end
    tick(wrap, 0, 0) tick(wrap, 1, 0)
    tick(wrap, 0, 1) tick(wrap, 1, 1)

    -- CRT scanlines
    for i = 0, 5 do
        local sl = Instance.new("Frame")
        sl.Size             = UDim2.new(1, -4, 0, 1)
        sl.Position         = UDim2.new(0, 2, 0, 5 + i * 14)
        sl.BackgroundColor3 = PAL.scan
        sl.BackgroundTransparency = 0.83
        sl.BorderSizePixel  = 0
        sl.ZIndex           = 15
        sl.Parent           = wrap
    end

    -- Drawn lightning bolt zigzags
    local function makeBolt(parent, ox, oy)
        local segs = {
            {dx=5,  dy=0,  r= 52, w=11, h=2},
            {dx=3,  dy=6,  r=-48, w=9,  h=2},
            {dx=6,  dy=12, r= 55, w=12, h=2},
            {dx=2,  dy=18, r=-42, w=8,  h=2},
        }
        for _, s in ipairs(segs) do
            local seg = Instance.new("Frame")
            seg.Size             = UDim2.new(0, s.w, 0, s.h)
            seg.Position         = UDim2.new(0, ox + s.dx, 0, oy + s.dy)
            seg.Rotation         = s.r
            seg.BackgroundColor3 = PAL.bolt
            seg.BackgroundTransparency = 0.12
            seg.BorderSizePixel  = 0
            seg.ZIndex           = 16
            seg.Parent           = parent
        end
    end
    makeBolt(wrap,  6,  10)
    makeBolt(wrap, 16,   6)
    makeBolt(wrap, 268, 10)
    makeBolt(wrap, 278,  6)

    -- Chromatic aberration ghosts
    local aberR = Instance.new("TextLabel")
    aberR.Size               = UDim2.new(1, 0, 0, 28)
    aberR.Position           = UDim2.new(0, 2.5, 0, 10)
    aberR.BackgroundTransparency = 1
    aberR.Text               = mainText
    aberR.Font               = Enum.Font.GothamBlack
    aberR.TextSize           = 15
    aberR.TextColor3         = PAL.aberR
    aberR.TextTransparency   = 0.70
    aberR.TextXAlignment     = Enum.TextXAlignment.Center
    aberR.ZIndex             = 11
    aberR.Parent             = wrap

    local aberB = Instance.new("TextLabel")
    aberB.Size               = UDim2.new(1, 0, 0, 28)
    aberB.Position           = UDim2.new(0, -2.5, 0, 8)
    aberB.BackgroundTransparency = 1
    aberB.Text               = mainText
    aberB.Font               = Enum.Font.GothamBlack
    aberB.TextSize           = 15
    aberB.TextColor3         = PAL.aberB
    aberB.TextTransparency   = 0.70
    aberB.TextXAlignment     = Enum.TextXAlignment.Center
    aberB.ZIndex             = 11
    aberB.Parent             = wrap

    -- Main title
    local mainLbl = Instance.new("TextLabel")
    mainLbl.Size               = UDim2.new(1, 0, 0, 28)
    mainLbl.Position           = UDim2.new(0, 0, 0, 9)
    mainLbl.BackgroundTransparency = 1
    mainLbl.Text               = mainText
    mainLbl.Font               = Enum.Font.GothamBlack
    mainLbl.TextSize           = 15
    mainLbl.TextColor3         = PAL.main
    mainLbl.TextStrokeColor3   = PAL.strokeB
    mainLbl.TextStrokeTransparency = 0.0
    mainLbl.TextXAlignment     = Enum.TextXAlignment.Center
    mainLbl.ZIndex             = 18
    mainLbl.Parent             = wrap

    local lStroke = Instance.new("UIStroke")
    lStroke.Color       = PAL.stroke
    lStroke.Thickness   = 1.1
    lStroke.Transparency = 0.18
    lStroke.Parent      = mainLbl

    -- Sub text
    local subLbl = Instance.new("TextLabel")
    subLbl.Size               = UDim2.new(1, -20, 0, 18)
    subLbl.Position           = UDim2.new(0, 10, 0, 40)
    subLbl.BackgroundTransparency = 1
    subLbl.Text               = subText
    subLbl.Font               = Enum.Font.GothamSemibold
    subLbl.TextSize           = 10
    subLbl.TextColor3         = PAL.sub
    subLbl.TextTransparency   = 0.08
    subLbl.TextXAlignment     = Enum.TextXAlignment.Center
    subLbl.ZIndex             = 18
    subLbl.Parent             = wrap

    -- ── Credit INSIDE the panel — bottom area ──────────────────────────────────
    -- Thin separator line above credit
    local sepLine = Instance.new("Frame")
    sepLine.Size             = UDim2.new(0.7, 0, 0, 1)
    sepLine.Position         = UDim2.new(0.15, 0, 1, -18)
    sepLine.BackgroundColor3 = PAL.stroke
    sepLine.BackgroundTransparency = 0.6
    sepLine.BorderSizePixel  = 0
    sepLine.ZIndex           = 17
    sepLine.Parent           = wrap
    Instance.new("UICorner", sepLine).CornerRadius = UDim.new(1,0)

    local cred = Instance.new("TextLabel")
    cred.Size               = UDim2.new(1, -16, 0, 14)
    cred.Position           = UDim2.new(0, 8, 1, -16)   -- 16px from bottom, inside wrap
    cred.BackgroundTransparency = 1
    cred.Text               = "By  Anonymous9x"
    cred.Font               = Enum.Font.Gotham
    cred.TextSize           = 8
    cred.TextColor3         = Color3.fromRGB(140, 140, 140)
    cred.TextTransparency   = 0.20
    cred.TextXAlignment     = Enum.TextXAlignment.Center
    cred.ZIndex             = 18
    cred.Parent             = wrap

    -- ============================================================
    --  Effects loop
    -- ============================================================
    local t           = 0
    local gTimer      = 0
    local glitching   = false
    local origText    = mainText
    local GCHARS      = {"#","X","/","_","!","I","1","\\","|","0","T","V","Z","N"}

    local function scramble(s)
        local chars = {}
        for c in s:gmatch(".") do table.insert(chars, c) end
        local n = math.random(2, 4)
        for _ = 1, n do
            local i = math.random(1, #chars)
            if chars[i] ~= " " then
                chars[i] = GCHARS[math.random(1,#GCHARS)]
            end
        end
        return table.concat(chars)
    end

    local effectConn
    effectConn = RunService.Heartbeat:Connect(function(dt)
        t      += dt
        gTimer += dt

        local fast = (math.sin(t * 6)   + 1) / 2
        local slow = (math.sin(t * 1.6) + 1) / 2

        borderStroke.Transparency = 0.04 + fast * 0.55
        lStroke.Transparency      = 0.02 + fast * 0.60

        leftBar.BackgroundTransparency  = fast * 0.65
        rightBar.BackgroundTransparency = fast * 0.65

        topLine.BackgroundTransparency = slow * 0.45
        botLine.BackgroundTransparency = 0.30 + fast * 0.50

        if math.random() < 0.035 then
            panel.BackgroundTransparency = 0.65
        else
            panel.BackgroundTransparency = 0.08 + slow * 0.07
        end

        local jitter = fast * 2.8
        aberR.Position = UDim2.new(0,  jitter, 0, 10)
        aberB.Position = UDim2.new(0, -jitter, 0,  8)
        aberR.TextTransparency = 0.60 + slow * 0.25
        aberB.TextTransparency = 0.60 + slow * 0.25

        for _, child in ipairs(wrap:GetChildren()) do
            if child:IsA("Frame") and math.abs(child.Rotation) > 10 then
                child.BackgroundTransparency = 0.08 + fast * 0.72
            end
        end

        subLbl.TextTransparency = 0.05 + slow * 0.38
        sepLine.BackgroundTransparency = 0.5 + slow * 0.35
        cred.TextTransparency = 0.15 + slow * 0.30

        if gTimer > 0.85 then
            gTimer    = 0
            glitching = true
            task.delay(0.065, function()
                glitching    = false
                mainLbl.Text = origText
                aberR.Text   = origText
                aberB.Text   = origText
            end)
        end

        if glitching then
            local g      = scramble(origText)
            mainLbl.Text = g
            aberR.Text   = g
            aberB.Text   = g
        end
    end)

    -- Slide IN
    TweenService:Create(wrap,
        TweenInfo.new(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 0, 18) }
    ):Play()

    -- Auto dismiss
    task.delay(displaySecs, function()
        effectConn:Disconnect()
        mainLbl.Text = origText
        local out = TweenService:Create(wrap,
            TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = UDim2.new(0.5, 0, 0, -(panelH + 40)) }
        )
        out:Play()
        out.Completed:Connect(function()
            pcall(function() gui:Destroy() end)
        end)
    end)
end

-- Main toggle notif (taller: 92px to fit credit comfortably inside)
local function showMainNotif(entering)
    if entering then
        buildNotif(
            "__GodNotif9x",
            "GOD MODE ACTIVATED",
            "PROTECTION SYSTEMS  ONLINE",
            true, 92, 3.0
        )
    else
        buildNotif(
            "__GodNotif9x",
            "NORMAL MODE RESTORED",
            "ALL SYSTEMS  OFFLINE",
            false, 92, 3.0
        )
    end
end

-- Respawn notif (same height, gold palette, different text)
local function showRespawnNotif()
    buildNotif(
        "__GodRespawnNotif9x",
        "GOD MODE RE-APPLIED",
        "AUTO REACTIVATED  ON RESPAWN",
        true, 92, 2.8
    )
end

-- ================================================================================
--  GOD MODE ENGINE
-- ================================================================================
local _connections = _G._GodModeConnections or {}
local _savedParts  = _G._GodModeParts       or {}
_G._GodModeConnections = _connections
_G._GodModeParts       = _savedParts

local KILL_KEYWORDS = {
    "kill","lava","acid","death","damage","spike","poison","void",
    "laser","fire","toxic","instant","drown","nuke","hot","burn",
    "explode","electric","zap","hazard","danger","lethal","harmful",
    "magma","boil","trap","deadly","dead","hurt","hit","ouch",
}

local function isKillPart(part)
    if not part:IsA("BasePart") then return false end
    local n = part.Name:lower()
    for _, kw in ipairs(KILL_KEYWORDS) do
        if n:find(kw, 1, true) then return true end
    end
    if part.Material == Enum.Material.Neon then return true end
    return false
end

local function disableKillPart(part)
    if isKillPart(part) then
        if _savedParts[part] == nil then
            _savedParts[part] = { CanTouch = part.CanTouch, CanCollide = part.CanCollide }
        end
        pcall(function()
            part.CanTouch   = false
            part.CanCollide = false
        end)
    end
end

local function restoreKillPart(part, props)
    pcall(function()
        part.CanTouch   = props.CanTouch
        part.CanCollide = props.CanCollide
    end)
end

local function disconnectAll()
    for _, c in ipairs(_connections) do pcall(function() c:Disconnect() end) end
    table.clear(_connections)
end

local function addConn(c) table.insert(_connections, c) end

local function enableGodMode(isRespawn)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.MaxHealth = math.huge
    hum.Health    = math.huge

    -- Remove any old FF first
    for _, v in ipairs(char:GetChildren()) do
        if v.Name == "_GodFF" then v:Destroy() end
    end

    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Name    = "_GodFF"
    ff.Parent  = char

    for _, part in ipairs(workspace:GetDescendants()) do
        disableKillPart(part)
    end

    -- Health + state clamp loop
    addConn(RunService.Heartbeat:Connect(function()
        local c2 = LocalPlayer.Character
        if not c2 then return end
        local h2 = c2:FindFirstChildOfClass("Humanoid")
        if not h2 then return end
        if h2.MaxHealth ~= math.huge then h2.MaxHealth = math.huge end
        if h2.Health < h2.MaxHealth   then h2.Health   = math.huge end
        local s = h2:GetState()
        if s == Enum.HumanoidStateType.Dead or s == Enum.HumanoidStateType.FallingDown then
            h2:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end))

    -- Anti-void loop
    addConn(RunService.Heartbeat:Connect(function()
        local c2 = LocalPlayer.Character
        if not c2 then return end
        local hrp = c2:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < -500 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
        end
    end))

    -- New kill part watcher
    addConn(workspace.DescendantAdded:Connect(function(p)
        if _G.GodModeActive then disableKillPart(p) end
    end))

    -- Re-apply on respawn + show respawn notif
    addConn(LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.18)
        if _G.GodModeActive then
            enableGodMode(true)     -- isRespawn = true
            showRespawnNotif()      -- fire the re-apply notif
        end
    end))

    -- Show respawn notif if this call was triggered by a respawn
    if isRespawn then
        -- already called by the caller above
    end
end

local function disableGodMode()
    disconnectAll()
    for part, props in pairs(_savedParts) do restoreKillPart(part, props) end
    table.clear(_savedParts)
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v.Name == "_GodFF" then v:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100
            hum.Health    = 100
        end
    end
end

-- ── Run ──────────────────────────────────────────────────────────────────────
if ENTERING then
    enableGodMode(false)
else
    disableGodMode()
end

showMainNotif(ENTERING)
