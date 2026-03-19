--[[
    ╔══════════════════════════════════════════════════════════╗
    ║   A9X Spam Chat                                          ║
    ║   By Anonymous9x                                         ║
    ║   Delta Mobile / iOS / iPad Only                         ║
    ╠══════════════════════════════════════════════════════════╣
    ║   SPAM ENGINE:                                           ║
    ║   [A] SayAsync — primary Roblox chat method              ║
    ║   [B] StarterGui:SetCore("ChatMakeSystemMessage")        ║
    ║       — local chat flood (visual noise)                  ║
    ║   [C] ReplicatedStorage chat remotes auto-scan           ║
    ║       — fires game-specific chat remotes if found        ║
    ║   [D] RunService.Heartbeat burst engine                  ║
    ║       — Turbo mode: fires as fast as engine allows       ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer      = Players.LocalPlayer

-- Destroy old instance
pcall(function() game.CoreGui:FindFirstChild("__A9XSpamChat"):Destroy() end)

-- ══════════════════════════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════════════════════════
local S = {
    spamOn   = false,
    turbo    = false,
    interval = 0.3,   -- seconds between each spam
    text     = "Anonymous9x",
    msgsSent = 0,
    mini     = false,
}

local _sparkToken = {}

-- ══════════════════════════════════════════════════════════════════
--  SPAM ENGINE — all methods fire per cycle
-- ══════════════════════════════════════════════════════════════════
-- ══════════════════════════════════════════════════════════════════
--  SPAM ENGINE  — CORRECT
--
--  KEY LESSON FROM WORKING SOURCE:
--  TextChatService.TextChannels.RBXGeneral:SendAsync() is a
--  YIELDING function. It CANNOT run inside RunService.Heartbeat
--  (Heartbeat callbacks must not yield).
--
--  The working source uses:  while wait(3) do ... SendAsync() end
--  This runs in its own coroutine so yielding is fine.
--
--  Our fix: task.spawn a while loop (same pattern, variable speed).
--  Turbo = minimum wait (task.wait() with no args = ~0 delay).
-- ══════════════════════════════════════════════════════════════════

local TextChatService = game:GetService("TextChatService")

local function fireSpam()
    local msg = S.text
    if msg == "" then msg = "." end

    -- THE method that actually works — exactly from working source
    pcall(function()
        TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
    end)

    S.msgsSent = S.msgsSent + 1
end

local _spamThread = nil  -- track running coroutine token

local function startSpam()
    -- Kill any previous loop
    local myToken = {}
    _spamThread = myToken

    task.spawn(function()
        while _spamThread == myToken and S.spamOn do
            fireSpam()
            if S.turbo then
                task.wait()           -- minimum yield (~0), max speed
            else
                task.wait(S.interval)
            end
        end
    end)
end

local function stopSpam()
    _spamThread = {}  -- invalidate current loop token
end



-- ══════════════════════════════════════════════════════════════════
--  GUI CONSTANTS
-- ══════════════════════════════════════════════════════════════════
local PW        = 224
local PH_FULL   = 248
local PH_MIN    = 22
local SPARK_LEN = 38
local SPARK_SPD = 0.40

-- ══════════════════════════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "__A9XSpamChat"
gui.ResetOnSpawn   = false
gui.DisplayOrder   = 997
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

-- ══════════════════════════════════════════════════════════════════
--  PANEL — positioned at pure Scale=0 offset for clean drag
-- ══════════════════════════════════════════════════════════════════
local vp      = workspace.CurrentCamera.ViewportSize
local startX  = math.floor((vp.X - PW) / 2)
local startY  = 100

local panel = Instance.new("Frame")
panel.Size                   = UDim2.new(0, PW, 0, PH_FULL)
panel.Position               = UDim2.new(0, startX, 0, startY)
panel.BackgroundColor3       = Color3.new(0, 0, 0)
panel.BackgroundTransparency = 0
panel.BorderSizePixel        = 0
panel.ClipsDescendants       = false
panel.ZIndex                 = 10
panel.Parent                 = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 7)

local panelBorder = Instance.new("UIStroke")
panelBorder.Color        = Color3.new(1, 1, 1)
panelBorder.Thickness    = 1.4
panelBorder.Transparency = 0
panelBorder.Parent       = panel

-- ══════════════════════════════════════════════════════════════════
--  SPARK
-- ══════════════════════════════════════════════════════════════════
local spark = Instance.new("Frame")
spark.Name                   = "Spark"
spark.BackgroundColor3       = Color3.new(1, 1, 1)
spark.BackgroundTransparency = 1
spark.BorderSizePixel        = 0
spark.ZIndex                 = 22
spark.Parent                 = panel
Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)

local function killSpark()
    _sparkToken = {}
    spark.BackgroundTransparency = 1
end

local function startSpark(h)
    local myToken = {}
    _sparkToken   = myToken
    spark.BackgroundTransparency = 0
    task.spawn(function()
        task.wait(0.05)
        while _sparkToken == myToken do
            local H = h
            spark.Size     = UDim2.new(0, SPARK_LEN, 0, 2)
            spark.Position = UDim2.new(0, 0, 0, 0)
            local tw = TweenService:Create(spark, TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear), {Position = UDim2.new(0, PW-SPARK_LEN, 0, 0)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency=1 return end

            spark.Size     = UDim2.new(0, 2, 0, SPARK_LEN)
            spark.Position = UDim2.new(0, PW-2, 0, 0)
            tw = TweenService:Create(spark, TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear), {Position = UDim2.new(0, PW-2, 0, H-SPARK_LEN)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency=1 return end

            spark.Size     = UDim2.new(0, SPARK_LEN, 0, 2)
            spark.Position = UDim2.new(0, PW-SPARK_LEN, 0, H-2)
            tw = TweenService:Create(spark, TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear), {Position = UDim2.new(0, 0, 0, H-2)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency=1 return end

            spark.Size     = UDim2.new(0, 2, 0, SPARK_LEN)
            spark.Position = UDim2.new(0, 0, 0, H-SPARK_LEN)
            tw = TweenService:Create(spark, TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear), {Position = UDim2.new(0, 0, 0, 0)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency=1 return end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════════════════════════════════
local titleBar = Instance.new("Frame")
titleBar.Size                   = UDim2.new(1, 0, 0, 22)
titleBar.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
titleBar.BackgroundTransparency = 0
titleBar.BorderSizePixel        = 0
titleBar.ZIndex                 = 11
titleBar.Parent                 = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 7)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size               = UDim2.new(1, -50, 1, 0)
titleLbl.Position           = UDim2.new(0, 8, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "A9X Spam Chat"
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 9
titleLbl.TextColor3         = Color3.new(1, 1, 1)
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 12
titleLbl.Parent             = titleBar

local function makeTitleBtn(xOff, lbl)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 18, 0, 14)
    b.Position         = UDim2.new(1, xOff, 0.5, -7)
    b.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    b.BorderSizePixel  = 0
    b.Text             = lbl
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 9
    b.TextColor3       = Color3.new(1, 1, 1)
    b.ZIndex           = 13
    b.Parent           = titleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    return b
end

local minBtn   = makeTitleBtn(-42, "_")
local closeBtn = makeTitleBtn(-22, "X")

-- ══════════════════════════════════════════════════════════════════
--  CONTENT
-- ══════════════════════════════════════════════════════════════════
local content = Instance.new("Frame")
content.Size                 = UDim2.new(1, 0, 1, -22)
content.Position             = UDim2.new(0, 0, 0, 22)
content.BackgroundTransparency = 1
content.ClipsDescendants     = true
content.ZIndex               = 11
content.Parent               = panel

local cPad = Instance.new("UIPadding")
cPad.PaddingLeft = UDim.new(0, 9); cPad.PaddingRight  = UDim.new(0, 9)
cPad.PaddingTop  = UDim.new(0, 9); cPad.PaddingBottom = UDim.new(0, 9)
cPad.Parent      = content

local cList = Instance.new("UIListLayout")
cList.SortOrder = Enum.SortOrder.LayoutOrder
cList.Padding   = UDim.new(0, 7)
cList.Parent    = content

-- ── Section label helper ─────────────────────────────────────────
local function makeSectionLbl(txt, order)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1, 0, 0, 11)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.Font               = Enum.Font.Gotham
    l.TextSize           = 8
    l.TextColor3         = Color3.fromRGB(140, 140, 140)
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.LayoutOrder        = order
    l.ZIndex             = 12
    l.Parent             = content
    return l
end

-- ── Button helper ────────────────────────────────────────────────
local function makeBtn(text, order, h)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(1, 0, 0, h or 28)
    b.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    b.BorderSizePixel  = 0
    b.Text             = text
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 9
    b.TextColor3       = Color3.fromRGB(120, 120, 120)
    b.LayoutOrder      = order
    b.ZIndex           = 12
    b.Parent           = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(45, 45, 45); bs.Thickness = 0.9; bs.Parent = b
    return b, bs
end

-- ── TextBox helper ───────────────────────────────────────────────
local function makeBox(placeholder, order, h)
    local b = Instance.new("TextBox")
    b.Size             = UDim2.new(1, 0, 0, h or 28)
    b.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    b.BorderSizePixel  = 0
    b.Text             = ""
    b.PlaceholderText  = placeholder
    b.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    b.Font             = Enum.Font.GothamSemibold
    b.TextSize         = 9
    b.TextColor3       = Color3.new(1, 1, 1)
    b.ClearTextOnFocus = false
    b.LayoutOrder      = order
    b.ZIndex           = 12
    b.Parent           = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(45, 45, 45); bs.Thickness = 0.9; bs.Parent = b
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 7); p.Parent = b
    return b, bs
end

-- ── Text box ─────────────────────────────────────────────────────
makeSectionLbl("MESSAGE", 1)
local msgBox, msgBoxS = makeBox("Enter spam message...", 2, 30)
msgBox.Text = S.text

-- ── Speed row ────────────────────────────────────────────────────
makeSectionLbl("SPEED  (seconds between each)", 3)

local speedRow = Instance.new("Frame")
speedRow.Size                 = UDim2.new(1, 0, 0, 28)
speedRow.BackgroundTransparency = 1
speedRow.LayoutOrder          = 4
speedRow.ZIndex               = 12
speedRow.Parent               = content

local srL = Instance.new("UIListLayout")
srL.FillDirection     = Enum.FillDirection.Horizontal
srL.VerticalAlignment = Enum.VerticalAlignment.Center
srL.Padding           = UDim.new(0, 6)
srL.Parent            = speedRow

local speedBox = Instance.new("TextBox")
speedBox.Size              = UDim2.new(0.48, 0, 1, 0)
speedBox.BackgroundColor3  = Color3.fromRGB(14, 14, 14)
speedBox.BorderSizePixel   = 0
speedBox.Text              = tostring(S.interval)
speedBox.PlaceholderText   = "0.3"
speedBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
speedBox.Font              = Enum.Font.GothamSemibold
speedBox.TextSize          = 9
speedBox.TextColor3        = Color3.new(1, 1, 1)
speedBox.ClearTextOnFocus  = false
speedBox.ZIndex            = 12
speedBox.Parent            = speedRow
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 5)
local sbS = Instance.new("UIStroke"); sbS.Color = Color3.fromRGB(45,45,45); sbS.Thickness = 0.9; sbS.Parent = speedBox
local sbPad = Instance.new("UIPadding"); sbPad.PaddingLeft = UDim.new(0,7); sbPad.Parent = speedBox

local turboBtn = Instance.new("TextButton")
turboBtn.Size             = UDim2.new(0.52, -6, 1, 0)
turboBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
turboBtn.BorderSizePixel  = 0
turboBtn.Text             = "TURBO  :  OFF"
turboBtn.Font             = Enum.Font.GothamBold
turboBtn.TextSize         = 9
turboBtn.TextColor3       = Color3.fromRGB(120, 120, 120)
turboBtn.ZIndex           = 12
turboBtn.Parent           = speedRow
Instance.new("UICorner", turboBtn).CornerRadius = UDim.new(0, 5)
local turboBtnS = Instance.new("UIStroke"); turboBtnS.Color = Color3.fromRGB(45,45,45); turboBtnS.Thickness = 0.9; turboBtnS.Parent = turboBtn

-- ── Start / Stop button ──────────────────────────────────────────
local spamBtn, spamBtnS = makeBtn("START SPAM", 5, 30)

-- ── Divider ──────────────────────────────────────────────────────
local divider = Instance.new("Frame")
divider.Size             = UDim2.new(1, 0, 0, 1)
divider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
divider.BackgroundTransparency = 0
divider.BorderSizePixel  = 0
divider.LayoutOrder      = 6
divider.ZIndex           = 12
divider.Parent           = content

-- ── Status frame ─────────────────────────────────────────────────
local statFrame = Instance.new("Frame")
statFrame.Size             = UDim2.new(1, 0, 0, 52)
statFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
statFrame.BorderSizePixel  = 0
statFrame.LayoutOrder      = 7
statFrame.ZIndex           = 12
statFrame.Parent           = content
Instance.new("UICorner", statFrame).CornerRadius = UDim.new(0, 5)
local sfStroke = Instance.new("UIStroke"); sfStroke.Color = Color3.fromRGB(35,35,35); sfStroke.Thickness = 0.9; sfStroke.Parent = statFrame

local sfPad = Instance.new("UIPadding")
sfPad.PaddingLeft = UDim.new(0, 8); sfPad.PaddingTop = UDim.new(0, 6); sfPad.Parent = statFrame

local sfList = Instance.new("UIListLayout"); sfList.Padding = UDim.new(0, 3); sfList.Parent = statFrame

local function makeStat(order)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1, -8, 0, 12)
    l.BackgroundTransparency = 1
    l.Font               = Enum.Font.Gotham
    l.TextSize           = 9
    l.TextColor3         = Color3.fromRGB(160, 160, 160)
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.LayoutOrder        = order
    l.ZIndex             = 13
    l.Parent             = statFrame
    return l
end

local sMsgs   = makeStat(1)
local sSpeed  = makeStat(2)
local sStatus = makeStat(3)

local function refreshStatus()
    sMsgs.Text   = "Sent      " .. S.msgsSent
    sSpeed.Text  = S.turbo and "Speed     TURBO" or ("Speed     " .. S.interval .. "s")
    sStatus.Text = "Status    " .. (S.spamOn and "RUNNING" or "STOPPED")
    sStatus.TextColor3 = S.spamOn and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
end
refreshStatus()

-- ══════════════════════════════════════════════════════════════════
--  DRAG — pure AbsolutePosition, no scale confusion
-- ══════════════════════════════════════════════════════════════════
do
    local _drag, _touch, _startIP, _startPP = false, nil, nil, nil

    local function inBtnZone(px)
        local abs = titleBar.AbsolutePosition
        local sz  = titleBar.AbsoluteSize
        return px > abs.X + sz.X - 52
    end

    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch
        and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if inBtnZone(inp.Position.X) then return end
        _drag    = true
        _touch   = inp
        _startIP = Vector2.new(inp.Position.X, inp.Position.Y)
        _startPP = Vector2.new(panel.AbsolutePosition.X, panel.AbsolutePosition.Y)
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not _drag then return end
        if inp ~= _touch and inp.UserInputType ~= Enum.UserInputType.MouseMove then return end
        local cur = Vector2.new(inp.Position.X, inp.Position.Y)
        local d   = cur - _startIP
        local vp2 = workspace.CurrentCamera.ViewportSize
        local nx  = math.clamp(_startPP.X + d.X, 0, vp2.X - PW)
        local ny  = math.clamp(_startPP.Y + d.Y, 0, vp2.Y - (S.mini and PH_MIN or PH_FULL))
        panel.Position = UDim2.new(0, nx, 0, ny)
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp == _touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            _drag = false; _touch = nil
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  MINIMIZE / CLOSE
-- ══════════════════════════════════════════════════════════════════
minBtn.MouseButton1Click:Connect(function()
    S.mini = not S.mini
    content.Visible = not S.mini
    local targetH = S.mini and PH_MIN or PH_FULL
    minBtn.Text   = S.mini and "+" or "_"

    if S.mini then
        killSpark()
        TweenService:Create(panel, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.new(0, PW, 0, PH_MIN)}):Play()
    else
        TweenService:Create(panel, TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, PW, 0, PH_FULL)}):Play()
        task.delay(0.22, function() startSpark(PH_FULL) end)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    killSpark()
    stopSpam()
    pcall(function() gui:Destroy() end)
end)

-- ══════════════════════════════════════════════════════════════════
--  INPUT HANDLERS
-- ══════════════════════════════════════════════════════════════════
msgBox.FocusLost:Connect(function()
    if msgBox.Text ~= "" then
        S.text = msgBox.Text
    end
end)

speedBox.FocusLost:Connect(function()
    local v = tonumber(speedBox.Text)
    if v and v > 0 and v <= 60 then
        S.interval = v
    end
    speedBox.Text = tostring(S.interval)
    refreshStatus()
    -- Restart spam with new interval if running and not turbo
    if S.spamOn and not S.turbo then
        startSpam()
    end
end)

turboBtn.MouseButton1Click:Connect(function()
    S.turbo = not S.turbo
    if S.turbo then
        turboBtn.Text       = "TURBO  :  ON"
        turboBtn.TextColor3 = Color3.new(1, 1, 1)
        turboBtnS.Color     = Color3.fromRGB(180, 180, 180)
    else
        turboBtn.Text       = "TURBO  :  OFF"
        turboBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        turboBtnS.Color     = Color3.fromRGB(45, 45, 45)
    end
    refreshStatus()
    -- Restart with new mode if already running
    if S.spamOn then startSpam() end
end)

spamBtn.MouseButton1Click:Connect(function()
    S.spamOn = not S.spamOn
    if S.spamOn then
        -- Apply latest text from box
        if msgBox.Text ~= "" then S.text = msgBox.Text end
        -- Apply latest interval from box
        local v = tonumber(speedBox.Text)
        if v and v > 0 and v <= 60 then S.interval = v end

        startSpam()
        spamBtn.Text       = "STOP SPAM"
        spamBtn.TextColor3 = Color3.new(1, 1, 1)
        spamBtnS.Color     = Color3.fromRGB(200, 200, 200)
    else
        stopSpam()
        spamBtn.Text       = "START SPAM"
        spamBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        spamBtnS.Color     = Color3.fromRGB(45, 45, 45)
    end
    refreshStatus()
end)

-- Live counter update
RunService.Heartbeat:Connect(function()
    if S.spamOn then
        sMsgs.Text = "Sent      " .. S.msgsSent
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  BOOT NOTIFICATION
-- ══════════════════════════════════════════════════════════════════
local function showBootNotif()
    local ng = Instance.new("ScreenGui")
    ng.Name = "__A9XSpamBoot"; ng.ResetOnSpawn = false
    ng.DisplayOrder = 999; ng.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ng.Parent = game.CoreGui end)
    if not ng.Parent then ng.Parent = LocalPlayer.PlayerGui end

    local nf = Instance.new("Frame")
    nf.Size             = UDim2.new(0, 240, 0, 38)
    nf.Position         = UDim2.new(0.5, -120, 0, 14)
    nf.BackgroundColor3 = Color3.new(0, 0, 0)
    nf.BackgroundTransparency = 1
    nf.BorderSizePixel  = 0
    nf.ZIndex           = 200
    nf.Parent           = ng
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 6)

    local nfB = Instance.new("UIStroke")
    nfB.Color = Color3.new(1,1,1); nfB.Thickness = 1.2; nfB.Transparency = 1; nfB.Parent = nf

    local nPad = Instance.new("UIPadding")
    nPad.PaddingLeft = UDim.new(0, 10); nPad.PaddingTop = UDim.new(0, 0); nPad.Parent = nf

    local nLL = Instance.new("UIListLayout")
    nLL.Padding = UDim.new(0,1); nLL.VerticalAlignment = Enum.VerticalAlignment.Center; nLL.Parent = nf

    local l1 = Instance.new("TextLabel")
    l1.Size = UDim2.new(1,-16,0,18); l1.BackgroundTransparency = 1
    l1.Text = "Anonymous9x Spam Chat Loaded"; l1.Font = Enum.Font.GothamBold
    l1.TextSize = 10; l1.TextColor3 = Color3.new(1,1,1); l1.TextTransparency = 1
    l1.TextXAlignment = Enum.TextXAlignment.Left; l1.ZIndex = 201; l1.Parent = nf

    local l2 = Instance.new("TextLabel")
    l2.Size = UDim2.new(1,-16,0,12); l2.BackgroundTransparency = 1
    l2.Text = "Delta Mobile / iOS / iPad"; l2.Font = Enum.Font.Gotham
    l2.TextSize = 8; l2.TextColor3 = Color3.fromRGB(160,160,160); l2.TextTransparency = 1
    l2.TextXAlignment = Enum.TextXAlignment.Left; l2.ZIndex = 201; l2.Parent = nf

    local Ti = TweenInfo.new(0.20, Enum.EasingStyle.Quad)
    TweenService:Create(nf,  Ti, {BackgroundTransparency = 0.06}):Play()
    TweenService:Create(nfB, Ti, {Transparency = 0.15}):Play()
    TweenService:Create(l1,  Ti, {TextTransparency = 0}):Play()
    TweenService:Create(l2,  Ti, {TextTransparency = 0}):Play()

    task.delay(3.5, function()
        local To = TweenInfo.new(0.20, Enum.EasingStyle.Quad)
        TweenService:Create(nf,  To, {BackgroundTransparency = 1}):Play()
        TweenService:Create(nfB, To, {Transparency = 1}):Play()
        TweenService:Create(l1,  To, {TextTransparency = 1}):Play()
        TweenService:Create(l2,  To, {TextTransparency = 1}):Play()
        task.delay(0.25, function() pcall(function() ng:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════════════════════════════
startSpark(PH_FULL)
showBootNotif()
