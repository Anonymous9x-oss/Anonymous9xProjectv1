-- ============================================================
--   Anonymous9x Fake Donate  |  Upgraded Build
--   Professional FE GUI | Delta All Devices Compatible
-- ============================================================

local Players          = game:GetService("Players")
local Marketplace      = game:GetService("MarketplaceService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local player = Players.LocalPlayer

-- ============================================================
-- STATE
-- ============================================================
local selectedId    = nil
local selectedName  = ""
local selectedPrice = 0
local spamActive    = false
local spamConn      = nil
local spamCount     = 0
local productList   = {}
local loadingDone   = false

-- ============================================================
-- SOUND  (BUY only)
-- ============================================================
local SFX_BUY = 142082167

local function playBuySound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://" .. tostring(SFX_BUY)
        s.Volume  = 0.6
        s.RollOffMaxDistance = 0
        s.Parent  = workspace
        s:Play()
        game:GetService("Debris"):AddItem(s, 3)
    end)
end

-- ============================================================
-- CORE LOGIC
-- ============================================================
local function buyBypass(id)
    if id then
        pcall(function()
            Marketplace:SignalPromptProductPurchaseFinished(player.UserId, id, true)
        end)
    end
end

-- ============================================================
-- GUI ROOT
-- ============================================================
local guiParent = (typeof(gethui) == "function" and gethui())
    or player:FindFirstChild("PlayerGui")
    or player.PlayerGui

for _, v in ipairs(guiParent:GetChildren()) do
    if v.Name == "Anon9xFakeDonate" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "Anon9xFakeDonate"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = guiParent

-- ============================================================
-- TWEEN HELPER
-- ============================================================
local function tw(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

-- ============================================================
-- NOTIFICATION  (bottom-right)
-- ============================================================
local NotifHolder = Instance.new("Frame")
NotifHolder.Name                   = "NotifHolder"
NotifHolder.Size                   = UDim2.new(0, 210, 1, 0)
NotifHolder.Position               = UDim2.new(1, -220, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex                 = 200
NotifHolder.Parent                 = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder           = Enum.SortOrder.LayoutOrder
NotifLayout.Padding             = UDim.new(0, 6)
NotifLayout.VerticalAlignment   = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Parent              = NotifHolder

local notifCounter = 0

local function notify(title, msg)
    notifCounter = notifCounter + 1
    local nf = Instance.new("Frame")
    nf.Name             = "N_" .. notifCounter
    nf.Size             = UDim2.new(1, 0, 0, 52)
    nf.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    nf.BorderSizePixel  = 0
    nf.LayoutOrder      = notifCounter
    nf.ClipsDescendants = true

    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 4)

    local ns = Instance.new("UIStroke", nf)
    ns.Color     = Color3.fromRGB(255, 255, 255)
    ns.Thickness = 1

    local bar = Instance.new("Frame", nf)
    bar.Size             = UDim2.new(1, 0, 0, 2)
    bar.Position         = UDim2.new(0, 0, 1, -2)
    bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 5

    local tl = Instance.new("TextLabel", nf)
    tl.Size               = UDim2.new(1, -10, 0, 20)
    tl.Position           = UDim2.new(0, 10, 0, 4)
    tl.BackgroundTransparency = 1
    tl.Text               = tostring(title)
    tl.TextColor3         = Color3.fromRGB(255, 255, 255)
    tl.TextSize           = 11
    tl.Font               = Enum.Font.GothamBold
    tl.TextXAlignment     = Enum.TextXAlignment.Left
    tl.ZIndex             = 5

    local ml = Instance.new("TextLabel", nf)
    ml.Size               = UDim2.new(1, -10, 0, 18)
    ml.Position           = UDim2.new(0, 10, 0, 24)
    ml.BackgroundTransparency = 1
    ml.Text               = tostring(msg)
    ml.TextColor3         = Color3.fromRGB(160, 160, 160)
    ml.TextSize           = 9
    ml.Font               = Enum.Font.Gotham
    ml.TextXAlignment     = Enum.TextXAlignment.Left
    ml.ZIndex             = 5

    nf.Parent   = NotifHolder
    nf.Position = UDim2.new(1.2, 0, 0, 0)
    tw(nf, 0.35, { Position = UDim2.new(0, 0, 0, 0) }):Play()
    tw(bar, 3.5, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear):Play()

    task.delay(3.5, function()
        tw(nf, 0.3, { Position = UDim2.new(1.2, 0, 0, 0) }, Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
        task.wait(0.35)
        nf:Destroy()
    end)
end

-- ============================================================
-- MAIN FRAME
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, 440, 0, 268)
MainFrame.Position         = UDim2.new(0.5, -220, 0.5, -134)
MainFrame.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex           = 2
MainFrame.Parent           = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 5)

local MF_Stroke = Instance.new("UIStroke", MainFrame)
MF_Stroke.Color     = Color3.fromRGB(255, 255, 255)
MF_Stroke.Thickness = 1.5

-- Glitch border loop
task.spawn(function()
    while MainFrame and MainFrame.Parent do
        tw(MF_Stroke, 1.0, { Color = Color3.fromRGB(255,255,255), Thickness = 1.5 }, Enum.EasingStyle.Linear):Play()
        task.wait(1.0)
        for _ = 1, 3 do
            MF_Stroke.Thickness = math.random(1,4) * 0.8
            MF_Stroke.Color     = Color3.fromRGB(math.random(180,255), math.random(180,255), math.random(180,255))
            task.wait(0.04)
        end
        MF_Stroke.Thickness = 1.5
        MF_Stroke.Color     = Color3.fromRGB(255,255,255)
        task.wait(0.06)
        tw(MF_Stroke, 0.6, { Color = Color3.fromRGB(60,60,60) }, Enum.EasingStyle.Linear):Play()
        task.wait(0.6)
        tw(MF_Stroke, 0.6, { Color = Color3.fromRGB(255,255,255) }, Enum.EasingStyle.Linear):Play()
        task.wait(0.6)
        task.wait(math.random(8,16) * 0.1)
    end
end)

-- ============================================================
-- HACKER SCAN LINE  (on main panel, white + green, infinite loop)
-- ============================================================
-- Thin white beam
local ScanBeamWhite = Instance.new("Frame", MainFrame)
ScanBeamWhite.Name             = "ScanBeamWhite"
ScanBeamWhite.Size             = UDim2.new(1, 0, 0, 1)
ScanBeamWhite.Position         = UDim2.new(0, 0, 0, 0)
ScanBeamWhite.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScanBeamWhite.BackgroundTransparency = 0.55
ScanBeamWhite.BorderSizePixel  = 0
ScanBeamWhite.ZIndex           = 45  -- below loading overlay (50), above content (3-5)

-- Soft green glow trail below white beam
local ScanGlow = Instance.new("Frame", MainFrame)
ScanGlow.Name             = "ScanGlow"
ScanGlow.Size             = UDim2.new(1, 0, 0, 18)
ScanGlow.Position         = UDim2.new(0, 0, 0, 0)
ScanGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 70)
ScanGlow.BackgroundTransparency = 0.92
ScanGlow.BorderSizePixel  = 0
ScanGlow.ZIndex           = 44

-- Scan loop: top to bottom, then reset
task.spawn(function()
    while MainFrame and MainFrame.Parent do
        -- Reset to top instantly
        ScanBeamWhite.Position = UDim2.new(0, 0, 0, 0)
        ScanGlow.Position      = UDim2.new(0, 0, 0, -14)

        -- Sweep down over 2.2s
        local dur = 2.2
        tw(ScanBeamWhite, dur, { Position = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear):Play()
        tw(ScanGlow,      dur, { Position = UDim2.new(0, 0, 1, -14) }, Enum.EasingStyle.Linear):Play()
        task.wait(dur)

        -- Brief pause, glitch flicker
        ScanBeamWhite.BackgroundTransparency = 1
        ScanGlow.BackgroundTransparency      = 1
        task.wait(0.04)
        ScanBeamWhite.BackgroundTransparency = 0.55
        ScanGlow.BackgroundTransparency      = 0.92
        task.wait(0.04)
        ScanBeamWhite.BackgroundTransparency = 1
        task.wait(0.06)
        ScanBeamWhite.BackgroundTransparency = 0.55
        ScanGlow.BackgroundTransparency      = 0.92

        -- Pause before next sweep
        task.wait(math.random(4, 8) * 0.1)
    end
end)

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 5

local TitleLine = Instance.new("Frame", TitleBar)
TitleLine.Size             = UDim2.new(1, 0, 0, 1)
TitleLine.Position         = UDim2.new(0, 0, 1, -1)
TitleLine.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleLine.BorderSizePixel  = 0
TitleLine.ZIndex           = 6

local LogoImg = Instance.new("ImageLabel", TitleBar)
LogoImg.Size                   = UDim2.new(0, 24, 0, 24)
LogoImg.Position               = UDim2.new(0, 10, 0.5, -12)
LogoImg.BackgroundTransparency = 1
LogoImg.Image                  = "rbxassetid://97269958324726"
LogoImg.ZIndex                 = 6

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size               = UDim2.new(1, -130, 1, 0)
TitleLabel.Position           = UDim2.new(0, 40, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = "Anonymous9x Fake Donate"
TitleLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize           = 12
TitleLabel.Font               = Enum.Font.GothamBold
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.ZIndex             = 6

local function makeTitleBtn(label, xOffset)
    local btn = Instance.new("TextButton", TitleBar)
    btn.Size             = UDim2.new(0, 28, 0, 22)
    btn.Position         = UDim2.new(1, xOffset, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.Text             = label
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 7
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(55, 55, 55)
    s.Thickness = 1
    btn.MouseEnter:Connect(function()
        tw(btn, 0.12, { BackgroundColor3 = Color3.fromRGB(35,35,35) }):Play()
        tw(s,   0.12, { Color = Color3.fromRGB(200,200,200) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, 0.12, { BackgroundColor3 = Color3.fromRGB(18,18,18) }):Play()
        tw(s,   0.12, { Color = Color3.fromRGB(55,55,55) }):Play()
    end)
    return btn
end

local MinBtn   = makeTitleBtn("-", -62)
local CloseBtn = makeTitleBtn("X", -30)

-- ============================================================
-- CONTENT AREA
-- ============================================================
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name                   = "ContentFrame"
ContentFrame.Size                   = UDim2.new(1, 0, 1, -58)
ContentFrame.Position               = UDim2.new(0, 0, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex                 = 3

local LeftPanel = Instance.new("Frame", ContentFrame)
LeftPanel.Name                   = "LeftPanel"
LeftPanel.Size                   = UDim2.new(0.62, -1, 1, 0)
LeftPanel.BackgroundTransparency = 1
LeftPanel.ZIndex                 = 3

local VDivider = Instance.new("Frame", ContentFrame)
VDivider.Size             = UDim2.new(0, 1, 1, 0)
VDivider.Position         = UDim2.new(0.62, 0, 0, 0)
VDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
VDivider.BorderSizePixel  = 0
VDivider.ZIndex           = 3

local RightPanel = Instance.new("Frame", ContentFrame)
RightPanel.Name                   = "RightPanel"
RightPanel.Size                   = UDim2.new(0.38, -1, 1, 0)
RightPanel.Position               = UDim2.new(0.62, 2, 0, 0)
RightPanel.BackgroundTransparency = 1
RightPanel.ZIndex                 = 3

-- ============================================================
-- PRODUCT SCROLL LIST  (no fetch button now)
-- ============================================================
local ScrollList = Instance.new("ScrollingFrame", LeftPanel)
ScrollList.Size                 = UDim2.new(1, 0, 1, 0)   -- full height, no fetch btn
ScrollList.Position             = UDim2.new(0, 0, 0, 0)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel      = 0
ScrollList.ScrollBarThickness   = 3
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ScrollList.CanvasSize           = UDim2.new(0, 0, 0, 0)
ScrollList.ZIndex               = 4

local ListLayout = Instance.new("UIListLayout", ScrollList)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding   = UDim.new(0, 3)

local ListPad = Instance.new("UIPadding", ScrollList)
ListPad.PaddingLeft  = UDim.new(0, 7)
ListPad.PaddingRight = UDim.new(0, 7)
ListPad.PaddingTop   = UDim.new(0, 7)

-- ============================================================
-- RIGHT PANEL CONTENT
-- ============================================================
local function makeLabel(parent, text, size, posX, posY, w, h, font, color)
    local l = Instance.new("TextLabel", parent)
    l.Size               = UDim2.new(0, w, 0, h)
    l.Position           = UDim2.new(0, posX, 0, posY)
    l.BackgroundTransparency = 1
    l.Text               = text
    l.TextColor3         = color or Color3.fromRGB(255,255,255)
    l.TextSize           = size
    l.Font               = font or Enum.Font.GothamBold
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.TextWrapped        = true
    l.ZIndex             = 5
    return l
end

local lbl_header    = makeLabel(RightPanel, "Selected Product", 9,  10, 10,  148, 14, Enum.Font.Gotham,     Color3.fromRGB(90,90,90))
local lbl_prodName  = makeLabel(RightPanel, "None",            11,  10, 24,  148, 28, Enum.Font.GothamBold)
local lbl_price     = makeLabel(RightPanel, "0 Robux",          9,  10, 52,  148, 14, Enum.Font.Gotham,     Color3.fromRGB(130,130,130))
local lbl_spamCount = makeLabel(RightPanel, "Spam count: 0x",   9,  10, 66,  148, 14, Enum.Font.Gotham,     Color3.fromRGB(100,100,100))

local HDivider = Instance.new("Frame", RightPanel)
HDivider.Size             = UDim2.new(1, -20, 0, 1)
HDivider.Position         = UDim2.new(0, 10, 0, 86)
HDivider.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HDivider.BorderSizePixel  = 0
HDivider.ZIndex           = 5

local BuyBtn = Instance.new("TextButton", RightPanel)
BuyBtn.Size             = UDim2.new(1, -20, 0, 34)
BuyBtn.Position         = UDim2.new(0, 10, 0, 96)
BuyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BuyBtn.Text             = "BUY"
BuyBtn.TextColor3       = Color3.fromRGB(0, 0, 0)
BuyBtn.TextSize         = 12
BuyBtn.Font             = Enum.Font.GothamBold
BuyBtn.BorderSizePixel  = 0
BuyBtn.ZIndex           = 5
Instance.new("UICorner", BuyBtn).CornerRadius = UDim.new(0, 3)

BuyBtn.MouseEnter:Connect(function()
    tw(BuyBtn, 0.12, { BackgroundColor3 = Color3.fromRGB(220,220,220) }):Play()
end)
BuyBtn.MouseLeave:Connect(function()
    tw(BuyBtn, 0.12, { BackgroundColor3 = Color3.fromRGB(255,255,255) }):Play()
end)

local SpamBtn = Instance.new("TextButton", RightPanel)
SpamBtn.Size             = UDim2.new(1, -20, 0, 34)
SpamBtn.Position         = UDim2.new(0, 10, 0, 136)
SpamBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
SpamBtn.Text             = "SPAM BUY"
SpamBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
SpamBtn.TextSize         = 12
SpamBtn.Font             = Enum.Font.GothamBold
SpamBtn.BorderSizePixel  = 0
SpamBtn.ZIndex           = 5
Instance.new("UICorner", SpamBtn).CornerRadius = UDim.new(0, 3)

local SpamStroke = Instance.new("UIStroke", SpamBtn)
SpamStroke.Color     = Color3.fromRGB(255, 255, 255)
SpamStroke.Thickness = 1

task.spawn(function()
    while SpamBtn and SpamBtn.Parent do
        if not spamActive then
            tw(SpamStroke, 0.8, { Color = Color3.fromRGB(80,80,80) }, Enum.EasingStyle.Linear):Play()
            task.wait(0.8)
            tw(SpamStroke, 0.8, { Color = Color3.fromRGB(255,255,255) }, Enum.EasingStyle.Linear):Play()
            task.wait(0.8)
        else
            SpamStroke.Thickness = 2
            task.wait(0.08)
            SpamStroke.Thickness = 1
            task.wait(0.08)
        end
    end
end)

-- ============================================================
-- STATUS BAR + CREDITS
-- ============================================================
local StatusBar = Instance.new("Frame", MainFrame)
StatusBar.Size             = UDim2.new(1, 0, 0, 20)
StatusBar.Position         = UDim2.new(0, 0, 1, -20)
StatusBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusBar.BorderSizePixel  = 0
StatusBar.ZIndex           = 5

local StatusTopLine = Instance.new("Frame", StatusBar)
StatusTopLine.Size             = UDim2.new(1, 0, 0, 1)
StatusTopLine.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
StatusTopLine.BorderSizePixel  = 0
StatusTopLine.ZIndex           = 6

local StatusLabel = Instance.new("TextLabel", StatusBar)
StatusLabel.Size               = UDim2.new(0.56, -10, 1, 0)
StatusLabel.Position           = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text               = "Ready"
StatusLabel.TextColor3         = Color3.fromRGB(80, 80, 80)
StatusLabel.TextSize           = 9
StatusLabel.Font               = Enum.Font.Gotham
StatusLabel.TextXAlignment     = Enum.TextXAlignment.Left
StatusLabel.ZIndex             = 6

local CreditsLabel = Instance.new("TextLabel", StatusBar)
CreditsLabel.Size               = UDim2.new(0.43, -6, 1, 0)
CreditsLabel.Position           = UDim2.new(0.57, 0, 0, 0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text               = "Created By Anonymous9x"
CreditsLabel.TextColor3         = Color3.fromRGB(45, 45, 45)
CreditsLabel.TextSize           = 8
CreditsLabel.Font               = Enum.Font.Gotham
CreditsLabel.TextXAlignment     = Enum.TextXAlignment.Right
CreditsLabel.ZIndex             = 6

local function setStatus(txt)
    StatusLabel.Text = tostring(txt)
end

-- ============================================================
-- PRODUCT CARD FACTORY
-- ============================================================
local function updateSelection()
    lbl_prodName.Text  = selectedName ~= "" and selectedName or "None"
    lbl_price.Text     = tostring(selectedPrice) .. " Robux"
    lbl_spamCount.Text = "Spam count: " .. tostring(spamCount) .. "x"

    for _, card in ipairs(ScrollList:GetChildren()) do
        if card:IsA("Frame") then
            local isSelected = (card:GetAttribute("ProdId") == selectedId)
            local s = card:FindFirstChildOfClass("UIStroke")
            local n = card:FindFirstChild("NameLbl")
            if s then tw(s, 0.15, { Color = isSelected and Color3.fromRGB(255,255,255) or Color3.fromRGB(35,35,35) }):Play() end
            if n then tw(n, 0.15, { TextColor3 = isSelected and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,160) }):Play() end
            tw(card, 0.15, { BackgroundColor3 = isSelected and Color3.fromRGB(16,16,16) or Color3.fromRGB(10,10,10) }):Play()
        end
    end
end

local function createCard(name, price, id, order)
    local card = Instance.new("Frame", ScrollList)
    card.Name             = "Card_" .. order
    card.Size             = UDim2.new(1, 0, 0, 46)
    card.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    card.BorderSizePixel  = 0
    card.LayoutOrder      = order
    card:SetAttribute("ProdId", id)
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

    local cs = Instance.new("UIStroke", card)
    cs.Color     = Color3.fromRGB(35, 35, 35)
    cs.Thickness = 1

    local badge = Instance.new("Frame", card)
    badge.Size             = UDim2.new(0, 36, 0, 36)
    badge.Position         = UDim2.new(0, 6, 0.5, -18)
    badge.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    badge.BorderSizePixel  = 0
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)
    local bS = Instance.new("UIStroke", badge)
    bS.Color = Color3.fromRGB(45, 45, 45)
    bS.Thickness = 1

    local badgeTxt = Instance.new("TextLabel", badge)
    badgeTxt.Size               = UDim2.new(1, 0, 1, 0)
    badgeTxt.BackgroundTransparency = 1
    badgeTxt.Text               = "R$"
    badgeTxt.TextColor3         = Color3.fromRGB(255, 255, 255)
    badgeTxt.TextSize           = 11
    badgeTxt.Font               = Enum.Font.GothamBold
    badgeTxt.TextXAlignment     = Enum.TextXAlignment.Center
    badgeTxt.ZIndex             = 2

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Name               = "NameLbl"
    nameLbl.Size               = UDim2.new(1, -52, 0, 20)
    nameLbl.Position           = UDim2.new(0, 48, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text               = tostring(name)
    nameLbl.TextColor3         = Color3.fromRGB(160, 160, 160)
    nameLbl.TextSize           = 10
    nameLbl.Font               = Enum.Font.GothamBold
    nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
    nameLbl.TextTruncate       = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex             = 2

    local priceLbl = Instance.new("TextLabel", card)
    priceLbl.Size               = UDim2.new(1, -52, 0, 16)
    priceLbl.Position           = UDim2.new(0, 48, 0, 24)
    priceLbl.BackgroundTransparency = 1
    priceLbl.Text               = tostring(price) .. " Robux"
    priceLbl.TextColor3         = Color3.fromRGB(80, 80, 80)
    priceLbl.TextSize           = 9
    priceLbl.Font               = Enum.Font.Gotham
    priceLbl.TextXAlignment     = Enum.TextXAlignment.Left
    priceLbl.ZIndex             = 2

    local clkBtn = Instance.new("TextButton", card)
    clkBtn.Size               = UDim2.new(1, 0, 1, 0)
    clkBtn.BackgroundTransparency = 1
    clkBtn.Text               = ""
    clkBtn.ZIndex             = 10
    clkBtn.MouseButton1Click:Connect(function()
        selectedId    = id
        selectedName  = name
        selectedPrice = price
        updateSelection()
    end)
end

-- ============================================================
-- LOADING OVERLAY  (covers MainFrame only, destroyed after use)
-- ============================================================
local LoadOverlay = Instance.new("Frame", MainFrame)
LoadOverlay.Name             = "LoadOverlay"
LoadOverlay.Size             = UDim2.new(1, 0, 1, 0)
LoadOverlay.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
LoadOverlay.BorderSizePixel  = 0
LoadOverlay.ZIndex           = 50
LoadOverlay.Visible          = true
Instance.new("UICorner", LoadOverlay).CornerRadius = UDim.new(0, 5)

-- ── GLITCH TITLE "Anonymous9x VIP"  ──────────────────────────
local GlitchTitle = Instance.new("TextLabel", LoadOverlay)
GlitchTitle.Size               = UDim2.new(1, -20, 0, 30)
GlitchTitle.Position           = UDim2.new(0, 10, 0, 46)
GlitchTitle.BackgroundTransparency = 1
GlitchTitle.Text               = "Anonymous9x VIP"
GlitchTitle.TextColor3         = Color3.fromRGB(255, 255, 255)
GlitchTitle.TextSize           = 22
GlitchTitle.Font               = Enum.Font.GothamBlack
GlitchTitle.TextXAlignment     = Enum.TextXAlignment.Center
GlitchTitle.ZIndex             = 52
GlitchTitle.ClipsDescendants   = false

-- Shadow/ghost duplicate for glitch depth effect
local GlitchShadow = Instance.new("TextLabel", LoadOverlay)
GlitchShadow.Size               = UDim2.new(1, -20, 0, 30)
GlitchShadow.Position           = UDim2.new(0, 10, 0, 46)
GlitchShadow.BackgroundTransparency = 1
GlitchShadow.Text               = "Anonymous9x VIP"
GlitchShadow.TextColor3         = Color3.fromRGB(0, 255, 80)
GlitchShadow.TextTransparency   = 0.7
GlitchShadow.TextSize           = 22
GlitchShadow.Font               = Enum.Font.GothamBlack
GlitchShadow.TextXAlignment     = Enum.TextXAlignment.Center
GlitchShadow.ZIndex             = 51

-- Glitch text character sets for scramble effect
local glitchChars = {"A","N","0","X","#","@","!","9","V","I","P","_","-","/","\\","[","]","?","$"}
local originalTitle = "Anonymous9x VIP"

-- FIX: flag killed immediately when hideLoading fires — no more lingering loops
local overlayAlive = true

-- Glitch title animation loop
task.spawn(function()
    while overlayAlive do
        -- Idle: normal text
        if not overlayAlive then break end
        GlitchTitle.Text          = originalTitle
        GlitchTitle.TextColor3    = Color3.fromRGB(255, 255, 255)
        GlitchShadow.Position     = UDim2.new(0, 10, 0, 46)
        GlitchShadow.TextColor3   = Color3.fromRGB(0, 255, 80)

        -- Short fragmented waits so we can bail out fast
        local idleTotal = math.random(8,20) * 0.1
        local elapsed   = 0
        while elapsed < idleTotal and overlayAlive do
            task.wait(0.05)
            elapsed = elapsed + 0.05
        end
        if not overlayAlive then break end

        -- Glitch burst: scramble 4-6 frames
        local burstCount = math.random(4, 7)
        for _ = 1, burstCount do
            if not overlayAlive then break end
            -- Scramble random characters
            local chars = {}
            for i = 1, #originalTitle do
                local c = originalTitle:sub(i,i)
                if c ~= " " and math.random() < 0.45 then
                    c = glitchChars[math.random(#glitchChars)]
                end
                chars[i] = c
            end
            GlitchTitle.Text = table.concat(chars)

            -- Color flash
            GlitchTitle.TextColor3 = Color3.fromRGB(math.random(180,255), math.random(180,255), math.random(180,255))

            -- Chromatic shift on shadow
            GlitchShadow.Position     = UDim2.new(0, 10 + math.random(-4,4), 0, 46 + math.random(-2,2))
            GlitchShadow.TextColor3   = Color3.fromRGB(math.random(0,60), math.random(200,255), math.random(50,120))
            GlitchShadow.TextTransparency = math.random(3,7) * 0.1

            task.wait(0.04)
        end

        if not overlayAlive then break end
        -- Reset
        GlitchTitle.Text              = originalTitle
        GlitchTitle.TextColor3        = Color3.fromRGB(255, 255, 255)
        GlitchShadow.Position         = UDim2.new(0, 10, 0, 46)
        GlitchShadow.TextTransparency = 0.7
        GlitchShadow.TextColor3       = Color3.fromRGB(0, 255, 80)
        task.wait(0.05)
    end
end)

-- ── Small logo above glitch title ────────────────────────────
local LOLogo = Instance.new("ImageLabel", LoadOverlay)
LOLogo.Size                  = UDim2.new(0, 32, 0, 32)
LOLogo.Position              = UDim2.new(0.5, -16, 0, 10)
LOLogo.BackgroundTransparency = 1
LOLogo.Image                 = "rbxassetid://97269958324726"
LOLogo.ZIndex                = 52

-- ── Status line  ─────────────────────────────────────────────
local LOSub = Instance.new("TextLabel", LoadOverlay)
LOSub.Size               = UDim2.new(1, 0, 0, 16)
LOSub.Position           = UDim2.new(0, 0, 0, 88)
LOSub.BackgroundTransparency = 1
LOSub.Text               = "Initializing..."
LOSub.TextColor3         = Color3.fromRGB(90, 90, 90)
LOSub.TextSize           = 9
LOSub.Font               = Enum.Font.Gotham
LOSub.TextXAlignment     = Enum.TextXAlignment.Center
LOSub.ZIndex             = 52

-- ── Progress bar  ─────────────────────────────────────────────
local LOBarBg = Instance.new("Frame", LoadOverlay)
LOBarBg.Size             = UDim2.new(0.6, 0, 0, 2)
LOBarBg.Position         = UDim2.new(0.2, 0, 0, 110)
LOBarBg.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LOBarBg.BorderSizePixel  = 0
LOBarBg.ZIndex           = 52

local LOBarFill = Instance.new("Frame", LOBarBg)
LOBarFill.Size             = UDim2.new(0, 0, 1, 0)
LOBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LOBarFill.BorderSizePixel  = 0
LOBarFill.ZIndex           = 53

-- Green bar accent that follows fill
local LOBarGreen = Instance.new("Frame", LOBarBg)
LOBarGreen.Size             = UDim2.new(0, 3, 1, 0)
LOBarGreen.Position         = UDim2.new(0, 0, 0, 0)
LOBarGreen.BackgroundColor3 = Color3.fromRGB(0, 255, 70)
LOBarGreen.BorderSizePixel  = 0
LOBarGreen.ZIndex           = 54

-- ── Extra loading details row  ────────────────────────────────
local LODetails = Instance.new("TextLabel", LoadOverlay)
LODetails.Size               = UDim2.new(1, -20, 0, 12)
LODetails.Position           = UDim2.new(0, 10, 0, 118)
LODetails.BackgroundTransparency = 1
LODetails.Text               = "v2.0  |  DELTA ALL DEVICES  |  FE"
LODetails.TextColor3         = Color3.fromRGB(40, 40, 40)
LODetails.TextSize           = 8
LODetails.Font               = Enum.Font.Gotham
LODetails.TextXAlignment     = Enum.TextXAlignment.Center
LODetails.ZIndex             = 52

-- ── Loading scanline (full overlay sweep)  ───────────────────
local LOScanLine = Instance.new("Frame", LoadOverlay)
LOScanLine.Size             = UDim2.new(1, 0, 0, 1)
LOScanLine.Position         = UDim2.new(0, 0, 0, 0)
LOScanLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LOScanLine.BackgroundTransparency = 0.6
LOScanLine.BorderSizePixel  = 0
LOScanLine.ZIndex           = 55

-- Green tinted scan beam
local LOScanGreen = Instance.new("Frame", LoadOverlay)
LOScanGreen.Size             = UDim2.new(1, 0, 0, 14)
LOScanGreen.Position         = UDim2.new(0, 0, 0, 0)
LOScanGreen.BackgroundColor3 = Color3.fromRGB(0, 255, 70)
LOScanGreen.BackgroundTransparency = 0.88
LOScanGreen.BorderSizePixel  = 0
LOScanGreen.ZIndex           = 54

task.spawn(function()
    while overlayAlive and LoadOverlay and LoadOverlay.Parent do
        LOScanLine.Position  = UDim2.new(0, 0, 0, 0)
        LOScanGreen.Position = UDim2.new(0, 0, 0, -10)
        tw(LOScanLine,  1.6, { Position = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear):Play()
        tw(LOScanGreen, 1.6, { Position = UDim2.new(0, 0, 1, -10) }, Enum.EasingStyle.Linear):Play()
        task.wait(1.65)
        if not overlayAlive then break end
        -- Glitch flicker on reset
        LOScanLine.BackgroundTransparency  = 1
        LOScanGreen.BackgroundTransparency = 1
        task.wait(0.05)
        if not overlayAlive then break end
        LOScanLine.BackgroundTransparency  = 0.6
        LOScanGreen.BackgroundTransparency = 0.88
        task.wait(math.random(2,5) * 0.1)
    end
end)

-- Animate green bar accent chasing fill
task.spawn(function()
    while LOBarFill and LOBarFill.Parent do
        LOBarGreen.Position = UDim2.new(LOBarFill.Size.X.Scale, LOBarFill.Size.X.Offset - 3, 0, 0)
        task.wait(0.03)
    end
end)

-- ── hideLoading: kill flag instantly, hard-clear all elements, then destroy  ──
local function hideLoading()
    if not (LoadOverlay and LoadOverlay.Parent) then return end
    loadingDone  = true
    overlayAlive = false  -- kills glitch loop and scanline loops immediately

    -- Hard-set all text/image transparent right now (no tween lag)
    for _, d in ipairs(LoadOverlay:GetDescendants()) do
        pcall(function()
            if d:IsA("TextLabel") or d:IsA("ImageLabel") then
                d.TextTransparency  = 1
                d.ImageTransparency = 1
            end
        end)
    end

    -- Quick bg fade then destroy
    tw(LoadOverlay, 0.18, { BackgroundTransparency = 1 }):Play()
    task.delay(0.2, function()
        if LoadOverlay and LoadOverlay.Parent then
            LoadOverlay:Destroy()
        end
    end)
end

-- ============================================================
-- FETCH PRODUCTS  (auto on start, no manual refresh button)
-- ============================================================
local function fetchProducts()
    setStatus("Fetching products...")

    for _, v in ipairs(ScrollList:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    task.spawn(function()
        task.wait(0.3)

        local ok, res = pcall(function()
            return Marketplace:GetDeveloperProductsAsync()
        end)

        if not ok then
            hideLoading()
            notify("Error", "Failed to fetch products")
            setStatus("Error")
            return
        end

        local list = {}
        local page = res
        repeat
            for _, item in ipairs(page:GetCurrentPage()) do
                table.insert(list, {
                    id    = item.ProductId,
                    nama  = item.Name,
                    harga = item.PriceInRobux or 0
                })
            end
            if not page.IsFinished then
                page:AdvanceToNextPageAsync()
                task.wait()
            end
        until page.IsFinished

        if #list == 0 then
            hideLoading()
            notify("Empty", "No products found")
            setStatus("No products found")
            return
        end

        table.sort(list, function(a, b) return a.harga < b.harga end)
        productList = list

        if LOSub and LOSub.Parent then LOSub.Text = "Building list..." end
        task.wait(0.15)

        for i, v in ipairs(list) do
            createCard(v.nama, v.harga, v.id, i)
            if i % 5 == 0 then task.wait() end
        end

        ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 14)

        selectedId    = list[1].id
        selectedName  = list[1].nama
        selectedPrice = list[1].harga
        updateSelection()

        hideLoading()
        notify("Ready", tostring(#list) .. " products loaded")
        setStatus(tostring(#list) .. " products loaded")
    end)
end

-- ============================================================
-- BUTTON CONNECTIONS
-- ============================================================
BuyBtn.MouseButton1Click:Connect(function()
    if not selectedId then
        notify("Error", "Select a product first")
        return
    end
    playBuySound()
    buyBypass(selectedId)
    notify("Bought", selectedName)
    setStatus("Bought: " .. selectedName)
end)

SpamBtn.MouseButton1Click:Connect(function()
    if not selectedId then
        notify("Error", "Select a product first")
        return
    end

    spamActive = not spamActive

    if spamActive then
        spamCount = 0
        tw(SpamBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(255,255,255) }):Play()
        tw(SpamBtn, 0.15, { TextColor3 = Color3.fromRGB(0,0,0) }):Play()
        SpamBtn.Text = "STOP SPAM"
        notify("Spam ON", selectedName .. " - spamming")
        setStatus("Spamming: " .. selectedName)

        -- 5 parallel Heartbeat threads = ~5x calls per frame vs single thread
        -- UI update only on thread 1 to avoid redundant writes
        local conns = {}
        spamConn = conns  -- store table ref for cleanup

        for threadIdx = 1, 5 do
            local c
            c = RunService.Heartbeat:Connect(function()
                if not spamActive then
                    c:Disconnect()
                    return
                end
                buyBypass(selectedId)
                if threadIdx == 1 then
                    spamCount = spamCount + 1
                    lbl_spamCount.Text = "Spam count: " .. tostring(spamCount) .. "x"
                end
            end)
            conns[threadIdx] = c
        end
    else
        -- Disconnect all 5 threads
        if type(spamConn) == "table" then
            for _, c in ipairs(spamConn) do
                pcall(function() c:Disconnect() end)
            end
        end
        spamConn = nil
        tw(SpamBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(8,8,8) }):Play()
        tw(SpamBtn, 0.15, { TextColor3 = Color3.fromRGB(255,255,255) }):Play()
        SpamBtn.Text = "SPAM BUY"
        notify("Spam OFF", "Total: " .. tostring(spamCount) .. "x")
        setStatus("Stopped  -  " .. tostring(spamCount) .. "x total")
        spamCount = 0
        lbl_spamCount.Text = "Spam count: 0x"
    end
end)

-- ============================================================
-- MINIMIZE ICON  (center-right, fixed)
-- ============================================================
local MinIcon = Instance.new("ImageButton", ScreenGui)
MinIcon.Name             = "MinIcon"
MinIcon.Size             = UDim2.new(0, 46, 0, 46)
MinIcon.Position         = UDim2.new(1, -56, 0.5, -23)
MinIcon.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
MinIcon.Image            = "rbxassetid://97269958324726"
MinIcon.ScaleType        = Enum.ScaleType.Fit
MinIcon.BorderSizePixel  = 0
MinIcon.Visible          = false
MinIcon.ZIndex           = 100
Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(0, 8)

local MIS = Instance.new("UIStroke", MinIcon)
MIS.Color     = Color3.fromRGB(255, 255, 255)
MIS.Thickness = 1.5

task.spawn(function()
    while MinIcon and MinIcon.Parent do
        if MinIcon.Visible then
            tw(MIS, 0.7, { Color = Color3.fromRGB(80,80,80) }, Enum.EasingStyle.Linear):Play()
            task.wait(0.7)
            tw(MIS, 0.7, { Color = Color3.fromRGB(255,255,255) }, Enum.EasingStyle.Linear):Play()
            task.wait(0.7)
        else
            task.wait(0.5)
        end
    end
end)

-- ============================================================
-- MINIMIZE / CLOSE
-- ============================================================
MinBtn.MouseButton1Click:Connect(function()
    tw(MainFrame, 0.2, { Size = UDim2.new(0, 440, 0, 0) }):Play()
    task.delay(0.22, function()
        MainFrame.Visible = false
        MainFrame.Size    = UDim2.new(0, 440, 0, 268)
        MinIcon.Visible   = true
    end)
end)

MinIcon.MouseButton1Click:Connect(function()
    MinIcon.Visible   = false
    MainFrame.Visible = true
    MainFrame.Size    = UDim2.new(0, 440, 0, 0)
    tw(MainFrame, 0.25, { Size = UDim2.new(0, 440, 0, 268) }):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    spamActive = false
    if type(spamConn) == "table" then
        for _, c in ipairs(spamConn) do pcall(function() c:Disconnect() end) end
    end
    spamConn = nil
    tw(MainFrame, 0.25, { BackgroundTransparency = 1, Size = UDim2.new(0, 440, 0, 0) }):Play()
    task.delay(0.3, function() ScreenGui:Destroy() end)
end)

-- ============================================================
-- DRAG  (title bar)
-- ============================================================
do
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = MainFrame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ============================================================
-- STARTUP  (auto-fetch, no refresh button needed)
-- ============================================================
task.spawn(function()
    -- Step 1
    tw(LOBarFill, 0.4, { Size = UDim2.new(0.2, 0, 1, 0) }, Enum.EasingStyle.Quart):Play()
    LOSub.Text = "Initializing modules..."
    task.wait(0.5)
    -- Step 2
    tw(LOBarFill, 0.4, { Size = UDim2.new(0.45, 0, 1, 0) }, Enum.EasingStyle.Quart):Play()
    LOSub.Text = "Connecting to Marketplace..."
    task.wait(0.5)
    -- Step 3: fetch
    tw(LOBarFill, 0.3, { Size = UDim2.new(0.6, 0, 1, 0) }, Enum.EasingStyle.Quart):Play()
    LOSub.Text = "Loading developer products..."
    fetchProducts()
end)

-- ============================================================
-- END
-- ============================================================
