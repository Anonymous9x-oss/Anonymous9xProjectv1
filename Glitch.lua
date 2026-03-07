--[[
    Anonymous9x Skybox
    Delta Mobile / Delta iOS
    FE Animation Skybox Engine
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1.5)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LP = Players.LocalPlayer

local function getChar() return LP.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- GUI Parent
local GuiParent
do
    local ok, h = pcall(function() return gethui() end)
    GuiParent = (ok and h) or LP:WaitForChild("PlayerGui", 15)
end
for _, v in pairs(GuiParent:GetChildren()) do
    if v.Name == "Ano9x_SkyMain" or v.Name == "Ano9x_SkyNotif" or v.Name == "Ano9x_SkyIcon" then
        v:Destroy()
    end
end

-- ============================================================
-- EMOTE ENGINE
-- ============================================================
local DEFAULT_ID = "93224413172183"

local S = {
    StopOnMove   = true,
    AllowInvis   = true,
    TimePosition = 0,
    Speed        = 1,
    Weight       = 1,
    FadeIn       = 0.1,
    FadeOut      = 0.1,
}

local CurrentTrack   = nil
local lastPos        = Vector3.new()
local origCollide    = {}
local isActive       = false

local function extractID(inp)
    if not inp or inp == "" then return nil end
    local n = tonumber(inp); if n then return n end
    for _, pat in ipairs({
        "rbxassetid://(%d+)",
        "roblox%.com/catalog/(%d+)",
        "roblox%.com/library/(%d+)",
        "roblox%.com/asset/%?id=(%d+)",
    }) do
        local m = string.match(inp, pat)
        if m then return tonumber(m) end
    end
    return nil
end

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

local function doPlay(idStr)
    local id = extractID(idStr)
    if not id then return false, "ID tidak valid" end
    local hum = getHum()
    if not hum then return false, "Humanoid tidak ditemukan" end

    doStop()

    -- Build animation ID
    local animId
    local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
    if ok and res and res[1] and res[1]:IsA("Animation") then
        animId = res[1].AnimationId
    else
        animId = "rbxassetid://" .. id
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId

    local ok2, track = pcall(function() return hum:LoadAnimation(anim) end)
    if not ok2 or not track then return false, "Gagal load animasi" end

    track.Priority = Enum.AnimationPriority.Action4

    local w = S.Weight == 0 and 0.001 or S.Weight
    track:Play(S.FadeIn, w, S.Speed)
    CurrentTrack = track

    -- Set time position
    task.delay(0.05, function()
        if CurrentTrack and CurrentTrack.IsPlaying and CurrentTrack.Length > 0 then
            CurrentTrack.TimePosition = math.clamp(S.TimePosition, 0, 1) * CurrentTrack.Length
        end
    end)

    saveCollide()
    if S.AllowInvis then disableCollide() end

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
local GW  = 265
local GH  = 220   -- window height (scrollable content extends further)
local TH  = 38
local PD  = 9
local IW  = GW - PD * 2   -- 247
local GP  = 5

-- ============================================================
-- NOTIFICATION  — bottom-right, 2s
-- ============================================================
local NotifSG = Instance.new("ScreenGui")
NotifSG.Name = "Ano9x_SkyNotif"; NotifSG.ResetOnSpawn = false
NotifSG.DisplayOrder = 9999; NotifSG.Parent = GuiParent

local NF = Instance.new("Frame", NotifSG)
NF.AnchorPoint = Vector2.new(1, 1)
NF.Size        = UDim2.new(0, 200, 0, 30)
NF.Position    = UDim2.new(1, -8, 1, -10)
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
-- FLOATING ICON  — top-right, fixed
-- ============================================================
local IconSG = Instance.new("ScreenGui")
IconSG.Name = "Ano9x_SkyIcon"; IconSG.ResetOnSpawn = false
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
        if     t < 2.0          then col = W
        elseif t < 2.5          then col = (math.random(2)==1) and W or P; thk = math.random(100)<=20 and math.random(1,5) or 2.5
        elseif t < 4.5          then col = P
        elseif t < 5.0          then col = (math.random(2)==1) and P or W; thk = math.random(100)<=20 and math.random(1,5) or 2.5
        else                         col = W
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
SG.Name = "Ano9x_SkyMain"; SG.ResetOnSpawn = false
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

-- ── Title bar
local TBar = Instance.new("Frame", Main)
TBar.Size = UDim2.new(1, 0, 0, TH)
TBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TBar.BorderSizePixel = 0; TBar.ZIndex = 10

local TLine = Instance.new("Frame", TBar)
TLine.Size = UDim2.new(1, 0, 0, 1); TLine.Position = UDim2.new(0, 0, 1, -1)
TLine.BackgroundColor3 = Color3.fromRGB(38, 38, 38); TLine.BorderSizePixel = 0; TLine.ZIndex = 11

local TTxt = Instance.new("TextLabel", TBar)
TTxt.Size = UDim2.new(1, -64, 1, 0); TTxt.Position = UDim2.new(0, 10, 0, 0)
TTxt.BackgroundTransparency = 1; TTxt.Text = "Anonymous9x Skybox"
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

-- ── Drag (whole panel)
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

-- ── Scroll
local SCH = GH - TH
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size     = UDim2.new(1, 0, 0, SCH)
Scroll.Position = UDim2.new(0, 0, 0, TH)
Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(85, 0, 115)
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
Scroll.ZIndex = 3; Scroll.ClipsDescendants = true

-- ============================================================
-- CONTENT BUILDERS
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

-- Big primary button
local function BigBtn(txt, h, bg)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, IW, 0, h); b.Position = UDim2.new(0, PD, 0, adv(h))
    b.BackgroundColor3 = bg or Color3.fromRGB(112, 0, 142); b.BorderSizePixel = 0
    b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true; b.Font = Enum.Font.GothamBold; b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

-- Secondary button
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

-- Two-column button row
local function Row2(t1, t2, h)
    local hw = math.floor((IW - GP) / 2); local y = adv(h)
    local function mk(txt, xo)
        local b = Instance.new("TextButton", Scroll)
        b.Size = UDim2.new(0, hw, 0, h); b.Position = UDim2.new(0, PD + xo, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.BorderSizePixel = 0
        b.Text = txt; b.TextColor3 = Color3.fromRGB(190, 190, 190)
        b.TextScaled = true; b.Font = Enum.Font.GothamSemibold; b.ZIndex = 4
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(42, 42, 42); s.Thickness = 1
        return b
    end
    return mk(t1, 0), mk(t2, hw + GP)
end

-- Emote textbox (full width)
local function EmoteBox(h)
    local y = adv(h)
    local b = Instance.new("TextBox", Scroll)
    b.Size = UDim2.new(0, IW, 0, h); b.Position = UDim2.new(0, PD, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(18, 18, 18); b.BorderSizePixel = 0
    b.PlaceholderText  = "Emote ID atau URL..."
    b.PlaceholderColor3 = Color3.fromRGB(68, 68, 68)
    b.Text = DEFAULT_ID
    b.TextColor3 = Color3.fromRGB(210, 210, 210)
    b.TextScaled = true; b.Font = Enum.Font.GothamSemibold
    b.ClearTextOnFocus = false; b.ZIndex = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(42, 42, 42); s.Thickness = 1
    return b
end

-- Toggle row  (label left, ON/OFF button right)
local function ToggleRow(labelTxt, settingKey, h)
    local y = adv(h)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0, IW, 0, h); f.Position = UDim2.new(0, PD, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 18); f.BorderSizePixel = 0; f.ZIndex = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(38, 38, 38)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.62, 0, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = labelTxt
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamSemibold; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 54, 0, 22); btn.Position = UDim2.new(1, -60, 0.5, -11)
    btn.BorderSizePixel = 0; btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold; btn.ZIndex = 5
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local on = S[settingKey]
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(185, 0, 0)
        btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        btn.Text             = on and "ON" or "OFF"
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        S[settingKey] = not S[settingKey]
        refresh()
    end)
end

-- Slider row
local function SliderRow(labelTxt, settingKey, mn, mx, h)
    -- Label + value display line
    local ly = adv(16)
    local le = Instance.new("TextLabel", Scroll)
    le.Size = UDim2.new(0, IW, 0, 16); le.Position = UDim2.new(0, PD, 0, ly)
    le.BackgroundTransparency = 1
    le.Text = string.format("%s: %.2f", labelTxt, S[settingKey])
    le.TextColor3 = Color3.fromRGB(165, 165, 165); le.TextScaled = true
    le.Font = Enum.Font.GothamSemibold; le.TextXAlignment = Enum.TextXAlignment.Left; le.ZIndex = 4

    -- Track
    local ty = adv(14)
    local tr = Instance.new("Frame", Scroll)
    tr.Size = UDim2.new(0, IW, 0, 14); tr.Position = UDim2.new(0, PD, 0, ty)
    tr.BackgroundColor3 = Color3.fromRGB(25, 25, 25); tr.BorderSizePixel = 0; tr.ZIndex = 4
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local iR = (S[settingKey] - mn) / math.max(mx - mn, 0.001)
    local fi = Instance.new("Frame", tr)
    fi.Size = UDim2.new(iR, 0, 1, 0)
    fi.BackgroundColor3 = Color3.fromRGB(140, 0, 170); fi.BorderSizePixel = 0; fi.ZIndex = 5
    Instance.new("UICorner", fi).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("TextButton", tr)
    kn.Size = UDim2.new(0, 18, 0, 18); kn.Position = UDim2.new(iR, -9, 0.5, -9)
    kn.BackgroundColor3 = Color3.fromRGB(228, 228, 228); kn.BorderSizePixel = 0
    kn.Text = ""; kn.ZIndex = 6
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)

    local active = false
    local function apply(r)
        r = math.clamp(r, 0, 1)
        local v = math.floor((mn + (mx - mn) * r) * 100) / 100
        S[settingKey] = v
        le.Text = string.format("%s: %.2f", labelTxt, v)
        fi.Size = UDim2.new(r, 0, 1, 0); kn.Position = UDim2.new(r, -9, 0.5, -9)
        -- live update on active track
        if CurrentTrack and CurrentTrack.IsPlaying then
            if settingKey == "Speed"  then pcall(function() CurrentTrack:AdjustSpeed(v) end) end
            if settingKey == "Weight" then
                pcall(function() CurrentTrack:AdjustWeight(v == 0 and 0.001 or v) end)
            end
            if settingKey == "TimePosition" and CurrentTrack.Length > 0 then
                pcall(function() CurrentTrack.TimePosition = math.clamp(v, 0, 1) * CurrentTrack.Length end)
            end
        end
    end
    local function fromInput(i)
        local ax = tr.AbsolutePosition.X; local aw = tr.AbsoluteSize.X
        if aw <= 0 then return end
        apply((i.Position.X - ax) / aw)
    end
    local function dn(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then active = true; fromInput(i) end
    end
    tr.InputBegan:Connect(dn); kn.InputBegan:Connect(dn)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not active then return end
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseMovement then fromInput(i) end
    end)
    apply(iR)
end

-- Info box
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
    l.TextColor3 = Color3.fromRGB(88, 88, 88); l.TextScaled = true
    l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true; l.ZIndex = 5
end

-- ============================================================
-- BUILD PANEL CONTENTS
-- ============================================================

SecLabel("SKYBOX & CRASH")
local ActiveBtn = BigBtn("ACTIVE", 42)
local StopBtn   = SecBtn("STOP",   32)
Sep()

SecLabel("SETTINGS")
ToggleRow("Stop On Move",    "StopOnMove",  36)
ToggleRow("Allow Invisible", "AllowInvis",  36)
SliderRow("Time Position", "TimePosition", 0, 1,   nil)
SliderRow("Speed",         "Speed",        0, 5,   nil)
SliderRow("Weight",        "Weight",       0, 1,   nil)
SliderRow("Fade In",       "FadeIn",       0, 2,   nil)
SliderRow("Fade Out",      "FadeOut",      0, 2,   nil)
Sep()

SecLabel("EXTRAS")
local GravBtn, TpBtn = Row2("Anti Gravity  OFF", "TP Up", 38)
Sep()

InfoBox("Anonymous9x Skybox  |  Delta Mobile & Delta iOS\nFE Emote Engine — gunakan R6 blocky avatar\nID default: 93224413172183", 50)

curY = curY + PD
Scroll.CanvasSize = UDim2.new(0, 0, 0, curY)

-- ============================================================
-- BUTTON LOGIC
-- ============================================================

ActiveBtn.MouseButton1Click:Connect(function()
    local id = DEFAULT_ID
    Notif("Mengaktifkan Skybox...", Color3.fromRGB(148, 0, 185))
    task.spawn(function()
        local ok, err = doPlay(id)
        if ok then
            ActiveBtn.BackgroundColor3 = Color3.fromRGB(172, 0, 202)
            ActiveBtn.Text = "ACTIVE — ON"
            Notif("Skybox & Crash aktif!", Color3.fromRGB(168, 0, 208))
        else
            Notif("Gagal: " .. tostring(err), Color3.fromRGB(195, 50, 50))
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    if isActive or CurrentTrack then
        doStop()
        ActiveBtn.BackgroundColor3 = Color3.fromRGB(112, 0, 142)
        ActiveBtn.Text = "ACTIVE"
        Notif("Skybox dihentikan.", Color3.fromRGB(48, 182, 92))
    else
        Notif("Tidak sedang aktif.", Color3.fromRGB(82, 82, 82))
    end
end)

-- Anti Gravity
local gravOn = false
GravBtn.MouseButton1Click:Connect(function()
    gravOn = not gravOn
    pcall(function() workspace.Gravity = gravOn and 8 or 196.2 end)
    GravBtn.BackgroundColor3 = gravOn and Color3.fromRGB(98, 0, 128) or Color3.fromRGB(20, 20, 20)
    GravBtn.TextColor3 = gravOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 190, 190)
    GravBtn.Text = gravOn and "Anti Gravity  ON" or "Anti Gravity  OFF"
    Notif(gravOn and "Anti Gravity aktif." or "Gravity dikembalikan.",
          gravOn and Color3.fromRGB(148, 0, 185) or Color3.fromRGB(82, 82, 82))
end)

-- TP Up
TpBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if hrp then pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 180, 0) end) end
    Notif("Teleport ke atas.", Color3.fromRGB(68, 135, 205))
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
    doStop(); stopIconAnim()
    if gravOn then pcall(function() workspace.Gravity = 196.2 end) end
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
    ActiveBtn.BackgroundColor3 = Color3.fromRGB(112, 0, 142)
    ActiveBtn.Text = "ACTIVE"
end)

-- ============================================================
-- INIT
-- ============================================================
task.wait(0.4)
Notif("Anonymous9x Skybox loaded.", Color3.fromRGB(148, 0, 188))
print("[Ano9x] Loaded. Canvas height: " .. curY .. "px")
