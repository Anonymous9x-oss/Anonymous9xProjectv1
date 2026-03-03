--[[
    Anonymous9x Glitch v1
    Delta Mobile / Delta iOS — Clean Edition
    FE Avatar Glitch Script
--]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1.5)

-- ============================================================
-- SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local LP = Players.LocalPlayer

local function getChar() return LP.Character end
local function getHRP()  local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function isR15()   local h = getHum(); return h and h.RigType == Enum.HumanoidRigType.R15 end

-- ============================================================
-- GUI PARENT — gethui() preferred (Delta native)
-- ============================================================
local GuiParent
do
    local ok, h = pcall(function() return gethui() end)
    GuiParent = (ok and h) or LP:WaitForChild("PlayerGui", 15)
end

for _, v in pairs(GuiParent:GetChildren()) do
    if v.Name == "Anon9x_Main" or v.Name == "Anon9x_Notif" then
        v:Destroy()
    end
end

-- ============================================================
-- STATE
-- ============================================================
local GlitchActive = false
local GlitchSpeed  = 85
local GlitchConns  = {}
local SavedC0, SavedC1 = {}, {}

local GravOn, FreezeOn, JumpOn, AfkOn = false, false, false, false
local GravConn, FreezeConn, AfkConn   = nil, nil, nil
local SavedCF = nil

local DEF_JP = 50
local HACK_JP = 100

local function sDes(o) if o and o.Parent then pcall(function() o:Destroy() end) end end
local function sDis(c) if c then pcall(function() c:Disconnect() end) end end

local function tweenProp(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ============================================================
-- LAYOUT CONSTANTS  (compact for mobile)
-- ============================================================
local GW      = 260   -- gui width
local GH      = 420   -- gui height
local TH      = 38    -- title height
local PD      = 9     -- padding
local IW      = GW - PD * 2   -- item width = 242
local GP      = 5     -- gap between items

-- ============================================================
-- NOTIFICATION  — FADE only, no position tween
-- Fade is 100% reliable across all executors / screen sizes
-- ============================================================
local NotifSG = Instance.new("ScreenGui")
NotifSG.Name         = "Anon9x_Notif"
NotifSG.ResetOnSpawn = false
NotifSG.DisplayOrder = 9999
NotifSG.Parent       = GuiParent

-- Container anchored to top-center
local NF = Instance.new("Frame", NotifSG)
NF.AnchorPoint      = Vector2.new(0.5, 0)
NF.Size             = UDim2.new(0, 200, 0, 32)
NF.Position         = UDim2.new(0.5, 0, 0, 8)
NF.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
NF.BackgroundTransparency = 1
NF.BorderSizePixel  = 0
NF.ZIndex           = 200
Instance.new("UICorner", NF).CornerRadius = UDim.new(0, 6)

local NFAccent = Instance.new("Frame", NF)
NFAccent.Size             = UDim2.new(0, 3, 1, 0)
NFAccent.Position         = UDim2.new(0, 0, 0, 0)
NFAccent.BackgroundColor3 = Color3.fromRGB(190, 0, 210)
NFAccent.BackgroundTransparency = 1
NFAccent.BorderSizePixel  = 0
NFAccent.ZIndex           = 201
Instance.new("UICorner", NFAccent).CornerRadius = UDim.new(0, 7)

local NFLabel = Instance.new("TextLabel", NF)
NFLabel.Size                  = UDim2.new(1, -14, 1, 0)
NFLabel.Position              = UDim2.new(0, 11, 0, 0)
NFLabel.BackgroundTransparency = 1
NFLabel.Text                  = ""
NFLabel.TextColor3            = Color3.fromRGB(225, 225, 225)
NFLabel.TextTransparency      = 1
NFLabel.TextScaled            = true
NFLabel.Font                  = Enum.Font.GothamSemibold
NFLabel.TextWrapped           = true
NFLabel.TextXAlignment        = Enum.TextXAlignment.Left
NFLabel.ZIndex                = 201

local notifThread = nil

local function Notif(msg, accentColor, dur)
    -- cancel previous
    if notifThread then task.cancel(notifThread) end

    -- set content immediately
    NFAccent.BackgroundColor3 = accentColor or Color3.fromRGB(190, 0, 210)
    NFLabel.Text = msg

    -- FADE IN (all children fade together)
    local fadeIn = {BackgroundTransparency = 0}
    tweenProp(NF,       {BackgroundTransparency = 0},  0.2)
    tweenProp(NFAccent, {BackgroundTransparency = 0},  0.2)
    tweenProp(NFLabel,  {TextTransparency = 0},        0.2)

    -- FADE OUT after duration
    notifThread = task.delay(dur or 3.5, function()
        tweenProp(NF,       {BackgroundTransparency = 1}, 0.18)
        tweenProp(NFAccent, {BackgroundTransparency = 1}, 0.18)
        tweenProp(NFLabel,  {TextTransparency = 1},       0.18)
    end)
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name         = "Anon9x_Main"
SG.ResetOnSpawn = false
SG.DisplayOrder = 9998
SG.Parent       = GuiParent

-- Main frame — set FULL SIZE immediately, AnchorPoint centers it
-- FADE entrance: no size tween, no ClipsDescendants issue
local Main = Instance.new("Frame", SG)
Main.Name              = "Main"
Main.AnchorPoint       = Vector2.new(0.5, 0.5)
Main.Size              = UDim2.new(0, GW, 0, GH)
Main.Position          = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3  = Color3.fromRGB(10, 10, 10)
Main.BackgroundTransparency = 1        -- start invisible
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.ZIndex            = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color     = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 1            -- fade in with frame

-- ENTRANCE: fade in after 1 frame
task.defer(function()
    tweenProp(Main,       {BackgroundTransparency = 0},  0.28, Enum.EasingStyle.Quad)
    tweenProp(MainStroke, {Transparency = 0},            0.28, Enum.EasingStyle.Quad)
end)

-- ── DRAG (title bar only)
local dragActive, dragStart, dragAnchor = false, nil, nil
-- dragAnchor tracks Position offset in pixels from center
local dragOffX, dragOffY = 0, 0

-- ── TITLE BAR
local TBar = Instance.new("Frame", Main)
TBar.Size             = UDim2.new(1, 0, 0, TH)
TBar.Position         = UDim2.new(0, 0, 0, 0)
TBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TBar.BorderSizePixel  = 0
TBar.ZIndex           = 10

local TLine = Instance.new("Frame", TBar)
TLine.Size             = UDim2.new(1, 0, 0, 1)
TLine.Position         = UDim2.new(0, 0, 1, -1)
TLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TLine.BorderSizePixel  = 0
TLine.ZIndex           = 11

local TTitle = Instance.new("TextLabel", TBar)
TTitle.Size             = UDim2.new(1, -66, 1, 0)
TTitle.Position         = UDim2.new(0, 10, 0, 0)
TTitle.BackgroundTransparency = 1
TTitle.Text             = "Anonymous9x Glitch"
TTitle.TextColor3       = Color3.fromRGB(235, 235, 235)
TTitle.TextScaled       = true
TTitle.Font             = Enum.Font.GothamBold
TTitle.TextXAlignment   = Enum.TextXAlignment.Left
TTitle.ZIndex           = 11

local MinBtn = Instance.new("TextButton", TBar)
MinBtn.Size             = UDim2.new(0, 24, 0, 24)
MinBtn.Position         = UDim2.new(1, -54, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
MinBtn.BorderSizePixel  = 0
MinBtn.Text             = "-"
MinBtn.TextColor3       = Color3.fromRGB(190, 190, 190)
MinBtn.TextScaled       = true
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.ZIndex           = 12
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", MinBtn).Color = Color3.fromRGB(60, 60, 60)

local CloseBtn = Instance.new("TextButton", TBar)
CloseBtn.Size             = UDim2.new(0, 24, 0, 24)
CloseBtn.Position         = UDim2.new(1, -26, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(175, 28, 28)
CloseBtn.BorderSizePixel  = 0
CloseBtn.Text             = "x"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled       = true
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.ZIndex           = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- Drag input on TBar
TBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStart  = i.Position
        dragAnchor = Main.Position
    end
end)
TBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dragActive then return end
    if i.UserInputType ~= Enum.UserInputType.Touch
    and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local d = i.Position - dragStart
    Main.Position = UDim2.new(
        dragAnchor.X.Scale, dragAnchor.X.Offset + d.X,
        dragAnchor.Y.Scale, dragAnchor.Y.Offset + d.Y
    )
end)

-- ── SCROLL  (no AutomaticCanvasSize, no UIListLayout, no UIPadding)
local SCH = GH - TH
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                 = UDim2.new(1, 0, 0, SCH)
Scroll.Position             = UDim2.new(0, 0, 0, TH)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel      = 0
Scroll.ScrollBarThickness   = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 130)
Scroll.ScrollingDirection   = Enum.ScrollingDirection.Y
Scroll.CanvasSize           = UDim2.new(0, 0, 0, 800)  -- updated at end
Scroll.ZIndex               = 3
Scroll.ClipsDescendants     = true

-- ============================================================
-- MANUAL Y BUILDER
-- ============================================================
local curY = PD

local function adv(h)
    local y = curY
    curY = curY + h + GP
    return y
end

local function Sep()
    local y = adv(1)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0, IW, 0, 1)
    f.Position         = UDim2.new(0, PD, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    f.BorderSizePixel  = 0
    f.ZIndex           = 4
end

local function SecLbl(txt)
    local y = adv(20)
    local l = Instance.new("TextLabel", Scroll)
    l.Size             = UDim2.new(0, IW, 0, 20)
    l.Position         = UDim2.new(0, PD, 0, y)
    l.BackgroundTransparency = 1
    l.Text             = txt
    l.TextColor3       = Color3.fromRGB(175, 0, 205)
    l.TextScaled       = true
    l.Font             = Enum.Font.GothamBold
    l.TextXAlignment   = Enum.TextXAlignment.Left
    l.ZIndex           = 4
    return l
end

local function StatusBar()
    local y = adv(26)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0, IW, 0, 26)
    f.Position         = UDim2.new(0, PD, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    f.BorderSizePixel  = 0
    f.ZIndex           = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(42, 42, 42)

    local l = Instance.new("TextLabel", f)
    l.Size             = UDim2.new(1, -10, 1, 0)
    l.Position         = UDim2.new(0, 5, 0, 0)
    l.BackgroundTransparency = 1
    l.Text             = "Status: Ready  |  Rig: Checking..."
    l.TextColor3       = Color3.fromRGB(200, 200, 200)
    l.TextScaled       = true
    l.Font             = Enum.Font.GothamSemibold
    l.TextXAlignment   = Enum.TextXAlignment.Left
    l.ZIndex           = 5
    return l
end

local function PBtn(txt, h)
    local y = adv(h)
    local b = Instance.new("TextButton", Scroll)
    b.Size             = UDim2.new(0, IW, 0, h)
    b.Position         = UDim2.new(0, PD, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
    b.BorderSizePixel  = 0
    b.Text             = txt
    b.TextColor3       = Color3.fromRGB(255, 255, 255)
    b.TextScaled       = true
    b.Font             = Enum.Font.GothamBold
    b.ZIndex           = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local function SBtn(txt, h)
    local y = adv(h)
    local b = Instance.new("TextButton", Scroll)
    b.Size             = UDim2.new(0, IW, 0, h)
    b.Position         = UDim2.new(0, PD, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.BorderSizePixel  = 0
    b.Text             = txt
    b.TextColor3       = Color3.fromRGB(210, 210, 210)
    b.TextScaled       = true
    b.Font             = Enum.Font.GothamSemibold
    b.ZIndex           = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(48, 48, 48); s.Thickness = 1
    return b
end

local function Row2(t1, t2, h)
    local H2 = math.floor((IW - GP) / 2)
    local y  = adv(h)

    local function mk(txt, xoff)
        local b = Instance.new("TextButton", Scroll)
        b.Size             = UDim2.new(0, H2, 0, h)
        b.Position         = UDim2.new(0, PD + xoff, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        b.BorderSizePixel  = 0
        b.Text             = txt
        b.TextColor3       = Color3.fromRGB(200, 200, 200)
        b.TextScaled       = true
        b.Font             = Enum.Font.GothamSemibold
        b.ZIndex           = 4
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        local s = Instance.new("UIStroke", b)
        s.Color = Color3.fromRGB(48, 48, 48); s.Thickness = 1
        return b
    end

    return mk(t1, 0), mk(t2, H2 + GP)
end

local function Slider(lbl, def, mn, mx)
    local ly = adv(17)
    local lblEl = Instance.new("TextLabel", Scroll)
    lblEl.Size             = UDim2.new(0, IW, 0, 17)
    lblEl.Position         = UDim2.new(0, PD, 0, ly)
    lblEl.BackgroundTransparency = 1
    lblEl.Text             = lbl .. ": " .. def
    lblEl.TextColor3       = Color3.fromRGB(175, 175, 175)
    lblEl.TextScaled       = true
    lblEl.Font             = Enum.Font.GothamSemibold
    lblEl.TextXAlignment   = Enum.TextXAlignment.Left
    lblEl.ZIndex           = 4

    local ty = adv(15)
    local track = Instance.new("Frame", Scroll)
    track.Size             = UDim2.new(0, IW, 0, 15)
    track.Position         = UDim2.new(0, PD, 0, ty)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel  = 0
    track.ZIndex           = 4
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local iR   = (def - mn) / (mx - mn)
    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(iR, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 0, 180)
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 5
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("TextButton", track)
    knob.Size             = UDim2.new(0, 19, 0, 19)
    knob.Position         = UDim2.new(iR, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
    knob.BorderSizePixel  = 0
    knob.Text             = ""
    knob.ZIndex           = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local curV   = def
    local active = false
    local cb     = nil

    local function apply(r)
        r    = math.clamp(r, 0, 1)
        curV = math.floor(mn + r * (mx - mn))
        fill.Size     = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -9, 0.5, -9)
        lblEl.Text    = lbl .. ": " .. curV
        if cb then cb(curV) end
    end

    local function down(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then active = true end
    end
    local function up(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end
    end

    track.InputBegan:Connect(down)
    knob.InputBegan:Connect(down)
    UserInputService.InputEnded:Connect(up)
    UserInputService.InputChanged:Connect(function(i)
        if not active then return end
        if i.UserInputType ~= Enum.UserInputType.Touch
        and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local ax = track.AbsolutePosition.X
        local aw = track.AbsoluteSize.X
        if aw <= 0 then return end
        apply((i.Position.X - ax) / aw)
    end)

    return { get = function() return curV end, onChange = function(f) cb = f end }
end

local function InputPair(ph, btxt, h)
    local H2  = math.floor(IW * 0.60)
    local H2b = IW - H2 - GP
    local y   = adv(h)

    local box = Instance.new("TextBox", Scroll)
    box.Size             = UDim2.new(0, H2, 0, h)
    box.Position         = UDim2.new(0, PD, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    box.BorderSizePixel  = 0
    box.PlaceholderText  = ph
    box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    box.Text             = ""
    box.TextColor3       = Color3.fromRGB(210, 210, 210)
    box.TextScaled       = true
    box.Font             = Enum.Font.GothamSemibold
    box.ClearTextOnFocus = false
    box.ZIndex           = 4
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
    local bs = Instance.new("UIStroke", box)
    bs.Color = Color3.fromRGB(48, 48, 48); bs.Thickness = 1

    local btn = Instance.new("TextButton", Scroll)
    btn.Size             = UDim2.new(0, H2b, 0, h)
    btn.Position         = UDim2.new(0, PD + H2 + GP, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(0, 95, 145)
    btn.BorderSizePixel  = 0
    btn.Text             = btxt
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.TextScaled       = true
    btn.Font             = Enum.Font.GothamBold
    btn.ZIndex           = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return box, btn
end

local function InfoBox(txt, h)
    local y = adv(h)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0, IW, 0, h)
    f.Position         = UDim2.new(0, PD, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.BorderSizePixel  = 0
    f.ZIndex           = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(38, 38, 38)

    local l = Instance.new("TextLabel", f)
    l.Size             = UDim2.new(1, -10, 1, -6)
    l.Position         = UDim2.new(0, 5, 0, 3)
    l.BackgroundTransparency = 1
    l.Text             = txt
    l.TextColor3       = Color3.fromRGB(110, 110, 110)
    l.TextScaled       = true
    l.Font             = Enum.Font.Gotham
    l.TextXAlignment   = Enum.TextXAlignment.Left
    l.TextWrapped      = true
    l.ZIndex           = 5
    return l
end

-- ============================================================
-- BUILD ELEMENTS
-- ============================================================

local StatusLbl = StatusBar()
Sep()

SecLbl("AVATAR GLITCH")
local BrokenBtn = PBtn("BROKEN",  44)
local StopBtn   = SBtn("STOP",    34)
local SpSl      = Slider("Speed", GlitchSpeed, 1, 200)
SpSl.onChange(function(v) GlitchSpeed = v end)
Sep()

SecLbl("EXTRA FEATURES")
local GravBtn, FreezeBtn = Row2("Anti Gravity  OFF", "Freeze  OFF", 42)
local JumpBtn, AfkBtn    = Row2("High Jump  OFF",    "Anti AFK  OFF", 42)
Sep()

SecLbl("TOOLS")
local ResetBtn, TpBtn  = Row2("Reset", "TP Up", 36)
local SaveBtn, LoadBtn = Row2("Save Position", "Load Position", 36)
local HatBox, WearBtn  = InputPair("Accessory Asset ID", "Wear", 34)
Sep()

InfoBox("Anonymous9x Glitch  |  Works on Delta Mobile & Delta iOS\nFE Script — visible to all players in server\nRequires R15 avatar — R6 will not work", 54)

curY = curY + PD
Scroll.CanvasSize = UDim2.new(0, 0, 0, curY)

-- ============================================================
-- REAL-TIME RIG STATUS
-- ============================================================
local lastRig = ""
RunService.Heartbeat:Connect(function()
    local h   = getHum()
    local rig = (h and h.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
    if rig == lastRig then return end
    lastRig = rig
    if rig == "R15" then
        StatusLbl.Text       = "Status: Ready  |  Rig: R15 — Glitch works"
        StatusLbl.TextColor3 = Color3.fromRGB(75, 210, 115)
    else
        StatusLbl.Text       = "Status: Ready  |  Rig: R6 — Glitch disabled"
        StatusLbl.TextColor3 = Color3.fromRGB(215, 75, 75)
    end
end)

-- ============================================================
-- GLITCH CORE
-- ============================================================
local function saveMotors()
    SavedC0, SavedC1 = {}, {}
    local c = getChar(); if not c then return end
    for _, m in pairs(c:GetDescendants()) do
        if m:IsA("Motor6D") and m.Part0 and m.Part1 then
            SavedC0[m] = m.C0; SavedC1[m] = m.C1
        end
    end
end

local function restoreMotors()
    local c = getChar(); if not c then return end
    for _, m in pairs(c:GetDescendants()) do
        if m:IsA("Motor6D") then
            if SavedC0[m] then pcall(function() m.C0 = SavedC0[m] end) end
            if SavedC1[m] then pcall(function() m.C1 = SavedC1[m] end) end
        end
    end
end

local function resetAccs()
    local c = getChar(); if not c then return end
    for _, a in pairs(c:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then pcall(function() h.Size = Vector3.new(1,1,1); h.Transparency = 0 end) end
        end
    end
end

local function stopGlitch(silent)
    GlitchActive = false
    for _, con in pairs(GlitchConns) do sDis(con) end
    GlitchConns = {}
    task.wait(0.05)
    restoreMotors()
    resetAccs()
    local hum = getHum()
    if hum then pcall(function() hum.PlatformStand = false end) end
    BrokenBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
    BrokenBtn.Text = "BROKEN"
    if not silent then Notif("Glitch stopped. Avatar restored.", Color3.fromRGB(55, 190, 100)) end
end

local function startGlitch()
    if GlitchActive then return end
    if not isR15() then
        Notif("R6 detected. Switch to R15 to use glitch.", Color3.fromRGB(215, 95, 0), 4)
        return
    end
    if not getHRP() then return end
    GlitchActive = true
    saveMotors()
    BrokenBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 210)
    BrokenBtn.Text = "BROKEN — ACTIVE"

    local c1 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local c = getChar(); if not c then return end
        local sp = GlitchSpeed; local t = tick()
        local wX = math.sin(t*sp*0.25)
        local wY = math.cos(t*sp*0.30)
        local wZ = math.sin(t*sp*0.20+0.8)
        for _, m in pairs(c:GetDescendants()) do
            if m:IsA("Motor6D") and SavedC0[m] and math.random(100) <= 75 then
                local rx = math.rad(math.random(-360,360)*(sp/100))
                local ry = math.rad(math.random(-360,360)*(sp/100))
                local rz = math.rad(math.random(-360,360)*(sp/100))
                pcall(function()
                    m.C0 = SavedC0[m]
                        * CFrame.new(wX*(sp/40), wY*(sp/22), wZ*(sp/40))
                        * CFrame.Angles(rx, ry, rz)
                end)
            end
        end
    end)

    local c2 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local c = getChar(); if not c then return end
        local sp = GlitchSpeed; local t = tick()
        for _, a in pairs(c:GetChildren()) do
            if a:IsA("Accessory") then
                local h = a:FindFirstChild("Handle")
                if h then pcall(function()
                    h.Size = Vector3.new(
                        1+math.abs(math.sin(t*sp*0.09))*(sp/20),
                        1+math.abs(math.cos(t*sp*0.07))*(sp/8),
                        1+math.abs(math.sin(t*sp*0.11))*(sp/20)
                    )
                end) end
            end
        end
    end)

    local c3 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local hrp = getHRP(); if not hrp then return end
        local sp = GlitchSpeed
        if math.random(math.max(2, 14-math.floor(sp/18))) == 1 then
            pcall(function()
                hrp.CFrame = hrp.CFrame + Vector3.new(
                    (math.random()-0.5)*sp*0.10,
                    (math.random()-0.5)*sp*0.05,
                    (math.random()-0.5)*sp*0.10
                )
            end)
        end
    end)

    local c4 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local hum = getHum()
        if hum then pcall(function() hum.PlatformStand = (math.random(4)==1) end) end
    end)

    GlitchConns = {c1, c2, c3, c4}
    Notif("Glitch activated. Speed: " .. GlitchSpeed, Color3.fromRGB(175, 0, 215))
end

-- ============================================================
-- TOGGLE HELPER  (visual ON/OFF)
-- ============================================================
local ON_BG  = Color3.fromRGB(105, 0, 138)
local OFF_BG = Color3.fromRGB(20, 20, 20)
local ON_TC  = Color3.fromRGB(255, 255, 255)
local OFF_TC = Color3.fromRGB(200, 200, 200)

local function setToggle(btn, state, onTxt, offTxt)
    btn.BackgroundColor3 = state and ON_BG or OFF_BG
    btn.TextColor3       = state and ON_TC or OFF_TC
    btn.Text             = state and onTxt or offTxt
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================

BrokenBtn.MouseButton1Click:Connect(function()
    if GlitchActive then
        Notif("Glitch is active. Press STOP to end.", Color3.fromRGB(195, 130, 0))
    else
        startGlitch()
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    if GlitchActive then stopGlitch(false)
    else Notif("Glitch is not active.", Color3.fromRGB(90, 90, 90)) end
end)

-- Anti Gravity
GravBtn.MouseButton1Click:Connect(function()
    GravOn = not GravOn
    pcall(function() workspace.Gravity = GravOn and 8 or 196.2 end)
    setToggle(GravBtn, GravOn, "Anti Gravity  ON", "Anti Gravity  OFF")
    Notif(GravOn and "Anti Gravity enabled." or "Gravity restored.",
          GravOn and Color3.fromRGB(155, 0, 195) or Color3.fromRGB(90, 90, 90))
end)

-- Freeze
FreezeBtn.MouseButton1Click:Connect(function()
    FreezeOn = not FreezeOn
    setToggle(FreezeBtn, FreezeOn, "Freeze  ON", "Freeze  OFF")
    if FreezeOn then
        local hrp = getHRP()
        if hrp then
            local frozenCF = hrp.CFrame
            FreezeConn = RunService.Heartbeat:Connect(function()
                if not FreezeOn then return end
                local h2 = getHRP()
                if h2 then pcall(function() h2.CFrame = frozenCF end) end
            end)
        end
        Notif("Freeze enabled. Position locked.", Color3.fromRGB(155, 0, 195))
    else
        sDis(FreezeConn)
        Notif("Freeze disabled.", Color3.fromRGB(90, 90, 90))
    end
end)

-- High Jump
JumpBtn.MouseButton1Click:Connect(function()
    JumpOn = not JumpOn
    local hum = getHum()
    if hum then pcall(function() hum.JumpPower = JumpOn and HACK_JP or DEF_JP end) end
    setToggle(JumpBtn, JumpOn, "High Jump  ON", "High Jump  OFF")
    Notif(JumpOn and "High Jump enabled." or "Jump restored.",
          JumpOn and Color3.fromRGB(155, 0, 195) or Color3.fromRGB(90, 90, 90))
end)

-- Anti AFK
AfkBtn.MouseButton1Click:Connect(function()
    AfkOn = not AfkOn
    if AfkOn then
        AfkConn = RunService.Heartbeat:Connect(function()
            if not AfkOn then return end
            local h2 = getHum()
            if h2 then pcall(function() h2:Move(Vector3.new(0.001,0,0), false) end) end
        end)
    else
        sDis(AfkConn)
    end
    setToggle(AfkBtn, AfkOn, "Anti AFK  ON", "Anti AFK  OFF")
    Notif(AfkOn and "Anti AFK enabled." or "Anti AFK disabled.",
          AfkOn and Color3.fromRGB(155, 0, 195) or Color3.fromRGB(90, 90, 90))
end)

-- Reset
ResetBtn.MouseButton1Click:Connect(function()
    stopGlitch(true)
    local hum = getHum()
    if hum then pcall(function() hum.Health = 0 end) end
    Notif("Character reset.", Color3.fromRGB(75, 148, 215))
end)

-- TP Up
TpBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if hrp then pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 180, 0) end) end
    Notif("Teleported upward.", Color3.fromRGB(75, 148, 215))
end)

-- Save Position
SaveBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP(); if not hrp then return end
    SavedCF = hrp.CFrame
    setToggle(SaveBtn, true, "Position Saved", "Save Position")
    Notif("Position saved.", Color3.fromRGB(75, 148, 215))
end)

-- Load Position
LoadBtn.MouseButton1Click:Connect(function()
    if not SavedCF then
        Notif("No position saved yet.", Color3.fromRGB(90, 90, 90))
        return
    end
    local hrp = getHRP()
    if hrp then pcall(function() hrp.CFrame = SavedCF end) end
    Notif("Teleported to saved position.", Color3.fromRGB(75, 148, 215))
end)

-- Wear Accessory
WearBtn.MouseButton1Click:Connect(function()
    local id = tonumber(HatBox.Text)
    if not id then
        Notif("Enter a valid asset ID.", Color3.fromRGB(200, 55, 55))
        return
    end
    Notif("Loading accessory " .. id .. "...", Color3.fromRGB(75, 120, 195))
    task.spawn(function()
        local ok = pcall(function()
            local IS  = game:GetService("InsertService")
            local mdl = IS:LoadAsset(id)
            local acc = mdl:FindFirstChildOfClass("Accessory") or mdl:FindFirstChildOfClass("Hat")
            if acc then
                acc.Parent = LP.Character
                mdl:Destroy()
                Notif("Accessory " .. id .. " equipped.", Color3.fromRGB(55, 190, 100))
            else
                mdl:Destroy()
                Notif("Asset " .. id .. " is not an accessory.", Color3.fromRGB(200, 55, 55))
            end
        end)
        if not ok then
            Notif("Failed. Game may block InsertService.", Color3.fromRGB(200, 55, 55))
        end
    end)
end)

-- ============================================================
-- MINIMIZE / CLOSE
-- ============================================================
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Scroll.Visible = not minimized
    local targetH = minimized and TH or GH
    TweenService:Create(Main,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, GW, 0, targetH)}
    ):Play()
    MinBtn.Text = minimized and "+" or "-"
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopGlitch(true)
    sDis(FreezeConn); sDis(AfkConn)
    if GravOn then pcall(function() workspace.Gravity = 196.2 end) end
    local hum = getHum()
    if hum then pcall(function() hum.JumpPower = DEF_JP; hum.PlatformStand = false end) end

    tweenProp(Main,       {BackgroundTransparency = 1}, 0.18)
    tweenProp(MainStroke, {Transparency = 1},           0.18)
    task.delay(0.2, function() sDes(SG); sDes(NotifSG) end)
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    GlitchActive = false; GlitchConns = {}; SavedC0 = {}; SavedC1 = {}
    BrokenBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
    BrokenBtn.Text = "BROKEN"
    task.wait(0.4)
    local h2 = char:FindFirstChildOfClass("Humanoid")
    if h2 and JumpOn then pcall(function() h2.JumpPower = HACK_JP end) end
end)

-- ============================================================
-- INIT NOTIF
-- ============================================================
task.wait(0.5)
Notif("Anonymous9x Glitch loaded.", Color3.fromRGB(155, 0, 195), 3.5)
print("[Anon9x] Loaded. Canvas: " .. curY .. "px")
