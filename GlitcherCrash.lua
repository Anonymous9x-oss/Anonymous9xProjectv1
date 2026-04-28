--[[
    Ano9x Glitcher Crash
    Delta Mobile / Delta iOS
    FE Emote Glitch Engine — Mode System
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1.5)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LP = Players.LocalPlayer
local function getChar() return LP.Character end
local function getHRP()  local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- GUI Parent
local GuiParent
do
    local ok, h = pcall(function() return gethui() end)
    GuiParent = (ok and h) or LP:WaitForChild("PlayerGui", 15)
end
for _, v in pairs(GuiParent:GetChildren()) do
    if v.Name == "Ano9x_GCMain" or v.Name == "Ano9x_GCNotif" or v.Name == "Ano9x_GCIcon" then
        v:Destroy()
    end
end

-- ============================================================
-- EMOTE ENGINE
-- ============================================================
local DEFAULT_ID = "93224413172183"

-- Mode presets
local MODES = {
    Crash = {
        StopOnMove   = false,
        TimePosition = 0,
        Speed        = 1.08,
        Weight       = 0.54,
        FadeIn       = 0,
        FadeOut      = 0,
    },
    Wide = {
        StopOnMove   = false,
        TimePosition = 0,
        Speed        = 2.00,
        Weight       = 8.00,   -- intentionally way above cap for max stretch
        FadeIn       = 0,
        FadeOut      = 0,
    },
    Custom = {
        StopOnMove   = false,
        TimePosition = 9.99,
        Speed        = 12.00,
        Weight       = 0.79,
        FadeIn       = 6.00,
        FadeOut      = 6.00,
    },
}

local S = {
    StopOnMove   = false,
    TimePosition = 0,
    Speed        = 1.08,
    Weight       = 0.54,
    FadeIn       = 0,
    FadeOut      = 0,
}

local CurrentTrack = nil
local lastPos      = Vector3.new()
local origCollide  = {}
local isActive     = false
local selectedMode = nil   -- "Crash" | "Wide" | "Speed"

local function saveCollide()
    origCollide = {}
    local c = getChar(); if not c then return end
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            origCollide[p] = p.CanCollide
        end
    end
end

local function disableCollide()
    local c = getChar(); if not c then return end
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            pcall(function() p.CanCollide = false end)
        end
    end
end

local function restoreCollide()
    for p, v in pairs(origCollide) do
        if p and p.Parent then pcall(function() p.CanCollide = v end) end
    end
    origCollide = {}
end

local function doStop()
    isActive = false
    if CurrentTrack then
        pcall(function() CurrentTrack:Stop(S.FadeOut) end)
        CurrentTrack = nil
    end
    restoreCollide()
end

local function doPlay()
    local hum = getHum()
    if not hum then return false, "Humanoid not found" end
    doStop()

    local animId
    local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. DEFAULT_ID) end)
    if ok and res and res[1] and res[1]:IsA("Animation") then
        animId = res[1].AnimationId
    else
        animId = "rbxassetid://" .. DEFAULT_ID
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId

    local ok2, track = pcall(function() return hum:LoadAnimation(anim) end)
    if not ok2 or not track then return false, "Failed to load animation" end

    track.Priority = Enum.AnimationPriority.Action4
    local w = S.Weight == 0 and 0.001 or S.Weight
    track:Play(S.FadeIn, w, S.Speed)
    CurrentTrack = track

    task.delay(0.05, function()
        if CurrentTrack and CurrentTrack.IsPlaying then
            if CurrentTrack.Length and CurrentTrack.Length > 0 then
                CurrentTrack.TimePosition = S.TimePosition
            end
            pcall(function() CurrentTrack:AdjustSpeed(S.Speed) end)
            pcall(function() CurrentTrack:AdjustWeight(w) end)
        end
    end)

    saveCollide()
    disableCollide()

    local hrp = getHRP()
    if hrp then lastPos = hrp.Position end
    isActive = true
    return true
end

-- Stop on move
RunService.RenderStepped:Connect(function()
    local hrp = getHRP(); if not hrp then return end
    if S.StopOnMove and CurrentTrack and CurrentTrack.IsPlaying then
        local moved = (hrp.Position - lastPos).Magnitude > 0.1
        local hum   = getHum()
        local jump  = hum and hum:GetState() == Enum.HumanoidStateType.Jumping
        if moved or jump then
            pcall(function() CurrentTrack:Stop(S.FadeOut) end)
            CurrentTrack = nil; isActive = false
            restoreCollide()
        end
    end
    lastPos = hrp.Position
end)

-- ============================================================
-- SPIN ENGINE — FE (character physics replicate to all players)
-- ============================================================
local spinConn   = nil
local spinActive = 0   -- 0 = off, 1 = spin1, 2 = spin2

local SPIN1_DEG = 2800  -- degrees per second (SUPER FAST — fastest)
local SPIN2_DEG = 1200  -- degrees per second (fast)

local function stopSpin()
    if spinConn then spinConn:Disconnect(); spinConn = nil end
    spinActive = 0
end

local function startSpin(idx)
    stopSpin()
    spinActive = idx
    local degPerSec = (idx == 1) and SPIN1_DEG or SPIN2_DEG
    spinConn = RunService.Heartbeat:Connect(function(dt)
        local hrp = getHRP(); if not hrp then return end
        pcall(function()
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(degPerSec * dt), 0)
        end)
    end)
end

-- ============================================================
-- HELPERS
-- ============================================================
local function sDes(o) if o and o.Parent then pcall(function() o:Destroy() end) end end
local function sDis(c) if c then pcall(function() c:Disconnect() end) end end
local function tw(obj, props, t, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, sty or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ============================================================
-- LAYOUT
-- ============================================================
local GW = 265
local GH = 220
local TH = 38
local PD = 9
local IW = GW - PD * 2
local GP = 5

-- ============================================================
-- NOTIFICATION — bottom-right, 2s
-- ============================================================
local NotifSG = Instance.new("ScreenGui")
NotifSG.Name = "Ano9x_GCNotif"; NotifSG.ResetOnSpawn = false
NotifSG.DisplayOrder = 9999; NotifSG.Parent = GuiParent

local NF = Instance.new("Frame", NotifSG)
NF.AnchorPoint = Vector2.new(1, 1); NF.Size = UDim2.new(0, 200, 0, 30)
NF.Position = UDim2.new(1, -8, 1, -10)
NF.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
NF.BackgroundTransparency = 1; NF.BorderSizePixel = 0; NF.ZIndex = 200
Instance.new("UICorner", NF).CornerRadius = UDim.new(0, 6)

local NFBar = Instance.new("Frame", NF)
NFBar.Size = UDim2.new(0, 3, 1, 0)
NFBar.BackgroundColor3 = Color3.fromRGB(175, 0, 205)
NFBar.BackgroundTransparency = 1; NFBar.BorderSizePixel = 0; NFBar.ZIndex = 201
Instance.new("UICorner", NFBar).CornerRadius = UDim.new(0, 6)

local NFLbl = Instance.new("TextLabel", NF)
NFLbl.Size = UDim2.new(1, -13, 1, 0); NFLbl.Position = UDim2.new(0, 10, 0, 0)
NFLbl.BackgroundTransparency = 1; NFLbl.TextTransparency = 1
NFLbl.TextScaled = true; NFLbl.Font = Enum.Font.GothamSemibold
NFLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
NFLbl.TextXAlignment = Enum.TextXAlignment.Left; NFLbl.ZIndex = 201

local notifThr = nil
local function Notif(msg, accent, dur)
    if notifThr then task.cancel(notifThr) end
    NFBar.BackgroundColor3 = accent or Color3.fromRGB(175, 0, 205)
    NFLbl.Text = msg
    tw(NF,    {BackgroundTransparency = 0}, 0.14)
    tw(NFBar, {BackgroundTransparency = 0}, 0.14)
    tw(NFLbl, {TextTransparency = 0},       0.14)
    notifThr = task.delay(dur or 2, function()
        tw(NF,    {BackgroundTransparency = 1}, 0.14)
        tw(NFBar, {BackgroundTransparency = 1}, 0.14)
        tw(NFLbl, {TextTransparency = 1},       0.14)
    end)
end

-- ============================================================
-- FLOATING ICON — top-right, fixed
-- ============================================================
local IconSG = Instance.new("ScreenGui")
IconSG.Name = "Ano9x_GCIcon"; IconSG.ResetOnSpawn = false
IconSG.DisplayOrder = 9997; IconSG.Parent = GuiParent

local IconBtn = Instance.new("ImageButton", IconSG)
IconBtn.AnchorPoint = Vector2.new(1, 0)
IconBtn.Size        = UDim2.new(0, 46, 0, 46)
IconBtn.Position    = UDim2.new(1, -10, 0, 10)
IconBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
IconBtn.BorderSizePixel  = 0
IconBtn.Image   = "rbxassetid://97269958324726"
IconBtn.ZIndex  = 100; IconBtn.Visible = false
Instance.new("UICorner", IconBtn).CornerRadius = UDim.new(0, 10)

local IconStroke = Instance.new("UIStroke", IconBtn)
IconStroke.Color = Color3.fromRGB(255, 255, 255); IconStroke.Thickness = 2.5

local iconConn = nil
local function startIconAnim()
    if iconConn then return end
    local t = 0
    local W = Color3.fromRGB(255, 255, 255)
    local P = Color3.fromRGB(180, 0, 220)
    iconConn = RunService.Heartbeat:Connect(function(dt)
        if not IconBtn.Visible then return end
        t = (t + dt) % 6
        local col, thk = W, 2.5
        if     t < 2.0 then col = W
        elseif t < 2.5 then col = (math.random(2)==1) and W or P; thk = math.random(100)<=20 and math.random(1,5) or 2.5
        elseif t < 4.5 then col = P
        elseif t < 5.0 then col = (math.random(2)==1) and P or W; thk = math.random(100)<=20 and math.random(1,5) or 2.5
        else                col = W
        end
        IconStroke.Color = col; IconStroke.Thickness = thk
    end)
end
local function stopIconAnim()
    sDis(iconConn); iconConn = nil
    IconStroke.Color = Color3.fromRGB(255, 255, 255); IconStroke.Thickness = 2.5
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "Ano9x_GCMain"; SG.ResetOnSpawn = false
SG.DisplayOrder = 9998; SG.Parent = GuiParent

local Main = Instance.new("Frame", SG)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size        = UDim2.new(0, GW, 0, GH)
Main.Position    = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BackgroundTransparency = 1
Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.ZIndex = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)

local MStroke = Instance.new("UIStroke", Main)
MStroke.Color = Color3.fromRGB(255, 255, 255); MStroke.Thickness = 1.2; MStroke.Transparency = 1

task.defer(function()
    tw(Main,    {BackgroundTransparency = 0}, 0.24, Enum.EasingStyle.Quad)
    tw(MStroke, {Transparency = 0},           0.24, Enum.EasingStyle.Quad)
end)

-- Title bar
local TBar = Instance.new("Frame", Main)
TBar.Size = UDim2.new(1, 0, 0, TH)
TBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TBar.BorderSizePixel = 0; TBar.ZIndex = 10

local TLine = Instance.new("Frame", TBar)
TLine.Size = UDim2.new(1, 0, 0, 1); TLine.Position = UDim2.new(0, 0, 1, -1)
TLine.BackgroundColor3 = Color3.fromRGB(38, 38, 38); TLine.BorderSizePixel = 0; TLine.ZIndex = 11

local TTxt = Instance.new("TextLabel", TBar)
TTxt.Size = UDim2.new(1, -64, 1, 0); TTxt.Position = UDim2.new(0, 10, 0, 0)
TTxt.BackgroundTransparency = 1; TTxt.Text = "Ano9x Glitcher Crash"
TTxt.TextColor3 = Color3.fromRGB(235, 235, 235); TTxt.TextScaled = true
TTxt.Font = Enum.Font.GothamBold; TTxt.TextXAlignment = Enum.TextXAlignment.Left; TTxt.ZIndex = 11

local MinBtn = Instance.new("TextButton", TBar)
MinBtn.Size = UDim2.new(0, 24, 0, 24); MinBtn.Position = UDim2.new(1, -54, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); MinBtn.BorderSizePixel = 0
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.fromRGB(185, 185, 185)
MinBtn.TextScaled = true; MinBtn.Font = Enum.Font.GothamBold; MinBtn.ZIndex = 12
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", MinBtn).Color = Color3.fromRGB(55, 55, 55)

local CloseBtn = Instance.new("TextButton", TBar)
CloseBtn.Size = UDim2.new(0, 24, 0, 24); CloseBtn.Position = UDim2.new(1, -26, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(168, 28, 28); CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "x"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.ZIndex = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- Drag whole panel
do
    local active, ds, dp = false, nil, nil
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            active = true; ds = i.Position; dp = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not active then return end
        if i.UserInputType ~= Enum.UserInputType.Touch
        and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = i.Position - ds
        Main.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
    end)
end

-- Scroll
local SCH = GH - TH
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size     = UDim2.new(1, 0, 0, SCH)
Scroll.Position = UDim2.new(0, 0, 0, TH)
Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(85, 0, 115)
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
Scroll.ZIndex = 3; Scroll.ClipsDescendants = true

-- ============================================================
-- BUILDERS
-- ============================================================
local curY = PD
local function adv(h) local y = curY; curY = curY + h + GP; return y end

local function Sep()
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0, IW, 0, 1); f.Position = UDim2.new(0, PD, 0, adv(1))
    f.BackgroundColor3 = Color3.fromRGB(36, 36, 36); f.BorderSizePixel = 0; f.ZIndex = 4
end

local function SecLabel(txt)
    local l = Instance.new("TextLabel", Scroll)
    l.Size = UDim2.new(0, IW, 0, 18); l.Position = UDim2.new(0, PD, 0, adv(18))
    l.BackgroundTransparency = 1; l.Text = txt
    l.TextColor3 = Color3.fromRGB(165, 0, 195); l.TextScaled = true
    l.Font = Enum.Font.GothamBold; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 4
end

local function BigBtn(txt, h, bg)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, IW, 0, h); b.Position = UDim2.new(0, PD, 0, adv(h))
    b.BackgroundColor3 = bg or Color3.fromRGB(112, 0, 142); b.BorderSizePixel = 0
    b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true; b.Font = Enum.Font.GothamBold; b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local function SecBtn(txt, h)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, IW, 0, h); b.Position = UDim2.new(0, PD, 0, adv(h))
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.BorderSizePixel = 0
    b.Text = txt; b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.TextScaled = true; b.Font = Enum.Font.GothamSemibold; b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(42, 42, 42); s.Thickness = 1
    return b
end

local function Row2(t1, t2, h)
    local hw = math.floor((IW - GP) / 2); local y = adv(h)
    local function mk(txt, xo, bg)
        local b = Instance.new("TextButton", Scroll)
        b.Size = UDim2.new(0, hw, 0, h); b.Position = UDim2.new(0, PD + xo, 0, y)
        b.BackgroundColor3 = bg or Color3.fromRGB(20, 20, 20); b.BorderSizePixel = 0
        b.Text = txt; b.TextColor3 = Color3.fromRGB(190, 190, 190)
        b.TextScaled = true; b.Font = Enum.Font.GothamSemibold; b.ZIndex = 4
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(42, 42, 42); s.Thickness = 1
        return b
    end
    return mk(t1, 0), mk(t2, hw + GP)
end

-- Mode button — full width, with selected highlight
local function ModeBtn(txt, h)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, IW, 0, h); b.Position = UDim2.new(0, PD, 0, adv(h))
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.BorderSizePixel = 0
    b.Text = txt; b.TextColor3 = Color3.fromRGB(190, 190, 190)
    b.TextScaled = true; b.Font = Enum.Font.GothamSemibold; b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(60, 0, 80); s.Thickness = 1
    return b, s
end

local function InfoBox(txt, h)
    local y = adv(h)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0, IW, 0, h); f.Position = UDim2.new(0, PD, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(14, 14, 14); f.BorderSizePixel = 0; f.ZIndex = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(34, 34, 34)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -10, 1, -6); l.Position = UDim2.new(0, 5, 0, 3)
    l.BackgroundTransparency = 1; l.Text = txt
    l.TextColor3 = Color3.fromRGB(95, 95, 95); l.TextScaled = true
    l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true; l.ZIndex = 5
end

local function CreditBox(h)
    local y = adv(h)
    local l = Instance.new("TextLabel", Scroll)
    l.Size = UDim2.new(0, IW, 0, h); l.Position = UDim2.new(0, PD, 0, y)
    l.BackgroundTransparency = 1
    l.Text = "Created By @Anonymous9x  •  Est 2025"
    l.TextColor3 = Color3.fromRGB(80, 0, 100); l.TextScaled = true
    l.Font = Enum.Font.GothamBold; l.TextXAlignment = Enum.TextXAlignment.Center
    l.ZIndex = 4
end

-- ============================================================
-- BUILD PANEL
-- ============================================================

-- ── GLITCH CONTROL
SecLabel("GLITCH CONTROL")
local ActiveBtn = BigBtn("ACTIVE", 42)
local StopBtn   = SecBtn("STOP",   30)
Sep()

-- ── MODE SELECT
SecLabel("SELECT MODE")
local CrashBtn, CrashStroke = ModeBtn("Mode Crash",  40)
local WideBtn,  WideStroke  = ModeBtn("Mode Wide",   40)
local CustomBtn, CustomStroke = ModeBtn("Mode Custom", 40)
Sep()

-- ── SPIN
SecLabel("SPIN FE")
local Spin1Btn, Spin2Btn = Row2("Spin 1  — Fastest", "Spin 2  — Fast", 40)
local StopSpinBtn = SecBtn("Stop Spin", 30)
Sep()

-- ── INFO BOX (long, English)
InfoBox(
[[HOW TO USE:
1. Select a mode first (Crash / Wide / Custom).
2. Press ACTIVE to start the glitch.
3. Press STOP to deactivate.

MODE CRASH — Best for crashing players nearby. Get as close as possible to the target, activate, and their client will struggle to resolve the physics collision. Works best in crowded areas.

MODE WIDE — Stretches your avatar across the entire map. All players will see your glitch covering the sky and surrounding area. Great for anti-visual and map-wide chaos.

MODE CUSTOM — The laser appears static/still on its own — this is normal. To make it move and look insane, combine it with Spin 1 or Spin 2. Adjust the experience to your liking using the spin speed.

SPIN FE — Spin 1 is the FASTEST spin, makes your avatar a full blur visible to all players. Spin 2 is fast but smoother. Both spins work simultaneously with any glitch mode. Press the button again or press Stop Spin to stop.

TIP: Combine Mode Wide + Spin 1 for maximum skybox coverage and visual crash effect.]],
    410
)

CreditBox(24)
curY = curY + PD
Scroll.CanvasSize = UDim2.new(0, 0, 0, curY)

-- ============================================================
-- MODE SELECTION VISUALS
-- ============================================================
local MODE_ON_BG  = Color3.fromRGB(112, 0, 142)
local MODE_OFF_BG = Color3.fromRGB(20, 20, 20)
local MODE_ON_TC  = Color3.fromRGB(255, 255, 255)
local MODE_OFF_TC = Color3.fromRGB(190, 190, 190)
local MODE_ON_STR = Color3.fromRGB(200, 0, 255)
local MODE_OFF_STR = Color3.fromRGB(60, 0, 80)

local modeButtons = {
    {btn = CrashBtn,  stroke = CrashStroke,  key = "Crash"},
    {btn = WideBtn,   stroke = WideStroke,   key = "Wide"},
    {btn = CustomBtn, stroke = CustomStroke, key = "Custom"},
}

local function setModeVisuals(activeKey)
    for _, m in ipairs(modeButtons) do
        local on = (m.key == activeKey)
        m.btn.BackgroundColor3 = on and MODE_ON_BG  or MODE_OFF_BG
        m.btn.TextColor3       = on and MODE_ON_TC  or MODE_OFF_TC
        m.stroke.Color         = on and MODE_ON_STR or MODE_OFF_STR
        m.stroke.Thickness     = on and 1.5 or 1
    end
end

local function applyMode(key)
    selectedMode = key
    local preset = MODES[key]
    S.StopOnMove   = preset.StopOnMove
    S.TimePosition = preset.TimePosition
    S.Speed        = preset.Speed
    S.Weight       = preset.Weight
    S.FadeIn       = preset.FadeIn
    S.FadeOut      = preset.FadeOut
    setModeVisuals(key)
    Notif("Mode " .. key .. " selected.", Color3.fromRGB(140, 0, 175))
end

CrashBtn.MouseButton1Click:Connect(function() applyMode("Crash") end)
WideBtn.MouseButton1Click:Connect(function()  applyMode("Wide")  end)
CustomBtn.MouseButton1Click:Connect(function() applyMode("Custom") end)

-- ============================================================
-- ACTIVE / STOP
-- ============================================================
ActiveBtn.MouseButton1Click:Connect(function()
    if not selectedMode then
        Notif("Select a mode first!", Color3.fromRGB(195, 50, 50))
        return
    end
    Notif("Activating " .. selectedMode .. "...", Color3.fromRGB(148, 0, 185))
    task.spawn(function()
        local ok, err = doPlay()
        if ok then
            ActiveBtn.BackgroundColor3 = Color3.fromRGB(172, 0, 202)
            ActiveBtn.Text = "ACTIVE — ON  [" .. selectedMode .. "]"
            Notif("Glitch active! Mode: " .. selectedMode, Color3.fromRGB(168, 0, 208))
        else
            Notif("Error: " .. tostring(err), Color3.fromRGB(195, 50, 50))
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    if isActive or CurrentTrack then
        doStop()
        ActiveBtn.BackgroundColor3 = Color3.fromRGB(112, 0, 142)
        ActiveBtn.Text = "ACTIVE"
        Notif("Glitch stopped.", Color3.fromRGB(48, 182, 92))
    else
        Notif("Glitch is not active.", Color3.fromRGB(82, 82, 82))
    end
end)

-- ============================================================
-- SPIN BUTTONS
-- ============================================================
local SPIN_ON_BG  = Color3.fromRGB(90, 0, 115)
local SPIN_OFF_BG = Color3.fromRGB(20, 20, 20)
local SPIN_ON_TC  = Color3.fromRGB(255, 255, 255)
local SPIN_OFF_TC = Color3.fromRGB(190, 190, 190)

local function refreshSpinBtns()
    local s1on = (spinActive == 1)
    local s2on = (spinActive == 2)
    Spin1Btn.BackgroundColor3 = s1on and SPIN_ON_BG or SPIN_OFF_BG
    Spin1Btn.TextColor3       = s1on and SPIN_ON_TC or SPIN_OFF_TC
    Spin1Btn.Text             = s1on and "Spin 1  — ON" or "Spin 1  — Fastest"
    Spin2Btn.BackgroundColor3 = s2on and SPIN_ON_BG or SPIN_OFF_BG
    Spin2Btn.TextColor3       = s2on and SPIN_ON_TC or SPIN_OFF_TC
    Spin2Btn.Text             = s2on and "Spin 2  — ON" or "Spin 2  — Fast"
end

Spin1Btn.MouseButton1Click:Connect(function()
    if spinActive == 1 then
        stopSpin(); refreshSpinBtns()
        Notif("Spin 1 stopped.", Color3.fromRGB(82, 82, 82))
    else
        startSpin(1); refreshSpinBtns()
        Notif("Spin 1 active — Fastest speed.", Color3.fromRGB(148, 0, 185))
    end
end)

Spin2Btn.MouseButton1Click:Connect(function()
    if spinActive == 2 then
        stopSpin(); refreshSpinBtns()
        Notif("Spin 2 stopped.", Color3.fromRGB(82, 82, 82))
    else
        startSpin(2); refreshSpinBtns()
        Notif("Spin 2 active — Fast.", Color3.fromRGB(168, 0, 208))
    end
end)

StopSpinBtn.MouseButton1Click:Connect(function()
    if spinActive ~= 0 then
        stopSpin(); refreshSpinBtns()
        Notif("Spin stopped.", Color3.fromRGB(48, 182, 92))
    else
        Notif("Spin is not active.", Color3.fromRGB(82, 82, 82))
    end
end)

-- ============================================================
-- MINIMIZE ↔ ICON
-- ============================================================
local minimized = false

local function showMain()
    minimized = false; Main.Visible = true
    tw(Main,    {BackgroundTransparency = 0}, 0.2)
    tw(MStroke, {Transparency = 0},           0.2)
    IconBtn.Visible = false; stopIconAnim(); MinBtn.Text = "-"
end

local function showIcon()
    minimized = true
    tw(Main,    {BackgroundTransparency = 1}, 0.16)
    tw(MStroke, {Transparency = 1},           0.16)
    task.delay(0.18, function()
        Main.Visible = false; IconBtn.Visible = true; startIconAnim()
    end)
    MinBtn.Text = "+"
end

MinBtn.MouseButton1Click:Connect(function()
    if minimized then showMain() else showIcon() end
end)
IconBtn.MouseButton1Click:Connect(showMain)

CloseBtn.MouseButton1Click:Connect(function()
    doStop(); stopSpin(); stopIconAnim()
    tw(Main,    {BackgroundTransparency = 1}, 0.16)
    tw(MStroke, {Transparency = 1},           0.16)
    task.delay(0.2, function() sDes(SG); sDes(NotifSG); sDes(IconSG) end)
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    CurrentTrack = nil; isActive = false; origCollide = {}
    spinActive = 0
    if spinConn then spinConn:Disconnect(); spinConn = nil end
    ActiveBtn.BackgroundColor3 = Color3.fromRGB(112, 0, 142)
    ActiveBtn.Text = "ACTIVE"
    refreshSpinBtns()
end)

-- ============================================================
-- INIT
-- ============================================================
task.wait(0.4)
Notif("Ano9x Glitcher Crash loaded.", Color3.fromRGB(148, 0, 188))
print("[Ano9x GC] Loaded. Canvas: " .. curY .. "px")
