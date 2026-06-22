-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local Workspace      = game:GetService("Workspace")
local LP             = Players.LocalPlayer
local Cam            = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════
-- CLEANUP OLD INSTANCE
-- ═══════════════════════════════════════════════
pcall(function() game.CoreGui:FindFirstChild("_A9xTroll"):Destroy() end)
pcall(function() LP.PlayerGui:FindFirstChild("_A9xTroll"):Destroy() end)

-- ═══════════════════════════════════════════════
-- ROOT
-- ═══════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name             = "_A9xTroll"
gui.ResetOnSpawn     = false
gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset   = true
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LP.PlayerGui end

-- ═══════════════════════════════════════════════
-- THEME (exact same as ControlPart)
-- ═══════════════════════════════════════════════
local C = {
    bg      = Color3.fromRGB(8,   8,   9),
    hdr     = Color3.fromRGB(5,   5,   6),
    card    = Color3.fromRGB(17,  17,  19),
    cardH   = Color3.fromRGB(25,  25,  28),
    sep     = Color3.fromRGB(28,  28,  31),
    border  = Color3.fromRGB(46,  46,  50),
    white   = Color3.new(1, 1, 1),
    pri     = Color3.fromRGB(222, 222, 226),
    sec     = Color3.fromRGB(118, 118, 126),
    dim     = Color3.fromRGB(60,  60,  66),
    btnBg   = Color3.fromRGB(28,  28,  30),
}

local LOGO_ID  = "rbxassetid://97269958324726"
local TOGGLE_SOUND_ID = "rbxassetid://942127495"

local W   = 190
local H   = 215
local HDR = 26

-- ═══════════════════════════════════════════════
-- SOUND
-- ═══════════════════════════════════════════════
local toggleSound = Instance.new("Sound")
toggleSound.SoundId = TOGGLE_SOUND_ID
toggleSound.Volume  = 0.5
toggleSound.Parent  = gui
local function playToggleSound()
    pcall(function()
        if toggleSound.IsPlaying then toggleSound:Stop() end
        toggleSound:Play()
    end)
end

-- ═══════════════════════════════════════════════
-- STATUS BAR
-- ═══════════════════════════════════════════════
local statusFrame = Instance.new("Frame")
statusFrame.Size               = UDim2.fromOffset(W, 20)
statusFrame.Position           = UDim2.fromScale(0.5, 0.5)
statusFrame.AnchorPoint        = Vector2.new(0.5, 0.5)
statusFrame.BackgroundColor3   = C.bg
statusFrame.BackgroundTransparency = 0.2
statusFrame.BorderSizePixel    = 0
statusFrame.ZIndex             = 1000
statusFrame.Parent             = gui
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 6)
local statusStroke = Instance.new("UIStroke", statusFrame)
statusStroke.Color = C.white
statusStroke.Thickness = 1
statusStroke.Transparency = 0.5

local statusLabel = Instance.new("TextLabel")
statusLabel.Size               = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text               = ""
statusLabel.Font               = Enum.Font.GothamBold
statusLabel.TextSize            = 9
statusLabel.TextColor3          = C.white
statusLabel.TextXAlignment      = Enum.TextXAlignment.Center
statusLabel.ZIndex              = 1001
statusLabel.Parent              = statusFrame

local statusTween
local function setStatus(msg, color)
    if not color then color = C.white end
    if statusTween then statusTween:Cancel() end
    statusLabel.Text = msg
    statusLabel.TextColor3 = color
    statusFrame.Visible = true
    local vp = Cam.ViewportSize
    statusFrame.Position = UDim2.fromOffset(vp.X/2 - W/2, vp.Y - 60)
    statusTween = TweenService:Create(statusFrame, TweenInfo.new(2.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.85
    })
    statusTween:Play()
    task.delay(2.2, function()
        pcall(function()
            statusFrame.Visible = false
            statusLabel.Text = ""
            statusFrame.BackgroundTransparency = 0.2
        end)
    end)
end

-- ═══════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════
local win = Instance.new("Frame")
win.Name               = "Win"
win.Size               = UDim2.fromOffset(W, H)
win.Position           = UDim2.fromScale(0.5, 0.5)
win.AnchorPoint        = Vector2.new(0.5, 0.5)
win.BackgroundColor3   = C.bg
win.BackgroundTransparency = 0
win.BorderSizePixel    = 0
win.ClipsDescendants   = true
win.Active             = true
win.ZIndex             = 10
win.Parent             = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)

local winS = Instance.new("UIStroke", win)
winS.Thickness = 1.2; winS.Color = C.white; winS.Transparency = 0.35

task.spawn(function()
    local t = 0
    while win.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.4) + 1) / 2
        winS.Transparency = 0.20 + s * 0.35
    end
end)

-- ═══════════════════════════════════════════════
-- HEADER (with drag)
-- ═══════════════════════════════════════════════
local hdr = Instance.new("Frame")
hdr.Size             = UDim2.new(1, 0, 0, HDR)
hdr.BackgroundColor3 = C.hdr
hdr.BackgroundTransparency = 0
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 11
hdr.Parent           = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 8)

local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1,0,0,8); hPatch.Position = UDim2.new(0,0,1,-8)
hPatch.BackgroundColor3 = C.hdr; hPatch.BorderSizePixel=0; hPatch.ZIndex=10; hPatch.Parent=hdr

local hSep = Instance.new("Frame")
hSep.Size=UDim2.new(1,0,0,1); hSep.Position=UDim2.new(0,0,1,-1)
hSep.BackgroundColor3=C.sep; hSep.BorderSizePixel=0; hSep.ZIndex=12; hSep.Parent=hdr

-- Title
local hTitle = Instance.new("TextLabel")
hTitle.Size               = UDim2.new(1, -50, 1, 0)
hTitle.Position           = UDim2.fromOffset(8, 0)
hTitle.BackgroundTransparency = 1
hTitle.Text               = "Anonymous9x Troll"
hTitle.Font               = Enum.Font.GothamBold
hTitle.TextSize            = 9
hTitle.TextColor3          = C.white
hTitle.TextStrokeTransparency = 0
hTitle.TextStrokeColor3    = Color3.fromRGB(20, 20, 22)
hTitle.TextXAlignment      = Enum.TextXAlignment.Left
hTitle.TextTruncate        = Enum.TextTruncate.AtEnd
hTitle.ZIndex              = 12
hTitle.Parent              = hdr

task.spawn(function()
    local t = 0
    while hdr.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.1) + 1) / 2
        hTitle.TextColor3       = Color3.new(1,1,1):Lerp(Color3.fromRGB(150,150,155), s*0.45)
        hTitle.TextStrokeColor3 = Color3.fromRGB(20,20,22):Lerp(Color3.new(0,0,0), s)
    end
end)

local function makeCtrl(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size               = UDim2.fromOffset(18, 16)
    b.Position           = UDim2.new(1, xOff, 0.5, -8)
    b.BackgroundColor3   = C.btnBg
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Image              = ""
    b.AutoButtonColor    = false
    b.ZIndex             = 13
    b.Parent             = hdr
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bS = Instance.new("UIStroke", b)
    bS.Color = C.white; bS.Thickness = 0.9; bS.Transparency = 0.4
    task.spawn(function()
        local t = 0
        while b.Parent do
            t = t + task.wait(0.05)
            local s = (math.sin(t * 2.2) + 1) / 2
            bS.Transparency = 0.15 + s * 0.45
        end
    end)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text               = sym
    l.Font               = Enum.Font.GothamBold
    l.TextSize            = 11
    l.TextColor3          = C.sec
    l.ZIndex              = 14
    l.Parent              = b
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play()
        l.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.btnBg}):Play()
        l.TextColor3 = C.sec
    end)
    return b, l
end

local minBtn, minL   = makeCtrl(-40, "-")
local closeBtn, _    = makeCtrl(-20, "x")

-- ═══════════════════════════════════════════════
-- DRAG (main panel only)
-- ═══════════════════════════════════════════════
do
    local drag=false; local dRef=nil; local sI=nil; local sW=nil

    UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseButton1
        if not (isT or isM) then return end
        local ap = hdr.AbsolutePosition
        local az = hdr.AbsoluteSize
        local px, py = inp.Position.X, inp.Position.Y
        if px < ap.X or px > ap.X+az.X-44 or py < ap.Y or py > ap.Y+az.Y then return end
        drag=true; dRef=inp
        sI = Vector2.new(px,py)
        sW = Vector2.new(win.AbsolutePosition.X, win.AbsolutePosition.Y)
    end)

    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType ~= Enum.UserInputType.Touch
        and inp.UserInputType ~= Enum.UserInputType.MouseMove then return end
        if inp.UserInputType == Enum.UserInputType.Touch and inp ~= dRef then return end
        local d = Vector2.new(inp.Position.X,inp.Position.Y) - sI
        local vp = Cam.ViewportSize
        win.Position = UDim2.fromOffset(
            math.clamp(sW.X+d.X, 0, vp.X-W),
            math.clamp(sW.Y+d.Y, 0, vp.Y-H))
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp==dRef or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false; dRef=nil
        end
    end)
end

-- ═══════════════════════════════════════════════
-- FLOAT ICON (minimized)
-- ═══════════════════════════════════════════════
local floatF = Instance.new("Frame")
floatF.Name             = "FloatIcon"
floatF.Size             = UDim2.fromOffset(40, 40)
floatF.BackgroundColor3 = C.hdr
floatF.BackgroundTransparency = 0
floatF.BorderSizePixel  = 0
floatF.Visible          = false
floatF.ZIndex           = 500
floatF.Parent           = gui
Instance.new("UICorner", floatF).CornerRadius = UDim.new(0, 9)
local fiS = Instance.new("UIStroke", floatF)
fiS.Color = C.white; fiS.Thickness = 1.1; fiS.Transparency = 0.3

task.spawn(function()
    local t = 0
    while gui.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.6) + 1) / 2
        fiS.Transparency = 0.15 + s * 0.40
    end
end)

local fiImg = Instance.new("ImageLabel")
fiImg.Size               = UDim2.fromOffset(34, 34)
fiImg.Position           = UDim2.fromOffset(3, 3)
fiImg.BackgroundTransparency = 1
fiImg.Image              = LOGO_ID
fiImg.ScaleType          = Enum.ScaleType.Fit
fiImg.ZIndex             = 501
fiImg.Parent             = floatF

local function anchorFloat()
    local vp = Cam.ViewportSize
    if vp.X < 10 then vp = Vector2.new(800, 600) end
    floatF.Position = UDim2.fromOffset(vp.X - 56, vp.Y - 130)
end
anchorFloat()

local fiBtn = Instance.new("ImageButton")
fiBtn.Size               = UDim2.fromScale(1, 1)
fiBtn.BackgroundTransparency = 1
fiBtn.Image              = ""
fiBtn.AutoButtonColor    = false
fiBtn.ZIndex             = 502
fiBtn.Parent             = floatF
fiBtn.MouseButton1Click:Connect(function()
    floatF.Visible = false
    win.Visible    = true
    minL.Text      = "-"
end)

minBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    anchorFloat()
    floatF.Visible = true
    minL.Text = "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    if connection then connection:Disconnect() end
    pcall(function() gui:Destroy() end)
end)

-- ═══════════════════════════════════════════════
-- PLAYER LIST (fixed panel, not in scroll)
-- ═══════════════════════════════════════════════
local playerListPanel = Instance.new("Frame")
playerListPanel.Size = UDim2.new(1, 0, 0, 90)  -- fixed height
playerListPanel.Position = UDim2.fromOffset(0, HDR)
playerListPanel.BackgroundTransparency = 1
playerListPanel.BorderSizePixel = 0
playerListPanel.ZIndex = 11
playerListPanel.Parent = win

-- Search box inside panel
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -12, 0, 20)
searchBox.Position = UDim2.fromOffset(6, 2)
searchBox.BackgroundColor3 = C.card
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search player..."
searchBox.PlaceholderColor3 = C.sec
searchBox.Text = ""
searchBox.TextColor3 = C.white
searchBox.TextSize = 8
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 12
searchBox.Parent = playerListPanel
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 5)
Instance.new("UIPadding", searchBox).PaddingLeft = UDim.new(0, 6)

-- Nested ScrollingFrame for players (works fine in this fixed panel)
local playerListScroll = Instance.new("ScrollingFrame")
playerListScroll.Size = UDim2.new(1, -12, 1, -48)  -- below search, above refresh
playerListScroll.Position = UDim2.fromOffset(6, 26)
playerListScroll.BackgroundColor3 = C.card
playerListScroll.BackgroundTransparency = 0
playerListScroll.BorderSizePixel = 0
playerListScroll.ScrollBarThickness = 4
playerListScroll.ScrollBarImageColor3 = C.border
playerListScroll.ScrollingDirection = Enum.ScrollingDirection.Y
playerListScroll.CanvasSize = UDim2.fromOffset(0, 0)
playerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListScroll.ZIndex = 12
playerListScroll.Active = true
playerListScroll.Parent = playerListPanel
Instance.new("UICorner", playerListScroll).CornerRadius = UDim.new(0, 5)

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.SortOrder = Enum.SortOrder.Name
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.Parent = playerListScroll

Instance.new("UIPadding", playerListScroll).PaddingLeft = UDim.new(0, 4)
Instance.new("UIPadding", playerListScroll).PaddingRight = UDim.new(0, 4)
Instance.new("UIPadding", playerListScroll).PaddingTop = UDim.new(0, 4)

local selectedPlayerLabel = Instance.new("TextLabel")
selectedPlayerLabel.Size = UDim2.new(1, -12, 0, 16)
selectedPlayerLabel.Position = UDim2.new(0, 6, 1, -18)
selectedPlayerLabel.BackgroundTransparency = 1
selectedPlayerLabel.Text = "Target: None"
selectedPlayerLabel.Font = Enum.Font.GothamBold
selectedPlayerLabel.TextSize = 8
selectedPlayerLabel.TextColor3 = C.sec
selectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedPlayerLabel.ZIndex = 12
selectedPlayerLabel.Parent = playerListPanel

local refreshBtn = Instance.new("ImageButton")
refreshBtn.Size = UDim2.new(1, -12, 0, 18)
refreshBtn.Position = UDim2.fromOffset(6, 72) -- inside panel
refreshBtn.BackgroundColor3 = C.btnBg
refreshBtn.BackgroundTransparency = 0
refreshBtn.BorderSizePixel = 0
refreshBtn.Image = ""
refreshBtn.AutoButtonColor = false
refreshBtn.ZIndex = 13
refreshBtn.Parent = playerListPanel
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)
local refreshLbl = Instance.new("TextLabel")
refreshLbl.Size = UDim2.fromScale(1, 1)
refreshLbl.BackgroundTransparency = 1
refreshLbl.Text = "Refresh List"
refreshLbl.Font = Enum.Font.GothamBold
refreshLbl.TextSize = 8
refreshLbl.TextColor3 = C.sec
refreshLbl.ZIndex = 14
refreshLbl.Parent = refreshBtn
refreshBtn.MouseButton1Click:Connect(function()
    updatePlayerList(searchBox.Text)
    setStatus("Player list refreshed", C.sec)
end)

-- ═══════════════════════════════════════════════
-- SCROLL BODY (below the player panel)
-- ═══════════════════════════════════════════════
local scroll = Instance.new("ScrollingFrame")
scroll.Size                 = UDim2.new(1, 0, 1, -(HDR + 90))   -- remaining space
scroll.Position             = UDim2.fromOffset(0, HDR + 90)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel      = 0
scroll.ScrollBarThickness   = 2
scroll.ScrollBarImageColor3 = C.border
scroll.ScrollingDirection   = Enum.ScrollingDirection.Y
scroll.CanvasSize           = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
scroll.ZIndex               = 11
scroll.Active               = true
scroll.Parent               = win

local sLL = Instance.new("UIListLayout")
sLL.SortOrder = Enum.SortOrder.LayoutOrder
sLL.Padding   = UDim.new(0, 4)
sLL.Parent    = scroll

local sPad = Instance.new("UIPadding")
sPad.PaddingLeft   = UDim.new(0, 6)
sPad.PaddingRight  = UDim.new(0, 6)
sPad.PaddingTop    = UDim.new(0, 6)
sPad.PaddingBottom = UDim.new(0, 8)
sPad.Parent        = scroll

local _o = 0
local function o() _o = _o + 1; return _o end

-- ═══════════════════════════════════════════════
-- COMPONENT LIBRARY
-- ═══════════════════════════════════════════════
local function mkSec(title)
    local f = Instance.new("Frame")
    f.Size               = UDim2.new(1, 0, 0, 14)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = o()
    f.ZIndex             = 12
    f.Parent             = scroll
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text               = title:upper()
    l.Font               = Enum.Font.GothamBold
    l.TextSize            = 6
    l.TextColor3          = C.dim
    l.TextXAlignment      = Enum.TextXAlignment.Left
    l.ZIndex              = 13
    l.Parent              = f
end

local function mkToggle(opts)
    local h = opts.sub and 36 or 26
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1, 0, 0, h)
    card.BackgroundColor3   = C.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel    = 0
    card.LayoutOrder        = o()
    card.ZIndex             = 12
    card.Parent             = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(1, -38, 0, 12)
    tl.Position           = UDim2.fromOffset(7, opts.sub and 4 or 7)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize            = 8
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 13
    tl.Parent              = card
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1, -10, 0, 10)
        sl.Position           = UDim2.fromOffset(7, 18)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize            = 6
        sl.TextColor3          = C.sec
        sl.TextXAlignment      = Enum.TextXAlignment.Left
        sl.ZIndex              = 13
        sl.Parent              = card
    end
    local TW, TH2 = 22, 12
    local trk = Instance.new("Frame")
    trk.Size             = UDim2.fromOffset(TW, TH2)
    trk.Position         = UDim2.new(1, -(TW+6), 0.5, -(TH2/2))
    trk.BackgroundColor3 = C.border
    trk.BorderSizePixel  = 0
    trk.ZIndex           = 13
    trk.Parent           = card
    Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)
    local KS = TH2 - 4
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KS, KS)
    knob.Position         = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 14
    knob.Parent           = trk
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local state = false
    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1, 1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 15
    hit.Parent             = card
    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(trk, TweenInfo.new(0.12), {
            BackgroundColor3 = state and C.white or C.border
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = state and UDim2.fromOffset(TW-KS-2, 2) or UDim2.fromOffset(2, 2),
            BackgroundColor3 = state and C.bg or C.white,
        }):Play()
        playToggleSound()
        if opts.cb then opts.cb(state) end
    end)
    hit.MouseEnter:Connect(function() TweenService:Create(card, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play() end)
    hit.MouseLeave:Connect(function() TweenService:Create(card, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play() end)
    return card
end

local function mkBtn(opts)
    local h = opts.sub and 32 or 24
    local btn = Instance.new("ImageButton")
    btn.Size               = UDim2.new(1, 0, 0, h)
    btn.BackgroundColor3   = C.card
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel    = 0
    btn.Image              = ""
    btn.AutoButtonColor    = false
    btn.LayoutOrder        = o()
    btn.ZIndex             = 12
    btn.Parent             = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local bS = Instance.new("UIStroke", btn); bS.Color=C.border; bS.Thickness=0.8
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(1, -10, 0, 11)
    tl.Position           = UDim2.fromOffset(7, opts.sub and 4 or 6)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamBold
    tl.TextSize            = 8
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 13
    tl.Parent              = btn
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1, -10, 0, 10)
        sl.Position           = UDim2.fromOffset(7, 17)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize            = 6
        sl.TextColor3          = C.sec
        sl.TextXAlignment      = Enum.TextXAlignment.Left
        sl.ZIndex              = 13
        sl.Parent              = btn
    end
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3=C.cardH}):Play()
        task.delay(0.14, function() pcall(function() TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play() end) end)
        playToggleSound()
        if opts.cb then opts.cb() end
    end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play() end)
    return btn
end

-- ═══════════════════════════════════════════════
-- TROLL STATE
-- ═══════════════════════════════════════════════
local selectedPlayer = nil
local followMode = "default"
local following = false
local connection = nil
local flingTouchEnabled = false
local flingPower = 50000

-- ═══════════════════════════════════════════════
-- PLAYER LIST FUNCTIONS
-- ═══════════════════════════════════════════════
local function createPlayerButton(plr)
    local displayName = plr.DisplayName
    local userName = plr.Name
    local btn = Instance.new("TextButton")
    btn.Name = plr.Name
    btn.Size = UDim2.new(1, -2, 0, 22)
    btn.BackgroundColor3 = C.btnBg
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 14
    btn.Parent = playerListScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.fromOffset(4, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = displayName .. " (@" .. userName .. ")"
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 8
    lbl.TextColor3 = C.pri
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 15
    lbl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        selectedPlayer = Players:FindFirstChild(btn.Name)
        if selectedPlayer then
            selectedPlayerLabel.Text = "Target: " .. selectedPlayer.DisplayName
            selectedPlayerLabel.TextColor3 = C.white
            -- highlight
            for _, child in pairs(playerListScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = C.btnBg
                end
            end
            btn.BackgroundColor3 = C.cardH
            playToggleSound()
        end
    end)
    btn.MouseEnter:Connect(function()
        if selectedPlayer ~= Players:FindFirstChild(btn.Name) then
            btn.BackgroundColor3 = C.cardH
        end
    end)
    btn.MouseLeave:Connect(function()
        if selectedPlayer ~= Players:FindFirstChild(btn.Name) then
            btn.BackgroundColor3 = C.btnBg
        end
    end)
    return btn
end

local function updatePlayerList(searchText)
    searchText = searchText and searchText:lower() or ""
    for _, child in pairs(playerListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP then
            local dname = (plr.DisplayName):lower()
            local uname = plr.Name:lower()
            if searchText == "" or dname:find(searchText, 1, true) or uname:find(searchText, 1, true) then
                createPlayerButton(plr)
            end
        end
    end
    playerListScroll.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 8)
end

updatePlayerList("")

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayerList(searchBox.Text)
end)

Players.PlayerAdded:Connect(function()
    updatePlayerList(searchBox.Text)
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    updatePlayerList(searchBox.Text)
end)

-- ═══════════════════════════════════════════════
-- FOLLOW MODES (in scroll)
-- ═══════════════════════════════════════════════
mkSec("Follow Modes")

local modeContainer = Instance.new("Frame")
modeContainer.Size = UDim2.new(1, 0, 0, 50)
modeContainer.BackgroundTransparency = 1
modeContainer.LayoutOrder = o()
modeContainer.ZIndex = 12
modeContainer.Parent = scroll

local modeButtons = {}
local modes = {
    {name="default", label="FOLLOW", color=Color3.fromRGB(70,130,255)},
    {name="carry",   label="CARRY",  color=Color3.fromRGB(180,100,200)},
    {name="attach",  label="ATTACH", color=Color3.fromRGB(255,150,80)},
    {name="drag",    label="DRAG",   color=Color3.fromRGB(150,80,180)},
}
for i, mode in ipairs(modes) do
    local row = math.floor((i-1)/2)
    local col = (i-1)%2
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.47, 0, 0, 20)
    btn.Position = UDim2.fromScale(col*0.53, 0, row*0.53, 0)
    btn.BackgroundColor3 = (mode.name == followMode) and mode.color or C.btnBg
    btn.BorderSizePixel = 0
    btn.Text = mode.label
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 7
    btn.TextColor3 = (mode.name == followMode) and C.white or C.pri
    btn.AutoButtonColor = false
    btn.ZIndex = 13
    btn.Parent = modeContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        followMode = mode.name
        for _, mBtn in pairs(modeButtons) do
            mBtn.button.BackgroundColor3 = C.btnBg
            mBtn.button.TextColor3 = C.pri
        end
        btn.BackgroundColor3 = mode.color
        btn.TextColor3 = C.white
        playToggleSound()
    end)
    btn.MouseEnter:Connect(function()
        if followMode ~= mode.name then
            btn.BackgroundColor3 = C.cardH
        end
    end)
    btn.MouseLeave:Connect(function()
        if followMode ~= mode.name then
            btn.BackgroundColor3 = C.btnBg
        end
    end)
    modeButtons[mode.name] = {button=btn, color=mode.color}
end

-- ═══════════════════════════════════════════════
-- FOLLOW TOGGLE BUTTON (in scroll)
-- ═══════════════════════════════════════════════
mkSec("Control")
local followToggleBtn = mkBtn({title="Start Follow", sub="Activate troll follow mode", cb=function()
    if not selectedPlayer then
        setStatus("No target selected", C.sec)
        return
    end
    if not following then
        startFollowing()
        followToggleBtn.Text = "Stop Follow"
        followToggleBtn.BackgroundColor3 = Color3.fromRGB(255,70,70)
    else
        stopFollowing()
        followToggleBtn.Text = "Start Follow"
        followToggleBtn.BackgroundColor3 = C.card
    end
end})

-- ═══════════════════════════════════════════════
-- FLING TOUCH (in scroll)
-- ═══════════════════════════════════════════════
mkSec("Troll Extras")

local flingTouchToggle = mkToggle({
    title = "Fling Touch",
    sub = "Fling players on contact",
    cb = function(v)
        flingTouchEnabled = v
        if v then
            setupFlingTouch()
            setStatus("Fling Touch enabled", C.white)
        else
            cleanupFlingTouch()
            setStatus("Fling Touch disabled", C.sec)
        end
    end
})

local flingPowerCard = Instance.new("Frame")
flingPowerCard.Size = UDim2.new(1, 0, 0, 24)
flingPowerCard.BackgroundColor3 = C.card
flingPowerCard.BackgroundTransparency = 0
flingPowerCard.BorderSizePixel = 0
flingPowerCard.LayoutOrder = o()
flingPowerCard.ZIndex = 12
flingPowerCard.Parent = scroll
Instance.new("UICorner", flingPowerCard).CornerRadius = UDim.new(0, 5)

local flingPowerLabel = Instance.new("TextLabel")
flingPowerLabel.Size = UDim2.new(1, -10, 0, 11)
flingPowerLabel.Position = UDim2.fromOffset(7, 6)
flingPowerLabel.BackgroundTransparency = 1
flingPowerLabel.Text = "Fling Power"
flingPowerLabel.Font = Enum.Font.GothamSemibold
flingPowerLabel.TextSize = 8
flingPowerLabel.TextColor3 = C.pri
flingPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
flingPowerLabel.ZIndex = 13
flingPowerLabel.Parent = flingPowerCard

local flingPowerInput = Instance.new("TextBox")
flingPowerInput.Size = UDim2.new(0.35, 0, 0, 18)
flingPowerInput.Position = UDim2.new(1, -50, 0.5, -9)
flingPowerInput.BackgroundColor3 = C.btnBg
flingPowerInput.BorderSizePixel = 0
flingPowerInput.Text = tostring(flingPower)
flingPowerInput.TextColor3 = C.white
flingPowerInput.TextSize = 8
flingPowerInput.Font = Enum.Font.Gotham
flingPowerInput.ZIndex = 14
flingPowerInput.Parent = flingPowerCard
Instance.new("UICorner", flingPowerInput).CornerRadius = UDim.new(0, 4)
flingPowerInput.FocusLost:Connect(function()
    local num = tonumber(flingPowerInput.Text)
    if num then
        flingPower = math.clamp(num, 1000, 500000)
        flingPowerInput.Text = tostring(flingPower)
    else
        flingPowerInput.Text = tostring(flingPower)
    end
end)

-- ═══════════════════════════════════════════════
-- STOP ALL
-- ═══════════════════════════════════════════════
mkSec("Reset")
mkBtn({title="Stop All Trolls", sub="Release follow & fling", cb=function()
    stopFollowing()
    cleanupFlingTouch()
    followToggleBtn.Text = "Start Follow"
    followToggleBtn.BackgroundColor3 = C.card
    setStatus("All troll effects stopped", C.white)
end})

-- ═══════════════════════════════════════════════
-- FOLLOW LOGIC (adapted from Siexther)
-- ═══════════════════════════════════════════════
local function startFollowing()
    if not selectedPlayer or not selectedPlayer.Character then
        setStatus("Target invalid", C.sec)
        return
    end
    following = true
    local targetPlayer = selectedPlayer
    local modeName = followMode == "default" and "Follow" or followMode == "carry" and "Carry" or followMode == "attach" and "Attach" or "Drag"
    setStatus("Troll " .. targetPlayer.DisplayName .. " [" .. modeName .. "]", Color3.fromRGB(70,255,150))

    if connection then connection:Disconnect() end
    local lastJumpTime = 0
    local wasInAir = false

    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not following or not targetPlayer or not targetPlayer.Character then
            if connection then connection:Disconnect(); connection = nil end
            following = false
            return
        end

        local targetChar = targetPlayer.Character
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        if not LP.Character or not targetRoot or not targetHumanoid then return end

        local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
        local myHumanoid = LP.Character:FindFirstChild("Humanoid")
        if not myRoot or not myHumanoid then return end

        if followMode == "default" then
            local followOffset = targetRoot.CFrame.LookVector * -2.5
            local followPos = targetRoot.Position + followOffset
            local distance = (myRoot.Position - followPos).Magnitude
            if distance > 1.5 then
                myHumanoid:MoveTo(followPos)
                myHumanoid.WalkSpeed = targetHumanoid.WalkSpeed
            else
                myHumanoid.WalkSpeed = targetHumanoid.WalkSpeed * 0.5
            end
            local targetIsJumping = targetHumanoid:GetState() == Enum.HumanoidStateType.Jumping or targetHumanoid:GetState() == Enum.HumanoidStateType.Freefall
            local targetVelocity = targetRoot.AssemblyLinearVelocity
            local isMovingUp = targetVelocity.Y > 5
            local currentTime = tick()
            if (targetIsJumping or isMovingUp) and not wasInAir then
                if currentTime - lastJumpTime > 0.3 then
                    myHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    lastJumpTime = currentTime
                end
            end
            wasInAir = targetIsJumping or isMovingUp
            if targetHumanoid.Sit ~= myHumanoid.Sit then
                myHumanoid.Sit = targetHumanoid.Sit
            end
        elseif followMode == "carry" then
            local carryOffset = targetRoot.CFrame.LookVector * -1.2 + Vector3.new(0, 1, 0)
            local carryPos = targetRoot.Position + carryOffset
            myRoot.CFrame = CFrame.new(carryPos, targetRoot.Position + targetRoot.CFrame.LookVector)
            myRoot.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
            myHumanoid.Sit = false
        elseif followMode == "attach" then
            myRoot.CFrame = targetRoot.CFrame
            myRoot.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
            myRoot.AssemblyAngularVelocity = targetRoot.AssemblyAngularVelocity
            myHumanoid.Sit = targetHumanoid.Sit
            myHumanoid.WalkSpeed = targetHumanoid.WalkSpeed
            if targetHumanoid:GetState() ~= myHumanoid:GetState() then
                myHumanoid:ChangeState(targetHumanoid:GetState())
            end
        elseif followMode == "drag" then
            local dragOffset = targetRoot.CFrame.LookVector * -2.8
            local targetDragPos = targetRoot.Position + dragOffset + Vector3.new(0, -1.8, 0)
            myHumanoid.PlatformStand = true
            local currentPos = myRoot.Position
            local lerpAlpha = 0.35
            local newPos = currentPos:Lerp(targetDragPos, lerpAlpha)
            local lookDirection = (targetRoot.Position - myRoot.Position).Unit
            myRoot.CFrame = CFrame.new(newPos, newPos + lookDirection) * CFrame.Angles(math.rad(90), 0, 0)
            myRoot.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity * 0.95
            myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            local distance = (myRoot.Position - targetDragPos).Magnitude
            if distance > 0.5 then
                local dragForce = (targetDragPos - myRoot.Position) * 8
                myRoot.AssemblyLinearVelocity = myRoot.AssemblyLinearVelocity + dragForce
            end
        end
    end)
end

local function stopFollowing()
    following = false
    if connection then connection:Disconnect(); connection = nil end
    if LP.Character then
        local myHumanoid = LP.Character:FindFirstChild("Humanoid")
        if myHumanoid then myHumanoid.PlatformStand = false end
    end
    setStatus("Follow stopped", C.sec)
end

-- ═══════════════════════════════════════════════
-- FLING TOUCH LOGIC
-- ═══════════════════════════════════════════════
local flingConnections = {}

local function connectCharacterForFling(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local con = part.Touched:Connect(function(hit)
                if not flingTouchEnabled then return end
                local hitParent = hit.Parent
                if hitParent and hitParent:IsA("Model") then
                    local targetPlayer = Players:GetPlayerFromCharacter(hitParent)
                    if targetPlayer and targetPlayer ~= LP then
                        local targetRoot = hitParent:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            targetRoot.Velocity = (targetRoot.Position - part.Position).Unit * flingPower
                        end
                    end
                end
            end)
            table.insert(flingConnections, con)
        end
    end
end

local function setupFlingTouch()
    if flingTouchEnabled and LP.Character then
        connectCharacterForFling(LP.Character)
    end
end

local function cleanupFlingTouch()
    flingTouchEnabled = false
    for _, con in ipairs(flingConnections) do
        con:Disconnect()
    end
    flingConnections = {}
end

-- Reconnect on respawn
LP.CharacterAdded:Connect(function(char)
    if flingTouchEnabled then
        connectCharacterForFling(char)
    end
end)

-- ═══════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════
setStatus("Anonymous9x Troll loaded.", C.white)
